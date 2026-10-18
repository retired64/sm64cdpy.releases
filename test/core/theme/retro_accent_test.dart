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
      test('${accent.name} dark=$dark has readable fill and text roles', () {
        final theme = RetroTheme(dark, retroAccent: accent);
        expect(RetroAccent.contrast(theme.accent, theme.inkOnAccent), greaterThanOrEqualTo(4.5));
        for (final surface in [theme.background, theme.surface, theme.surfaceAlt]) {
          expect(RetroAccent.contrast(theme.accentText, surface), greaterThanOrEqualTo(4.5));
        }
        expect(theme.copyWith().accent, theme.accent);
      });
    }
  }

  test('other designs and overlay keep their own palette', () {
    for (final design in AppThemeCatalog.designs) {
      if (design.id == AppThemeId.retroManga) continue;
      for (final dark in [false, true]) {
        expect(RetroTheme(dark, design: design, retroAccent: RetroAccent.pink).accent,
            RetroTheme(dark, design: design).accent);
      }
    }
    expect(RetroTheme.overlay().accent, RetroAccent.cyan.color);
  });
}
