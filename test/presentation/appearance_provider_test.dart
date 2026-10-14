import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';

void main() {
  late Directory directory;
  late ProviderContainer container;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('appearance-test-');
    Hive.init(directory.path);
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('legacy mode survives missing or unknown design', () async {
    final box = Hive.box<String>(AppConstants.settingsBoxKey);
    await box.put('theme_mode', 'dark');
    await box.put('theme_id', 'future-or-retired');
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(themeDesignProvider).id, AppThemeId.retroManga);
  });

  test('theme and brightness persist independently across containers', () async {
    final writer = container.read(appearanceProvider.notifier);
    expect(await writer.setTheme(AppThemeId.gamecube), isTrue);
    expect(await writer.setThemeMode(ThemeMode.light), isTrue);
    final restored = ProviderContainer();
    try {
      expect(restored.read(themeDesignProvider).id, AppThemeId.gamecube);
      expect(restored.read(themeModeProvider), ThemeMode.light);
    } finally {
      restored.dispose();
    }
  });

  test('rapid selections cannot produce out-of-order confirmed state', () async {
    final writer = container.read(appearanceProvider.notifier);
    final saving = writer.setTheme(AppThemeId.odyssey);
    expect(container.read(appearanceProvider).isSaving, isTrue);
    expect(await writer.setTheme(AppThemeId.mario64), isFalse);
    expect(await saving, isTrue);
    expect(container.read(themeDesignProvider).id, AppThemeId.odyssey);
    expect(container.read(appearanceProvider).isSaving, isFalse);
    expect(Hive.box<String>(AppConstants.settingsBoxKey).get('theme_id'), 'odyssey');
  });

  test('unavailable persistence preserves selection and releases saving state', () async {
    final writer = container.read(appearanceProvider.notifier);
    final previous = container.read(appearanceProvider);
    await Hive.close();
    expect(await writer.setTheme(AppThemeId.mario64), isFalse);
    expect(container.read(appearanceProvider), same(previous));
    expect(container.read(appearanceProvider).isSaving, isFalse);
  });

  test('startup without an open settings box has safe appearance and locale', () async {
    await Hive.close();
    expect(container.read(themeDesignProvider).id, AppThemeId.retroManga);
    expect(container.read(themeModeProvider), ThemeMode.system);
    expect(container.read(localeNotifierProvider), isNull);
  });
}
