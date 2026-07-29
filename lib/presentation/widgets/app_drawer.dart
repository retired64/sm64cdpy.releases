import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../presentation/providers/mod_providers.dart';
import '../../presentation/providers/extra_providers.dart';
import '../../services/update_service.dart';

const Duration _kItemDuration = Duration(milliseconds: 150);
const Duration _kNavDelay = Duration(milliseconds: 260);
const Curve _kCurve = Curves.easeOutCubic;

void _navigateTo(BuildContext context, String route) {
  Navigator.of(context).pop();
  Future.delayed(_kNavDelay, () {
    if (context.mounted) context.go(route);
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// AppDrawer
// ─────────────────────────────────────────────────────────────────────────────
class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

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
      backgroundColor: retro.background,
      elevation: 0,
      shape: Border(right: BorderSide(color: retro.border, width: 3)),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DrawerHeader(),
              _RetroDivider(retro: retro),
              const SizedBox(height: 4),

              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/m64.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navHome, route: '/',
                isActive: currentRoute == '/',
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/catalog.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navCatalog, route: '/catalogue',
                isActive: currentRoute == '/catalogue',
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/favorites.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navFavourites, route: '/favourites',
                isActive: currentRoute == '/favourites',
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/popular.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navPopular, route: '/popular',
                isActive: currentRoute == '/popular',
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                child: _RetroDivider(retro: retro),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                child: SectionKicker(retro: retro, label: l10n.sectionExclusive),
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/vip.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navVIPMods, route: '/vip',
                isActive: currentRoute == '/vip',
                accentColor: retro.amber,
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/dynos.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navDynOS, route: '/dynos',
                isActive: currentRoute == '/dynos',
                accentColor: retro.blue,
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/controls.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navTouchControls, route: '/touch-controls',
                isActive: currentRoute == '/touch-controls',
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/omm.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navOmmRebirth, route: '/omm-rebirth',
                isActive: currentRoute == '/omm-rebirth',
                accentColor: retro.red,
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                child: _RetroDivider(retro: retro),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                child: SectionKicker(retro: retro, label: l10n.sectionExplore),
              ),
              _CategoryList(),
              _SortOptions(),

              // Footer
              _RetroDivider(retro: retro),
              const _SocialLinks(),
              _RetroDivider(retro: retro),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/links-resource.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navLinksResource, route: '/links-resource',
                isActive: currentRoute == '/links-resource',
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/disclaimer.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navDisclaimer, route: '/disclaimer',
                isActive: currentRoute == '/disclaimer',
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/changelogs.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navChangelog, route: '/changelog',
                isActive: currentRoute == '/changelog',
              ),
              _NavItem(
                iconBuilder: (color) => SvgPicture.asset(
                  'assets/icons/menu/settings.svg',
                  width: 19, height: 19,
                ),
                label: l10n.navSettings, route: '/settings',
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: retro.surface,
              border: Border.all(color: retro.border, width: 2.5),
              boxShadow: retro.hardShadow(dx: 3, dy: 3),
            ),
            child: RepaintBoundary(
              child: SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SM64', style: retro.heading(size: 16, color: retro.ink)),
                Text('CoopDX', style: retro.heading(size: 16, color: retro.accent)),
                const SizedBox(height: 3),
                Text('モッド・カタログ', style: retro.body(size: 10.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NavItem — estado activo = relleno sólido de acento + texto invertido.
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.iconBuilder,
    required this.label,
    required this.route,
    required this.isActive,
    this.accentColor,
  });

  final Widget Function(Color color) iconBuilder;
  final String label;
  final String route;
  final bool isActive;
  final Color? accentColor;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
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
      end: 0.965,
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
    final accent = widget.accentColor ?? retro.accent;
    final fg = widget.isActive ? retro.background : retro.inkDim;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.isActive
            ? Navigator.of(context).pop()
            : _navigateTo(context, widget.route);
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: _kItemDuration,
          curve: _kCurve,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          decoration: BoxDecoration(
            color: widget.isActive ? accent : Colors.transparent,
            border: widget.isActive ? Border.all(color: retro.border, width: 2) : null,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: _kItemDuration,
                curve: _kCurve,
                width: 3,
                height: widget.isActive ? 26 : 0,
                color: widget.isActive ? retro.background : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 19,
                        height: 19,
                        // RepaintBoundary: el SVG se cachea como textura y en
                        // el scroll del drawer solo se recompone (barato) en
                        // vez de volver a ejecutar los draw calls vectoriales
                        // en cada frame (caro, sobre todo en gama baja).
                        child: RepaintBoundary(
                          child: widget.iconBuilder(fg),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedDefaultTextStyle(
                        duration: _kItemDuration,
                        curve: _kCurve,
                        style: TextStyle(
                          color: fg,
                          fontSize: 13.5,
                          fontWeight: widget.isActive
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                        child: Text(widget.label),
                      ),
                    ],
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
                RepaintBoundary(
                  child: SvgPicture.asset(
                    'assets/icons/menu/categorias.svg',
                    width: 19,
                    height: 19,
                  ),
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
                      .map((cat) => _CategoryItem(
                            category: cat,
                            selectedCategory: selectedCategory,
                          ))
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
  const _CategoryItem({
    required this.category,
    required this.selectedCategory,
  });

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
          decoration: BoxDecoration(
            color: isSelected ? catColor : Colors.transparent,
            border: isSelected ? Border.all(color: retro.border, width: 1.5) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                color: isSelected ? retro.background : catColor,
              ),
              const SizedBox(width: 10),
              Icon(
                icon,
                size: 15,
                color: isSelected ? retro.background : catColor,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: _kItemDuration,
                  curve: _kCurve,
                  style: TextStyle(
                    color: isSelected ? retro.background : retro.inkDim,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  child: Text(CategoryConstants.displayName(context, widget.category)),
                ),
              ),
              AnimatedOpacity(
                duration: _kItemDuration,
                opacity: isSelected ? 1.0 : 0.0,
                child: Icon(Icons.check, size: 14, color: retro.background),
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
                Icon(Icons.sort, size: 19, color: retro.inkDim),
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
                      .map((item) => _SortItem(
                            value: item.value,
                            label: item.label,
                            currentSort: currentSort,
                          ))
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
          decoration: BoxDecoration(
            color: isSelected ? retro.accent : Colors.transparent,
            border: isSelected ? Border.all(color: retro.border, width: 1.5) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: _kItemDuration,
                  curve: _kCurve,
                  style: TextStyle(
                    color: isSelected ? retro.background : retro.inkDim,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  child: Text(widget.label),
                ),
              ),
              AnimatedOpacity(
                duration: _kItemDuration,
                opacity: isSelected ? 1.0 : 0.0,
                child: Icon(Icons.check, size: 14, color: retro.background),
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
    return AnimatedRotation(
      turns: expanded ? 0.5 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: _kCurve,
      child: Icon(
        Icons.expand_more,
        size: 20,
        color: expanded ? retro.accent : retro.inkDim,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Links
// ─────────────────────────────────────────────────────────────────────────────
class _SocialLinks extends StatelessWidget {
  const _SocialLinks();

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    final links = [
      _SocialLinkData(
        asset: 'assets/icons/youtube.svg',
        url: AppConstants.youtubeUrl,
        tooltip: l10n.socialYouTube,
      ),
      _SocialLinkData(
        asset: 'assets/icons/discord.svg',
        url: AppConstants.discordUrl,
        tooltip: l10n.socialDiscord,
      ),
      _SocialLinkData(
        asset: 'assets/icons/github.svg',
        url: AppConstants.githubUrl,
        tooltip: l10n.socialGitHub,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionKicker(retro: retro, label: l10n.sectionSocialLinks),
          const SizedBox(height: 10),
          Row(
            children: links
                .map(
                  (link) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SocialButton(link: link),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SocialLinkData {
  const _SocialLinkData({
    required this.asset,
    required this.url,
    required this.tooltip,
  });

  final String asset;
  final String url;
  final String tooltip;
}

class _SocialButton extends StatefulWidget {
  const _SocialButton({required this.link});
  final _SocialLinkData link;

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Future<void> _launch() async {
    final uri = Uri.parse(widget.link.url);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Tooltip(
      message: widget.link.tooltip,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapCancel: () => _pressCtrl.reverse(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          _launch();
        },
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: retro.surfaceAlt,
              border: Border.all(color: retro.border, width: 2),
            ),
            child: Center(
              child: RepaintBoundary(
                child: SvgPicture.asset(
                  widget.link.asset,
                  width: 20,
                  height: 20,
                  colorFilter: retro.isDark && widget.link.asset.contains('github')
                      ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
