import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/retro_theme.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/mod_entity.dart';
import '../../services/game_launcher_service.dart';
import '../providers/mod_providers.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_shell.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allModsProvider);

    return allAsync.when(
      loading: () => const _HomeSkeleton(),
      error: (e, _) => _HomeError(message: e.toString()),
      data: (_) => const _HomeBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _HomeBody extends ConsumerWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredModsProvider);
    final topAsync = ref.watch(topModsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Custom app bar ────────────────────────────────────
        const _HomeAppBar(),

        // ── Featured carousel ─────────────────────────────────
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: featuredAsync.maybeWhen(
              data: (mods) =>
                  mods.isNotEmpty ? _FeaturedCarousel(mods: mods) : null,
              orElse: () => null,
            ),
          ),
        ),
        if (featuredAsync.maybeWhen(
              data: (mods) => mods.isNotEmpty,
              orElse: () => false,
            ))
          const SliverToBoxAdapter(child: SizedBox(height: 14)),

        // ── Quick access ──────────────────────────────────────
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Browse'),
        ),
        const SliverToBoxAdapter(child: _QuickAccessGrid()),

        // ── Launch game ─────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: _LaunchGameButton()),

        // ── Exclusive content ─────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(
          child: _SectionHeader(title: 'Exclusive Content'),
        ),
        const SliverToBoxAdapter(child: _ExclusiveSection()),

        // ── Top downloads ─────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Top Downloads',
            actionLabel: 'See all',
            onAction: () => context.go('/popular'),
          ),
        ),
        SliverToBoxAdapter(
          child: _TopDownloads(
            mods: topAsync.maybeWhen(
              data: (mods) => mods,
              orElse: () => <ModEntity>[],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Custom AppBar — sin SVG, solo texto ────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return SliverAppBar(
      backgroundColor: retro.background,
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const DrawerMenuButton(icon: Icons.menu),
      title: Text('SM64CoopDX', style: retro.heading(size: 17)),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: retro.inkDim, size: 22),
          onPressed: () => context.go('/catalogue'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ── Featured carousel ─────────────────────────────────────────────────────────

class _FeaturedCarousel extends StatefulWidget {
  const _FeaturedCarousel({required this.mods});

  final List<ModEntity> mods;

  @override
  State<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<_FeaturedCarousel> {
  late final PageController _ctrl;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final carouselHeight =
        (MediaQuery.orientationOf(context) == Orientation.landscape)
            ? 160.0
            : 220.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeader(title: 'Featured'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.mods.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) =>
                _FeaturedCard(mod: widget.mods[i], isActive: _current == i),
          ),
        ),
        if (widget.mods.length > 1) ...[
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.mods.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _current == i
                        ? retro.accent
                        : retro.inkDim.withValues(alpha: 0.3),
                    borderRadius: RetroTheme.radius,
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeaturedCard extends ConsumerStatefulWidget {
  const _FeaturedCard({required this.mod, required this.isActive});

  final ModEntity mod;
  final bool isActive;

  @override
  ConsumerState<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends ConsumerState<_FeaturedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _pressScale = Tween<double>(
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
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: widget.isActive ? 0 : 8,
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          context.push('/mod/${Uri.encodeComponent(widget.mod.id)}');
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _pressScale,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'mod_img_${widget.mod.id}',
                  child: widget.mod.imageUrl != null &&
                          widget.mod.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.mod.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: retro.surfaceAlt),
                          errorWidget: (_, _, _) => _FeaturedPlaceholder(),
                        )
                      : _FeaturedPlaceholder(),
                ),

                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.82),
                        ],
                        stops: const [0.0, 0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 14,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RetroTag(
                              retro: retro,
                              label: 'FEATURED',
                              icon: Icons.star,
                              filled: true,
                              dense: true,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.mod.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person,
                                    size: 11,
                                    color: Colors.white.withValues(alpha: 0.7)),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.mod.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.75),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.mod.rating != null) ...[
                                  const SizedBox(width: 10),
                                  Icon(Icons.star,
                                      size: 11, color: retro.amber),
                                  const SizedBox(width: 3),
                                  Text(
                                    widget.mod.rating!.star,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      GestureDetector(
                        onTap: () => ref
                            .read(favouritesProvider.notifier)
                            .toggle(widget.mod.id),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: RetroTheme.radius,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 17,
                            color: isFav ? retro.red : Colors.white,
                          ),
                        ),
                      ),
                    ],
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

class _FeaturedPlaceholder extends StatelessWidget {
  const _FeaturedPlaceholder();

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      color: retro.surfaceAlt,
      child: Center(
        child: Icon(Icons.extension,
            size: 48, color: retro.inkDim.withValues(alpha: 0.3)),
      ),
    );
  }
}

// ── Quick access grid — migrado de SVG a Icons.* ──────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickCard(
              icon: Icons.apps_rounded,
              label: 'Catalog',
              description: 'Browse, search & filter the full mod collection',
              route: '/catalogue',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _QuickCard(
              icon: Icons.favorite_rounded,
              label: 'Favourites',
              description: 'Your saved mods across all sections',
              route: '/favourites',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _QuickCard(
              icon: Icons.trending_up_rounded,
              label: 'Popular',
              description: 'Top mods ranked by total downloads',
              route: '/popular',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatefulWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String description;
  final String route;

  @override
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.go(widget.route);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: retro.surface,
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border, width: 2),
            boxShadow: retro.hardShadow(dx: 3, dy: 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: retro.surface,
                  borderRadius: RetroTheme.radius,
                  border: Border.all(color: retro.border, width: 1.5),
                ),
                child: Icon(widget.icon, size: 19, color: retro.accent),
              ),
              const SizedBox(height: 10),
              Text(widget.label, style: retro.heading(size: 13)),
              const SizedBox(height: 2),
              Text(
                widget.description,
                style: retro.body(size: 10, height: 1.25),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Exclusive section — botones con skew tipo anime ─────────────────────────────

class _ExclusiveSection extends StatelessWidget {
  const _ExclusiveSection();

  static const _items = [
    (
      route: '/vip',
      label: 'VIP Mods',
      description: 'Exclusive character & model packs',
      icon: Icons.workspace_premium_rounded,
      colorKey: 'amber',
    ),
    (
      route: '/dynos',
      label: 'DynOS',
      description: 'Custom textures & model swaps',
      icon: Icons.color_lens_rounded,
      colorKey: 'blue',
    ),
    (
      route: '/touch-controls',
      label: 'Touch Controls',
      description: 'Custom button & joystick layouts',
      icon: Icons.touch_app_rounded,
      colorKey: 'accent',
    ),
    (
      route: '/omm-rebirth',
      label: 'OMMR PACK',
      description: 'Complete OMM Rebirth texture pack',
      icon: Icons.folder_zip_rounded,
      colorKey: 'red',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final colors = <String, Color>{
      'amber': retro.amber,
      'blue': retro.blue,
      'accent': retro.accent,
      'red': retro.red,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: _items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ExclusiveCard(
              retro: retro,
              icon: item.icon,
              label: item.label,
              description: item.description,
              accent: colors[item.colorKey] ?? retro.accent,
              route: item.route,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExclusiveCard extends StatefulWidget {
  const _ExclusiveCard({
    required this.retro,
    required this.icon,
    required this.label,
    required this.description,
    required this.accent,
    required this.route,
  });

  final RetroTheme retro;
  final IconData icon;
  final String label;
  final String description;
  final Color accent;
  final String route;

  @override
  State<_ExclusiveCard> createState() => _ExclusiveCardState();
}

class _ExclusiveCardState extends State<_ExclusiveCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  static const _skew = 0.18;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.go(widget.route);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(-_skew),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: widget.retro.surface,
              borderRadius: RetroTheme.radius,
              border: Border.all(color: widget.retro.border, width: 2),
              boxShadow: widget.retro.hardShadow(dx: 3, dy: 3),
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(_skew),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.accent.withValues(alpha: 0.18),
                      border: Border.all(color: widget.accent, width: 2),
                    ),
                    child:
                        Icon(widget.icon, size: 20, color: widget.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: widget.retro.heading(size: 14),
                        ),
                        Text(
                          widget.description,
                          style: widget.retro.body(size: 11.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: widget.retro.inkDim),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Launch game button ────────────────────────────────────────────────────────

class _LaunchGameButton extends ConsumerStatefulWidget {
  const _LaunchGameButton();

  @override
  ConsumerState<_LaunchGameButton> createState() => _LaunchGameButtonState();
}

class _LaunchGameButtonState extends ConsumerState<_LaunchGameButton> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final installed = await GameLauncherService.isInstalled();
    if (!mounted) return;
    ref.read(gameInstalledProvider.notifier).setInstalled(installed);
    setState(() => _checking = false);
  }

  Future<void> _launch() async {
    final launched = await GameLauncherService.launch();
    if (!mounted) return;
    if (!launched) {
      _showNotInstalledDialog();
    }
  }

  void _showNotInstalledDialog() {
    final retro = RetroTheme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: retro.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('Game not installed',
            style: retro.heading(size: 16, color: retro.red)),
        content: Text(
          'SM64CoopDX (com.maniscat2.sm64coopdx)\nis not installed on this device.',
          style: retro.body(size: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Close', style: retro.body(size: 13, color: retro.inkDim)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/links-resource');
            },
            child: Text('Download',
                style: retro.body(
                    size: 13, color: retro.accent, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    if (_checking) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: retro.surface,
            border: Border.all(color: retro.border, width: 2),
          ),
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: retro.accent),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: GestureDetector(
        onTap: _launch,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(-0.18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: retro.accent,
              border: Border.all(color: retro.border, width: 2),
              boxShadow: retro.hardShadow(dx: 3, dy: 3),
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(0.18),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded,
                      size: 22, color: Color(0xFF20232E)),
                  SizedBox(width: 8),
                  Text(
                    'LAUNCH  GAME',
                    style: TextStyle(
                      color: Color(0xFF20232E),
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(Icons.arrow_forward,
                      size: 18, color: Color(0xFF20232E)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top downloads ─────────────────────────────────────────────────────────────

class _TopDownloads extends StatelessWidget {
  const _TopDownloads({required this.mods});

  final List<ModEntity> mods;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: mods.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _TopModRow(mod: e.value, rank: e.key + 1),
          );
        }).toList(),
      ),
    );
  }
}

class _TopModRow extends ConsumerStatefulWidget {
  const _TopModRow({required this.mod, required this.rank});

  final ModEntity mod;
  final int rank;

  @override
  ConsumerState<_TopModRow> createState() => _TopModRowState();
}

class _TopModRowState extends ConsumerState<_TopModRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _rankColor(int r) {
    if (r == 1) return const Color(0xFFFFD700);
    if (r == 2) return const Color(0xFFC0C0C0);
    if (r == 3) return const Color(0xFFCD7F32);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);
    final isTop3 = widget.rank <= 3;
    final rankColor = _rankColor(widget.rank);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.push('/mod/${Uri.encodeComponent(widget.mod.id)}');
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: retro.surface,
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border, width: 2),
            boxShadow: retro.hardShadow(dx: 2, dy: 2),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: isTop3
                    ? RetroTag(
                        retro: retro,
                        label: '#${widget.rank}',
                        filled: true,
                        color: rankColor,
                        dense: true,
                      )
                    : Center(
                        child: Text(
                          '${widget.rank}',
                          style: retro.body(
                              size: 13,
                              color: retro.ink,
                              weight: FontWeight.w700),
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Hero(
                tag: 'mod_img_${widget.mod.id}',
                child: ClipRect(
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: widget.mod.imageUrl != null &&
                            widget.mod.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.mod.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: retro.surfaceAlt),
                            errorWidget: (_, _, _) => Container(
                              color: retro.surfaceAlt,
                              child: Icon(Icons.extension,
                                  size: 18, color: retro.inkDim),
                            ),
                          )
                        : Container(
                            color: retro.surfaceAlt,
                            child: Icon(Icons.extension,
                                size: 18, color: retro.inkDim),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mod.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: retro.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.download, size: 11, color: retro.inkDim),
                        const SizedBox(width: 3),
                        Text(
                          widget.mod.downloads.compact,
                          style: retro.body(size: 11),
                        ),
                        if (widget.mod.rating != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 11, color: retro.amber),
                          const SizedBox(width: 3),
                          Text(
                            widget.mod.rating!.star,
                            style: retro.body(size: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  size: 17,
                  color: isFav
                      ? retro.red
                      : retro.inkDim.withValues(alpha: 0.35),
                ),
                onPressed: () =>
                    ref.read(favouritesProvider.notifier).toggle(widget.mod.id),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: retro.heading(size: 16)),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: retro.body(
                        size: 12,
                        color: retro.accent,
                        weight: FontWeight.w700),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios, size: 10, color: retro.accent),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
      children: [
        const _Bone(height: 220),
        const SizedBox(height: 20),
        const _Bone(height: 88),
        const SizedBox(height: 28),
        const _Bone(height: 14, width: 80),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(child: _Bone(height: 90)),
            SizedBox(width: 10),
            Expanded(child: _Bone(height: 90)),
            SizedBox(width: 10),
            Expanded(child: _Bone(height: 90)),
          ],
        ),
        const SizedBox(height: 28),
        const _Bone(height: 14, width: 110),
        const SizedBox(height: 12),
        ...List.generate(
          4,
          (i) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _Bone(height: 66),
          ),
        ),
      ],
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Shimmer.fromColors(
      baseColor: retro.surfaceAlt,
      highlightColor: retro.surface,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: retro.surface,
          borderRadius: RetroTheme.radius,
        ),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: retro.surfaceAlt,
                borderRadius: RetroTheme.radius,
                border: Border.all(color: retro.red, width: 2),
              ),
              child: Icon(Icons.error_outline, size: 32, color: retro.red),
            ),
            const SizedBox(height: 16),
            Text('Failed to load mods', style: retro.heading(size: 16)),
            const SizedBox(height: 6),
            Text(
              message,
              style: retro.body(size: 12),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
