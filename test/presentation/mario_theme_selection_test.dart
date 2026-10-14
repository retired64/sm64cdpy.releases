import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/domain/entities/mario_theme_assets.dart';
import 'package:sm64cdpy/services/mario_theme_assets_service.dart';
import 'package:sm64cdpy/presentation/providers/mario_theme_assets_provider.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'mario_rom_fixture.dart';

class PendingRom extends MarioThemeAssetsService {
  final result = Completer<MarioThemeAssets?>();
  @override
  Future<MarioThemeAssets?> call(String method) async => method == 'read' ? const MarioThemeAssets() : result.future;
}
void main() {
  test('Mario is selected only after a complete ROM import; cancelling keeps the previous theme', () async {
    final dir = await Directory.systemTemp.createTemp('rom-theme-select-');
    Hive.init(dir.path);
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
    try {
      for (final cancel in [true, false]) {
        final service = PendingRom();
        final container = ProviderContainer(overrides: [marioThemeAssetsServiceProvider.overrideWithValue(service)]);
        final notifier = container.read(appearanceProvider.notifier);
        await notifier.setTheme(AppThemeId.retroManga);
        final selection = notifier.selectThemeWithRom(AppThemeId.mario64);
        await Future<void>.delayed(Duration.zero);
        expect(container.read(appearanceProvider).themeId, AppThemeId.retroManga);
        expect(container.read(appearanceProvider).isSaving, isTrue);
        expect(await notifier.selectThemeWithRom(AppThemeId.retroManga), isNull);
        service.result.complete(cancel ? null : completeMarioFixture());
        expect(await selection, cancel ? isNull : isTrue);
        expect(container.read(appearanceProvider).themeId, cancel ? AppThemeId.retroManga : AppThemeId.mario64);
        expect(container.read(appearanceProvider).isSaving, isFalse);
        container.dispose();
      }
    } finally {
      await Hive.close();
      await dir.delete(recursive: true);
    }
  });
}
