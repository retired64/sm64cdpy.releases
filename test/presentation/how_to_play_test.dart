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
              final chip = find.byType(ChoiceChip).at(step);
              await tester.ensureVisible(chip);
              await tester.tap(chip);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pumpAndSettle();
          },
        );
      }
    }

    testWidgets('post-install missing game offers guide: $language', (tester) async {
      final router = GoRouter(routes: [
        GoRoute(path: '/', builder: (context, state) => Scaffold(
          body: TextButton(onPressed: () => showPostInstallDialog(context), child: const Text('Installed')),
        )),
        GoRoute(path: '/how-to-play', builder: (_, state) => const Scaffold(body: Text('Guide destination'))),
      ]);
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: RetroTheme.materialTheme(false),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Installed'));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(tester.element(find.byType(AlertDialog)));
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
