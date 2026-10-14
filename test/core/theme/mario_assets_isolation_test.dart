import '../../presentation/mario_rom_fixture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/mario_theme_assets.dart';

void main() {
  test(
    'imported files remain exclusive to Mario, including copy and interpolation',
    () {
      const assets = MarioThemeAssets(
        generation: 'local',
        files: {'stone': '/private/stone.png'},
      );
      final mario = RetroTheme(
        false,
        design: AppThemeCatalog.resolve(AppThemeId.mario64),
        marioAssets: assets,
      );
      expect(mario.marioAsset('stone'), '/private/stone.png');
      expect(mario.copyWith().marioAsset('stone'), '/private/stone.png');
      expect(
        mario.lerp(mario.copyWith(isDark: true), 0.5).marioAsset('stone'),
        '/private/stone.png',
      );
      expect(
        RetroTheme(false, marioAssets: assets).marioAsset('stone'),
        isNull,
      );
      expect(RetroTheme.overlay().marioAsset('stone'), isNull);
    },
  );
  test('incomplete persisted asset maps fall back to the built-in design', () {
    expect(
      MarioThemeAssets.fromMap({
        'generation': 'local',
        'files': {'stone': '/file'},
      }).available,
      isFalse,
    );
    expect(MarioThemeAssets.fromMap(null).available, isFalse);
  });
  test(
    'custom filled surfaces preserve their contrast color without texture or highlight',
    () {
      final mario = RetroTheme(
        false,
        design: AppThemeCatalog.resolve(AppThemeId.mario64),
      );
      final filled = mario.surfaceDecoration(color: mario.accent);
      expect(filled.color, mario.accent);
      expect(filled.gradient, isNull);
      expect(filled.image, isNull);
      expect(mario.surfaceDecoration().gradient, isNull);
    },
  );
  test(
    'full Mario scenes use opaque ROM materials and original font roles in both modes',
    () {
      final assets = completeMarioFixture();
      for (final dark in [false, true]) {
        final mario = RetroTheme(
          dark,
          design: AppThemeCatalog.resolve(AppThemeId.mario64),
          marioAssets: assets,
        );
        expect(mario.headingFamily, 'MarioRomHudV2');
        expect(mario.bodyFamily, 'MarioRomDialogV2');
        expect(mario.menuFamily, 'MarioRomMenuV2');
        expect(mario.surfaceDecoration().image!.opacity, 1);
        expect(
          mario.toMaterialTheme().filledButtonTheme.style!.backgroundBuilder,
          isNotNull,
        );
        expect(mario.surfaceDecoration(color: mario.accent).image, isNull);
        expect(mario.marioAsset(dark ? 'sky_night' : 'sky_day'), isNotNull);
      }
      expect(RetroTheme.overlay().bodyFamily, isNull);
      expect(const RetroTheme(false).surfaceDecoration().image, isNull);
    },
  );
}
