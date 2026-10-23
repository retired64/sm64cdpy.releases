import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/presentation/widgets/home_typography.dart';

void main() {
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
                  HomeMarioLabel(label: 'Exclusive Content'),
                  Text('Author and description', key: ValueKey('home-body')),
                  Row(children: [
                    HomeLaunchIcon(), SizedBox(width: 8),
                    Expanded(child: HomeMarioLabel(label: 'Abrir el juego')),
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
        expect(image.width, 36);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
