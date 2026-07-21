import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/touch_control_entity.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';

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
    final touchAsync = ref.watch(allTouchControlsProvider);

    return touchAsync.when(
      loading: () => const _TouchSkeleton(),
      error: (e, _) => _TouchError(message: e.toString()),
      data: (mods) => _TouchBody(mods: mods, scrollCtrl: _scrollCtrl),
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
    final retro = RetroTheme.of(context);

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
          leading: DrawerMenuButton(color: retro.accent),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'TOUCH ', style: retro.heading(size: 16, color: retro.ink)),
                TextSpan(text: 'CONTROLS', style: retro.heading(size: 16, color: retro.accent)),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SkewChip(
                retro: retro,
                icon: Icons.touch_app_rounded,
                label: '${mods.length} LAYOUTS',
                dense: true,
                selected: true,
              ),
            ),
          ],
        ),

        // ── Section label ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
            child: Text('タッチ操作・レイアウト', style: retro.body(size: 12)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: SectionKicker(
              retro: retro,
              label: 'MOBILE LAYOUTS',
              japanese: mods.isEmpty ? null : '${mods.length} 件',
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
              separatorBuilder: (_, _) => const SizedBox(height: 16),
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

  Timer? _longPressTimer;
  bool _isLongPressing = false;

  bool _downloading = false;
  // ValueNotifier en vez de double + setState(): evita reconstruir toda
  // la card en cada tick de progreso durante la descarga.
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  double get _progress => _progressNotifier.value;
  set _progress(double v) => _progressNotifier.value = v;
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
    // Pixel-press: en vez de un scale suave, el "press" retro se resuelve
    // en el build() desplazando la card estilo botón de arcade.
    _fakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _fakeAnim =
        Tween<double>(begin: 0.0, end: 0.85).animate(
          CurvedAnimation(parent: _fakeCtrl, curve: Curves.easeOut),
        )..addListener(() {
          if (mounted && _downloading && _realProgress <= 0.0) {
            _progress = _fakeAnim.value;
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
    AppSnackbar.info(
      context,
      message: isNowFav ? 'Added to favorites' : 'Removed from favorites',
      duration: const Duration(seconds: 1),
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
        final normalized = (progress > 1.0 ? progress / 100.0 : progress).clamp(
          0.0,
          1.0,
        );
        if (normalized > _progress) {
          _realProgress = normalized;
          _progress = normalized; // solo repinta la barra, no toda la card
        }
      },
      onDownloadCompleted: (path) async {
        if (!mounted) return;
        _fakeCtrl.stop();
        final completeCtrl = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        );
        final completeAnim = Tween<double>(
          begin: _progress,
          end: 1.0,
        ).animate(CurvedAnimation(parent: completeCtrl, curve: Curves.easeOut));
        completeAnim.addListener(() {
          if (mounted) _progress = completeAnim.value;
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        AppSnackbar.success(
          context,
          message: 'Downloaded: ${path.split('/').last}',
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        AppSnackbar.error(context, message: 'Download failed');
      },
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _fakeCtrl.dispose();
    _progressNotifier.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final isFav = ref.watch(touchFavouritesProvider).contains(widget.mod.id);
    final cardImageHeight =
        (MediaQuery.orientationOf(context) == Orientation.landscape)
            ? 140.0
            : 180.0;

    // Solo hay banner de imagen si el mod trae una URL real.
    final hasImage =
        widget.mod.imageUrl != null && widget.mod.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onLongPressStart: (_) => _startLongPress(),
      onLongPressEnd: (_) => _cancelLongPress(),
      onLongPressMoveUpdate: (_) => _cancelLongPress(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          final pressed = _pressCtrl.value;
          final offset = 4.0 * pressed;
          return Transform.translate(
            offset: Offset(offset, offset),
            child: Container(
              decoration: BoxDecoration(
                color: retro.surface,
                borderRadius: RetroTheme.radius,
                border: Border.all(color: retro.border, width: 3),
                boxShadow: retro.hardShadow(dx: 5 - offset, dy: 5 - offset),
              ),
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: RetroTheme.radius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image banner (solo si hay URL, sin corazón encima) ──
              if (hasImage)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: retro.border, width: 3),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.mod.imageUrl!,
                    width: double.infinity,
                    height: cardImageHeight,
                    fit: BoxFit.cover,
                    placeholder: (context, loadState) => Container(
                      color: retro.surfaceAlt,
                      height: cardImageHeight,
                    ),
                    errorWidget: (context, loadState, error) => Container(
                      color: retro.surfaceAlt,
                      height: cardImageHeight,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.touch_app_rounded,
                        size: 30,
                        color: retro.inkDim,
                      ),
                    ),
                  ),
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
                      style: retro.heading(size: 16.5, letterSpacing: -0.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // Added date
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 13,
                          color: retro.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.mod.addedAt,
                          style: TextStyle(
                            color: retro.inkDim,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Favorite button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: retro.accent,
                        ),
                        label: Text(
                          isFav ? 'REMOVE FROM FAVORITES' : 'ADD TO FAVORITES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: _toggleFavorite,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: retro.accent,
                          side: BorderSide(color: retro.accent, width: 2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: RetroTheme.radius,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Download button — botón de arcade sólido teal
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: retro.border, width: 3),
                          boxShadow: _downloading
                              ? []
                              : retro.hardShadow(dx: 4, dy: 4),
                        ),
                        child: ElevatedButton(
                          onPressed: _downloading ? null : _download,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: retro.accent,
                            foregroundColor: retro.background,
                            disabledBackgroundColor: retro.accent.withValues(
                              alpha: 0.55,
                            ),
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: _downloading
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: _progressNotifier,
                                    builder: (context, progress, _) => Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: retro.background
                                              .withValues(alpha: 0.3),
                                          color: retro.background,
                                          minHeight: 4,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(progress * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            color: retro.background,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.download_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'DOWNLOAD',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
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
    final retro = RetroTheme.of(context);
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
                color: retro.surface,
                border: Border.all(color: retro.border, width: 3),
                boxShadow: retro.hardShadow(),
              ),
              child: Icon(
                Icons.touch_app_outlined,
                size: 30,
                color: retro.accent,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'NO TOUCH LAYOUTS YET',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: retro.ink,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for mobile control layouts.',
              style: TextStyle(color: retro.inkDim, fontSize: 12),
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
    final retro = RetroTheme.of(context);
    return Container(
      color: retro.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 32),
        children: [
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _Bone(height: 280),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Shimmer.fromColors(
      baseColor: retro.surface,
      highlightColor: retro.surfaceAlt,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: retro.border, width: 3),
          borderRadius: RetroTheme.radius,
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
                decoration: BoxDecoration(
                  color: retro.surface,
                  border: Border.all(color: retro.red, width: 3),
                  boxShadow: retro.hardShadow(),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: retro.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'FAILED TO LOAD TOUCH CONTROLS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: retro.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(color: retro.inkDim, fontSize: 12),
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
