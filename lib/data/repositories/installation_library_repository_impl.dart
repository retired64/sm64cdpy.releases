import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/installation_library.dart';
import '../../domain/repositories/installation_library_repository.dart';
import '../../services/mod_installer.dart';

abstract interface class InstallationLibraryNativeGateway {
  Future<Map<String, dynamic>> read();
  Future<Map<String, dynamic>> verify({List<String>? artifactKeys});
  Future<void> clearHistory();
}

class MethodChannelInstallationLibraryGateway
    implements InstallationLibraryNativeGateway {
  MethodChannelInstallationLibraryGateway([ModInstaller? installer])
    : _installer = installer ?? ModInstaller();

  final ModInstaller _installer;

  @override
  Future<Map<String, dynamic>> read() => _installer.getInstallationLibrary();

  @override
  Future<Map<String, dynamic>> verify({List<String>? artifactKeys}) =>
      _installer.verifyInstallationLibrary(artifactKeys: artifactKeys);

  @override
  Future<void> clearHistory() => _installer.clearInstallationHistory();
}

class InstallationLibraryRepositoryImpl
    implements InstallationLibraryRepository {
  InstallationLibraryRepositoryImpl({
    InstallationLibraryNativeGateway? gateway,
    Box<dynamic>? projection,
  }) : _gateway = gateway ?? MethodChannelInstallationLibraryGateway(),
       _projection = projection;

  static const projectionSchemaVersion = 2;
  static const _schemaKey = 'schemaVersion';
  static const _snapshotKey = 'snapshot';
  static Future<void> _operationTail = Future<void>.value();

  final InstallationLibraryNativeGateway _gateway;
  final Box<dynamic>? _projection;

  Box<dynamic>? get _box {
    if (_projection != null) return _projection;
    if (!Hive.isBoxOpen(AppConstants.installationLibraryBoxKey)) return null;
    return Hive.box<dynamic>(AppConstants.installationLibraryBoxKey);
  }

  @override
  Future<InstallationLibrarySnapshot> synchronize() =>
      _serialized(_synchronize);

  Future<InstallationLibrarySnapshot> _synchronize() async {
    final raw = await _gateway.read();
    return _store(raw);
  }

  @override
  Future<InstallationLibrarySnapshot> verifyAll() => _serialized(_verify);

  @override
  Future<InstallationLibrarySnapshot> verifyArtifact(String artifactKey) =>
      _serialized(() => _verify(artifactKeys: [artifactKey]));

  Future<InstallationLibrarySnapshot> _verify({
    List<String>? artifactKeys,
  }) async {
    final native = await _gateway.read();
    final verification = await _gateway.verify(artifactKeys: artifactKeys);
    final previous = await _readRawProjection();
    final priorResults = <dynamic>[
      ...?previous?['verificationResults'] as List?,
    ];
    final requested = artifactKeys?.toSet();
    final retained = requested == null
        ? <dynamic>[]
        : priorResults.where(
            (value) =>
                value is Map && !requested.contains(value['artifactKey']),
          );
    final raw = <String, dynamic>{
      ...native,
      'verificationResults': [
        ...retained,
        ...?verification['results'] as List?,
      ],
      'verifiedAt': verification['verifiedAt'],
    };
    return _store(raw);
  }

  Future<InstallationLibrarySnapshot> _store(Map<String, dynamic> raw) async {
    final snapshot = _parseSnapshot(raw);
    final box = _box;
    if (box == null) {
      return _withIssue(
        snapshot,
        const InstallationLibraryIssue(
          file: 'hive',
          reason: 'Library projection is unavailable',
        ),
      );
    }
    try {
      if (box.get(_schemaKey) != projectionSchemaVersion) {
        await box.clear();
      }
      await box.put(_schemaKey, projectionSchemaVersion);
      await box.put(_snapshotKey, raw);
      return snapshot;
    } catch (error) {
      return _withIssue(
        snapshot,
        InstallationLibraryIssue(file: 'hive', reason: error.toString()),
      );
    }
  }

  Future<Map<String, dynamic>?> _readRawProjection() async {
    final box = _box;
    if (box == null || box.get(_schemaKey) != projectionSchemaVersion) {
      return null;
    }
    final raw = box.get(_snapshotKey);
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  @override
  Future<InstallationLibrarySnapshot?> readCached() async {
    final box = _box;
    if (box == null) return null;
    if (box.get(_schemaKey) != projectionSchemaVersion) {
      await box.clear();
      return null;
    }
    final raw = box.get(_snapshotKey);
    if (raw is! Map) return null;
    try {
      return _parseSnapshot(Map<String, dynamic>.from(raw));
    } catch (_) {
      await box.delete(_snapshotKey);
      return null;
    }
  }

  @override
  Future<InstallationLibrarySnapshot> clearHistory() async {
    return _serialized(() async {
      await _gateway.clearHistory();
      return _synchronize();
    });
  }

  Future<T> _serialized<T>(Future<T> Function() operation) {
    final previous = _operationTail;
    final completer = Completer<T>();
    _operationTail = () async {
      try {
        await previous;
      } catch (_) {
        // A failed operation must not poison later reconciliation attempts.
      }
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    }();
    return completer.future;
  }

  InstallationLibrarySnapshot _parseSnapshot(Map<String, dynamic> raw) {
    if (raw['schemaVersion'] != 1) {
      throw const FormatException('Unsupported native library schema');
    }
    final issues = <InstallationLibraryIssue>[
      for (final value in (raw['issues'] as List? ?? const []))
        if (value is Map) InstallationLibraryIssue.fromMap(value),
    ];
    final verifications = <String, InstallationVerification>{};
    final verifiedAtValue = raw['verifiedAt'];
    if (verifiedAtValue is String) {
      try {
        final verifiedAt = DateTime.parse(verifiedAtValue).toUtc();
        for (final value in (raw['verificationResults'] as List? ?? const [])) {
          try {
            if (value is! Map) {
              throw const FormatException('Verification is not a map');
            }
            final verification = InstallationVerification.fromMap(
              value,
              verifiedAt,
            );
            verifications[verification.artifactKey] = verification;
          } catch (error) {
            issues.add(
              InstallationLibraryIssue(
                file: 'verification',
                reason: error.toString(),
              ),
            );
          }
        }
      } catch (error) {
        issues.add(
          InstallationLibraryIssue(
            file: 'verification',
            reason: error.toString(),
          ),
        );
      }
    }

    List<InstallationRecord> parseRecords(String key, String identityField) {
      final unique = <String, InstallationRecord>{};
      for (final value in (raw[key] as List? ?? const [])) {
        try {
          if (value is! Map) throw const FormatException('Record is not a map');
          final record = InstallationRecord.fromMap(value);
          final identity = identityField == 'artifactKey'
              ? record.artifactKey
              : record.installWorkerId;
          final previous = unique[identity];
          if (previous == null ||
              record.installedAt.isAfter(previous.installedAt)) {
            unique[identity] = record;
          }
        } catch (error) {
          issues.add(
            InstallationLibraryIssue(
              file: '$key:$identityField',
              reason: error.toString(),
            ),
          );
        }
      }
      final records = unique.values.toList()
        ..sort((a, b) => b.installedAt.compareTo(a.installedAt));
      return records;
    }

    return InstallationLibrarySnapshot(
      receipts: parseRecords('receipts', 'artifactKey'),
      history: parseRecords('history', 'installWorkerId'),
      issues: List.unmodifiable(issues),
      verifications: Map.unmodifiable(verifications),
    );
  }

  InstallationLibrarySnapshot _withIssue(
    InstallationLibrarySnapshot snapshot,
    InstallationLibraryIssue issue,
  ) => InstallationLibrarySnapshot(
    receipts: snapshot.receipts,
    history: snapshot.history,
    issues: [...snapshot.issues, issue],
    verifications: snapshot.verifications,
  );
}
