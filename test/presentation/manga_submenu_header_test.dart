import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/widgets/manga_submenu_header.dart';
import 'package:sm64cdpy/presentation/widgets/mario_multicolor_label.dart';

void main() {
  for (final dark in [false, true]) {
    for (final language in ['en', 'es', 'pt']) {
      testWidgets('submenu header fits and closes $language dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(dark),
          home: Builder(builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.6)),
                  child: MangaSubmenuHeader(
                    title: AppLocalizations.of(context).gameToolTitle,
                    asset: 'assets/themes/manga/navigation/tools.webp',
                    fallbackIcon: Icons.sports_esports_outlined,
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          )),
        ));
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(MarioMulticolorLabel), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
        expect(tester.getSize(find.byType(CloseButton)).shortestSide, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(find.byType(MangaSubmenuHeader), findsNothing);
      });
    }
  }
}
