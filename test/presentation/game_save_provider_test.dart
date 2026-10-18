import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:sm64cdpy/presentation/providers/game_save_provider.dart';
import 'package:sm64cdpy/services/game_save_service.dart';

class _SaveService extends GameSaveService {
  Completer<Map<String, dynamic>>? pending;
  Map<String, dynamic>? received;
  bool fail = false;
  @override
  Future<Map<String, dynamic>> read() async => pending == null
      ? {
          'identity': 'document',
          'revision': 'current',
          'slots': [],
          'backups': [],
        }
      : pending!.future;
  @override
  Future<Map<String, dynamic>> change(Map<String, dynamic> data) async {
    received = data;
    if (fail) throw PlatformException(code: 'conflict');
    return {
      'identity': 'document',
      'revision': 'next',
      'slots': [],
      'backups': [],
    };
  }
}

void main() {
  test(
    'deduplicates reads and keeps an explicit stale draft revision for native rejection',
    () async {
      final service = _SaveService()
        ..pending = Completer<Map<String, dynamic>>();
      final container = ProviderContainer(
        overrides: [gameSaveServiceProvider.overrideWithValue(service)],
      );
      try {
        final notifier = container.read(gameSaveProvider.notifier);
        final reading = notifier.run();
        expect(await notifier.run(), isFalse);
        service.pending!.complete({
          'identity': 'document',
          'revision': 'current',
        });
        expect(await reading, isTrue);
        expect(
          await notifier.run({
            'action': 'edit',
            'revision': 'old',
            'identity': 'original',
          }),
          isTrue,
        );
        expect(service.received?['revision'], 'old');
        expect(service.received?['identity'], 'original');
        expect(container.read(gameSaveProvider).busy, isFalse);
      } finally {
        container.dispose();
      }
    },
  );
  test(
    'write conflict retains confirmed data and releases busy state',
    () async {
      final service = _SaveService()..fail = true;
      final container = ProviderContainer(
        overrides: [gameSaveServiceProvider.overrideWithValue(service)],
      );
      try {
        final notifier = container.read(gameSaveProvider.notifier);
        await notifier.run();
        expect(await notifier.run({'action': 'erase', 'slot': 0}), isFalse);
        expect(container.read(gameSaveProvider).data?['revision'], 'current');
        expect(container.read(gameSaveProvider).error, 'conflict');
        expect(container.read(gameSaveProvider).busy, isFalse);
      } finally {
        container.dispose();
      }
    },
  );
}
