import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';

void main() {
  for (final dark in [false, true]) {
    test('Mario fonts follow heading/body roles in $dark appearance', () {
      final mario = RetroTheme(
        dark,
        design: AppThemeCatalog.resolve(AppThemeId.mario64),
      );
      expect(mario.heading(size: 24).fontFamily, 'TypefaceMario64');
      expect(mario.heading(size: 24).fontFamilyFallback, ['Roboto']);
      expect(mario.body(size: 14).fontFamily, isNull);
      final material = mario.toMaterialTheme();
      expect(material.textTheme.displayLarge!.fontFamily, 'TypefaceMario64');
      expect(material.textTheme.titleLarge!.fontFamily, 'TypefaceMario64');
      expect(
        material.primaryTextTheme.headlineSmall!.fontFamily,
        'TypefaceMario64',
      );
      expect(
        material.textTheme.bodyMedium!.fontFamily,
        const RetroTheme(
          false,
        ).toMaterialTheme().textTheme.bodyMedium!.fontFamily,
      );
      expect(material.textTheme.titleLarge!.fontWeight, FontWeight.w400);
    });
  }
  test(
    'Retro and overlay do not inherit Mario typography; interpolation preserves fallback',
    () {
      const retro = RetroTheme(false);
      final mario = RetroTheme(
        false,
        design: AppThemeCatalog.resolve(AppThemeId.mario64),
      );
      expect(retro.heading(size: 24).fontFamily, isNull);
      expect(retro.body(size: 14).fontFamily, isNull);
      expect(RetroTheme.overlay().heading(size: 24).fontFamily, isNull);
      expect(mario.lerp(retro, 0).heading(size: 24).fontFamilyFallback, [
        'Roboto',
      ]);
      expect(mario.lerp(retro, 1).heading(size: 24).fontFamily, isNull);
    },
  );
}
