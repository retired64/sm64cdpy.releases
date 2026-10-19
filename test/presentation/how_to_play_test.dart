import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';
import 'package:sm64cdpy/presentation/screens/how_to_play_screen.dart';
import 'package:sm64cdpy/presentation/widgets/game_launch_flow.dart';
import 'package:sm64cdpy/presentation/widgets/post_install_dialog.dart';

class _UnconnectedFolder extends GameFolderNotifier {
  @override
  GameFolderState build() => const GameFolderState(initialized: true);
  @override
  Future<void> refresh() async {}
}

void main() {
  for (final language in ['en', 'es', 'pt']) {
    for (final design in AppThemeCatalog.designs) {
      for (final dark in [false, true]) {
        testWidgets(
          'guide $language ${design.id} dark=$dark fits narrow screens',
          (tester) async {
            tester.view.physicalSize = const Size(360, 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  gameFolderProvider.overrideWith(_UnconnectedFolder.new),
                ],
                child: MaterialApp(
                  locale: Locale(language),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: RetroTheme.materialTheme(dark, design: design),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(1.3)),
                    child: child!,
                  ),
                  home: const Scaffold(body: HowToPlayScreen()),
                ),
              ),
            );
            await tester.pumpAndSettle();
            for (var step = 0; step < 6; step++) {
              final chip = find.byKey(ValueKey('guide-stage-$step'));
              await tester.ensureVisible(chip);
              await tester.tap(chip);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            final pager = find.byKey(const ValueKey('guide-pager'));
            await tester.drag(pager, const Offset(300, 0));
            await tester.pumpAndSettle();
            expect(tester.widget<PageView>(pager).controller!.page, 4);
            await tester.tap(find.byKey(const ValueKey('guide-previous')));
            await tester.pumpAndSettle();
            expect(tester.widget<PageView>(pager).controller!.page, 3);
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          },
        );
      }
    }

    testWidgets('chapter map and compact landscape: $language', (tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ProviderScope(
        overrides: [gameFolderProvider.overrideWith(_UnconnectedFolder.new)],
        child: MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(false),
          builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.6)), child: child!),
          home: const Scaffold(body: HowToPlayScreen()),
        ),
      ));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(HowToPlayScreen)));
      await tester.tap(find.byTooltip(l10n.playGuideOverview));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      final target = find.byType(ListTile).at(3);
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 3);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip(l10n.playGuideOverview));
      await tester.pumpAndSettle();
      final handle = tester.getTopLeft(find.byType(BottomSheet)) + const Offset(100, 12);
      await tester.dragFrom(handle, const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('post-install missing game offers guide: $language', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => showPostInstallDialog(context),
                child: const Text('Installed'),
              ),
            ),
          ),
          GoRoute(
            path: '/how-to-play',
            builder: (_, state) =>
                const Scaffold(body: Text('Guide destination')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Installed'));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AlertDialog)),
      );
      await tester.tap(find.text(l10n.playGuideRead));
      await tester.pumpAndSettle();
      expect(find.text('Guide destination'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'missing game offers localized guide without auto-navigation: $language',
      (tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: TextButton(
                  onPressed: () => launchGameWithGuide(context),
                  child: const Text('Launch'),
                ),
              ),
            ),
            GoRoute(
              path: '/how-to-play',
              builder: (_, state) =>
                  const Scaffold(body: Text('Guide destination')),
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: RetroTheme.materialTheme(false),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Launch'));
        await tester.pumpAndSettle();
        final dialogContext = tester.element(find.byType(Dialog));
        final l10n = AppLocalizations.of(dialogContext);
        final retro = RetroTheme.of(dialogContext);
        expect(find.text(l10n.playGuideMissingTitle), findsOneWidget);
        expect(find.text('Guide destination'), findsNothing);
        await tester.tap(find.text(retro.displayLabel(l10n.playGuideLater)));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        await tester.tap(find.text('Launch'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(retro.displayLabel(l10n.playGuideRead)));
        await tester.pumpAndSettle();
        expect(find.text('Guide destination'), findsOneWidget);
      },
    );
  }
}
