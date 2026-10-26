import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sm64cdpy/core/navigation/app_navigation_policy.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/core/theme/themes/retro_manga_theme.dart';
import 'package:sm64cdpy/domain/entities/player_profile.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/auto_install_provider.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';
import 'package:sm64cdpy/presentation/providers/navigation_provider.dart';
import 'package:sm64cdpy/presentation/providers/player_profile_provider.dart';
import 'package:sm64cdpy/presentation/widgets/app_drawer.dart';
import 'package:sm64cdpy/presentation/widgets/app_navigation_scope.dart';
import 'package:sm64cdpy/presentation/widgets/app_shell.dart';
import 'package:sm64cdpy/services/auto_install_preference_service.dart';
import 'package:sm64cdpy/services/game_folder_service.dart';

class _Auto extends AutoInstallNotifier {
  @override
  AutoInstallSettings build() =>
      const AutoInstallSettings(decision: AutoInstallDecision.disabled);
}

class _Folder extends GameFolderNotifier {
  @override
  GameFolderState build() => const GameFolderState(
    initialized: true,
    connection: GameFolderConnection(connected: true, unified: true),
  );
}

class _DirtyPlayer extends PlayerProfileNotifier {
  @override
  PlayerProfileState build() => const PlayerProfileState(
    status: 'ready',
    confirmed: PlayerProfile(
      name: 'Original',
      model: 0,
      palette: PlayerPalette.mario,
    ),
    draft: PlayerProfile(name: 'Draft', model: 0, palette: PlayerPalette.mario),
    revision: 'original',
  );
}

const _routes = [
  '/',
  '/catalogue',
  '/popular',
  '/favourites',
  '/library',
  '/player',
  '/game-tool/play-2p2',
  '/game-tool/save-file',
  '/game-tool/rom-preparer',
  '/settings',
  '/settings/permissions',
  '/how-to-play',
  '/links-resource',
  '/disclaimer',
  '/vip',
  '/dynos',
  '/touch-controls',
  '/omm-rebirth',
  '/render96',
];

GoRouter _router({String initial = '/'}) => GoRouter(
  initialLocation: initial,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(
        currentRoute: state.uri.path,
        currentUri: state.uri,
        isSecondary:
            state.extra is AppSecondaryDestination ||
            AppNavigationPolicy.isSecondaryLocation(state.uri),
        child: child,
      ),
      routes: [
        for (final route in _routes)
          GoRoute(
            path: route,
            pageBuilder: (context, state) =>
                NoTransitionPage(child: _TestPage(route: route)),
          ),
      ],
    ),
    GoRoute(
      path: '/mod/:id',
      pageBuilder: (context, state) => NoTransitionPage(
        child: Scaffold(
          body: Center(child: Text('detail ${state.pathParameters['id']}')),
        ),
      ),
    ),
  ],
);

class _TestPage extends StatelessWidget {
  const _TestPage({required this.route});

  final String route;

  Widget _button(String key, String label, VoidCallback onPressed) {
    return TextButton(
      key: ValueKey(key),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        RetroPinnedAppBar(title: Text(route)),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (route == '/') ...[
                _button(
                  'home-player',
                  'Player',
                  () => openPrimaryDestination(context, '/player'),
                ),
                _button(
                  'home-library',
                  'Library',
                  () => openPrimaryDestination(context, '/library'),
                ),
                _button(
                  'home-settings',
                  'Settings',
                  () => openPrimaryDestination(context, '/settings'),
                ),
                _button(
                  'home-query-library',
                  'Recent library',
                  () => openPrimaryDestination(context, '/library?view=recent'),
                ),
                _button(
                  'home-guide',
                  'Guide',
                  () => openSecondaryDestination(context, '/how-to-play'),
                ),
              ],
              if (route == '/library')
                _button(
                  'library-player',
                  'Player',
                  () => openPrimaryDestination(context, '/player'),
                ),
              if (route == '/settings')
                _button(
                  'settings-permissions',
                  'Permissions',
                  () => openSecondaryDestination(
                    context,
                    '/settings/permissions',
                  ),
                ),
              if (route == '/catalogue')
                _button(
                  'catalogue-detail',
                  'Detail',
                  () => context.push('/mod/1'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _app(
  ProviderContainer container,
  GoRouter router, {
  AppThemeDesign design = retroMangaTheme,
}) => UncontrolledProviderScope(
  container: container,
  child: MaterialApp.router(
    routerConfig: router,
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: RetroTheme.materialTheme(false, design: design),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(disableAnimations: true, textScaler: TextScaler.noScaling),
      child: child!,
    ),
  ),
);

ProviderContainer _container({bool dirty = false}) {
  final container = ProviderContainer(
    overrides: [
      autoInstallProvider.overrideWith(_Auto.new),
      gameFolderProvider.overrideWith(_Folder.new),
      if (dirty) playerProfileProvider.overrideWith(_DirtyPlayer.new),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _back(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home to Player and Back returns Home', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-player')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/player');

    await _back(tester);

    expect(router.state.uri.path, '/');
  });

  testWidgets('Library and Player back through the main history', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-library')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('library-player')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/player');

    await _back(tester);
    expect(router.state.uri.path, '/library');

    await _back(tester);
    expect(router.state.uri.path, '/');
  });

  testWidgets('Settings pushes Permissions and both Back forms return', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(
        _container(),
        router,
        design: AppThemeCatalog.resolve(AppThemeId.minimal),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-permissions')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/settings/permissions');
    expect(find.byType(AppBackButton), findsOneWidget);
    expect(find.byType(DrawerMenuButton), findsNothing);

    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/settings');

    await tester.tap(find.byKey(const ValueKey('settings-permissions')));
    await tester.pumpAndSettle();
    await _back(tester);
    expect(router.state.uri.path, '/settings');
  });

  testWidgets('a main destination without history returns Home', (
    tester,
  ) async {
    final router = _router(initial: '/library');
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();

    await _back(tester);

    expect(router.state.uri.path, '/');
  });

  testWidgets('Home without history allows Android to exit', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(handled, isFalse);
    expect(router.state.uri.path, '/');
  });

  testWidgets('repeating the same destination does not duplicate history', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    final container = _container();
    await tester.pumpWidget(_app(container, router));
    await tester.pumpAndSettle();
    final navigator = container.read(appNavigatorProvider);

    navigator.openPrimary(router, '/player');
    await tester.pumpAndSettle();
    navigator.openPrimary(router, '/player');
    await tester.pumpAndSettle();

    await _back(tester);

    expect(router.state.uri.path, '/');
  });

  testWidgets('Catalogue to mod detail and Back returns Catalogue', (
    tester,
  ) async {
    final router = _router(initial: '/catalogue');
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('catalogue-detail')));
    await tester.pumpAndSettle();
    expect(find.text('detail 1'), findsOneWidget);

    await _back(tester);

    expect(router.state.uri.path, '/catalogue');
  });

  testWidgets('dirty Player asks before Back', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    final container = _container(dirty: true);
    await tester.pumpWidget(_app(container, router));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-player')));
    await tester.pumpAndSettle();

    final back = tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(AppShell)));

    expect(find.text(l10n.playerUnsavedTitle), findsOneWidget);
    expect(router.state.uri.path, '/player');

    await tester.tap(find.text(l10n.playerKeepEditing));
    await tester.pumpAndSettle();
    await back;
  });

  testWidgets('cancelling discard keeps Player and its changes', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    final container = _container(dirty: true);
    await tester.pumpWidget(_app(container, router));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-player')));
    await tester.pumpAndSettle();

    final back = tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(AppShell)));
    await tester.tap(find.text(l10n.playerKeepEditing));
    await tester.pumpAndSettle();
    await back;

    expect(router.state.uri.path, '/player');
    expect(container.read(playerProfileProvider).dirty, isTrue);
  });

  testWidgets('confirming discard returns to the previous destination', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    final container = _container(dirty: true);
    await tester.pumpWidget(_app(container, router));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-player')));
    await tester.pumpAndSettle();

    final back = tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(AppShell)));
    await tester.tap(find.text(l10n.playerDiscard));
    await tester.pumpAndSettle();
    await back;

    expect(router.state.uri.path, '/');
    expect(container.read(playerProfileProvider).dirty, isFalse);
  });

  testWidgets('an open drawer closes before navigating or exiting', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(
        _container(),
        router,
        design: AppThemeCatalog.resolve(AppThemeId.minimal),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DrawerMenuButton));
    await tester.pumpAndSettle();
    expect(find.byType(AppDrawer), findsOneWidget);

    await _back(tester);

    expect(find.byType(AppDrawer), findsNothing);
    expect(router.state.uri.path, '/');
  });

  testWidgets('primary and secondary headers follow every theme', (
    tester,
  ) async {
    for (final design in [
      AppThemeCatalog.resolve(AppThemeId.minimal),
      AppThemeCatalog.resolve(AppThemeId.retroManga),
      AppThemeCatalog.resolve(AppThemeId.mangaDeluxe),
    ]) {
      final primaryRouter = _router();
      addTearDown(primaryRouter.dispose);
      await tester.pumpWidget(
        _app(_container(), primaryRouter, design: design),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(DrawerMenuButton),
        design.id == AppThemeId.minimal ? findsOneWidget : findsNothing,
      );
      expect(find.byType(AppBackButton), findsNothing);

      final secondaryRouter = _router(initial: '/settings/permissions');
      addTearDown(secondaryRouter.dispose);
      await tester.pumpWidget(
        _app(_container(), secondaryRouter, design: design),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBackButton), findsOneWidget);
      expect(find.byType(DrawerMenuButton), findsNothing);
      if (design.id == AppThemeId.minimal) {
        expect(find.byKey(const ValueKey('app-back-surface')), findsNothing);
      } else {
        expect(find.byKey(const ValueKey('app-back-surface')), findsOneWidget);
      }
    }
  });

  testWidgets('a contextual guide is secondary and returns to its opener', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-guide')));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, '/how-to-play');
    expect(find.byType(AppBackButton), findsOneWidget);

    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, '/');
  });

  testWidgets('query strings survive a round trip through main history', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-query-library')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('library-player')));
    await tester.pumpAndSettle();

    await _back(tester);

    expect(router.state.uri.toString(), '/library?view=recent');
  });

  testWidgets('each Back event produces one route transition', (tester) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(_container(), router));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-player')));
    await tester.pumpAndSettle();

    var lastPath = router.state.uri.path;
    var transitions = 0;
    void listener() {
      final path = router.state.uri.path;
      if (path == lastPath) return;
      lastPath = path;
      transitions++;
    }

    router.routerDelegate.addListener(listener);
    addTearDown(() => router.routerDelegate.removeListener(listener));

    await _back(tester);

    expect(transitions, 1);
    expect(router.state.uri.path, '/');
  });
}
