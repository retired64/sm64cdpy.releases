import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/services/game_folder_service.dart';
import 'package:sm64cdpy/services/game_mod_activation.dart';
import 'package:sm64cdpy/presentation/providers/game_mod_activation_provider.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';

class FolderFake extends GameFolderService {
  final pending = Completer<GameFolderConnection?>();
  bool fail = false;
  int writes = 0;
  @override
  Future<GameFolderConnection?> call(String method) async {
    if (method == 'getGameFolder') return const GameFolderConnection();
    writes++;
    if (fail) throw PlatformException(code: 'installing');
    return pending.future;
  }
}

class DelayedFolderRead extends GameFolderService {
  final stale = Completer<GameFolderConnection?>();
  int reads = 0;
  @override
  Future<GameFolderConnection?> call(String method) async {
    if (method == 'getGameFolder') {
      reads++;
      return reads == 1 ? const GameFolderConnection() : stale.future;
    }
    return const GameFolderConnection(
      connected: true,
      unified: true,
      mods: true,
      dynos: true,
    );
  }
}

class ChangingFolderRead extends GameFolderService {
  int reads = 0;
  @override
  Future<GameFolderConnection?> call(String method) async {
    reads++;
    return GameFolderConnection(
      connected: true,
      connectionKey: reads == 1 ? 'folder-a' : 'folder-b',
    );
  }
}

class CacheGateway extends GameModActivation {
  int clears = 0;
  @override
  Future<void> clearCached() async {
    clears++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'recreated descendants change connection identity without changing the root grant',
    () {
      GameFolderConnection read(String user, String mods) =>
          GameFolderConnection.fromMap({
            'rootUri': 'same-root',
            'userUri': user,
            'modsUri': mods,
            'dynosUri': 'packs',
            'fullAccess': true,
          });
      expect(
        read('user-1', 'mods-1').connectionKey,
        isNot(read('user-2', 'mods-2').connectionKey),
      );
      expect(
        read('user-1', 'mods-1').connectionKey,
        read('user-1', 'mods-1').connectionKey,
      );
      expect(read('user-1', 'mods-1').fullAccess, isTrue);
      expect(GameFolderConnection.fromMap({}).fullAccess, isFalse);
    },
  );
  test(
    'startup keeps owner-scoped caches but a real folder change clears them',
    () async {
      final service = ChangingFolderRead();
      final cache = CacheGateway();
      final container = ProviderContainer(
        overrides: [
          gameFolderServiceProvider.overrideWithValue(service),
          gameModGatewayProvider.overrideWithValue(cache),
        ],
      );
      try {
        final notifier = container.read(gameFolderProvider.notifier);
        await notifier.initialize();
        expect(cache.clears, 0);
        await notifier.refresh();
        expect(cache.clears, 1);
      } finally {
        container.dispose();
      }
    },
  );
  test('a stale refresh cannot overwrite a confirmed connection', () async {
    final service = DelayedFolderRead();
    final container = ProviderContainer(
      overrides: [gameFolderServiceProvider.overrideWithValue(service)],
    );
    final notifier = container.read(gameFolderProvider.notifier);
    await notifier.initialize();
    final oldRefresh = notifier.refresh();
    expect(await notifier.perform('connectGameFolder'), isTrue);
    service.stale.complete(const GameFolderConnection());
    await oldRefresh;
    expect(container.read(gameFolderProvider).connection.connected, isTrue);
    expect(container.read(gameFolderProvider).connection.unified, isTrue);
    expect(container.read(gameFolderProvider).busy, isFalse);
    container.dispose();
  });
  test(
    'one pending selection blocks duplicates and cancellation releases UI',
    () async {
      final service = FolderFake();
      final container = ProviderContainer(
        overrides: [gameFolderServiceProvider.overrideWithValue(service)],
      );
      final notifier = container.read(gameFolderProvider.notifier);
      await notifier.initialize();
      final selecting = notifier.perform('connectGameFolder');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(gameFolderProvider).busy, isTrue);
      expect(await notifier.perform('connectGameFolder'), isFalse);
      service.pending.complete(null);
      expect(await selecting, isFalse);
      expect(container.read(gameFolderProvider).busy, isFalse);
      expect(container.read(gameFolderProvider).connection.connected, isFalse);
      expect(service.writes, 1);
      container.dispose();
    },
  );
  test(
    'an active install error preserves the previous connection and releases UI',
    () async {
      final service = FolderFake()..fail = true;
      final container = ProviderContainer(
        overrides: [gameFolderServiceProvider.overrideWithValue(service)],
      );
      final notifier = container.read(gameFolderProvider.notifier);
      expect(await notifier.perform('disconnectGameFolder'), isFalse);
      expect(container.read(gameFolderProvider).error, 'installing');
      expect(container.read(gameFolderProvider).busy, isFalse);
      container.dispose();
    },
  );
}
