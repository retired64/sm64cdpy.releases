import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/retro_theme.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/mod_entity.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_drawer.dart';

// ── Constants ─────────────────────────────────────────────────────────────────
// El oro reutiliza retro.amber (mismo tono que VIP/featured) para que el
// podio no introduzca un cuarto acento suelto. Plata y bronce sí son
// colores propios de esta pantalla — no hay equivalente en el theme.
const _kSilver = Color(0xFFB9C0CE);
const _kBronze = Color(0xFFC97C42);
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
    final retro = RetroTheme.of(context);
    final popularAsync = ref.watch(popularModsProvider);

    return Scaffold(
      backgroundColor: retro.background,
      drawer: const AppDrawer(currentRoute: '/popular'),
      body: Stack(
        children: [
          Positioned.fill(
            child: HalftoneBackground(
              color: retro.ink.withValues(alpha: retro.isDark ? 0.05 : 0.08),
            ),
          ),
          popularAsync.when(
            loading: () => const _PopularSkeleton(),
            error: (e, _) => _PopularError(message: e.toString()),
            data: (mods) => _PopularBody(
              mods: mods,
              page: _page,
              scrollCtrl: _scrollCtrl,
              onPageChanged: _goToPage,
            ),
          ),
        ],
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
    final retro = RetroTheme.of(context);
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
          backgroundColor: retro.background,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          floating: true,
          snap: true,
          elevation: 0,
          shape: Border(bottom: BorderSide(color: retro.border, width: 3)),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: Icon(Icons.menu_rounded, color: retro.ink, size: 22),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: RichText(
            text: TextSpan(
              children: [
                const TextSpan(text: '🔥 '),
                TextSpan(text: 'POPULAR', style: retro.heading(size: 16)),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SkewChip(
                retro: retro,
                icon: Icons.local_fire_department_rounded,
                label: '${mods.length} MODS',
                dense: true,
                selected: true,
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
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: SectionKicker(
                    retro: retro,
                    label: showPodium ? 'MORE RANKINGS' : 'RANKINGS',
                    japanese: '人気ランキング',
                  ),
                ),
                const SizedBox(width: 10),
                RetroTag(
                  retro: retro,
                  label: 'PG ${safePage + 1}/$totalPages',
                  dense: true,
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
            separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    final retro = RetroTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
        decoration: BoxDecoration(
          color: retro.surface,
          border: Border.all(color: retro.border, width: 2.5),
          boxShadow: retro.hardShadow(),
        ),
        child: Column(
          children: [
            // Label
            SectionKicker(retro: retro, label: 'TOP 3', japanese: '殿堂'),
            const SizedBox(height: 18),

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
                    baseHeight: 34,
                  ),
                ),
                const SizedBox(width: 8),
                // 1st place — tallest
                Expanded(
                  child: _PodiumColumn(
                    mod: gold,
                    rank: 1,
                    color: retro.amber,
                    baseHeight: 50,
                  ),
                ),
                const SizedBox(width: 8),
                // 3rd place
                Expanded(
                  child: _PodiumColumn(
                    mod: bronze,
                    rank: 3,
                    color: _kBronze,
                    baseHeight: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumColumn extends ConsumerStatefulWidget {
  const _PodiumColumn({
    required this.mod,
    required this.rank,
    required this.color,
    required this.baseHeight,
  });

  final ModEntity mod;
  final int rank;
  final Color color;
  // Alto de la franja "base" del podio — más alta para el 1er lugar.
  final double baseHeight;

  @override
  ConsumerState<_PodiumColumn> createState() => _PodiumColumnState();
}

class _PodiumColumnState extends ConsumerState<_PodiumColumn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  String get _medal {
    if (widget.rank == 1) return '🥇';
    if (widget.rank == 2) return '🥈';
    return '🥉';
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);
    final thumbSize = widget.rank == 1 ? 60.0 : 50.0;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        HapticFeedback.lightImpact();
        context.push('/mod/${Uri.encodeComponent(widget.mod.id)}');
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          final offset = 2.0 * _pressCtrl.value;
          return Transform.translate(offset: Offset(offset, offset), child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Fav
            GestureDetector(
              onTap: () =>
                  ref.read(favouritesProvider.notifier).toggle(widget.mod.id),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 14,
                  color: isFav ? retro.red : retro.inkDim,
                ),
              ),
            ),

            // Thumbnail
            Hero(
              tag: 'mod_img_${widget.mod.id}',
              child: Container(
                width: thumbSize,
                height: thumbSize,
                decoration: BoxDecoration(
                  border: Border.all(color: widget.color, width: 2.5),
                  boxShadow: [
                    BoxShadow(color: widget.color.withValues(alpha: 0.35), offset: const Offset(2, 2)),
                  ],
                ),
                child: _PodiumThumb(mod: widget.mod, retro: retro),
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
              style: retro.heading(size: 10.5, letterSpacing: -0.1),
            ),
            const SizedBox(height: 6),

            // Podium base
            Container(
              height: widget.baseHeight,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.color,
                border: Border.all(color: retro.border, width: 2),
              ),
              child: Text(
                widget.mod.downloads.compact,
                style: TextStyle(
                  color: retro.background,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Miniatura del podio: imagen si existe, si no un placeholder a rayas
/// diagonales consistente con el resto del catálogo (ver ModCard).
class _PodiumThumb extends StatelessWidget {
  const _PodiumThumb({required this.mod, required this.retro});

  final ModEntity mod;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    final hasImage = mod.imageUrl != null && mod.imageUrl!.isNotEmpty;
    if (!hasImage) {
      return Stack(
        fit: StackFit.expand,
        children: [
          DiagonalStripeBanner(
            baseColor: retro.surfaceAlt,
            stripeColor: retro.border.withValues(alpha: 0.35),
            stripeWidth: 6,
            gap: 6,
          ),
          Center(
            child: Icon(Icons.extension_rounded, size: 18, color: retro.inkDim),
          ),
        ],
      );
    }
    return CachedNetworkImage(
      imageUrl: mod.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: retro.surfaceAlt),
      errorWidget: (_, _, _) => Container(
        color: retro.surfaceAlt,
        child: Icon(Icons.extension_rounded, size: 18, color: retro.inkDim),
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
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Color? _rankColor(RetroTheme retro) {
    if (widget.rank == 1) return retro.amber;
    if (widget.rank == 2) return _kSilver;
    if (widget.rank == 3) return _kBronze;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);
    final isTop3 = widget.rank <= 3;
    final rankColor = _rankColor(retro);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        HapticFeedback.selectionClick();
        context.push('/mod/${Uri.encodeComponent(widget.mod.id)}');
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          final offset = 3.0 * _pressCtrl.value;
          return Transform.translate(
            offset: Offset(offset, offset),
            child: Container(
              decoration: BoxDecoration(
                color: retro.surface,
                border: Border.all(
                  color: isTop3 ? rankColor! : retro.border,
                  width: isTop3 ? 2.5 : 2,
                ),
                boxShadow: retro.hardShadow(dx: 3 - offset, dy: 3 - offset),
              ),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              // Rank badge
              SizedBox(
                width: 28,
                child: isTop3
                    ? Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: rankColor,
                          border: Border.all(color: retro.border, width: 1.5),
                        ),
                        child: Text(
                          '#${widget.rank}',
                          style: TextStyle(
                            color: retro.background,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          '${widget.rank}',
                          style: retro.heading(size: 13, color: retro.inkDim),
                        ),
                      ),
              ),
              const SizedBox(width: 10),

              // Thumbnail with Hero
              Hero(
                tag: 'mod_img_${widget.mod.id}',
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    border: Border.all(color: retro.border, width: 1.5),
                  ),
                  child: _PodiumThumb(mod: widget.mod, retro: retro),
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
                      style: retro.heading(size: 13, letterSpacing: -0.1),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 10,
                      runSpacing: 3,
                      children: [
                        RetroMeta(
                          retro: retro,
                          icon: Icons.download_rounded,
                          label: widget.mod.downloads.compact,
                          color: retro.accent,
                        ),
                        if (widget.mod.rating != null)
                          RetroMeta(
                            retro: retro,
                            icon: Icons.star_rounded,
                            label: widget.mod.rating!.star,
                            color: retro.amber,
                          ),
                        if (widget.mod.isFeatured)
                          RetroTag(
                            retro: retro,
                            label: 'FEATURED',
                            color: retro.amber,
                            filled: true,
                            dense: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // Fav
              GestureDetector(
                onTap: () =>
                    ref.read(favouritesProvider.notifier).toggle(widget.mod.id),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    size: 17,
                    color: isFav ? retro.red : retro.inkDim,
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
    final retro = RetroTheme.of(context);
    final start = currentPage * pageSize + 1;
    final end = ((currentPage + 1) * pageSize).clamp(0, totalItems);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        children: [
          // Range label
          Text(
            'MOSTRANDO $start–$end DE $totalItems',
            style: TextStyle(
              color: retro.inkDim,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Previous
              _PageButton(
                icon: Icons.arrow_back_ios_new_rounded,
                enabled: currentPage > 0,
                onTap: () => onPageChanged(currentPage - 1),
                retro: retro,
              ),
              const SizedBox(width: 10),

              // Page pills
              Expanded(
                child: _PagePills(
                  currentPage: currentPage,
                  totalPages: totalPages,
                  onPageChanged: onPageChanged,
                  retro: retro,
                ),
              ),

              const SizedBox(width: 10),

              // Next
              _PageButton(
                icon: Icons.arrow_forward_ios_rounded,
                enabled: currentPage < totalPages - 1,
                onTap: () => onPageChanged(currentPage + 1),
                retro: retro,
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
    required this.retro,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final RetroTheme retro;

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
            child: Text('…', style: retro.body(size: 12, color: retro.inkDim)),
          );
        }
        final isActive = page == currentPage;
        return GestureDetector(
          onTap: isActive ? null : () => onPageChanged(page),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? retro.accent : retro.surface,
              border: Border.all(color: retro.border, width: isActive ? 2 : 1.5),
              boxShadow: isActive ? retro.hardShadow(dx: 2, dy: 2) : null,
            ),
            child: Text(
              '${page + 1}',
              style: TextStyle(
                color: isActive ? retro.background : retro.inkDim,
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
    required this.retro,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: retro.surface,
          border: Border.all(
            color: enabled ? retro.border : retro.border.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: enabled ? retro.hardShadow(dx: 2, dy: 2) : null,
        ),
        child: Icon(
          icon,
          size: 13,
          color: enabled ? retro.ink : retro.inkDim.withValues(alpha: 0.4),
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
    final retro = RetroTheme.of(context);
    return Container(
      color: retro.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 32),
        children: [
          _Bone(height: 240, retro: retro),
          const SizedBox(height: 24),
          _Bone(height: 14, width: 120, retro: retro),
          const SizedBox(height: 14),
          ...List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _Bone(height: 66, retro: retro),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.height, required this.retro, this.width});

  final double height;
  final RetroTheme retro;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: retro.surface,
      highlightColor: retro.surfaceAlt,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: retro.border, width: 2),
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
    final retro = RetroTheme.of(context);
    return Container(
      color: retro.background,
      child: Center(
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
                  color: retro.surface,
                  border: Border.all(color: retro.red, width: 3),
                  boxShadow: retro.hardShadow(),
                ),
                child: Icon(Icons.error_outline_rounded, size: 28, color: retro.red),
              ),
              const SizedBox(height: 20),
              Text(
                'FAILED TO LOAD',
                style: retro.heading(size: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
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
      ),
    );
  }
}
