import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/category_constants.dart';
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: cs.surface,
      elevation: 0,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            _staggerItem(
              index: 0,
              ctrl: _staggerCtrl,
              child: const _DrawerHeader(),
            ),
            _GradientDivider(isDark: isDark),
            const SizedBox(height: 4),

            // ── Scroll area ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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

                    // Separador degradado antes de EXCLUSIVE
                    _staggerItem(
                      index: 5,
                      ctrl: _staggerCtrl,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                        child: _GradientDivider(isDark: isDark),
                      ),
                    ),
                    _staggerItem(
                      index: 5,
                      ctrl: _staggerCtrl,
                      child: const _SectionLabel('EXCLUSIVE'),
                    ),
                    _staggerItem(
                      index: 6,
                      ctrl: _staggerCtrl,
                      child: _NavItem(
                        icon: Icons.star_rounded,
                        label: 'VIP Mods',
                        route: '/vip',
                        isActive: widget.currentRoute == '/vip',
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

                    // Separador degradado antes de Explore
                    _staggerItem(
                      index: 9,
                      ctrl: _staggerCtrl,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
                        child: _GradientDivider(isDark: isDark),
                      ),
                    ),
                    _staggerItem(
                      index: 9,
                      ctrl: _staggerCtrl,
                      child: const _SectionLabel('Explore'),
                    ),
                    _staggerItem(
                      index: 10,
                      ctrl: _staggerCtrl,
                      child: _CategoryList(currentRoute: widget.currentRoute),
                    ),
                    _staggerItem(
                      index: 11,
                      ctrl: _staggerCtrl,
                      child: _SortOptions(currentRoute: widget.currentRoute),
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            _GradientDivider(isDark: isDark),
            const _SocialLinks(),
            _GradientDivider(isDark: isDark),
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
              padding: const EdgeInsets.fromLTRB(22, 2, 0, 14),
              child: Text(
                'v1.0.1',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Separador con degradado horizontal — transparente › color › transparente
// Se usa como reemplazo del Divider plano para un look más premium.
// ─────────────────────────────────────────────────────────────────────────────
class _GradientDivider extends StatelessWidget {
  const _GradientDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mid = isDark
        ? cs.primary.withValues(alpha: 0.20)
        : cs.primary.withValues(alpha: 0.12);

    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, mid, mid, Colors.transparent],
          stops: const [0.0, 0.30, 0.70, 1.0],
        ),
      ),
    );
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary.withValues(alpha: 0.88), cs.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SM64CoopDX',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Mods catalog',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 4, 0, 4),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.2,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// NavItem
// · ScaleTransition en press (80 ms forward / 140 ms reverse) da la
//   sensación de "presionar" sin lag visual.
// · La barra lateral usa un LinearGradient vertical que la hace parecer
//   que tiene profundidad.
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

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
    final cs = Theme.of(context).colorScheme;
    final activeColor = cs.primary;
    final restColor = cs.onSurfaceVariant;
    final color = widget.isActive ? activeColor : restColor;

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
            color: widget.isActive
                ? cs.primaryContainer.withValues(alpha: 0.68)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // ── Barra lateral con degradado ──────────────────────────
              AnimatedContainer(
                duration: _kItemDuration,
                curve: _kCurve,
                width: 3,
                height: widget.isActive ? 26 : 0,
                decoration: BoxDecoration(
                  gradient: widget.isActive
                      ? LinearGradient(
                          colors: [
                            activeColor.withValues(alpha: 0.5),
                            activeColor,
                            activeColor.withValues(alpha: 0.5),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ── Label + icon ─────────────────────────────────────────
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
                          color: color,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      AnimatedDefaultTextStyle(
                        duration: _kItemDuration,
                        curve: _kCurve,
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: widget.isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
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
    final cs = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        iconColor: cs.onSurfaceVariant,
        collapsedIconColor: cs.onSurfaceVariant,
        expansionAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          curve: _kCurve,
          reverseDuration: const Duration(milliseconds: 160),
          reverseCurve: Curves.easeInCubic,
        ),
        title: Text(
          'Categories',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: Icon(
          Icons.category_rounded,
          size: 20,
          color: cs.onSurfaceVariant,
        ),
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
    final cs = Theme.of(context).colorScheme;
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
            color: isSelected
                ? cs.primaryContainer.withValues(alpha: 0.52)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: _kItemDuration,
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary
                      : catColor.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.35),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? cs.primary
                    : catColor.withValues(alpha: 0.72),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: _kItemDuration,
                  curve: _kCurve,
                  style: TextStyle(
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  child: Text(widget.category),
                ),
              ),
              AnimatedOpacity(
                duration: _kItemDuration,
                opacity: isSelected ? 1.0 : 0.0,
                child: Icon(Icons.check_rounded, size: 13, color: cs.primary),
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
    final cs = Theme.of(context).colorScheme;

    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: EdgeInsets.zero,
        iconColor: cs.onSurfaceVariant,
        collapsedIconColor: cs.onSurfaceVariant,
        expansionAnimationStyle: AnimationStyle(
          duration: const Duration(milliseconds: 200),
          curve: _kCurve,
          reverseDuration: const Duration(milliseconds: 160),
          reverseCurve: Curves.easeInCubic,
        ),
        title: Text(
          'Sort by',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: Icon(Icons.sort_rounded, size: 20, color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
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
            color: isSelected
                ? cs.primaryContainer.withValues(alpha: 0.52)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  child: Text(widget.label),
                ),
              ),
              AnimatedOpacity(
                duration: _kItemDuration,
                opacity: isSelected ? 1.0 : 0.0,
                child: Icon(Icons.check_rounded, size: 13, color: cs.primary),
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
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOCIAL LINKS',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
            ),
          ),
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: AnimatedContainer(
            duration: _kItemDuration,
            curve: _kCurve,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surfaceContainerHigh.withValues(alpha: 0.70)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cs.outline.withValues(alpha: isDark ? 0.18 : 0.25),
                width: 0.8,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                widget.link.asset,
                width: 20,
                height: 20,
                colorFilter: isDark && widget.link.asset.contains('github')
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
