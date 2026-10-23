import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/presentation/widgets/home_typography.dart';

void main() {
  test('custom Home icons are small bundled WebPs', () async {
    for (final name in ['start-game', 'catalog', 'favorites', 'popular']) {
      final data = await rootBundle.load('assets/themes/manga/navigation/home-$name.webp');
      expect(data.getUint32(0), 0x52494646);
      expect(data.lengthInBytes, lessThan(12000));
    }
  });

  for (final id in [AppThemeId.retroManga, AppThemeId.mangaDeluxe]) {
    for (final dark in [false, true]) {
      testWidgets('Home type fits narrow layouts $id dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(320, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
          theme: RetroTheme.materialTheme(dark, design: AppThemeCatalog.resolve(id)),
          home: Scaffold(body: HomeTypography(child: Builder(builder: (context) =>
            MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.6)),
              child: const SingleChildScrollView(child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  HomeMarioLabel(label: 'Exclusive'),
                  Text('Author and description', key: ValueKey('home-body')),
                  Row(children: [
                    HomeLaunchIcon(), SizedBox(width: 8),
                    Expanded(child: HomeMarioLabel(label: 'INICIAR JUEGO', size: 14, singleLine: true)),
                  ]),
                ]),
              )),
            ),
          ))),
        ));
        await tester.pumpAndSettle();
        final body = tester.element(find.byKey(const ValueKey('home-body')));
        expect(DefaultTextStyle.of(body).style.fontFamily, 'FamiljenGrotesk');
        final texts = tester.widgetList<Text>(find.descendant(
          of: find.byType(HomeMarioLabel), matching: find.byType(Text),
        ));
        expect(texts, hasLength(4));
        for (final text in texts) {
          expect(text.style?.fontFamily, 'TypefaceMario64');
          if (text.style?.foreground case final paint?) {
            expect(paint.style, PaintingStyle.stroke);
            expect(paint.color, Colors.black);
          } else {
            expect(text.style?.color, Colors.white);
          }
        }
        final image = tester.widget<Image>(find.byType(Image));
        expect(image.width, 32);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
