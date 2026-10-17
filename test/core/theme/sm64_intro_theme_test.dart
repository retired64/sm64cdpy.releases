import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import '../../presentation/mario_rom_fixture.dart';

void main() {
  test('Intro persists independently and keeps bundled typography', () {
    expect(AppThemeId.fromStorage('sm64_intro'), AppThemeId.sm64Intro);
    for (final dark in [false, true]) {
      final intro = RetroTheme(
        dark,
        design: AppThemeCatalog.resolve(AppThemeId.sm64Intro),
        marioAssets: completeMarioFixture(),
      );
      expect(intro.isIntro, isTrue);
      expect(intro.headingFamily, 'TypefaceMario64');
      expect(intro.bodyFamily, isNull);
      expect(intro.menuFamily, 'TypefaceMario64');
      final button = intro.toMaterialTheme().filledButtonTheme.style!;
      expect(button.backgroundColor!.resolve({}), const Color(0xFF24479B));
      expect(button.foregroundColor!.resolve({}), Colors.white);
      expect(
        button.backgroundColor!.resolve({WidgetState.disabled}),
        intro.surfaceAlt,
      );
      expect(intro.surfaceDecoration().image, isNull);
      expect(intro.surfaceDecoration().color, intro.surface);
      expect(intro.copyWith().isIntro, isTrue);
    }
    expect(RetroTheme.overlay().isIntro, isFalse);
    expect(RetroTheme.overlay().marioAsset('mario_save'), isNull);
  });

  testWidgets('Intro slot requests a change without claiming it was saved', (
    tester,
  ) async {
    bool? requested;
    final intro = RetroTheme(
      false,
      design: AppThemeCatalog.resolve(AppThemeId.sm64Intro),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: intro.toMaterialTheme(),
        home: Scaffold(
          body: MarioGameToggle(
            value: false,
            onChanged: (value) => requested = value,
          ),
        ),
      ),
    );
    final glyph = tester.widget<MarioMenuGlyph>(find.byType(MarioMenuGlyph));
    expect(glyph.asset, 'mario_new');
    expect(glyph.size, 40);
    expect(tester.getSize(find.byType(InkWell)), const Size(64, 48));
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(requested, isTrue);
    expect(
      tester.widget<MarioGameToggle>(find.byType(MarioGameToggle)).value,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}
