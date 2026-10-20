import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';

void main() {
  for (final design in AppThemeCatalog.designs) {
    for (final dark in [false, true]) {
      testWidgets('${design.id.name} dark=$dark gates Japanese decoration', (
        tester,
      ) async {
        final retro = RetroTheme(dark, design: design);
        final manga = design.id == AppThemeId.retroManga;
        expect(retro.showJapaneseDecorations, manga);
        await tester.pumpWidget(
          MaterialApp(
            theme: retro.toMaterialTheme(),
            home: Scaffold(
              body: SectionKicker(
                retro: retro,
                label: 'Library',
                japanese: 'ライブラリ',
              ),
            ),
          ),
        );
        expect(find.text('ライブラリ'), manga ? findsOneWidget : findsNothing);
        expect(find.text(retro.displayLabel('Library')), findsOneWidget);
      });
    }
  }
}
