import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

typedef JsonParser<T> = List<T> Function(
  String raw,
  String jsonKey,
  T Function(String id, Map<String, dynamic> json) fromJson,
);

typedef FetchInfoFn = FetchInfo Function(
  Map<String, dynamic> decoded,
  String jsonKey,
);

class FetchInfo {
  final int modCount;
  final String generatedAt;
  const FetchInfo({required this.modCount, required this.generatedAt});
}

FetchInfo defaultFetchInfo(Map<String, dynamic> decoded, String jsonKey) {
  final count =
      (decoded[jsonKey] as Map<String, dynamic>).length;
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
      ? DateTime.fromMillisecondsSinceEpoch(generatedAtRaw * 1000)
          .toUtc()
          .toIso8601String()
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
  });

  final String remoteUrl;
  final String assetPath;
  final String localFileName;
  final String jsonKey;
  final T Function(String id, Map<String, dynamic> json) fromJson;
  final JsonParser<T> parseJson;
  final FetchInfoFn getFetchInfo;

  List<T>? _cache;

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$localFileName');
  }

  Future<List<T>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await _readRaw();
    _cache = parseJson(raw, jsonKey, fromJson);
    return _cache!;
  }

  Future<String> _readRaw() async {
    try {
      final file = await _localFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {}
    return rootBundle.loadString(assetPath);
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

      final body = response.body;
      final decoded = json.decode(body) as Map<String, dynamic>;

      if (!decoded.containsKey(jsonKey)) {
        return const FetchResult.error('Invalid database format received.');
      }

      final info = getFetchInfo(decoded, jsonKey);

      final file = await _localFile();
      await file.writeAsString(body, flush: true);

      invalidateCache();

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

  Future<void> deleteLocalDb() async {
    try {
      final file = await _localFile();
      if (await file.exists()) await file.delete();
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
