import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef JsonParser<T> =
    List<T> Function(
      String raw,
      String jsonKey,
      T Function(String id, Map<String, dynamic> json) fromJson,
    );

typedef FetchInfoFn =
    FetchInfo Function(Map<String, dynamic> decoded, String jsonKey);

typedef JsonValidator = void Function(Map<String, dynamic> decoded);

class FetchInfo {
  final int modCount;
  final String generatedAt;
  const FetchInfo({required this.modCount, required this.generatedAt});
}

FetchInfo defaultFetchInfo(Map<String, dynamic> decoded, String jsonKey) {
  final count = (decoded[jsonKey] as Map<String, dynamic>).length;
  final generatedAt = decoded['generated_at'] as String? ?? '';
  return FetchInfo(modCount: count, generatedAt: generatedAt);
}

FetchInfo flexibleFetchInfo(Map<String, dynamic> decoded, String jsonKey) {
  final modsData = decoded[jsonKey];
  final count = modsData is List
      ? modsData.length
      : (modsData as Map<String, dynamic>).length;
  final generatedAtRaw = decoded['generated_at'];
  final generatedAt = generatedAtRaw is int
      ? DateTime.fromMillisecondsSinceEpoch(
          generatedAtRaw * 1000,
        ).toUtc().toIso8601String()
      : generatedAtRaw as String? ?? '';
  return FetchInfo(modCount: count, generatedAt: generatedAt);
}

List<T> mapJsonParser<T>(
  String raw,
  String jsonKey,
  T Function(String id, Map<String, dynamic> json) fromJson,
) {
  final data = json.decode(raw) as Map<String, dynamic>;
  final modsMap = data[jsonKey] as Map<String, dynamic>? ?? {};
  return modsMap.entries.map((e) {
    final map = e.value as Map<String, dynamic>;
    final id = map['id'] as String? ?? e.key;
    return fromJson(id, map);
  }).toList();
}

List<T> listOrMapJsonParser<T>(
  String raw,
  String jsonKey,
  T Function(String id, Map<String, dynamic> json) fromJson,
) {
  final data = json.decode(raw) as Map<String, dynamic>;
  final modsData = data[jsonKey];
  if (modsData is List) {
    return modsData.map((m) {
      final map = m as Map<String, dynamic>;
      final id = (map['id'] ?? map['slug'] ?? '').toString();
      return fromJson(id, map);
    }).toList();
  } else {
    final modsMap = modsData as Map<String, dynamic>? ?? {};
    return modsMap.entries.map((e) {
      final map = e.value as Map<String, dynamic>;
      final id = map['id'] as String? ?? e.key;
      return fromJson(id, map);
    }).toList();
  }
}

class RemoteJsonDatasource<T> {
  RemoteJsonDatasource({
    required this.remoteUrl,
    required this.assetPath,
    required this.localFileName,
    required this.jsonKey,
    required this.fromJson,
    required this.parseJson,
    required this.getFetchInfo,
    this.validateJson,
    this.supportedSchemaVersions = const <int>{1, 2},
    this.minimumRelativeItemCount,
  });

  final String remoteUrl;
  final String assetPath;
  final String localFileName;
  final String jsonKey;
  final T Function(String id, Map<String, dynamic> json) fromJson;
  final JsonParser<T> parseJson;
  final FetchInfoFn getFetchInfo;
  final JsonValidator? validateJson;
  final Set<int> supportedSchemaVersions;
  final double? minimumRelativeItemCount;

  List<T>? _cache;

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$localFileName');
  }

  Future<List<T>> getAll() async {
    if (_cache != null) return _cache!;
    final file = await _localFile();
    if (await file.exists()) {
      try {
        _cache = _parseAndValidate(await file.readAsString());
        return _cache!;
      } catch (_) {
        await _quarantineInvalidLocal(file);
        if (await file.exists()) {
          try {
            _cache = _parseAndValidate(await file.readAsString());
            return _cache!;
          } catch (_) {
            // Continue to the immutable APK-bundled database.
          }
        }
      }
    }
    final raw = await rootBundle.loadString(assetPath);
    _cache = _parseAndValidate(raw);
    return _cache!;
  }

  Future<FetchResult> fetchRemote() async {
    try {
      final response = await http
          .get(Uri.parse(remoteUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return FetchResult.error(
          'Server returned ${response.statusCode}. Try again later.',
        );
      }

      final body = utf8.decode(response.bodyBytes);
      final decoded = json.decode(body) as Map<String, dynamic>;

      if (!decoded.containsKey(jsonKey)) {
        return const FetchResult.error('Invalid database format received.');
      }

      final schemaVersion = (decoded['schema_version'] as num?)?.toInt() ?? 1;
      if (!supportedSchemaVersions.contains(schemaVersion)) {
        return FetchResult.error(
          'This database requires a newer version of the app.',
        );
      }

      validateJson?.call(decoded);
      final parsed = parseJson(body, jsonKey, fromJson);
      if (parsed.isEmpty) {
        return const FetchResult.error('The downloaded database is empty.');
      }

      final info = getFetchInfo(decoded, jsonKey);
      final declaredCount = decoded['mod_count'];
      if (declaredCount is num && declaredCount.toInt() != info.modCount) {
        return const FetchResult.error(
          'The downloaded database failed its integrity check.',
        );
      }
      final minimumRatio = minimumRelativeItemCount;
      if (minimumRatio != null) {
        final currentCount = _cache?.length ?? (await getAll()).length;
        final minimumCount = (currentCount * minimumRatio).floor();
        if (currentCount > 0 && info.modCount < minimumCount) {
          return FetchResult.error(
            'The update was not applied because it unexpectedly removed '
            'too much catalogue content (${info.modCount}/$currentCount).',
          );
        }
      }

      final file = await _localFile();
      await _replaceAtomically(file, body);

      _cache = parsed;

      return FetchResult.success(
        modCount: info.modCount,
        generatedAt: info.generatedAt,
      );
    } on SocketException {
      return const FetchResult.error(
        'No internet connection. Check your network and try again.',
      );
    } on HttpException {
      return const FetchResult.error('Could not reach the server.');
    } on FormatException {
      return const FetchResult.error(
        'The downloaded file has an unexpected format.',
      );
    } catch (e) {
      return FetchResult.error('Unexpected error: $e');
    }
  }

  void invalidateCache() => _cache = null;

  List<T> _parseAndValidate(String raw) {
    final decoded = json.decode(raw) as Map<String, dynamic>;
    if (!decoded.containsKey(jsonKey)) {
      throw const FormatException('Missing database collection');
    }
    final schemaVersion = (decoded['schema_version'] as num?)?.toInt() ?? 1;
    if (!supportedSchemaVersions.contains(schemaVersion)) {
      throw FormatException('Unsupported database schema: $schemaVersion');
    }
    validateJson?.call(decoded);
    final parsed = parseJson(raw, jsonKey, fromJson);
    if (parsed.isEmpty) throw const FormatException('Empty database');
    return parsed;
  }

  Future<void> _replaceAtomically(File destination, String body) async {
    final temporary = File('${destination.path}.next');
    final backup = File('${destination.path}.last-good');
    await temporary.writeAsString(body, flush: true);
    var movedCurrent = false;
    try {
      if (await backup.exists()) await backup.delete();
      if (await destination.exists()) {
        await destination.rename(backup.path);
        movedCurrent = true;
      }
      await temporary.rename(destination.path);
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      if (movedCurrent &&
          !await destination.exists() &&
          await backup.exists()) {
        await backup.rename(destination.path);
      }
      rethrow;
    }
  }

  Future<void> _quarantineInvalidLocal(File file) async {
    try {
      final invalid = File('${file.path}.invalid');
      if (await invalid.exists()) await invalid.delete();
      await file.rename(invalid.path);
      final backup = File('${file.path}.last-good');
      if (await backup.exists()) {
        try {
          final restored = await backup.readAsString();
          _parseAndValidate(restored);
          await backup.rename(file.path);
        } catch (_) {
          // The bundled asset remains the final known-good fallback.
        }
      }
    } catch (_) {
      // Reading the bundled database below must remain possible even when the
      // documents provider refuses a rename.
    }
  }

  Future<void> deleteLocalDb() async {
    try {
      final file = await _localFile();
      if (await file.exists()) await file.delete();
      for (final suffix in const ['.next', '.last-good', '.invalid']) {
        final sibling = File('${file.path}$suffix');
        if (await sibling.exists()) await sibling.delete();
      }
    } catch (_) {}
    invalidateCache();
  }

  Future<bool> hasLocalDb() async {
    try {
      final file = await _localFile();
      return await file.exists();
    } catch (_) {
      return false;
    }
  }
}

class FetchResult {
  const FetchResult._({
    required this.success,
    this.modCount,
    this.generatedAt,
    this.errorMessage,
  });

  const FetchResult.success({
    required int modCount,
    required String generatedAt,
  }) : this._(success: true, modCount: modCount, generatedAt: generatedAt);

  const FetchResult.error(String message)
    : this._(success: false, errorMessage: message);

  final bool success;
  final int? modCount;
  final String? generatedAt;
  final String? errorMessage;
}
