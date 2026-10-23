import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/category_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/providers/mod_providers.dart';
import '../../presentation/providers/extra_providers.dart';
import '../../services/update_service.dart';

const Duration _kItemDuration = Duration(milliseconds: 150);
const Duration _kNavDelay = Duration.zero;
const Curve _kCurve = Curves.easeOutCubic;

void _navigateTo(BuildContext context, String route) {
  Navigator.of(context).pop();
  if (context.mounted) context.go(route);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDrawer
// ─────────────────────────────────────────────────────────────────────────────
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentRoute = ref.watch(currentRouteProvider);

    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.86).clamp(280.0, 340.0),
      backgroundColor: retro.background,
      elevation: 0,
      shape: Border(
        right: BorderSide(color: retro.border, width: retro.borderWidth(2)),
      ),
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: DecoratedBox(
          decoration: retro.surfaceDecoration(shadowDx: 0, shadowDy: 0),
          child: SingleChildScrollView(
            controller: widget.scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DrawerHeader(),
                _RetroDivider(retro: retro),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
                  child: Text(
                    l10n.sectionNavigation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: retro
                        .body(size: 11, color: retro.inkDim)
                        .copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                  ),
                ),

                _NavItem(
                  retroIconAsset: 'm64',
                  iconBuilder: (color) => MarioGameIcon(
                    Icons.home_outlined,
                    size: 22,
                    color: color,
                  ),
                  isTopLevel: true,
                  label: l10n.navHome,
                  route: '/',
                  isActive: currentRoute == '/',
                ),
                _DrawerGroup(
                  key: const PageStorageKey('explore-drawer'),
                  title: l10n.sectionExplore,
                  icon: Icons.explore_outlined,
                  activeRoute:
                      const [
                        '/catalogue',
                        '/popular',
                        '/favourites',
                      ].contains(currentRoute)
                      ? currentRoute
                      : null,
                  children: [
                    _NavItem(
                      retroIconAsset: 'catalog',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.grid_view_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navCatalog,
                      route: '/catalogue',
                      isActive: currentRoute == '/catalogue',
                    ),
                    _NavItem(
                      retroIconAsset: 'popular',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.trending_up,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navPopular,
                      route: '/popular',
                      isActive: currentRoute == '/popular',
                    ),
                    _NavItem(
                      retroIconAsset: 'favorites',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.favorite_border,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navFavourites,
                      route: '/favourites',
                      isActive: currentRoute == '/favourites',
                    ),
                  ],
                ),
                _DrawerGroup(
                  key: const PageStorageKey('game-tool-drawer'),
                  title: l10n.gameToolTitle,
                  icon: Icons.sports_esports_outlined,
                  activeRoute:
                      (currentRoute.startsWith('/game-tool/') &&
                              currentRoute != '/game-tool/play-2p2') ||
                          currentRoute == '/library' ||
                          currentRoute == '/player'
                      ? currentRoute
                      : null,
                  children: [
                    _NavItem(
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.inventory_2_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navLibrary,
                      route: '/library',
                      isActive: currentRoute == '/library',
                    ),
                    _NavItem(
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.person_outline_rounded,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navPlayer,
                      route: '/player',
                      isActive: currentRoute == '/player',
                    ),

                    _NavItem(
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.save_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.saveFileTitle,
                      route: '/game-tool/save-file',
                      isActive: currentRoute == '/game-tool/save-file',
                    ),
                    _NavItem(
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.memory_rounded,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.romPrepareNav,
                      route: '/game-tool/rom-preparer',
                      isActive: currentRoute == '/game-tool/rom-preparer',
                    ),
                  ],
                ),
                _NavItem(
                  retroIconPath: 'assets/themes/manga/navigation/play.webp',
                  iconBuilder: (color) => MarioGameIcon(
                    Icons.sports_esports_outlined,
                    size: 22,
                    color: color,
                  ),
                  isTopLevel: true,
                  label: l10n.coopNav,
                  route: '/game-tool/play-2p2',
                  isActive: currentRoute == '/game-tool/play-2p2',
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                  child: _RetroDivider(retro: retro),
                ),
                _DrawerGroup(
                  key: const PageStorageKey('exclusive-drawer'),
                  title: l10n.sectionExclusive,
                  icon: Icons.collections_bookmark_outlined,
                  activeRoute:
                      const [
                        '/render96',
                        '/vip',
                        '/dynos',
                        '/touch-controls',
                        '/omm-rebirth',
                      ].contains(currentRoute)
                      ? currentRoute
                      : null,
                  children: [
                    _NavItem(
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.view_in_ar_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navRender96,
                      route: '/render96',
                      isActive: currentRoute == '/render96',
                      accentColor: retro.amber,
                    ),
                    _NavItem(
                      retroIconAsset: 'vip',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.workspace_premium_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navVIPMods,
                      route: '/vip',
                      isActive: currentRoute == '/vip',
                      accentColor: retro.amber,
                    ),
                    _NavItem(
                      retroIconAsset: 'dynos',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.extension_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navDynOS,
                      route: '/dynos',
                      isActive: currentRoute == '/dynos',
                      accentColor: retro.blue,
                    ),
                    _NavItem(
                      retroIconAsset: 'controls',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.gamepad_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navTouchControls,
                      route: '/touch-controls',
                      isActive: currentRoute == '/touch-controls',
                    ),
                    _NavItem(
                      retroIconAsset: 'omm',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.sports_esports_outlined,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navOmmRebirth,
                      route: '/omm-rebirth',
                      isActive: currentRoute == '/omm-rebirth',
                      accentColor: retro.red,
                    ),
                  ],
                ),

                // Footer
                _RetroDivider(retro: retro),
                _DrawerGroup(
                  key: const PageStorageKey('resources-drawer'),
                  title: l10n.drawerResources,
                  icon: Icons.help_outline_rounded,
                  activeRoute:
                      const [
                        '/how-to-play',
                        '/links-resource',
                        '/disclaimer',
                      ].contains(currentRoute)
                      ? currentRoute
                      : null,
                  children: [
                    _NavItem(
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.menu_book_rounded,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.playGuideTitle,
                      route: '/how-to-play',
                      isActive: currentRoute == '/how-to-play',
                    ),
                    _NavItem(
                      retroIconAsset: 'links-resource',
                      iconBuilder: (color) =>
                          MarioGameIcon(Icons.link, size: 19, color: color),
                      label: l10n.navLinksResource,
                      route: '/links-resource',
                      isActive: currentRoute == '/links-resource',
                    ),
                    _NavItem(
                      retroIconAsset: 'disclaimer',
                      iconBuilder: (color) => MarioGameIcon(
                        Icons.info_outline,
                        size: 19,
                        color: color,
                      ),
                      label: l10n.navDisclaimer,
                      route: '/disclaimer',
                      isActive: currentRoute == '/disclaimer',
                    ),
                  ],
                ),
                _RetroDivider(retro: retro),
                _NavItem(
                  retroIconAsset: 'settings',
                  iconBuilder: (color) => MarioGameIcon(
                    Icons.settings_outlined,
                    size: 22,
                    color: color,
                  ),
                  isTopLevel: true,
                  label: l10n.navSettings,
                  route: '/settings',
                  isActive: currentRoute == '/settings',
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 0, 14),
                  child: Text(
                    'v${UpdateService.currentVersion}',
                    style: TextStyle(
                      color: retro.inkDim,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
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

/// Expansion is local navigation state, retained independently per group for
/// this drawer's PageStorage lifetime. Entering a child route reveals its group.
class _DrawerGroup extends StatefulWidget {
  const _DrawerGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.activeRoute,
    required this.children,
  });
  final String title;
  final IconData icon;
  final String? activeRoute;
  final List<Widget> children;

  @override
  State<_DrawerGroup> createState() => _DrawerGroupState();
}

class _DrawerGroupState extends State<_DrawerGroup> {
  bool _expanded = false;
  bool _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;
    final saved = PageStorage.maybeOf(context)?.readState(context);
    _expanded = widget.activeRoute != null || saved == true;
  }

  @override
  void didUpdateWidget(covariant _DrawerGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeRoute != null &&
        widget.activeRoute != oldWidget.activeRoute) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final active = widget.activeRoute != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          selected: active,
          expanded: _expanded,
          child: InkWell(
            onTap: () {
              setState(() => _expanded = !_expanded);
              PageStorage.maybeOf(context)?.writeState(context, _expanded);
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: active && retro.usesComicSurfaces
                  ? retro.surfaceDecoration(
                      color: retro.surfaceAlt,
                      borderColor: retro.accentText,
                      border: 2,
                      shadowDx: 3,
                      shadowDy: 3,
                    )
                  : BoxDecoration(
                      color: active ? retro.surfaceAlt : Colors.transparent,
                      borderRadius: retro.radius,
                      border: active
                          ? Border.all(color: retro.accentText, width: 1)
                          : null,
                    ),
              child: Row(
                children: [
                  MarioGameIcon(
                    widget.icon,
                    color: active ? retro.accentText : retro.inkDim,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: retro.heading(
                        size: 15,
                        color: active ? retro.accentText : retro.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ExpandArrow(expanded: _expanded, retro: retro),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: _kCurve,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 6),
                  child: Column(children: widget.children),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RetroDivider — línea sólida, sin gradientes.
// ─────────────────────────────────────────────────────────────────────────────
class _RetroDivider extends StatelessWidget {
  const _RetroDivider({required this.retro});
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(height: 2, color: retro.border);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/logo.png',
            width: 44,
            height: 44,
            cacheWidth: 88,
            cacheHeight: 88,
            filterQuality: FilterQuality.low,
            excludeFromSemantics: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SM64', style: retro.heading(size: 16, color: retro.ink)),
                Text(
                  'CoopDX',
                  style: retro.heading(size: 16, color: retro.accentText),
                ),
                if (retro.showJapaneseDecorations) ...[
                  const SizedBox(height: 3),
                  Text('モッド・カタログ', style: retro.body(size: 10.5)),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            icon: MarioGameIcon(
              Icons.close_rounded,
              color: retro.inkDim,
              size: 22,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NavItem — estado activo = relleno sólido de acento + texto invertido.
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconBuilder,
    required this.label,
    required this.route,
    required this.isActive,
    this.accentColor,
    this.retroIconAsset,
    this.retroIconPath,
    this.isTopLevel = false,
  });

  final Widget Function(Color color) iconBuilder;
  final String label;
  final String route;
  final bool isActive;
  final Color? accentColor;
  final String? retroIconAsset;
  final String? retroIconPath;
  final bool isTopLevel;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final accent = accentColor ?? retro.accent;
    final minimal = retro.usesMinimalSurfaces;
    final fg = isActive
        ? (minimal ? accent : retro.onColor(accent))
        : retro.ink;

    return Semantics(
      button: true,
      selected: isActive,
      child: InkWell(
        onTap: isActive
            ? () => Navigator.of(context).pop()
            : () => _navigateTo(context, route),
        child: Container(
          constraints: BoxConstraints(minHeight: isTopLevel ? 52 : 48),
          margin: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: isTopLevel ? 2 : 1,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: isTopLevel ? 12 : 0,
          ),
          decoration: isActive && retro.usesComicSurfaces
              ? retro.surfaceDecoration(
                  color: accent,
                  borderColor: retro.border,
                  border: 2,
                  shadowDx: 3,
                  shadowDy: 3,
                )
              : BoxDecoration(
                  border: minimal && isActive
                      ? Border(left: BorderSide(color: accent, width: 2))
                      : null,
                  borderRadius: minimal ? null : retro.radius,
                  color: isActive && !minimal ? accent : Colors.transparent,
                ),
          child: Row(
            children: [
              if (!minimal) ...[
                SizedBox(
                  width: 22,
                  height: 22,
                  child:
                      retro.design.drawerRasterIcons &&
                          (retroIconPath != null || retroIconAsset != null)
                      ? Image.asset(
                          retroIconPath ??
                              'assets/icons/menu/$retroIconAsset.png',
                          width: 22,
                          height: 22,
                          cacheWidth: 64,
                          cacheHeight: 64,
                          filterQuality: FilterQuality.low,
                          gaplessPlayback: true,
                          excludeFromSemantics: true,
                        )
                      : Center(child: iconBuilder(fg)),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  label,
                  style: isTopLevel
                      ? retro.heading(size: 15, color: fg)
                      : retro
                            .body(size: 14, color: fg)
                            .copyWith(
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CategoryList — expandible perezoso.
// Los _CategoryItem (c/u con su AnimationController) NO se crean hasta que
// el usuario expande la sección. Esto evita N controladores en el frame de
// apertura del drawer.
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryList extends ConsumerStatefulWidget {
  const _CategoryList();

  @override
  ConsumerState<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<_CategoryList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (retro.design.drawerRasterIcons)
                  Image.asset(
                    'assets/icons/menu/categorias.png',
                    width: 22,
                    height: 22,
                    cacheWidth: 64,
                    cacheHeight: 64,
                    filterQuality: FilterQuality.low,
                    excludeFromSemantics: true,
                  )
                else
                  MarioGameIcon(
                    Icons.category_outlined,
                    size: 19,
                    color: retro.inkDim,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.sectionCategories,
                    style: TextStyle(
                      color: retro.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                _ExpandArrow(expanded: _expanded, retro: retro),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: _kCurve,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: _expanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: CategoryConstants.allCategories
                      .map(
                        (cat) => _CategoryItem(
                          category: cat,
                          selectedCategory: selectedCategory,
                        ),
                      )
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CategoryItem — una categoría individual tappeable.
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryItem extends ConsumerStatefulWidget {
  const _CategoryItem({required this.category, required this.selectedCategory});

  final String category;
  final String? selectedCategory;

  @override
  ConsumerState<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends ConsumerState<_CategoryItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final currentRoute = ref.watch(currentRouteProvider);
    final isSelected = widget.selectedCategory == widget.category;
    final icon = CategoryConstants.getIconForCategory(widget.category);
    final catColor = CategoryConstants.getColorForCategory(widget.category);
    final minimal = retro.usesMinimalSurfaces;
    final selectedForeground = minimal ? catColor : retro.onColor(catColor);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        Navigator.of(context).pop();
        final notifier = ref.read(selectedCategoryProvider.notifier);
        if (isSelected) {
          notifier.clear();
        } else {
          notifier.setCategory(widget.category);
          ref.read(currentPageProvider.notifier).setPage(0);
          ref.read(searchQueryProvider.notifier).clear();
        }
        if (currentRoute != '/catalogue') {
          Future.delayed(_kNavDelay, () {
            if (context.mounted) context.go('/catalogue');
          });
        }
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: _kItemDuration,
          curve: _kCurve,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: retro.gameDecoration(
            BoxDecoration(
              borderRadius: retro.radius,
              color: isSelected && !minimal ? catColor : Colors.transparent,
              border: isSelected && !minimal
                  ? Border.all(
                      color: retro.border,
                      width: retro.borderWidth(1.5),
                    )
                  : null,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                color: isSelected ? selectedForeground : catColor,
              ),
              const SizedBox(width: 10),
              MarioGameIcon(
                icon,
                size: 15,
                color: isSelected ? selectedForeground : catColor,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: _kItemDuration,
                  curve: _kCurve,
                  style: TextStyle(
                    color: isSelected ? selectedForeground : retro.inkDim,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  child: Text(
                    CategoryConstants.displayName(context, widget.category),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: _kItemDuration,
                opacity: isSelected ? 1.0 : 0.0,
                child: MarioGameIcon(
                  Icons.check,
                  size: 14,
                  color: selectedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SortOptions — expandible perezoso (mismo patrón que _CategoryList).
// ─────────────────────────────────────────────────────────────────────────────
class _SortOptions extends ConsumerStatefulWidget {
  const _SortOptions();

  @override
  ConsumerState<_SortOptions> createState() => _SortOptionsState();
}

class _SortOptionsState extends ConsumerState<_SortOptions> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final currentSort = ref.watch(sortOrderProvider);
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    final sortItems = [
      (value: SortOrder.none, label: l10n.sortDefault),
      (value: SortOrder.ratingDesc, label: l10n.sortRating),
      (value: SortOrder.downloadsDesc, label: l10n.sortDownloads),
      (value: SortOrder.newest, label: l10n.sortNewest),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                MarioGameIcon(Icons.sort, size: 19, color: retro.inkDim),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.sectionSortBy,
                    style: TextStyle(
                      color: retro.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                _ExpandArrow(expanded: _expanded, retro: retro),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: _kCurve,
          alignment: Alignment.topCenter,
          clipBehavior: Clip.hardEdge,
          child: _expanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: sortItems
                      .map(
                        (item) => _SortItem(
                          value: item.value,
                          label: item.label,
                          currentSort: currentSort,
                        ),
                      )
                      .toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SortItem — una opción de ordenamiento individual tappeable.
// ─────────────────────────────────────────────────────────────────────────────
class _SortItem extends ConsumerStatefulWidget {
  const _SortItem({
    required this.value,
    required this.label,
    required this.currentSort,
  });

  final SortOrder value;
  final String label;
  final SortOrder currentSort;

  @override
  ConsumerState<_SortItem> createState() => _SortItemState();
}

class _SortItemState extends ConsumerState<_SortItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final currentRoute = ref.watch(currentRouteProvider);
    final isSelected = widget.currentSort == widget.value;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        Navigator.of(context).pop();
        ref.read(sortOrderProvider.notifier).setSortOrder(widget.value);
        ref.read(currentPageProvider.notifier).setPage(0);
        if (currentRoute != '/catalogue') {
          Future.delayed(_kNavDelay, () {
            if (context.mounted) context.go('/catalogue');
          });
        }
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: _kItemDuration,
          curve: _kCurve,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: retro.gameDecoration(
            BoxDecoration(
              borderRadius: retro.radius,
              color: isSelected ? retro.accent : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: retro.border,
                      width: retro.borderWidth(1.5),
                    )
                  : null,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: _kItemDuration,
                  curve: _kCurve,
                  style: TextStyle(
                    color: isSelected ? retro.inkOnAccent : retro.inkDim,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  child: Text(widget.label),
                ),
              ),
              AnimatedOpacity(
                duration: _kItemDuration,
                opacity: isSelected ? 1.0 : 0.0,
                child: MarioGameIcon(
                  Icons.check,
                  size: 14,
                  color: retro.inkOnAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ExpandArrow — flecha rotatoria compartida.
// ─────────────────────────────────────────────────────────────────────────────
class _ExpandArrow extends StatelessWidget {
  const _ExpandArrow({required this.expanded, required this.retro});
  final bool expanded;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return AnimatedRotation(
      turns: expanded ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: _kCurve,
      child: MarioGameIcon(
        Icons.expand_more,
        size: 20,
        color: expanded ? retro.accentText : retro.inkDim,
      ),
    );
  }
}
