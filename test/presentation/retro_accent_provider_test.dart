import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/retro_accent.dart';
import 'package:sm64cdpy/presentation/providers/retro_accent_provider.dart';

void main() {
  test('accent persists across containers without changing design or brightness', () async {
    final directory = await Directory.systemTemp.createTemp('retro-accent-');
    Hive.init(directory.path);
    final box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
    final first = ProviderContainer();
    try {
      await box.putAll({'theme_id': 'retro_manga', 'theme_mode': 'dark'});
      expect(first.read(retroAccentProvider), RetroAccent.cyan);
      expect(await first.read(retroAccentProvider.notifier).select(RetroAccent.violet), isTrue);
      final restored = ProviderContainer();
      try {
        expect(restored.read(retroAccentProvider), RetroAccent.violet);
        expect(box.get('theme_id'), 'retro_manga');
        expect(box.get('theme_mode'), 'dark');
      } finally {
        restored.dispose();
      }
    } finally {
      first.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('unavailable persistence reports failure and keeps the accepted color', () async {
    final container = ProviderContainer();
    try {
      expect(await container.read(retroAccentProvider.notifier).select(RetroAccent.pink), isFalse);
      expect(container.read(retroAccentProvider), RetroAccent.cyan);
    } finally {
      container.dispose();
    }
  });
}
