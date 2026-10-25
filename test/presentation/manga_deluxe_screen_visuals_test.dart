import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/presentation/widgets/manga_deluxe_screen_visuals.dart';

Widget _scene(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: RetroTheme.materialTheme(
    false,
    design: AppThemeCatalog.resolve(AppThemeId.mangaDeluxe),
  ),
  builder: (context, content) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      disableAnimations: reduceMotion,
      accessibleNavigation: reduceMotion,
    ),
    child: content!,
  ),
  home: Scaffold(body: child),
);

void main() {
  test('Deluxe screen assets are compact bundled WebPs', () async {
    for (final name in ['rom-prepare', 'save-files']) {
      final data = await rootBundle.load(
        'assets/themes/manga_deluxe/$name.webp',
      );
      expect(data.getUint32(0), 0x52494646);
      expect(data.lengthInBytes, lessThan(12000));
    }
  });

  testWidgets('Deluxe title uses Mario lettering and body uses reading font', (
    tester,
  ) async {
    await tester.pumpWidget(
      _scene(
        const MangaDeluxeTypography(
          child: Column(
            children: [
              MangaDeluxeScreenTitle(label: 'Prepare your ROM'),
              Text('Local processing', key: ValueKey('body-copy')),
            ],
          ),
        ),
      ),
    );
    final titleParts = tester.widgetList<Text>(
      find.descendant(
        of: find.byType(MangaDeluxeScreenTitle),
        matching: find.byType(Text),
      ),
    );
    expect(titleParts, isNotEmpty);
    expect(titleParts.last.style?.fontFamily, 'TypefaceMario64');
    final bodyContext = tester.element(find.byKey(const ValueKey('body-copy')));
    expect(
      DefaultTextStyle.of(bodyContext).style.fontFamily,
      'FamiljenGrotesk',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('rainbow accent animates sparsely and respects reduced motion', (
    tester,
  ) async {
    const key = ValueKey('rainbow-copy');
    Widget label() => const MangaDeluxeRainbowText(
      label: 'Ready',
      style: TextStyle(color: Colors.black),
      key: key,
    );
    await tester.pumpWidget(_scene(label()));
    final initial = tester.widget<Text>(find.text('Ready')).style?.color;
    await tester.pump(const Duration(seconds: 1));
    final moved = tester.widget<Text>(find.text('Ready')).style?.color;
    expect(moved, isNot(initial));

    await tester.pumpWidget(_scene(label(), reduceMotion: true));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<Text>(find.text('Ready')).style?.color, Colors.black);
    expect(tester.takeException(), isNull);
  });
}
