import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/touch_control_entity.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_drawer.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class TouchControlsScreen extends ConsumerStatefulWidget {
  const TouchControlsScreen({super.key});

  @override
  ConsumerState<TouchControlsScreen> createState() =>
      _TouchControlsScreenState();
}

class _TouchControlsScreenState extends ConsumerState<TouchControlsScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final touchAsync = ref.watch(allTouchControlsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      drawer: const AppDrawer(currentRoute: '/touch-controls'),
      body: touchAsync.when(
        loading: () => const _TouchSkeleton(),
        error: (e, _) => _TouchError(message: e.toString()),
        data: (mods) => _TouchBody(mods: mods, scrollCtrl: _scrollCtrl),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _TouchBody extends StatelessWidget {
  const _TouchBody({required this.mods, required this.scrollCtrl});

  final List<TouchControlEntity> mods;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
              Text(
                'Touch Controls',
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
                '${mods.length} layouts',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),

        // ── Section label ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Text(
                  'Mobile Layouts',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 8),
                if (mods.isNotEmpty)
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
                      '${mods.length} total',
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

        // ── List ───────────────────────────────────────────────
        if (mods.isEmpty)
          const SliverFillRemaining(hasScrollBody: false, child: _EmptyView())
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: mods.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final mod = mods[index];
                return TouchControlCard(mod: mod);
              },
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ── Touch Control Card ────────────────────────────────────────────────────────

class TouchControlCard extends ConsumerStatefulWidget {
  const TouchControlCard({super.key, required this.mod});

  final TouchControlEntity mod;

  @override
  ConsumerState<TouchControlCard> createState() => _TouchControlCardState();
}

class _TouchControlCardState extends ConsumerState<TouchControlCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  Timer? _longPressTimer;
  bool _isLongPressing = false;

  bool _downloading = false;
  double _progress = 0.0;
  double _realProgress = 0.0;
  late AnimationController _fakeCtrl;
  late Animation<double> _fakeAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

    _fakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _fakeAnim = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(parent: _fakeCtrl, curve: Curves.easeOut),
    )..addListener(() {
      if (mounted && _downloading && _realProgress <= 0.0) {
        setState(() => _progress = _fakeAnim.value);
      }
    });
  }

  void _startLongPress() {
    _longPressTimer?.cancel();
    _isLongPressing = true;

    _longPressTimer = Timer(const Duration(seconds: 2), _completeLongPress);
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    if (_isLongPressing) {
      setState(() {
        _isLongPressing = false;
      });
    }
  }

  void _completeLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    setState(() {
      _isLongPressing = false;
    });
    _toggleFavorite();
  }

  Future<void> _toggleFavorite() async {
    await toggleTouchFavourite(ref, widget.mod.id);
    if (!mounted) return;
    final isNowFav = ref.read(touchFavouritesProvider).contains(widget.mod.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFav ? 'Added to favorites' : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _download() async {
    if (_downloading) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _downloading = true;
      _progress = 0.0;
      _realProgress = 0.0;
    });
    _fakeCtrl.forward(from: 0.0);

    final url = widget.mod.downloadUrl;
    final rawName = widget.mod.title
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s\-]"), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .trim();
    final filename = '${rawName.isNotEmpty ? rawName : 'mod'}.zip';

    await FileDownloader.downloadFile(
      url: url,
      name: filename,
      onProgress: (name, progress) {
        if (!mounted) return;
        final normalized = (progress > 1.0 ? progress / 100.0 : progress).clamp(0.0, 1.0);
        if (normalized > _progress) {
          setState(() {
            _realProgress = normalized;
            _progress = normalized;
          });
        }
      },
      onDownloadCompleted: (path) async {
        if (!mounted) return;
        _fakeCtrl.stop();
        final completeCtrl = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        final completeAnim = Tween<double>(begin: _progress, end: 1.0)
            .animate(CurvedAnimation(parent: completeCtrl, curve: Curves.easeOut));
        completeAnim.addListener(() {
          if (mounted) setState(() => _progress = completeAnim.value);
        });
        await completeCtrl.forward();
        completeCtrl.dispose();
        await Future.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        setState(() {
          _downloading = false;
          _progress = 0.0;
          _realProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(child: Text('Downloaded: ${path.split('/').last}')),
              ],
            ),
          ),
        );
      },
      onDownloadError: (error) {
        if (!mounted) return;
        _fakeCtrl.stop();
        setState(() {
          _downloading = false;
          _progress = 0.0;
          _realProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                Icon(Icons.error_rounded, size: 18, color: Colors.white),
                SizedBox(width: 10),
                Text('Download failed'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _fakeCtrl.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFav = ref.watch(touchFavouritesProvider).contains(widget.mod.id);

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onLongPressStart: (_) => _startLongPress(),
      onLongPressEnd: (_) => _cancelLongPress(),
      onLongPressMoveUpdate: (_) => _cancelLongPress(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image banner (16:9) ──────────────────────────────
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child:
                        widget.mod.imageUrl != null &&
                            widget.mod.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.mod.imageUrl!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            placeholder: (context, loadState) => Container(
                              color: cs.surfaceContainerHigh,
                              height: 180,
                            ),
                            errorWidget: (context, loadState, error) =>
                                Container(
                                  color: cs.surfaceContainerHigh,
                                  height: 180,
                                  child: Icon(
                                    Icons.touch_app_rounded,
                                    size: 32,
                                    color: cs.outline,
                                  ),
                                ),
                          )
                      : Container(
                          color: cs.surfaceContainerHigh,
                          height: 180,
                          child: Icon(
                            Icons.touch_app_rounded,
                            size: 32,
                            color: cs.outline,
                          ),
                        ),
                  ),
                  // Favourite heart (indicator only)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 22,
                      color: isFav
                          ? cs.primary
                          : Colors.white.withValues(alpha: 0.9),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Content ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      widget.mod.title,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Added date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 13,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.mod.addedAt,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Favorite button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        icon: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                        ),
                        label: Text(
                          isFav ? 'Remove from Favorites' : 'Add to Favorites',
                        ),
                        onPressed: _toggleFavorite,
                        style: TextButton.styleFrom(
                          foregroundColor: cs.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Download button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _downloading ? null : _download,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          disabledBackgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _downloading
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LinearProgressIndicator(
                                      value: _progress,
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      color: Colors.white,
                                      minHeight: 4,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(_progress * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text('Download', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                ],
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
    );
  }
}

// ── Empty view ────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.touch_app_outlined,
                size: 34,
                color: cs.outline.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No touch layouts yet',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back later for mobile control layouts.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _TouchSkeleton extends StatelessWidget {
  const _TouchSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 32),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        ...List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _Bone(height: 280, radius: 16, isDark: isDark),
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
  });

  final double height;
  final double radius;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? AppTheme.darkShimmerBase : AppTheme.lightShimmerBase,
      highlightColor: isDark
          ? AppTheme.darkShimmerHighlight
          : AppTheme.lightShimmerHighlight,
      child: Container(
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

class _TouchError extends StatelessWidget {
  const _TouchError({required this.message});

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
              'Failed to load touch controls',
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
