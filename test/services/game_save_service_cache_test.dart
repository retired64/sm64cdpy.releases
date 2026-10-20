import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/services/game_save_service.dart';

void main() {
  late Directory directory;
  late GameSaveService service;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('game-save-cache-');
    Hive.init(directory.path);
    await Hive.openBox<dynamic>(AppConstants.installationLibraryBoxKey);
    service = GameSaveService();
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'display snapshot is owner-scoped and survives process recreation',
    () async {
      final snapshot = <String, dynamic>{
        'identity': 'content://save',
        'revision': 'a' * 64,
        'damaged': false,
        'slots': <dynamic>[],
        'backups': <dynamic>[],
      };

      await service.writeCached('folder-a', snapshot);

      expect(service.readCached('folder-a'), snapshot);
      expect(service.readCached('folder-b'), isNull);
      expect(service.readCached(null), isNull);
    },
  );

  test('invalid cache is rejected without becoming save authority', () async {
    await Hive.box<dynamic>(AppConstants.installationLibraryBoxKey).put(
      'game_save_display_snapshot_v1',
      {
        'schema': 1,
        'owner': 'folder-a',
        'snapshot': {'revision': 'not-a-hash'},
      },
    );

    expect(service.readCached('folder-a'), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(
      Hive.box<dynamic>(
        AppConstants.installationLibraryBoxKey,
      ).containsKey('game_save_display_snapshot_v1'),
      isFalse,
    );
  });
}
