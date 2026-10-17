import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';

void main() {
  test('Mario themes are selected without preparing resources', () async {
    final directory = await Directory.systemTemp.createTemp(
      'built-in-theme-select-',
    );
    Hive.init(directory.path);
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
    try {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      for (final id in [AppThemeId.mario64, AppThemeId.sm64Intro]) {
        expect(
          await container.read(appearanceProvider.notifier).setTheme(id),
          isTrue,
        );
        expect(container.read(appearanceProvider).themeId, id);
        expect(container.read(appearanceProvider).isSaving, isFalse);
      }
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
