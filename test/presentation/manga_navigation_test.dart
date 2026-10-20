import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/player_profile.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/auto_install_provider.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';
import 'package:sm64cdpy/presentation/providers/player_profile_provider.dart';
import 'package:sm64cdpy/presentation/widgets/app_shell.dart';
import 'package:sm64cdpy/presentation/widgets/manga_navigation_bar.dart';
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
  '/game-tool/save-file',
  '/game-tool/rom-preparer',
  '/settings',
  '/render96',
  '/vip',
  '/dynos',
  '/touch-controls',
  '/omm-rebirth',
  '/how-to-play',
  '/links-resource',
  '/disclaimer',
];

GoRouter _router({String initial = '/'}) => GoRouter(
  initialLocation: initial,
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(currentRoute: state.uri.path, child: child),
      routes: [
        for (final route in _routes)
          GoRoute(
            path: route,
            builder: (context, state) => CustomScrollView(
              slivers: [
                RetroPinnedAppBar(title: Text(route)),
                SliverToBoxAdapter(child: Text('content $route')),
                const SliverToBoxAdapter(child: SizedBox(height: 1200)),
              ],
            ),
          ),
      ],
    ),
  ],
);

Widget _app(
  GoRouter router,
  RetroTheme retro,
  String language,
  double scale, {
  bool dirty = false,
  double keyboard = 0,
}) => ProviderScope(
  overrides: [
    autoInstallProvider.overrideWith(_Auto.new),
    gameFolderProvider.overrideWith(_Folder.new),
    if (dirty) playerProfileProvider.overrideWith(_DirtyPlayer.new),
  ],
  child: MaterialApp.router(
    routerConfig: router,
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: RetroTheme.materialTheme(retro.isDark, design: retro.design),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        viewInsets: EdgeInsets.only(bottom: keyboard),
      ),
      child: child!,
    ),
  ),
);

void main() {
  testWidgets('Home has neighbours on both sides without navigating', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('manga-nav-4')), findsOneWidget);
    expect(find.byKey(const ValueKey('manga-nav-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('manga-nav-1')), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(tester.takeException(), isNull);
  });

  for (final design in AppThemeCatalog.designs) {
    for (final dark in [false, true]) {
      testWidgets('navigation follows ${design.id} dark=$dark', (tester) async {
        final router = _router(initial: '/library');
        addTearDown(router.dispose);
        await tester.pumpWidget(
          _app(router, RetroTheme(dark, design: design), 'en', 1),
        );
        await tester.pumpAndSettle();
        final manga = RetroTheme(dark, design: design).showJapaneseDecorations;
        expect(
          find.byType(MangaNavigationBar),
          manga ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(DrawerMenuButton),
          manga ? findsNothing : findsOneWidget,
        );
        if (manga) {
          final body = tester.getRect(find.byType(CustomScrollView));
          final bar = tester.getRect(
            find.byKey(const ValueKey('manga-navigation')),
          );
          expect(body.bottom, lessThanOrEqualTo(bar.top));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final language in ['en', 'es', 'pt']) {
    for (final size in [const Size(320, 640), const Size(640, 320)]) {
      testWidgets('manga carousel $language $size is explicit and responsive', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final router = _router(initial: '/library');
        addTearDown(router.dispose);
        await tester.pumpWidget(
          _app(router, const RetroTheme(false), language, 1.6),
        );
        await tester.pumpAndSettle();
        final pages = find.byKey(const ValueKey('manga-navigation-pages'));
        await tester.drag(pages, const Offset(-180, 0));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/library');
        // Centrar un grupo no cambia de pantalla; pulsarlo sí muestra sus opciones.
        final controller = tester.widget<PageView>(pages).controller!;
        controller.jumpToPage(3);
        await tester.pumpAndSettle();
        final tile = find.byKey(const ValueKey('manga-nav-3'));
        expect(tester.getSize(tile).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(tile).height, greaterThanOrEqualTo(48));
        await tester.tap(tile);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('manga-route-/game-tool/save-file')),
        );
        await tester.pumpAndSettle();
        expect(
          router.routeInformationProvider.value.uri.path,
          '/game-tool/save-file',
        );
        expect(find.byType(DrawerMenuButton), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('more retains exclusive resources settings and native launch', (
    tester,
  ) async {
    final calls = <String>[];
    const channel = MethodChannel('sm64cdpy/launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      return true;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    final router = _router(initial: '/settings');
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('manga-nav-4')));
    await tester.pumpAndSettle();
    final list = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(ListView),
    );
    for (final path in [
      '/settings',
      '/render96',
      '/vip',
      '/dynos',
      '/touch-controls',
      '/omm-rebirth',
      '/how-to-play',
      '/links-resource',
      '/disclaimer',
    ]) {
      final target = find.byKey(ValueKey('manga-route-$path'));
      await tester.scrollUntilVisible(
        target,
        100,
        scrollable: find.descendant(
          of: list,
          matching: find.byType(Scrollable),
        ),
      );
      expect(target, findsOneWidget);
    }
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('manga-play')));
    await tester.pumpAndSettle();
    expect(calls, ['launch']);
    expect(router.routeInformationProvider.value.uri.path, '/settings');
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('leaving Player asks before discarding its draft', (
    tester,
  ) async {
    final router = _router(initial: '/player');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(router, const RetroTheme(false), 'en', 1, dirty: true),
    );
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(
      tester.element(find.byType(MangaNavigationBar)),
    );
    final pages = tester
        .widget<PageView>(find.byKey(const ValueKey('manga-navigation-pages')))
        .controller!;
    pages.jumpToPage(2);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('manga-nav-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.playerKeepEditing));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/player');
    await tester.tap(find.byKey(const ValueKey('manga-nav-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.playerDiscard));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/library');
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard hides the strip and closing it restores navigation', (
    tester,
  ) async {
    final router = _router(initial: '/catalogue');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(router, const RetroTheme(false), 'en', 1, keyboard: 240),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MangaNavigationBar), findsNothing);
    expect(find.byType(DrawerMenuButton), findsNothing);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await tester.pumpAndSettle();
    expect(find.byType(MangaNavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing game opens the guide only after confirmation', (
    tester,
  ) async {
    final calls = <String>[];
    const channel = MethodChannel('sm64cdpy/launcher');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      calls.add(call.method);
      return false;
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    final router = _router(initial: '/library');
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(
      tester.element(find.byType(MangaNavigationBar)),
    );
    await tester.tap(find.byKey(const ValueKey('manga-play')));
    await tester.pumpAndSettle();
    expect(calls, ['launch', 'isInstalled']);
    expect(router.routeInformationProvider.value.uri.path, '/library');
    await tester.tap(find.text(l.playGuideRead));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/how-to-play');
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
