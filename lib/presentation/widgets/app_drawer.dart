import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/category_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../presentation/providers/mod_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Timings
// · _kDrawerClose → duración real de cierre del Drawer de Material (~240 ms)
// · _kNavDelay    → esperamos a que el drawer cierre COMPLETAMENTE antes de
//                   navegar. Esto elimina el "saltito": Flutter ya no tiene
//                   que desmontar el drawer y construir la nueva ruta en el
//                   mismo frame.
// ─────────────────────────────────────────────────────────────────────────────
const Duration _kItemDuration = Duration(milliseconds: 150);
const Duration _kNavDelay = Duration(milliseconds: 260); // cierre + margen
const Curve _kCurve = Curves.easeOutCubic;

/// Cierra el drawer y navega sólo cuando la animación de cierre terminó.
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
  const AppDrawer({super.key, required this.currentRoute});
  final String currentRoute;

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Drawer(
      backgroundColor: retro.background,
      elevation: 0,
      shape: Border(right: BorderSide(color: retro.border, width: 3)),
      child: Stack(
        children: [
          Positioned.fill(
            child: HalftoneBackground(
              color: retro.ink.withValues(alpha: retro.isDark ? 0.05 : 0.08),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────
                  _staggerItem(
                    index: 0,
                    ctrl: _staggerCtrl,
                    child: const _DrawerHeader(),
                  ),
                  _RetroDivider(retro: retro),
                  const SizedBox(height: 4),

                  // ── Navigation items ────────────────────────────────
                  _staggerItem(
                    index: 1,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      route: '/',
                      isActive: widget.currentRoute == '/',
                    ),
                  ),
                  _staggerItem(
                    index: 2,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.apps_rounded,
                      label: 'catalog',
                      route: '/catalogue',
                      isActive: widget.currentRoute == '/catalogue',
                    ),
                  ),
                  _staggerItem(
                    index: 3,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.favorite_rounded,
                      label: 'Favourites',
                      route: '/favourites',
                      isActive: widget.currentRoute == '/favourites',
                    ),
                  ),
                  _staggerItem(
                    index: 4,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Popular',
                      route: '/popular',
                      isActive: widget.currentRoute == '/popular',
                    ),
                  ),

                  // Separador antes de EXCLUSIVE
                  _staggerItem(
                    index: 5,
                    ctrl: _staggerCtrl,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                      child: _RetroDivider(retro: retro),
                    ),
                  ),
                  _staggerItem(
                    index: 5,
                    ctrl: _staggerCtrl,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                      child: SectionKicker(retro: retro, label: 'EXCLUSIVE'),
                    ),
                  ),
                  _staggerItem(
                    index: 6,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.star_rounded,
                      label: 'VIP Mods',
                      route: '/vip',
                      isActive: widget.currentRoute == '/vip',
                      accentColor: retro.amber,
                    ),
                  ),
                  _staggerItem(
                    index: 7,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.rocket_launch_rounded,
                      label: 'DynOS',
                      route: '/dynos',
                      isActive: widget.currentRoute == '/dynos',
                      accentColor: retro.blue,
                    ),
                  ),
                  _staggerItem(
                    index: 8,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.touch_app_rounded,
                      label: 'Touch Controls',
                      route: '/touch-controls',
                      isActive: widget.currentRoute == '/touch-controls',
                    ),
                  ),
                  _staggerItem(
                    index: 9,
                    ctrl: _staggerCtrl,
                    child: _NavItem(
                      icon: Icons.auto_awesome_rounded,
                      label: 'OMMR PACK',
                      route: '/omm-rebirth',
                      isActive: widget.currentRoute == '/omm-rebirth',
                      accentColor: retro.red,
                    ),
                  ),

                  // Separador antes de Explore
                  _staggerItem(
                    index: 10,
                    ctrl: _staggerCtrl,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                      child: _RetroDivider(retro: retro),
                    ),
                  ),
                  _staggerItem(
                    index: 10,
                    ctrl: _staggerCtrl,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                      child: SectionKicker(retro: retro, label: 'EXPLORE'),
                    ),
                  ),
                  _staggerItem(
                    index: 11,
                    ctrl: _staggerCtrl,
                    child: _CategoryList(currentRoute: widget.currentRoute),
                  ),
                  _staggerItem(
                    index: 12,
                    ctrl: _staggerCtrl,
                    child: _SortOptions(currentRoute: widget.currentRoute),
                  ),

                  // ── Footer ─────────────────────────────────────────
                  _RetroDivider(retro: retro),
                  const _SocialLinks(),
                  _RetroDivider(retro: retro),
                  _NavItem(
                    icon: Icons.link_rounded,
                    label: 'Links Resource',
                    route: '/links-resource',
                    isActive: widget.currentRoute == '/links-resource',
                  ),
                  _NavItem(
                    icon: Icons.info_outline_rounded,
                    label: 'Disclaimer',
                    route: '/disclaimer',
                    isActive: widget.currentRoute == '/disclaimer',
                  ),
                  _NavItem(
                    icon: Icons.history_rounded,
                    label: 'Changelog',
                    route: '/changelog',
                    isActive: widget.currentRoute == '/changelog',
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    route: '/settings',
                    isActive: widget.currentRoute == '/settings',
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 8, 0, 14),
                    child: Text(
                      'v1.4.3',
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Separador con línea sólida — reemplaza al degradado horizontal, coherente
// con el resto de la app (nada de bordes difusos).
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
// Stagger helper — fade + tiny slide-up
// ─────────────────────────────────────────────────────────────────────────────
Widget _staggerItem({
  required int index,
  required AnimationController ctrl,
  required Widget child,
}) {
  final start = (index * 0.055).clamp(0.0, 0.80);
  final end = (start + 0.38).clamp(0.0, 1.0);
  final anim = CurvedAnimation(
    parent: ctrl,
    curve: Interval(start, end, curve: _kCurve),
  );
  return AnimatedBuilder(
    animation: anim,
    builder: (_, child) => Opacity(
      opacity: anim.value,
      child: Transform.translate(
        offset: Offset(0, 7 * (1 - anim.value)),
        child: child,
      ),
    ),
    child: child,
  );
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
            child: SvgPicture.asset('assets/icons/logo.svg', width: 32, height: 32),
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
// NavItem
// · Estado activo = relleno sólido de acento + texto sobre fondo, igual que
//   un SkewChip seleccionado — nada de contenedores translúcidos redondeados.
// · Barra lateral sólida (sin degradado) cuando está activo.
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    this.accentColor,
  });

  final IconData icon;
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
              // ── Barra lateral sólida ────────────────────────────
              AnimatedContainer(
                duration: _kItemDuration,
                curve: _kCurve,
                width: 3,
                height: widget.isActive ? 26 : 0,
                color: widget.isActive ? retro.background : Colors.transparent,
              ),
              // ── Label + icon ─────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: _kItemDuration,
                        child: Icon(
                          widget.icon,
                          key: ValueKey(widget.isActive),
                          color: fg,
                          size: 19,
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
// CategoryList
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.currentRoute});
  final String currentRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final retro = RetroTheme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        iconColor: retro.accent,
        collapsedIconColor: retro.inkDim,
        expansionAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          curve: _kCurve,
          reverseDuration: const Duration(milliseconds: 160),
          reverseCurve: Curves.easeInCubic,
        ),
        title: Text(
          'CATEGORIES',
          style: TextStyle(
            color: retro.ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        leading: Icon(Icons.category_rounded, size: 19, color: retro.inkDim),
        children: CategoryConstants.allCategories
            .map(
              (cat) => _CategoryItem(
                category: cat,
                selectedCategory: selectedCategory,
                currentRoute: currentRoute,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategoryItem extends ConsumerStatefulWidget {
  const _CategoryItem({
    required this.category,
    required this.selectedCategory,
    required this.currentRoute,
  });

  final String category;
  final String? selectedCategory;
  final String currentRoute;

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
        if (widget.currentRoute != '/catalogue') {
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
                  child: Text(widget.category),
                ),
              ),
              AnimatedOpacity(
                duration: _kItemDuration,
                opacity: isSelected ? 1.0 : 0.0,
                child: Icon(Icons.check_rounded, size: 14, color: retro.background),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SortOptions
// ─────────────────────────────────────────────────────────────────────────────
class _SortOptions extends ConsumerWidget {
  const _SortOptions({required this.currentRoute});
  final String currentRoute;

  static const _items = [
    (value: SortOrder.none, label: 'Default', emoji: '·'),
    (value: SortOrder.ratingDesc, label: 'Rating', emoji: '⭐'),
    (value: SortOrder.downloadsDesc, label: 'Downloads', emoji: '⬇️'),
    (value: SortOrder.newest, label: 'Newest Update', emoji: '🕐'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(sortOrderProvider);
    final retro = RetroTheme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        iconColor: retro.accent,
        collapsedIconColor: retro.inkDim,
        expansionAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          curve: _kCurve,
          reverseDuration: const Duration(milliseconds: 160),
          reverseCurve: Curves.easeInCubic,
        ),
        title: Text(
          'SORT BY',
          style: TextStyle(
            color: retro.ink,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        leading: Icon(Icons.sort_rounded, size: 19, color: retro.inkDim),
        children: _items
            .map(
              (item) => _SortItem(
                value: item.value,
                label: item.label,
                emoji: item.emoji,
                currentSort: currentSort,
                currentRoute: currentRoute,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SortItem extends ConsumerStatefulWidget {
  const _SortItem({
    required this.value,
    required this.label,
    required this.emoji,
    required this.currentSort,
    required this.currentRoute,
  });

  final SortOrder value;
  final String label;
  final String emoji;
  final SortOrder currentSort;
  final String currentRoute;

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
    final isSelected = widget.currentSort == widget.value;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        Navigator.of(context).pop();
        ref.read(sortOrderProvider.notifier).setSortOrder(widget.value);
        ref.read(currentPageProvider.notifier).setPage(0);
        if (widget.currentRoute != '/catalogue') {
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
              Text(widget.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 10),
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
                child: Icon(Icons.check_rounded, size: 14, color: retro.background),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Social Links
// Muestra YouTube · Discord · GitHub en fila horizontal con SVG icons.
// Cada botón tiene su propio ScaleTransition en press y abre la URL
// en el navegador externo vía url_launcher.
// ─────────────────────────────────────────────────────────────────────────────
class _SocialLinks extends StatelessWidget {
  const _SocialLinks();

  static const _links = [
    _SocialLinkData(
      asset: 'assets/icons/youtube.svg',
      url: AppConstants.youtubeUrl,
      tooltip: 'YouTube',
    ),
    _SocialLinkData(
      asset: 'assets/icons/discord.svg',
      url: AppConstants.discordUrl,
      tooltip: 'Discord',
    ),
    _SocialLinkData(
      asset: 'assets/icons/github.svg',
      url: AppConstants.githubUrl,
      tooltip: 'GitHub',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionKicker(retro: retro, label: 'SOCIAL LINKS'),
          const SizedBox(height: 10),
          Row(
            children: _links
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

// Datos inmutables de cada red social (const-safe).
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
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Falla silenciosa — la URL no pudo abrirse
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
    );
  }
}
