import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/mod_entity.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_drawer.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kGold = Color(0xFFFFD700);
const _kSilver = Color(0xFFC0C0C0);
const _kBronze = Color(0xFFCD7F32);
const _kPageSize = 15;

// ── Entry point ───────────────────────────────────────────────────────────────

class PopularScreen extends ConsumerStatefulWidget {
  const PopularScreen({super.key});

  @override
  ConsumerState<PopularScreen> createState() => _PopularScreenState();
}

class _PopularScreenState extends ConsumerState<PopularScreen> {
  final _scrollCtrl = ScrollController();
  int _page = 0;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    setState(() => _page = page);
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final popularAsync = ref.watch(popularModsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      drawer: const AppDrawer(currentRoute: '/popular'),
      body: popularAsync.when(
        loading: () => const _PopularSkeleton(),
        error: (e, _) => _PopularError(message: e.toString()),
        data: (mods) => _PopularBody(
          mods: mods,
          page: _page,
          scrollCtrl: _scrollCtrl,
          onPageChanged: _goToPage,
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _PopularBody extends StatelessWidget {
  const _PopularBody({
    required this.mods,
    required this.page,
    required this.scrollCtrl,
    required this.onPageChanged,
  });

  final List<ModEntity> mods;
  final int page;
  final ScrollController scrollCtrl;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalPages = (mods.length / _kPageSize).ceil();
    final safePage = page.clamp(0, totalPages - 1);
    final start = safePage * _kPageSize;
    final end = (start + _kPageSize).clamp(0, mods.length);
    final pageMods = mods.sublist(start, end);
    final rankOffset = safePage * _kPageSize;

    // Top 3 only shown on page 0
    final showPodium = safePage == 0 && mods.length >= 3;

    return CustomScrollView(
      controller: scrollCtrl,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // ── App bar ───────────────────────────────────────────
        SliverAppBar(
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          floating: true,
          snap: true,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu_rounded, color: cs.onSurface, size: 22),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              Text('🔥', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Popular',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          actions: [
            // Total count pill
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${mods.length} mods',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        // ── Podium top 3 — only page 0 ───────────────────────
        if (showPodium)
          SliverToBoxAdapter(
            child: _Podium(gold: mods[0], silver: mods[1], bronze: mods[2]),
          ),

        // ── Section label ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Text(
                  showPodium ? 'More Rankings' : 'Rankings',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Page ${safePage + 1} of $totalPages',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Ranked list ───────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.separated(
            itemCount: pageMods.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final mod = pageMods[i];
              final globalRank = i + 1 + rankOffset;
              // Skip top 3 on page 0 — they're shown in podium
              if (showPodium && globalRank <= 3) return const SizedBox.shrink();
              return _RankedRow(mod: mod, rank: globalRank);
            },
          ),
        ),

        // ── Pagination ────────────────────────────────────────
        if (totalPages > 1)
          SliverToBoxAdapter(
            child: _PaginationBar(
              currentPage: safePage,
              totalPages: totalPages,
              totalItems: mods.length,
              pageSize: _kPageSize,
              onPageChanged: onPageChanged,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  const _Podium({
    required this.gold,
    required this.silver,
    required this.bronze,
  });

  final ModEntity gold;
  final ModEntity silver;
  final ModEntity bronze;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_rounded, size: 14, color: _kGold),
              const SizedBox(width: 6),
              Text(
                'TOP 3',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Podium columns: silver | gold | bronze
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              Expanded(
                child: _PodiumColumn(
                  mod: silver,
                  rank: 2,
                  color: _kSilver,
                  height: 100,
                  labelHeight: 28,
                ),
              ),
              const SizedBox(width: 8),
              // 1st place — tallest
              Expanded(
                child: _PodiumColumn(
                  mod: gold,
                  rank: 1,
                  color: _kGold,
                  height: 130,
                  labelHeight: 36,
                ),
              ),
              const SizedBox(width: 8),
              // 3rd place
              Expanded(
                child: _PodiumColumn(
                  mod: bronze,
                  rank: 3,
                  color: _kBronze,
                  height: 80,
                  labelHeight: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends ConsumerStatefulWidget {
  const _PodiumColumn({
    required this.mod,
    required this.rank,
    required this.color,
    required this.height,
    required this.labelHeight,
  });

  final ModEntity mod;
  final int rank;
  final Color color;
  final double height;
  final double labelHeight;

  @override
  ConsumerState<_PodiumColumn> createState() => _PodiumColumnState();
}

class _PodiumColumnState extends ConsumerState<_PodiumColumn>
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

  String get _medal {
    if (widget.rank == 1) return '🥇';
    if (widget.rank == 2) return '🥈';
    return '🥉';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        context.push('/mod/${Uri.encodeComponent(widget.mod.id)}');
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Fav
            GestureDetector(
              onTap: () =>
                  ref.read(favouritesProvider.notifier).toggle(widget.mod.id),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 14,
                color: isFav
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 4),

            // Thumbnail
            Hero(
              tag: 'mod_img_${widget.mod.id}',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
                              size: 22,
                              color: cs.outline,
                            ),
                          ),
                        )
                      : Container(
                          color: cs.surfaceContainerHigh,
                          child: Icon(
                            Icons.extension_rounded,
                            size: 22,
                            color: cs.outline,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Medal + title
            Text(_medal, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              widget.mod.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),

            // Podium base
            Container(
              height: widget.labelHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                border: Border(
                  top: BorderSide(
                    color: widget.color.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  left: BorderSide(color: widget.color.withValues(alpha: 0.2)),
                  right: BorderSide(color: widget.color.withValues(alpha: 0.2)),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.mod.downloads.compact,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ranked row ────────────────────────────────────────────────────────────────

class _RankedRow extends ConsumerStatefulWidget {
  const _RankedRow({required this.mod, required this.rank});

  final ModEntity mod;
  final int rank;

  @override
  ConsumerState<_RankedRow> createState() => _RankedRowState();
}

class _RankedRowState extends ConsumerState<_RankedRow>
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

  Color _rankColor() {
    if (widget.rank == 1) return _kGold;
    if (widget.rank == 2) return _kSilver;
    if (widget.rank == 3) return _kBronze;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);
    final isTop3 = widget.rank <= 3;
    final rankColor = _rankColor();

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
                  ? rankColor.withValues(alpha: 0.3)
                  : cs.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Rank badge
              SizedBox(
                width: 32,
                child: isTop3
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: rankColor.withValues(alpha: 0.45),
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
                    width: 48,
                    height: 48,
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
                                size: 20,
                                color: cs.outline,
                              ),
                            ),
                          )
                        : Container(
                            color: cs.surfaceContainerHigh,
                            child: Icon(
                              Icons.extension_rounded,
                              size: 20,
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
                            fontWeight: FontWeight.w600,
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
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (widget.mod.isFeatured) ...[
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'FEATURED',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Fav
              GestureDetector(
                onTap: () =>
                    ref.read(favouritesProvider.notifier).toggle(widget.mod.id),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 17,
                    color: isFav
                        ? cs.primary
                        : cs.onSurfaceVariant.withValues(alpha: 0.35),
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

// ── Pagination bar ────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final start = currentPage * pageSize + 1;
    final end = ((currentPage + 1) * pageSize).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Range label
          Text(
            'Showing $start–$end of $totalItems',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Previous
              _PageButton(
                icon: Icons.arrow_back_ios_rounded,
                enabled: currentPage > 0,
                onTap: () => onPageChanged(currentPage - 1),
                cs: cs,
              ),
              const SizedBox(width: 10),

              // Page pills
              Expanded(
                child: _PagePills(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: onPageChanged,
                  cs: cs,
                ),
              ),

              const SizedBox(width: 10),

              // Next
              _PageButton(
                icon: Icons.arrow_forward_ios_rounded,
                enabled: currentPage < totalPages - 1,
                onTap: () => onPageChanged(currentPage + 1),
                cs: cs,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PagePills extends StatelessWidget {
  const _PagePills({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.cs,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ColorScheme cs;

  List<int?> get _visiblePages {
    if (totalPages <= 5) return List.generate(totalPages, (i) => i);
    final pages = <int?>{0, totalPages - 1, currentPage};
    if (currentPage > 0) pages.add(currentPage - 1);
    if (currentPage < totalPages - 1) pages.add(currentPage + 1);
    final sorted = pages.toList()..sort((a, b) => a!.compareTo(b!));
    final result = <int?>[];
    for (int i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i]! - sorted[i - 1]! > 1) result.add(null);
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _visiblePages.map((page) {
        if (page == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              '…',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }
        final isActive = page == currentPage;
        return GestureDetector(
          onTap: isActive ? null : () => onPageChanged(page),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? cs.primary : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isActive ? cs.primary : cs.outline.withValues(alpha: 0.3),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${page + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : cs.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.cs,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled
              ? cs.surfaceContainerHigh
              : cs.surfaceContainerHigh.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? cs.outline.withValues(alpha: 0.4)
                : cs.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: enabled ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _PopularSkeleton extends StatelessWidget {
  const _PopularSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 32),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Podium skeleton
        _Bone(height: 220, radius: 20, isDark: isDark),
        const SizedBox(height: 24),
        _Bone(height: 14, width: 100, radius: 6, isDark: isDark),
        const SizedBox(height: 12),
        ...List.generate(
          6,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Bone(height: 68, radius: 14, isDark: isDark),
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

class _PopularError extends StatelessWidget {
  const _PopularError({required this.message});

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
                size: 30,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
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
