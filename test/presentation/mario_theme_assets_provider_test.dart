import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/mario_theme_assets.dart';
import 'package:sm64cdpy/presentation/providers/mario_theme_assets_provider.dart';
import 'package:sm64cdpy/services/mario_theme_assets_service.dart';

MarioThemeAssets pack(String generation) => MarioThemeAssets(
  generation: generation,
  files: {
    for (final id in [
      'stone',
      'stone_dark',
      'hand',
      'hand_pressed',
      'star',
      ...List.generate(10, (i) => 'digit_$i'),
    ])
      id: '/private/$generation/$id.png',
  },
);

class FakeService extends MarioThemeAssetsService {
  MarioThemeAssets assets = pack('old');
  Completer<MarioThemeAssets?>? pending;
  int requests = 0;
  bool cancelRequested = false;
  @override
  Future<MarioThemeAssets?> call(String method) async {
    if (method == 'read') return assets;
    if (method == 'remove') return const MarioThemeAssets();
    requests++;
    return pending!.future;
  }

  @override
  Future<void> cancel() async {
    cancelRequested = true;
  }
}

void main() {
  test(
    'import keeps old resources until confirmed and blocks duplicate selection',
    () async {
      final service = FakeService()..pending = Completer<MarioThemeAssets?>();
      final container = ProviderContainer(
        overrides: [marioThemeAssetsServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(marioThemeAssetsProvider.notifier);
      await notifier.initialize();
      final operation = notifier.perform('import');
      await Future<void>.delayed(Duration.zero);
      await notifier.perform('import');
      expect(service.requests, 1);
      expect(container.read(marioThemeAssetsProvider).assets.generation, 'old');
      expect(container.read(marioThemeAssetsProvider).busy, isTrue);
      service.pending!.complete(pack('new'));
      await operation;
      expect(container.read(marioThemeAssetsProvider).assets.generation, 'new');
      expect(container.read(marioThemeAssetsProvider).imported, 1);
      expect(container.read(marioThemeAssetsProvider).busy, isFalse);
      await notifier.perform('remove');
      expect(
        container.read(marioThemeAssetsProvider).assets.available,
        isFalse,
      );
    },
  );
  test(
    'failed import and cancellation preserve assets and release busy only on confirmation',
    () async {
      final service = FakeService()..pending = Completer<MarioThemeAssets?>();
      final container = ProviderContainer(
        overrides: [marioThemeAssetsServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(marioThemeAssetsProvider.notifier);
      await notifier.initialize();
      final operation = notifier.perform('import');
      await Future<void>.delayed(Duration.zero);
      await notifier.cancel();
      expect(service.cancelRequested, isTrue);
      expect(container.read(marioThemeAssetsProvider).busy, isTrue);
      service.pending!.completeError(PlatformException(code: 'cancelled'));
      await operation;
      expect(container.read(marioThemeAssetsProvider).busy, isFalse);
      expect(container.read(marioThemeAssetsProvider).assets.generation, 'old');
      expect(container.read(marioThemeAssetsProvider).error, isNull);
      service.pending = Completer<MarioThemeAssets?>();
      final failed = notifier.perform('import');
      await Future<void>.delayed(Duration.zero);
      service.pending!.completeError(PlatformException(code: 'unsupported'));
      await failed;
      expect(container.read(marioThemeAssetsProvider).assets.generation, 'old');
      expect(container.read(marioThemeAssetsProvider).error, 'unsupported');
      expect(container.read(marioThemeAssetsProvider).busy, isFalse);
    },
  );
}
