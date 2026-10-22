import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';

void main() {
  test('retired themes restore Retro Manga and preserve brightness', () async {
    final directory = await Directory.systemTemp.createTemp(
      'built-in-theme-select-',
    );
    Hive.init(directory.path);
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
    try {
      final box = Hive.box<String>(AppConstants.settingsBoxKey);
      for (final id in [
        AppThemeId.mario64,
        AppThemeId.sm64Intro,
        AppThemeId.minishCap,
      ]) {
        await box.putAll({'theme_id': id.storageKey, 'theme_mode': 'dark'});
        final container = ProviderContainer();
        try {
          expect(
            container.read(appearanceProvider).themeId,
            AppThemeId.retroManga,
          );
          expect(container.read(themeModeProvider).name, 'dark');
          expect(
            await container.read(appearanceProvider.notifier).setTheme(id),
            isTrue,
          );
          expect(box.get('theme_id'), 'retro_manga');
          expect(box.get('theme_mode'), 'dark');
          expect(container.read(appearanceProvider).isSaving, isFalse);
        } finally {
          container.dispose();
        }
      }
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
