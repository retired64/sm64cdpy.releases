import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/core/theme/retro_accent.dart';
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
                const SliverToBoxAdapter(
                  child: SizedBox(
                    height: 1200,
                    child: ColoredBox(color: Colors.red),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      key: const ValueKey('last-content-action'),
                      onPressed: () {},
                      child: const Text('Last action'),
                    ),
                  ),
                ),
                const MangaNavigationSliverInset(),
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
  bool reduceMotion = false,
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
    theme: RetroTheme.materialTheme(
      retro.isDark,
      design: retro.design,
      retroAccent: retro.retroAccent,
    ),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scale),
        disableAnimations: reduceMotion,
        viewInsets: EdgeInsets.only(bottom: keyboard),
      ),
      child: child!,
    ),
  ),
);

Future<void> _openMenu(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final toggle = find.byKey(const ValueKey('manga-menu-toggle'));
  if (toggle.evaluate().isEmpty) return;
  if (MediaQuery.viewInsetsOf(tester.element(toggle)).bottom > 0) return;
  if (find.byType(MangaNavigationBar).evaluate().isNotEmpty) return;
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'es', 'pt']) {
    testWidgets(
      'carousel anchors below its lifted close button and closes with Back: $language',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final router = _router(initial: '/library');
        addTearDown(router.dispose);
        await tester.pumpWidget(
          _app(router, const RetroTheme(false), language, 1),
        );
        await tester.pumpAndSettle();
        final toggle = find.byKey(const ValueKey('manga-menu-toggle'));
        expect(find.byType(MangaNavigationBar), findsNothing);
        final closed = tester.getRect(toggle);
        expect(closed.width, greaterThanOrEqualTo(48));
        expect(closed.height, greaterThanOrEqualTo(48));
        expect(closed.right, greaterThan(280));
        expect(closed.bottom, lessThanOrEqualTo(640));
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(find.byType(MangaNavigationBar), findsOneWidget);
        expect(
          find.byKey(const ValueKey('manga-menu-caption-fill')),
          findsNothing,
        );
        final closeImage = find.byKey(
          const ValueKey('manga-menu-close-button'),
        );
        final closeSize = tester.getBottomRight(closeImage) -
            tester.getTopLeft(closeImage);
        expect(closeSize.dx, closeTo(28, 0.01));
        expect(closeSize.dy, closeTo(28, 0.01));
        final opened = tester.getRect(toggle);
        expect(opened.width, greaterThanOrEqualTo(48));
        expect(opened.height, greaterThanOrEqualTo(48));
        expect(opened.top, lessThan(closed.top));
        expect(opened.right, closeTo(closed.right, 0.01));
        final bar = tester.getRect(
          find.byKey(const ValueKey('manga-navigation')),
        );
        expect(bar.bottom, closeTo(closed.bottom, 0.01));
        expect(opened.bottom, lessThanOrEqualTo(bar.top - 24));
        expect(opened.overlaps(bar), isFalse);
        final menuImage = tester.widget<Image>(
          find.byKey(const ValueKey('manga-menu-menu-button')),
        );
        final cached = menuImage.image as ResizeImage;
        expect(cached.width, 192);
        expect(cached.height, 192);
        final pages = tester
            .widget<PageView>(
              find.byKey(const ValueKey('manga-navigation-pages')),
            )
            .controller!;
        pages.jumpToPage(pages.initialPage + 1);
        await tester.pumpAndSettle();
        final page = pages.page;
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(MangaNavigationBar), findsNothing);
        expect(
          find.byKey(const ValueKey('manga-menu-caption-fill')),
          findsOneWidget,
        );
        expect(router.routeInformationProvider.value.uri.path, '/library');
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        final restored = tester
            .widget<PageView>(
              find.byKey(const ValueKey('manga-navigation-pages')),
            )
            .controller!;
        expect(identical(restored, pages), isTrue);
        expect(restored.page, page);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'toggle semantics and reduce motion reflect open and closed states',
    (tester) async {
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        _app(router, const RetroTheme(false), 'es', 1, reduceMotion: true),
      );
      await tester.pumpAndSettle();
      final toggle = find.byKey(const ValueKey('manga-menu-toggle'));
      final l = AppLocalizations.of(tester.element(toggle));
      final semantics = tester.ensureSemantics();
      try {
        expect(find.bySemanticsLabel(l.mangaMenuOpen), findsOneWidget);
        await tester.tap(toggle);
        await tester.pump();
        final fade = tester.widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(MangaNavigationBar),
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        expect(fade.opacity.value, 1);
        expect(find.bySemanticsLabel(l.mangaMenuClose), findsOneWidget);
        await tester.tap(toggle);
        await tester.pump();
        expect(find.byType(MangaNavigationBar), findsNothing);
      } finally {
        semantics.dispose();
      }
    },
  );

  for (final dark in [false, true]) {
    testWidgets('Menu caption uses localized Mario lettering dark=$dark', (tester) async {
      final router = _router();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router, RetroTheme(dark), 'es', 1.6));
      await tester.pumpAndSettle();
      final caption = tester.widget<Text>(
        find.byKey(const ValueKey('manga-menu-caption-fill')),
      );
      expect(caption.style!.fontFamily, 'TypefaceMario64');
      expect(caption.textSpan!.toPlainText(), 'MENÚ');
      final colors = (caption.textSpan! as TextSpan).children!
          .cast<TextSpan>().map((span) => span.style!.color).toSet();
      expect(colors.length, 4);
      final outline = tester.widget<Text>(
        find.byKey(const ValueKey('manga-menu-caption-outline')),
      );
      expect(outline.style!.foreground!.color, Colors.black);
      expect(find.byKey(const ValueKey('manga-menu-caption-rim')),
          dark ? findsOneWidget : findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('modal Back closes the destination sheet before the menu', (
    tester,
  ) async {
    final router = _router(initial: '/settings');
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await _openMenu(tester);
    await tester.tap(find.byKey(const ValueKey('manga-nav-4')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(find.byType(MangaNavigationBar), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/settings');
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'es', 'pt']) {
    testWidgets('audio submenu preserves Player and scrolls on small screens: $language', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = _router(initial: '/player');
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router, const RetroTheme(true), language, 1.6, dirty: true));
      await _openMenu(tester);
      final pages = tester.widget<PageView>(
        find.byKey(const ValueKey('manga-navigation-pages')),
      ).controller!;
      pages.jumpToPage(pages.initialPage + 2);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('manga-nav-5')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('manga-audio-menu')), findsOneWidget);
      expect(find.byKey(const ValueKey('ambient-music-enabled')), findsOneWidget);
      expect(find.byKey(const ValueKey('ambient-music-volume')), findsOneWidget);
      expect(find.byKey(const ValueKey('manga-menu-sounds')), findsOneWidget);
      final effects = find.byKey(const ValueKey('app-effects-volume'));
      await tester.ensureVisible(effects);
      await tester.pumpAndSettle();
      expect(effects.hitTestable(), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(router.routeInformationProvider.value.uri.path, '/player');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('manga-audio-menu')), findsNothing);
      expect(find.byType(MangaNavigationBar), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/player');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('all carousel papercraft assets are bundled', (tester) async {
    for (final name in ['home', 'explore', 'library', 'tools', 'more', 'audio', 'menu-button', 'close-button']) {
      final bytes = await rootBundle.load(
        'assets/themes/manga/navigation/$name.webp',
      );
      expect(bytes.lengthInBytes, greaterThan(0));
      expect(bytes.getUint32(0), 0x52494646); // Cabecera RIFF/WebP.
      expect(bytes.getUint32(8), 0x57454250);
    }
  });

  testWidgets('Home has neighbours on both sides without navigating', (
    tester,
  ) async {
    final router = _router();
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await _openMenu(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('manga-nav-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('manga-nav-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('manga-nav-1')), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/');
    final bar = find.byKey(const ValueKey('manga-navigation'));
    expect(tester.getSize(bar).height, inInclusiveRange(48, 50));
    expect(
      tester.getSize(find.byKey(const ValueKey('manga-nav-0'))).height,
      greaterThanOrEqualTo(48),
    );
    final active = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey('manga-nav-visual-0')),
    );
    final neighbour = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey('manga-nav-visual-1')),
    );
    final image = tester.widget<Image>(
      find.byKey(const ValueKey('manga-nav-image-0')),
    );
    expect(image.excludeFromSemantics, isTrue);
    final resized = image.image as ResizeImage;
    expect(resized.width, 256);
    expect(resized.height, 256);
    expect(
      (resized.imageProvider as AssetImage).assetName,
      'assets/themes/manga/navigation/home.webp',
    );
    expect(active.scale, closeTo(2, 0.001));
    expect(neighbour.scale, lessThan(active.scale));
    final icon = find.byKey(const ValueKey('manga-nav-image-0'));
    expect(
      tester.getBottomRight(icon).dx - tester.getTopLeft(icon).dx,
      closeTo(52, 0.01),
    );
    final label = find
        .descendant(
          of: find.byKey(const ValueKey('manga-nav-0')),
          matching: find.byType(Text),
        )
        .first;
    expect(
      tester.getBottomRight(icon).dy,
      lessThanOrEqualTo(tester.getTopLeft(label).dy),
    );
    expect(find.byKey(const ValueKey('manga-play')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('carousel focus follows the center and accent dark=$dark', (
      tester,
    ) async {
      final router = _router();
      addTearDown(router.dispose);
      final theme = RetroTheme(dark, retroAccent: RetroAccent.coral);
      await tester.pumpWidget(_app(router, theme, 'en', 1));
      await _openMenu(tester);
      await tester.pumpAndSettle();
      final pages = tester
          .widget<PageView>(
            find.byKey(const ValueKey('manga-navigation-pages')),
          )
          .controller!;
      pages.jumpToPage(pages.initialPage + 1);
      await tester.pumpAndSettle();
      final centered = tester.widget<AnimatedScale>(
        find.byKey(const ValueKey('manga-nav-visual-1')),
      );
      final previous = tester.widget<AnimatedScale>(
        find.byKey(const ValueKey('manga-nav-visual-0')),
      );
      expect(centered.scale, greaterThan(previous.scale));
      final halo =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const ValueKey('manga-nav-halo-1')),
                  )
                  .decoration
              as BoxDecoration;
      expect(
        halo.boxShadow!.single.color,
        theme.accent.withValues(alpha: 0.65),
      );
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(tester.takeException(), isNull);
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
      'translucent strip keeps a full viewport and reachable last action dark=$dark',
      (tester) async {
        final router = _router(initial: '/settings');
        addTearDown(router.dispose);
        await tester.pumpWidget(_app(router, RetroTheme(dark), 'es', 1));
        await _openMenu(tester);
        await tester.pumpAndSettle();
        final viewport = tester.getRect(find.byType(CustomScrollView));
        final bar = tester.getRect(
          find.byKey(const ValueKey('manga-navigation')),
        );
        expect(viewport.bottom, greaterThanOrEqualTo(bar.bottom));
        final scrollable = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
        await tester.pumpAndSettle();
        final lastAction = find.byKey(const ValueKey('last-content-action'));
        expect(
          tester.getRect(lastAction).bottom,
          lessThanOrEqualTo(bar.top - 20),
        );
        await tester.tap(lastAction);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final design in AppThemeCatalog.designs) {
    for (final dark in [false, true]) {
      testWidgets('navigation follows ${design.id} dark=$dark', (tester) async {
        final router = _router(initial: '/library');
        addTearDown(router.dispose);
        await tester.pumpWidget(
          _app(router, RetroTheme(dark, design: design), 'en', 1),
        );
        await _openMenu(tester);
        await tester.pumpAndSettle();
        final manga = RetroTheme(dark, design: design).isManga;
        expect(
          find.byType(MangaNavigationBar),
          manga ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(DrawerMenuButton),
          manga ? findsNothing : findsOneWidget,
        );
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).extendBody,
          manga,
        );
        if (manga) {
          final body = tester.getRect(find.byType(CustomScrollView));
          final bar = tester.getRect(
            find.byKey(const ValueKey('manga-navigation')),
          );
          // La lista pinta detrás de toda la tira, no se recorta en su borde.
          expect(body.bottom, greaterThanOrEqualTo(bar.bottom));
          final backdrop = find.byType(ThemeBackdrop);
          if (backdrop.evaluate().isNotEmpty) {
            expect(
              tester.getRect(backdrop).bottom,
              greaterThanOrEqualTo(bar.bottom),
            );
          }
          final surface = tester
              .widget<Material>(find.byKey(const ValueKey('manga-navigation')))
              .color!;
          expect(surface.a, closeTo(0.85, 0.005));
          expect(
            surface.withValues(alpha: 1),
            RetroTheme(dark, design: design).background,
          );
          expect(
            find.descendant(
              of: find.byKey(const ValueKey('manga-navigation')),
              matching: find.byType(HalftoneBackground),
            ),
            findsNothing,
          );
          final label = tester.widget<Text>(
            find.byKey(const ValueKey('manga-nav-label-fill-2')),
          );
          expect(label.style!.fontFamily, 'TypefaceMario64');
          final outline = tester
              .widget<Text>(
                find.byKey(const ValueKey('manga-nav-label-outline-2')),
              )
              .style!
              .foreground!;
          expect(outline.style, PaintingStyle.stroke);
          expect(outline.color, Colors.black);
          expect(label.style!.color, const Color(0xFFFFD83D));
          expect(
            RetroAccent.contrast(label.style!.color!, outline.color),
            greaterThanOrEqualTo(4.5),
          );
          final bubble =
              tester
                      .widget<DecoratedBox>(
                        find.byKey(const ValueKey('manga-nav-label-bubble-2')),
                      )
                      .decoration
                  as BoxDecoration;
          expect(bubble.borderRadius, BorderRadius.circular(999));
          expect(bubble.gradient!.colors.every((color) => color.a < 1), isTrue);
          for (final color in bubble.gradient!.colors) {
            expect(color.a, closeTo(0.35, 0.005));
          }
          expect(
            bubble.gradient!.colors[1],
            (dark ? const Color(0xFF2387FF) : const Color(0xFFE53935))
                .withValues(alpha: 0.35),
          );
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
        await _openMenu(tester);
        await tester.pumpAndSettle();
        final libraryLabel = tester.widget<Text>(
          find.byKey(const ValueKey('manga-nav-label-fill-2')),
        );
        expect(libraryLabel.data, switch (language) {
          'es' => 'MIS MODS',
          'pt' => 'BIBLIOTECA',
          _ => 'LIBRARY',
        });
        expect(libraryLabel.overflow, TextOverflow.visible);
        final fit = find.byKey(const ValueKey('manga-nav-label-fit-2'));
        expect(tester.widget<FittedBox>(fit).fit, BoxFit.scaleDown);
        final pill = find.byKey(const ValueKey('manga-nav-label-bubble-2'));
        final text = find.byKey(const ValueKey('manga-nav-label-fill-2'));
        expect(
          tester.getTopLeft(text).dx,
          greaterThanOrEqualTo(tester.getTopLeft(pill).dx),
        );
        expect(
          tester.getBottomRight(text).dx,
          lessThanOrEqualTo(tester.getBottomRight(pill).dx),
        );
        final exploreLabel = tester.widget<Text>(
          find.byKey(const ValueKey('manga-nav-label-fill-1')),
        );
        expect(exploreLabel.maxLines, 1);
        expect(exploreLabel.data, switch (language) {
          'es' => 'MODS',
          'pt' => 'EXPLORAR',
          _ => 'EXPLORE',
        });
        final pages = find.byKey(const ValueKey('manga-navigation-pages'));
        await tester.drag(pages, const Offset(-180, 0));
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/library');
        // Centrar un grupo no cambia de pantalla; pulsarlo sí muestra sus opciones.
        final controller = tester.widget<PageView>(pages).controller!;
        controller.jumpToPage(3);
        await tester.pumpAndSettle();
        final tile = find.byKey(const ValueKey('manga-nav-3'));
        final shortLabel = tester.widget<Text>(
          find.byKey(const ValueKey('manga-nav-label-fill-3')),
        );
        expect(shortLabel.data, switch (language) {
          'es' => 'TALLER',
          'pt' => 'OFICINA',
          _ => 'TOOLS',
        });
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
        // Elegir destino cierra el dock; abrirlo de nuevo conserva su grupo.
        expect(find.byType(MangaNavigationBar), findsNothing);
        await _openMenu(tester);
        final moreLabel = tester.widget<Text>(
          find.byKey(const ValueKey('manga-nav-label-fill-4')),
        );
        expect(moreLabel.data, switch (language) {
          'es' => 'MAS',
          'pt' => 'MAIS',
          _ => 'MORE',
        });
        expect(find.byType(DrawerMenuButton), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('more retains exclusive resources and settings', (tester) async {
    final router = _router(initial: '/settings');
    addTearDown(router.dispose);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await _openMenu(tester);
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
    expect(find.byKey(const ValueKey('manga-play')), findsNothing);
    expect(router.routeInformationProvider.value.uri.path, '/settings');
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving Player asks before discarding its draft', (
    tester,
  ) async {
    final router = _router(initial: '/player');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(router, const RetroTheme(false), 'en', 1, dirty: true),
    );
    await _openMenu(tester);
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

  testWidgets('keyboard preserves the floating toggle and hides the panel', (
    tester,
  ) async {
    final router = _router(initial: '/catalogue');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _app(router, const RetroTheme(false), 'en', 1, keyboard: 240),
    );
    await _openMenu(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('manga-menu-toggle')), findsOneWidget);
    expect(find.byType(MangaNavigationBar), findsNothing);
    expect(find.byType(DrawerMenuButton), findsNothing);
    await tester.pumpWidget(_app(router, const RetroTheme(false), 'en', 1));
    await _openMenu(tester);
    await tester.pumpAndSettle();
    expect(find.byType(MangaNavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
