import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/data/repositories/installation_library_repository_impl.dart';
import 'package:sm64cdpy/domain/entities/installation_library.dart';

import '../helpers/installation_receipt_fixture.dart';

class FakeGateway implements InstallationLibraryNativeGateway {
  FakeGateway(this.snapshot);

  Map<String, dynamic> snapshot;
  int clearCalls = 0;
  int verifyCalls = 0;
  Map<String, dynamic> verification = {
    'schemaVersion': 1,
    'verifiedAt': '2026-09-25T13:00:00Z',
    'results': <dynamic>[],
  };

  @override
  Future<Map<String, dynamic>> read() async => snapshot;

  @override
  Future<Map<String, dynamic>> verify({List<String>? artifactKeys}) async {
    verifyCalls++;
    final results = verification['results'] as List<dynamic>;
    return {
      ...verification,
      if (artifactKeys != null)
        'results': results
            .where(
              (value) => artifactKeys.contains((value as Map)['artifactKey']),
            )
            .toList(),
    };
  }

  @override
  Future<void> clearHistory() async {
    clearCalls++;
    snapshot = {...snapshot, 'history': <dynamic>[]};
  }
}

void main() {
  late Directory temporaryDirectory;
  late Box<dynamic> box;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp('library-test-');
    Hive.init(temporaryDirectory.path);
    box = await Hive.openBox<dynamic>('library');
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteFromDisk();
    await temporaryDirectory.delete(recursive: true);
  });

  test('synchronization is idempotent and ordered by date', () async {
    final newer = installationReceiptFixture(
      workerId: 'worker-new',
      installedAt: '2026-09-25T12:00:00Z',
    );
    final olderDuplicate = installationReceiptFixture(
      workerId: 'worker-old',
      installedAt: '2026-09-24T12:00:00Z',
    );
    final secondArtifact = installationReceiptFixture(
      artifactKey: 'v1|mods|content-1|file-2',
      workerId: 'worker-2',
      installedAt: '2026-09-25T11:00:00Z',
    );
    final gateway = FakeGateway({
      'schemaVersion': 1,
      'receipts': [olderDuplicate, newer, secondArtifact],
      'history': [olderDuplicate, newer, newer, secondArtifact],
      'issues': <dynamic>[],
    });
    final repository = InstallationLibraryRepositoryImpl(
      gateway: gateway,
      projection: box,
    );

    final first = await repository.synchronize();
    final second = await repository.synchronize();

    expect(first.receipts.length, 2);
    expect(first.receipts.first.installWorkerId, 'worker-new');
    expect(first.history.length, 3);
    expect(
      second.receipts.map((e) => e.artifactKey),
      first.receipts.map((e) => e.artifactKey),
    );
  });

  test(
    'bad record produces a partial snapshot instead of blocking valid data',
    () async {
      final gateway = FakeGateway({
        'schemaVersion': 1,
        'receipts': [
          installationReceiptFixture(),
          {'schemaVersion': 99},
        ],
        'history': <dynamic>[],
        'issues': [
          {'file': 'broken.json', 'reason': 'quarantined'},
        ],
      });
      final repository = InstallationLibraryRepositoryImpl(
        gateway: gateway,
        projection: box,
      );

      final snapshot = await repository.synchronize();

      expect(snapshot.receipts, hasLength(1));
      expect(snapshot.isPartial, isTrue);
      expect(snapshot.issues, hasLength(2));
    },
  );

  test(
    'projection schema mismatch is migrated by rebuilding the box',
    () async {
      await box.put('schemaVersion', 999);
      await box.put('stale', true);
      final repository = InstallationLibraryRepositoryImpl(
        gateway: FakeGateway({
          'schemaVersion': 1,
          'receipts': [installationReceiptFixture()],
          'history': <dynamic>[],
          'issues': <dynamic>[],
        }),
        projection: box,
      );

      await repository.synchronize();

      expect(box.get('schemaVersion'), 2);
      expect(box.containsKey('stale'), isFalse);
      expect((await repository.readCached())?.receipts, hasLength(1));
    },
  );

  test('clearing history preserves current receipts', () async {
    final gateway = FakeGateway({
      'schemaVersion': 1,
      'receipts': [installationReceiptFixture()],
      'history': [installationReceiptFixture()],
      'issues': <dynamic>[],
    });
    final repository = InstallationLibraryRepositoryImpl(
      gateway: gateway,
      projection: box,
    );

    final snapshot = await repository.clearHistory();

    expect(gateway.clearCalls, 1);
    expect(snapshot.receipts, hasLength(1));
    expect(snapshot.history, isEmpty);
  });

  test(
    'verification is projected and per-artifact refresh preserves siblings',
    () async {
      final first = installationReceiptFixture();
      final second = installationReceiptFixture(
        artifactKey: 'v1|mods|content-1|file-2',
        workerId: 'worker-2',
      );
      final gateway =
          FakeGateway({
              'schemaVersion': 1,
              'receipts': [first, second],
              'history': <dynamic>[],
              'issues': <dynamic>[],
            })
            ..verification = {
              'schemaVersion': 1,
              'verifiedAt': '2026-09-25T13:00:00Z',
              'results': [
                {'artifactKey': first['artifactKey'], 'status': 'present'},
                {
                  'artifactKey': second['artifactKey'],
                  'status': 'missing',
                  'missingPath': 'sample/main.lua',
                },
              ],
            };
      final repository = InstallationLibraryRepositoryImpl(
        gateway: gateway,
        projection: box,
      );

      final all = await repository.verifyAll();
      expect(
        all.verifications[first['artifactKey']]?.status,
        InstallationVerificationStatus.present,
      );

      gateway.verification = {
        'schemaVersion': 1,
        'verifiedAt': '2026-09-25T14:00:00Z',
        'results': [
          {'artifactKey': first['artifactKey'], 'status': 'permissionRevoked'},
          {'artifactKey': second['artifactKey'], 'status': 'missing'},
        ],
      };
      final one = await repository.verifyArtifact(
        first['artifactKey'] as String,
      );

      expect(
        one.verifications[first['artifactKey']]?.status,
        InstallationVerificationStatus.permissionRevoked,
      );
      expect(
        one.verifications[second['artifactKey']]?.status,
        InstallationVerificationStatus.missing,
      );
    },
  );
}
