import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';
import '../../core/theme/themes/mario64_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/player_profile_provider.dart';
import '../providers/manga_menu_audio_provider.dart';
import 'app_snackbar.dart';

const _navigationAssets = [
  'assets/themes/manga/navigation/home.webp',
  'assets/themes/manga/navigation/explore.webp',
  'assets/themes/manga/navigation/library.webp',
  'assets/themes/manga/navigation/tools.webp',
  'assets/themes/manga/navigation/more.webp',
];

typedef _Destination = ({String label, IconData icon, String route});

/// La ruta es la selección real. Deslizar solo explora las viñetas disponibles.
class MangaNavigationBar extends ConsumerStatefulWidget {
  const MangaNavigationBar({
    super.key,
    required this.currentRoute,
    this.onDestinationSelected,
    this.bottomSafeArea = true,
  });
  final VoidCallback? onDestinationSelected;
  final bool bottomSafeArea;
  final String currentRoute;

  @override
  ConsumerState<MangaNavigationBar> createState() => _MangaNavigationBarState();
}

class _MangaNavigationBarState extends ConsumerState<MangaNavigationBar> {
  // Solo se construyen las viñetas visibles; el origen permite explorar ambos lados.
  static const _origin = 1000;
  late final PageController _pages;
  bool _busy = false;

  static int _group(String route) {
    if (route == '/') return 0;
    if (const ['/catalogue', '/popular', '/favourites'].contains(route)) {
      return 1;
    }
    if (route == '/library') return 2;
    if (route == '/player' || route.startsWith('/game-tool/')) return 3;
    return 4;
  }

  @override
  void initState() {
    super.initState();
    _pages = PageController(
      initialPage: _origin + _group(widget.currentRoute),
      viewportFraction: 0.32,
      keepPage: false,
    );
  }

  @override
  void didUpdateWidget(covariant MangaNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pages.hasClients) {
          // El cambio confirmado de ruta centra su grupo, sin otra navegación.
          _pages.jumpToPage(_origin + _group(widget.currentRoute));
        }
      });
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<bool> _canLeave() async {
    if (widget.currentRoute != '/player') return true;
    final profile = ref.read(playerProfileProvider);
    if (profile.busy) return false;
    if (!profile.dirty) return true;
    final l = AppLocalizations.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.playerUnsavedTitle),
        content: Text(l.playerUnsavedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.playerKeepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.playerDiscard),
          ),
        ],
      ),
    );
    if (!mounted || discard != true) return false;
    ref.read(playerProfileProvider.notifier).reset();
    return true;
  }

  Future<void> _select(int index) async {
    if (_busy) return;
    unawaited(ref.read(mangaMenuSoundsProvider.notifier).play('press'));
    setState(() => _busy = true);
    try {
      final l = AppLocalizations.of(context);
      final route = switch (index) {
        0 => '/',
        2 => '/library',
        _ => await _showDestinations(index, l),
      };
      if (!mounted || route == null) return;
      if (route == widget.currentRoute) {
        widget.onDestinationSelected?.call();
        return;
      }
      if (!await _canLeave() || !mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      context.go(route);
      widget.onDestinationSelected?.call();
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(
          context,
          message: AppLocalizations.of(context).mangaNavError,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _showDestinations(int group, AppLocalizations l) {
    final sections = switch (group) {
      1 => [
        (
          title: l.sectionExplore,
          entries: <_Destination>[
            (
              label: l.navCatalog,
              icon: Icons.grid_view_outlined,
              route: '/catalogue',
            ),
            (label: l.navPopular, icon: Icons.trending_up, route: '/popular'),
            (
              label: l.navFavourites,
              icon: Icons.favorite_border,
              route: '/favourites',
            ),
          ],
        ),
      ],
      3 => [
        (
          title: l.gameToolTitle,
          entries: <_Destination>[
            (label: l.navPlayer, icon: Icons.person_outline, route: '/player'),
            (
              label: l.saveFileTitle,
              icon: Icons.save_outlined,
              route: '/game-tool/save-file',
            ),
            (
              label: l.romPrepareNav,
              icon: Icons.memory,
              route: '/game-tool/rom-preparer',
            ),
          ],
        ),
      ],
      _ => [
        (
          title: l.navSettings,
          entries: <_Destination>[
            (
              label: l.navSettings,
              icon: Icons.settings_outlined,
              route: '/settings',
            ),
          ],
        ),
        (
          title: l.sectionExclusive,
          entries: <_Destination>[
            (
              label: l.navRender96,
              icon: Icons.view_in_ar_outlined,
              route: '/render96',
            ),
            (
              label: l.navVIPMods,
              icon: Icons.workspace_premium_outlined,
              route: '/vip',
            ),
            (
              label: l.navDynOS,
              icon: Icons.extension_outlined,
              route: '/dynos',
            ),
            (
              label: l.navTouchControls,
              icon: Icons.gamepad_outlined,
              route: '/touch-controls',
            ),
            (
              label: l.navOmmRebirth,
              icon: Icons.folder_zip_outlined,
              route: '/omm-rebirth',
            ),
          ],
        ),
        (
          title: l.drawerResources,
          entries: <_Destination>[
            (
              label: l.playGuideTitle,
              icon: Icons.menu_book_outlined,
              route: '/how-to-play',
            ),
            (
              label: l.navLinksResource,
              icon: Icons.link,
              route: '/links-resource',
            ),
            (
              label: l.navDisclaimer,
              icon: Icons.info_outline,
              route: '/disclaimer',
            ),
          ],
        ),
      ],
    };
    final retro = RetroTheme.of(context);
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: retro.background,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: retro.radius,
        side: BorderSide(color: retro.border, width: retro.borderWidth(2)),
      ),
      builder: (context) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: CloseButton(onPressed: () => Navigator.pop(context)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  for (final section in sections) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        section.title,
                        style: retro.heading(size: 16),
                      ),
                    ),
                    for (final destination in section.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: retro.surfaceDecoration(
                              color: destination.route == widget.currentRoute
                                  ? retro.accent
                                  : retro.surface,
                              shadowDx: 2,
                              shadowDy: 2,
                            ),
                            child: ListTile(
                              key: ValueKey('manga-route-${destination.route}'),
                              selected:
                                  destination.route == widget.currentRoute,
                              textColor: retro.ink,
                              iconColor: retro.ink,
                              selectedColor: retro.onColor(retro.accent),
                              leading: Icon(destination.icon),
                              title: Text(destination.label),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                unawaited(ref.read(mangaMenuSoundsProvider.notifier).play('press'));
                                Navigator.pop(context, destination.route);
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    final entries = [
      (label: l.navHome, icon: Icons.home_outlined),
      (label: l.mangaNavExplore, icon: Icons.explore_outlined),
      (label: l.mangaNavLibrary, icon: Icons.inventory_2_outlined),
      (label: l.mangaNavTools, icon: Icons.sports_esports_outlined),
      (label: l.mangaNavMore, icon: Icons.dashboard_outlined),
    ];
    final scaledLabelSize = MediaQuery.textScalerOf(context).scale(11);
    final labelHeight = scaledLabelSize * (scaledLabelSize > 14.3 ? 2.6 : 1.3);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final selected = _group(widget.currentRoute);
    final foreground = retro.onColor(retro.background);
    return Material(
      key: const ValueKey('manga-navigation'),
      color: retro.background.withValues(alpha: 0.85),
      child: SafeArea(
        top: false,
        bottom: widget.bottomSafeArea,
        child: Stack(
          children: [
            SizedBox(
              // Siluetas flotantes; solo el texto accesible aumenta la altura.
              height: (34 + labelHeight)
                  .clamp(48.0, double.infinity)
                  .toDouble(),
              child: Semantics(
                hint: l.mangaNavHint,
                child: PageView.custom(
                  key: const ValueKey('manga-navigation-pages'),
                  controller: _pages,
                  onPageChanged: (_) {
                    if (_pages.position.isScrollingNotifier.value) {
                      unawaited(ref.read(mangaMenuSoundsProvider.notifier).play('slide'));
                    }
                  },
                  clipBehavior: Clip.none,
                  childrenDelegate: SliverChildBuilderDelegate((context, page) {
                    final index = page % entries.length;
                    final item = entries[index];
                    return AnimatedBuilder(
                      animation: _pages,
                      builder: (context, child) {
                        final position =
                            _pages.hasClients &&
                                _pages.position.hasContentDimensions
                            ? _pages.page ?? _pages.initialPage.toDouble()
                            : _pages.initialPage.toDouble();
                        // El centro visual sigue el dedo sin cambiar de ruta.
                        final focus = reduceMotion
                            ? (position.round() == page ? 1.0 : 0.0)
                            : (1 - (position - page).abs())
                                  .clamp(0.0, 1.0)
                                  .toDouble();
                        return _MangaNavigationTile(
                          index: index,
                          label: item.label,
                          icon: item.icon,
                          asset: _navigationAssets[index],
                          foreground: foreground,
                          selected: index == selected,
                          focus: focus,
                          labelHeight: labelHeight,
                          onTap: _busy ? null : () => unawaited(_select(index)),
                        );
                      },
                    );
                  }, addSemanticIndexes: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MangaNavigationTile extends StatelessWidget {
  const _MangaNavigationTile({
    required this.index,
    required this.label,
    required this.icon,
    required this.asset,
    required this.foreground,
    required this.selected,
    required this.focus,
    required this.labelHeight,
    required this.onTap,
  });

  final int index;
  final String label, asset;
  final IconData icon;
  final Color foreground;
  final bool selected;
  final double focus;
  final double labelHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('manga-nav-$index'),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        if (focus > 0.01)
                          Positioned(
                            bottom: 2,
                            child: DecoratedBox(
                              key: ValueKey('manga-nav-halo-$index'),
                              decoration: BoxDecoration(
                                color: retro.accent.withValues(
                                  alpha: 0.38 * focus,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.elliptical(12, 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: retro.accent.withValues(
                                      alpha: 0.65 * focus,
                                    ),
                                    blurRadius: 6,
                                    spreadRadius: 1.5 * focus,
                                  ),
                                ],
                              ),
                              child: const SizedBox(width: 34, height: 8),
                            ),
                          ),
                        Transform.translate(
                          // Crece hacia arriba para no cubrir la etiqueta.
                          offset: Offset(0, -11 * focus),
                          child: AnimatedScale(
                            key: ValueKey('manga-nav-visual-$index'),
                            scale: 0.62 + 1.38 * focus,
                            curve: Curves.easeOutCubic,
                            // El desplazamiento ya interpola cada fotograma.
                            duration: Duration.zero,
                            child: RepaintBoundary(
                              child: Image.asset(
                                asset,
                                key: ValueKey('manga-nav-image-$index'),
                                width: 26,
                                height: 26,
                                // Decodificación acotada y compartida por ImageCache.
                                cacheWidth: 256,
                                cacheHeight: 256,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                                excludeFromSemantics: true,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(icon, size: 24, color: foreground),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: labelHeight,
                    child: Center(
                      child: _MangaNavigationLabel(
                        index: index,
                        label: retro.displayLabel(label),
                        selected: selected,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tipografía Mario limitada a los cinco accesos del carrusel.
class _MangaNavigationLabel extends StatelessWidget {
  const _MangaNavigationLabel({
    required this.index,
    required this.label,
    required this.selected,
  });

  final int index;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final enlarged = MediaQuery.textScalerOf(context).scale(11) > 14.3;
    // Solo separar palabras completas; nunca dejar la E de EXPLORE sola.
    final wrap = enlarged && label.contains(' ');
    const fill = Color(0xFFFFD83D);
    final bubbleColor = retro.isDark
        ? const Color(0xFF2387FF)
        : const Color(0xFFE53935);
    // El borde oscuro conserva la silueta del amarillo sobre la burbuja.
    const outline = Colors.black;
    final style = TextStyle(
      fontFamily: mario64Theme.headingFontFamily,
      fontFamilyFallback: mario64Theme.headingFontFamilyFallback,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.2,
    );
    final lettering = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Text(
          label,
          key: ValueKey('manga-nav-label-outline-$index'),
          maxLines: wrap ? 2 : 1,
          softWrap: wrap,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..strokeJoin = StrokeJoin.round
              ..color = outline,
          ),
        ),
        Text(
          label,
          key: ValueKey('manga-nav-label-fill-$index'),
          maxLines: wrap ? 2 : 1,
          softWrap: wrap,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          style: style.copyWith(
            color: fill,
            decoration: selected ? TextDecoration.underline : null,
            decorationColor: retro.accent,
            decorationThickness: 2,
          ),
        ),
      ],
    );
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        key: ValueKey('manga-nav-label-bubble-$index'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withValues(alpha: retro.isDark ? 0.22 : 0.7),
            width: 0.7,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // 65 % transparente: alfa 0.35 también en los reflejos.
              Color.lerp(
                bubbleColor,
                Colors.white,
                0.22,
              )!.withValues(alpha: 0.35),
              bubbleColor.withValues(alpha: 0.35),
              Color.lerp(
                bubbleColor,
                Colors.black,
                0.08,
              )!.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0.5),
          child: LayoutBuilder(
            builder: (context, constraints) => FittedBox(
              key: ValueKey('manga-nav-label-fit-$index'),
              fit: BoxFit.scaleDown,
              child: wrap
                  ? SizedBox(width: constraints.maxWidth, child: lettering)
                  : lettering,
            ),
          ),
        ),
      ),
    );
  }
}
