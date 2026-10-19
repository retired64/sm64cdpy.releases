import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_accent.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';

void main() {
  test('missing and unknown accent IDs preserve the original cyan', () {
    expect(RetroAccent.fromStorage(null), RetroAccent.cyan);
    expect(RetroAccent.fromStorage('unknown'), RetroAccent.cyan);
  });

  for (final accent in RetroAccent.values) {
    for (final dark in [false, true]) {
      for (final themeId in [AppThemeId.retroManga, AppThemeId.marioKart64]) {
        test(
          '${themeId.name} ${accent.name} dark=$dark has readable roles',
          () {
            final theme = RetroTheme(
              dark,
              design: AppThemeCatalog.resolve(themeId),
              retroAccent: accent,
            );
            expect(theme.supportsAdaptiveAccent, isTrue);
            expect(theme.accent, accent.color);
            expect(
              RetroAccent.contrast(theme.accent, theme.inkOnAccent),
              greaterThanOrEqualTo(4.5),
            );
            for (final surface in [
              theme.background,
              theme.surface,
              theme.surfaceAlt,
            ]) {
              expect(
                RetroAccent.contrast(theme.accentText, surface),
                greaterThanOrEqualTo(4.5),
              );
            }
            expect(theme.copyWith().accent, theme.accent);
          },
        );
      }
    }
  }

  test('MK64 coordinates its canvas, panels and grid role with the accent', () {
    for (final dark in [false, true]) {
      final design = AppThemeCatalog.resolve(AppThemeId.marioKart64);
      final cyan = RetroTheme(
        dark,
        design: design,
        retroAccent: RetroAccent.cyan,
      );
      final violet = RetroTheme(
        dark,
        design: design,
        retroAccent: RetroAccent.violet,
      );
      expect(violet.background, isNot(cyan.background));
      expect(violet.surface, isNot(cyan.surface));
      expect(violet.surfaceAlt, isNot(cyan.surfaceAlt));
      expect(violet.border, isNot(cyan.border));
      expect(violet.secondaryAccent, isNot(cyan.secondaryAccent));
    }
  });

  test('designs without accent accessibility keep their own palette', () {
    for (final design in AppThemeCatalog.designs) {
      if (design.id == AppThemeId.retroManga ||
          design.id == AppThemeId.marioKart64) {
        continue;
      }
      for (final dark in [false, true]) {
        final custom = RetroTheme(
          dark,
          design: design,
          retroAccent: RetroAccent.pink,
        );
        final original = RetroTheme(dark, design: design);
        expect(custom.accent, original.accent);
        expect(custom.background, original.background);
      }
    }
    expect(RetroTheme.overlay().accent, RetroAccent.cyan.color);
  });
}
