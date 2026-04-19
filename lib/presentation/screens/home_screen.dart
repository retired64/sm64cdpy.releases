import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/mod_entity.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_drawer.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allModsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(currentRoute: '/'),
      body: allAsync.when(
        loading: () => const _HomeSkeleton(),
        error: (e, _) => _HomeError(message: e.toString()),
        data: (mods) => _HomeBody(mods: mods),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.mods});

  final List<ModEntity> mods;

  @override
  Widget build(BuildContext context) {
    final featuredMods = mods.where((m) => m.isFeatured).toList();
    final topMods = ([
      ...mods,
    ]..sort((a, b) => b.downloads.compareTo(a.downloads))).take(5).toList();
    final newestMods =
        ([...mods]..sort(
              (a, b) => (b.lastUpdate ?? '').compareTo(a.lastUpdate ?? ''),
            ))
            .take(8)
            .toList();
    final uniqueTags = <String>{};
    for (final m in mods) {
      uniqueTags.addAll(m.tags);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Custom app bar ────────────────────────────────────
        _HomeAppBar(modCount: mods.length),

        // ── Featured carousel ─────────────────────────────────
        if (featuredMods.isNotEmpty)
          SliverToBoxAdapter(child: _FeaturedCarousel(mods: featuredMods)),

        // ── Stats strip ───────────────────────────────────────
        SliverToBoxAdapter(
          child: _StatsStrip(
            modCount: mods.length,
            tagCount: uniqueTags.length,
            featuredCount: featuredMods.length,
          ),
        ),

        // ── Quick access ──────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Browse',
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: _QuickAccessGrid()),

        // ── Top downloads ─────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Top Downloads',
            actionLabel: 'See all',
            onAction: () => context.go('/popular'),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(child: _TopDownloads(mods: topMods)),

        // ── Recently updated ──────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: 'Recently Updated',
            actionLabel: 'Browse all',
            onAction: () => context.go('/catalogue'),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverToBoxAdapter(child: _RecentlyUpdated(mods: newestMods)),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ── Custom AppBar ─────────────────────────────────────────────────────────────

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.modCount});

  final int modCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(Icons.menu_rounded, color: cs.onSurface, size: 22),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.star_rounded, color: cs.primary, size: 17),
          ),
          const SizedBox(width: 10),
          Text(
            'SM64CoopDX',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: cs.onSurfaceVariant,
            size: 22,
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeader(title: 'Featured'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
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
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
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
    final cs = Theme.of(context).colorScheme;
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with Hero
                Hero(
                  tag: 'mod_img_${widget.mod.id}',
                  child:
                      widget.mod.imageUrl != null &&
                          widget.mod.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.mod.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: cs.surfaceContainerHigh),
                          errorWidget: (_, _, _) =>
                              _FeaturedPlaceholder(cs: cs),
                        )
                      : _FeaturedPlaceholder(cs: cs),
                ),

                // Bottom gradient overlay
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

                // Content overlay
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
                            // Featured badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'FEATURED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
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
                                Icon(
                                  Icons.person_rounded,
                                  size: 11,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.mod.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.75),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (widget.mod.rating != null) ...[
                                  const SizedBox(width: 10),
                                  Icon(
                                    Icons.star_rounded,
                                    size: 11,
                                    color: cs.secondary,
                                  ),
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

                      // Fav button
                      GestureDetector(
                        onTap: () => ref
                            .read(favouritesProvider.notifier)
                            .toggle(widget.mod.id),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 17,
                            color: isFav ? cs.primary : Colors.white,
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
  const _FeaturedPlaceholder({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.extension_rounded,
          size: 48,
          color: cs.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ── Stats strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.modCount,
    required this.tagCount,
    required this.featuredCount,
  });

  final int modCount;
  final int tagCount;
  final int featuredCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _StatCell(
                value: modCount.compact,
                label: 'Total Mods',
                icon: Icons.extension_rounded,
                iconColor: cs.primary,
                cs: cs,
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: cs.outline.withValues(alpha: 0.25),
              ),
              _StatCell(
                value: tagCount.compact,
                label: 'Unique Tags',
                icon: Icons.label_rounded,
                iconColor: cs.tertiary,
                cs: cs,
              ),
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: cs.outline.withValues(alpha: 0.25),
              ),
              _StatCell(
                value: featuredCount.toString(),
                label: 'Featured',
                icon: Icons.star_rounded,
                iconColor: cs.secondary,
                cs: cs,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.cs,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick access grid ─────────────────────────────────────────────────────────

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _QuickCard(
              icon: Icons.apps_rounded,
              label: 'Catalogue',
              subtitle: 'All mods',
              iconColor: cs.primary,
              iconBg: cs.primaryContainer,
              onTap: () => context.go('/catalogue'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickCard(
              icon: Icons.favorite_rounded,
              label: 'Favourites',
              subtitle: 'Your saved',
              iconColor: cs.secondary,
              iconBg: cs.secondaryContainer,
              onTap: () => context.go('/favourites'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickCard(
              icon: Icons.local_fire_department_rounded,
              label: 'Popular',
              subtitle: 'Trending',
              iconColor: const Color(0xFFFF6B35),
              iconBg: const Color(0xFFFF6B35).withValues(alpha: 0.12),
              onTap: () => context.go('/popular'),
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
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

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
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(widget.icon, size: 19, color: widget.iconColor),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    final cs = Theme.of(context).colorScheme;
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
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isTop3
                  ? rankColor.withValues(alpha: 0.25)
                  : cs.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Rank
              SizedBox(
                width: 28,
                child: isTop3
                    ? Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: rankColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '#${widget.rank}',
                          style: TextStyle(
                            color: rankColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          '${widget.rank}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 10),

              // Thumbnail with Hero
              Hero(
                tag: 'mod_img_${widget.mod.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child:
                        widget.mod.imageUrl != null &&
                            widget.mod.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.mod.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: cs.surfaceContainerHigh),
                            errorWidget: (_, _, _) => Container(
                              color: cs.surfaceContainerHigh,
                              child: Icon(
                                Icons.extension_rounded,
                                size: 18,
                                color: cs.outline,
                              ),
                            ),
                          )
                        : Container(
                            color: cs.surfaceContainerHigh,
                            child: Icon(
                              Icons.extension_rounded,
                              size: 18,
                              color: cs.outline,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.mod.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.download_rounded,
                          size: 11,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.mod.downloads.compact,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.mod.rating != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.star_rounded,
                            size: 11,
                            color: cs.secondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.mod.rating!.star,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Fav
              IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 17,
                  color: isFav
                      ? cs.primary
                      : cs.onSurfaceVariant.withValues(alpha: 0.35),
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

// ── Recently updated horizontal scroll ───────────────────────────────────────

class _RecentlyUpdated extends StatelessWidget {
  const _RecentlyUpdated({required this.mods});

  final List<ModEntity> mods;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: mods.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _RecentCard(mod: mods[i]),
      ),
    );
  }
}

class _RecentCard extends StatefulWidget {
  const _RecentCard({required this.mod});

  final ModEntity mod;

  @override
  State<_RecentCard> createState() => _RecentCardState();
}

class _RecentCardState extends State<_RecentCard>
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
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        context.push('/mod/${Uri.encodeComponent(widget.mod.id)}');
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Hero(
                tag: 'mod_img_${widget.mod.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 120,
                    height: 100,
                    child:
                        widget.mod.imageUrl != null &&
                            widget.mod.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.mod.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) {
                              final isDark =
                                  Theme.of(context).brightness ==
                                  Brightness.dark;
                              return Shimmer.fromColors(
                                baseColor: isDark
                                    ? AppTheme.darkShimmerBase
                                    : AppTheme.lightShimmerBase,
                                highlightColor: isDark
                                    ? AppTheme.darkShimmerHighlight
                                    : AppTheme.lightShimmerHighlight,
                                child: Container(color: Colors.white),
                              );
                            },
                            errorWidget: (_, _, _) => Container(
                              color: cs.surfaceContainerHigh,
                              child: Icon(
                                Icons.extension_rounded,
                                size: 28,
                                color: cs.outline,
                              ),
                            ),
                          )
                        : Container(
                            color: cs.surfaceContainerHigh,
                            child: Icon(
                              Icons.extension_rounded,
                              size: 28,
                              color: cs.outline,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                widget.mod.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.mod.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
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
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: cs.primary,
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _Bone(height: 220, radius: 20, isDark: isDark),
        const SizedBox(height: 20),
        _Bone(height: 88, radius: 18, isDark: isDark),
        const SizedBox(height: 28),
        _Bone(height: 14, width: 80, radius: 6, isDark: isDark),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _Bone(height: 90, radius: 16, isDark: isDark)),
            const SizedBox(width: 10),
            Expanded(child: _Bone(height: 90, radius: 16, isDark: isDark)),
            const SizedBox(width: 10),
            Expanded(child: _Bone(height: 90, radius: 16, isDark: isDark)),
          ],
        ),
        const SizedBox(height: 28),
        _Bone(height: 14, width: 110, radius: 6, isDark: isDark),
        const SizedBox(height: 12),
        ...List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Bone(height: 66, radius: 14, isDark: isDark),
          ),
        ),
      ],
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({
    required this.height,
    required this.radius,
    required this.isDark,
    this.width,
  });

  final double height;
  final double radius;
  final bool isDark;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppTheme.darkShimmerBase : AppTheme.lightShimmerBase,
      highlightColor: isDark
          ? AppTheme.darkShimmerHighlight
          : AppTheme.lightShimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
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
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load mods',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
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
