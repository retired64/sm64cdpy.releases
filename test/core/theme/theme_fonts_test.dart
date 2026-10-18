import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';

void main() {
  test('Mario Kart typography uses the racing display face', () {
    final kart = RetroTheme(
      false,
      design: AppThemeCatalog.resolve(AppThemeId.marioKart64),
    );

    expect(kart.heading(size: 24).fontFamily, 'Mk64Racing');
    expect(kart.body(size: 14).fontFamily, isNull);
    expect(
      kart.toMaterialTheme().textTheme.titleLarge!.fontFamily,
      'Mk64Racing',
    );
  });

  test('Minish typography follows booklet heading and body roles', () {
    final minish = RetroTheme(
      false,
      design: AppThemeCatalog.resolve(AppThemeId.minishCap),
    );

    expect(minish.heading(size: 24).fontFamily, 'MinishFondamento');
    expect(minish.body(size: 14).fontFamily, 'MinishBarlow');
    expect(
      minish.toMaterialTheme().textTheme.bodyMedium!.fontFamily,
      'MinishBarlow',
    );
    expect(
      minish.toMaterialTheme().textTheme.titleLarge!.fontFamily,
      'MinishFondamento',
    );
  });

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
