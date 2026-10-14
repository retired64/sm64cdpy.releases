import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/services/game_folder_service.dart';
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
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('one pending selection blocks duplicates and cancellation releases UI', () async {
    final service = FolderFake();
    final container = ProviderContainer(overrides: [gameFolderServiceProvider.overrideWithValue(service)]);
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
  });
  test('an active install error preserves the previous connection and releases UI', () async {
    final service = FolderFake()..fail = true;
    final container = ProviderContainer(overrides: [gameFolderServiceProvider.overrideWithValue(service)]);
    final notifier = container.read(gameFolderProvider.notifier);
    expect(await notifier.perform('disconnectGameFolder'), isFalse);
    expect(container.read(gameFolderProvider).error, 'installing');
    expect(container.read(gameFolderProvider).busy, isFalse);
    container.dispose();
  });
}
