import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/player_profile_provider.dart';
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
  const MangaNavigationBar({super.key, required this.currentRoute});
  final String currentRoute;

  @override
  ConsumerState<MangaNavigationBar> createState() => _MangaNavigationBarState();
}

class _MangaNavigationBarState extends ConsumerState<MangaNavigationBar> {
  // Solo se construyen las viñetas visibles; el origen permite explorar ambos lados.
  static const _origin = 1000;
  late final PageController _pages;
  late int _focused;
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
    _focused = _group(widget.currentRoute);
    _pages = PageController(
      initialPage: _origin + _focused,
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
    setState(() => _busy = true);
    try {
      final l = AppLocalizations.of(context);
      final route = switch (index) {
        0 => '/',
        2 => '/library',
        _ => await _showDestinations(index, l),
      };
      if (!mounted || route == null || route == widget.currentRoute) return;
      if (!await _canLeave() || !mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      context.go(route);
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
                              onTap: () =>
                                  Navigator.pop(context, destination.route),
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
      (label: l.sectionExplore, icon: Icons.explore_outlined),
      (label: l.navLibrary, icon: Icons.inventory_2_outlined),
      (label: l.gameToolTitle, icon: Icons.sports_esports_outlined),
      (label: l.mangaNavMore, icon: Icons.dashboard_outlined),
    ];
    final labelHeight = MediaQuery.textScalerOf(context).scale(11) * 2.6;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final selected = _group(widget.currentRoute);
    return Material(
      key: const ValueKey('manga-navigation'),
      color: retro.background,
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: HalftoneBackground(
                color: retro.ink.withValues(alpha: 0.035),
              ),
            ),
            SizedBox(
              // Siluetas flotantes; solo el texto accesible aumenta la altura.
              height: 80 + labelHeight,
              child: Semantics(
                hint: l.mangaNavHint,
                child: PageView.custom(
                  key: const ValueKey('manga-navigation-pages'),
                  controller: _pages,
                  onPageChanged: (index) => setState(
                    () => _focused = index % entries.length,
                  ),
                  childrenDelegate: SliverChildBuilderDelegate((context, page) {
                    final index = page % entries.length;
                    final item = entries[index];
                    return _MangaNavigationTile(
                      index: index,
                      label: item.label,
                      icon: item.icon,
                      asset: _navigationAssets[index],
                      selected: index == selected,
                      focused: index == _focused,
                      labelHeight: labelHeight,
                      reduceMotion: reduceMotion,
                      onTap: _busy ? null : () => unawaited(_select(index)),
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
    required this.selected,
    required this.focused,
    required this.labelHeight,
    required this.reduceMotion,
    required this.onTap,
  });

  final int index;
  final String label, asset;
  final IconData icon;
  final bool selected, focused, reduceMotion;
  final double labelHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('manga-nav-$index'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 64,
                  child: AnimatedScale(
                    key: ValueKey('manga-nav-visual-$index'),
                    scale: selected ? 1 : (focused ? 0.86 : 0.74),
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 160),
                    child: RepaintBoundary(
                      child: Image.asset(
                        asset,
                        key: ValueKey('manga-nav-image-$index'),
                        width: 64,
                        height: 64,
                        // Decodificación acotada y compartida por ImageCache.
                        cacheWidth: 256,
                        cacheHeight: 256,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        excludeFromSemantics: true,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          icon,
                          size: 36,
                          color: retro.ink,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  height: labelHeight,
                  child: Center(
                    child: Text(
                      retro.displayLabel(label),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: retro.body(size: 11, color: retro.ink).copyWith(
                        fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                        decoration: selected ? TextDecoration.underline : null,
                        decorationColor: retro.accent,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
