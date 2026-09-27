import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/installation_library.dart';
import '../../domain/repositories/installation_library_repository.dart';
import '../../services/installation_library_update_bus.dart';
import '../../services/mod_installer.dart';

abstract interface class InstallationLibraryNativeGateway {
  Future<Map<String, dynamic>> read();
  Future<Map<String, dynamic>> discover({bool force = false});
  Future<Map<String, dynamic>> verify({List<String>? artifactKeys});
  Future<void> clearHistory();
  Future<void> forgetContent(String contentKey);
  Future<void> removeHistoryEvent(String workerId);
}

class MethodChannelInstallationLibraryGateway
    implements InstallationLibraryNativeGateway {
  MethodChannelInstallationLibraryGateway([ModInstaller? installer])
    : _installer = installer ?? ModInstaller();

  final ModInstaller _installer;

  @override
  Future<Map<String, dynamic>> read() => _installer.getInstallationLibrary();

  @override
  Future<Map<String, dynamic>> discover({bool force = false}) =>
      _installer.discoverInstallationLibrary(force: force);

  @override
  Future<Map<String, dynamic>> verify({List<String>? artifactKeys}) =>
      _installer.verifyInstallationLibrary(artifactKeys: artifactKeys);

  @override
  Future<void> clearHistory() => _installer.clearInstallationHistory();

  @override
  Future<void> forgetContent(String contentKey) =>
      _installer.forgetInstallationContent(contentKey);

  @override
  Future<void> removeHistoryEvent(String workerId) =>
      _installer.removeInstallationHistoryEvent(workerId);
}

class InstallationLibraryRepositoryImpl
    implements InstallationLibraryRepository {
  InstallationLibraryRepositoryImpl({
    InstallationLibraryNativeGateway? gateway,
    Box<dynamic>? projection,
  }) : _gateway = gateway ?? MethodChannelInstallationLibraryGateway(),
       _projection = projection;

  static const projectionSchemaVersion = 3;
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
  Future<InstallationLibrarySnapshot> discover({bool force = false}) =>
      _serialized(() async => _store(await _gateway.discover(force: force)));

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
      final result = _withIssue(
        snapshot,
        const InstallationLibraryIssue(
          file: 'hive',
          reason: 'Library projection is unavailable',
        ),
      );
      InstallationLibraryUpdateBus.publish(result);
      return result;
    }
    try {
      if (box.get(_schemaKey) != projectionSchemaVersion) {
        await box.clear();
      }
      await box.put(_schemaKey, projectionSchemaVersion);
      await box.put(_snapshotKey, raw);
      InstallationLibraryUpdateBus.publish(snapshot);
      return snapshot;
    } catch (error) {
      final result = _withIssue(
        snapshot,
        InstallationLibraryIssue(file: 'hive', reason: error.toString()),
      );
      InstallationLibraryUpdateBus.publish(result);
      return result;
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

  @override
  Future<InstallationLibrarySnapshot> forgetContent(String contentKey) =>
      _serialized(() async {
        await _gateway.forgetContent(contentKey);
        // Force discovery because forgotten files remain in the selected SAF
        // tree and should now be represented conservatively as external.
        return _store(await _gateway.discover(force: true));
      });

  @override
  Future<InstallationLibrarySnapshot> removeHistoryEvent(String workerId) =>
      _serialized(() async {
        await _gateway.removeHistoryEvent(workerId);
        return _synchronize();
      });

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

    final receipts = parseRecords('receipts', 'artifactKey');
    final history = parseRecords('history', 'installWorkerId');
    final discoveries = _parseDiscoveries(raw, issues);
    final discoveryScannedAt = _parseDiscoveryDate(raw, issues);
    return InstallationLibrarySnapshot(
      receipts: receipts,
      history: history,
      issues: List.unmodifiable(issues),
      verifications: Map.unmodifiable(verifications),
      discoveries: discoveries,
      discoveryScannedAt: discoveryScannedAt,
      discoveryTruncated: raw['discoveryTruncated'] == true,
    );
  }

  List<DiscoveredInstallation> _parseDiscoveries(
    Map<String, dynamic> raw,
    List<InstallationLibraryIssue> issues,
  ) {
    final unique = <String, DiscoveredInstallation>{};
    for (final value in (raw['discoveries'] as List? ?? const [])) {
      try {
        if (value is! Map) {
          throw const FormatException('Discovery is not a map');
        }
        final discovery = DiscoveredInstallation.fromMap(value);
        unique[discovery.discoveryKey] = discovery;
      } catch (error) {
        issues.add(
          InstallationLibraryIssue(file: 'discovery', reason: error.toString()),
        );
      }
    }
    final discoveries = unique.values.toList()
      ..sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );
    return List.unmodifiable(discoveries);
  }

  DateTime? _parseDiscoveryDate(
    Map<String, dynamic> raw,
    List<InstallationLibraryIssue> issues,
  ) {
    final value = raw['discoveryScannedAt'];
    if (value == null) return null;
    try {
      return DateTime.parse(value as String).toUtc();
    } catch (error) {
      issues.add(
        InstallationLibraryIssue(file: 'discovery', reason: error.toString()),
      );
      return null;
    }
  }

  InstallationLibrarySnapshot _withIssue(
    InstallationLibrarySnapshot snapshot,
    InstallationLibraryIssue issue,
  ) => InstallationLibrarySnapshot(
    receipts: snapshot.receipts,
    history: snapshot.history,
    issues: [...snapshot.issues, issue],
    verifications: snapshot.verifications,
    discoveries: snapshot.discoveries,
    discoveryScannedAt: snapshot.discoveryScannedAt,
    discoveryTruncated: snapshot.discoveryTruncated,
  );
}
