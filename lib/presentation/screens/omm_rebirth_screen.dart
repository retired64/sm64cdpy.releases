import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/omm_rebirth_entity.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_snackbar.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class OmmRebirthScreen extends ConsumerStatefulWidget {
  const OmmRebirthScreen({super.key});

  @override
  ConsumerState<OmmRebirthScreen> createState() => _OmmRebirthScreenState();
}

class _OmmRebirthScreenState extends ConsumerState<OmmRebirthScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final ommAsync = ref.watch(allOmmRebirthProvider);

    return Scaffold(
      backgroundColor: retro.void_,
      drawer: const AppDrawer(currentRoute: '/omm-rebirth'),
      body: ommAsync.when(
        loading: () => const _OmmSkeleton(),
        error: (e, _) => _OmmError(message: e.toString()),
        data: (mods) => _OmmBody(mods: mods, scrollCtrl: _scrollCtrl),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _OmmBody extends StatelessWidget {
  const _OmmBody({required this.mods, required this.scrollCtrl});

  final List<OmmRebirthEntity> mods;
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
          backgroundColor: retro.void_,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          floating: true,
          snap: true,
          elevation: 0,
          shape: Border(
            bottom: BorderSide(color: retro.line, width: 3),
          ),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: retro.gold,
                size: 22,
              ),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                color: retro.red,
                margin: const EdgeInsets.only(right: 4),
              ),
              const SizedBox(width: 6),
              Text(
                'OMM PACK',
                style: TextStyle(
                  color: retro.gold,
                  fontFamily: RetroTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          actions: [
            // Total count tag
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: retro.panel,
                border: Border.all(color: retro.line, width: 2),
              ),
              child: Text(
                '${mods.length} MODS',
                style: TextStyle(
                  color: retro.inkDim,
                  fontFamily: RetroTheme.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),

        // ── Section label ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: retro.red, width: 2),
                  ),
                  child: Text(
                    'STAGE',
                    style: TextStyle(
                      color: retro.red,
                      fontFamily: RetroTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      'OMM REBIRTH MODS',
                      style: TextStyle(
                        color: retro.ink,
                        fontFamily: RetroTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
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
                          color: retro.panel,
                          border: Border.all(color: retro.line, width: 2),
                        ),
                        child: Text(
                          '${mods.length} TOTAL',
                          style: TextStyle(
                            color: retro.inkDim,
                            fontFamily: RetroTheme.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
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
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final mod = mods[index];
                return OmmRebirthCard(mod: mod);
              },
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ── OMM Rebirth Card ──────────────────────────────────────────────────────────

class OmmRebirthCard extends ConsumerStatefulWidget {
  const OmmRebirthCard({super.key, required this.mod});

  final OmmRebirthEntity mod;

  @override
  ConsumerState<OmmRebirthCard> createState() => _OmmRebirthCardState();
}

class _OmmRebirthCardState extends ConsumerState<OmmRebirthCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  bool _isExpanded = false;

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
    await toggleOmmFavourite(ref, widget.mod.id);
    if (!mounted) return;
    final isNowFav = ref.read(ommFavouritesProvider).contains(widget.mod.id);
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
        final completeAnim = Tween<double>(
          begin: _progress,
          end: 1.0,
        ).animate(CurvedAnimation(parent: completeCtrl, curve: Curves.easeOut));
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
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final isFav = ref.watch(ommFavouritesProvider).contains(widget.mod.id);
    final cardImageHeight =
        (MediaQuery.orientationOf(context) == Orientation.landscape)
            ? 140.0
            : 180.0;

    // ── PATCH: solo hay banner de imagen si el mod trae una URL real.
    // Si no hay imageUrl, la sección completa se elimina — nada de
    // placeholder ni icono de reemplazo.
    final hasImage =
        widget.mod.imageUrl != null && widget.mod.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) => _pressCtrl.reverse(),
      onTapCancel: () => _pressCtrl.reverse(),
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      onLongPressStart: (_) => _startLongPress(),
      onLongPressEnd: (_) => _cancelLongPress(),
      onLongPressMoveUpdate: (_) => _cancelLongPress(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          final pressed = _pressCtrl.value;
          // Botón de arcade: se hunde 4px y pierde su sombra dura al tocar.
          final offset = 4.0 * pressed;
          return Transform.translate(
            offset: Offset(offset, offset),
            child: Container(
              decoration: BoxDecoration(
                color: retro.panel,
                borderRadius: RetroTheme.pixelRadius,
                border: Border.all(color: retro.line, width: 3),
                boxShadow: retro.hardShadow(
                  dx: 5 - offset,
                  dy: 5 - offset,
                ),
              ),
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: RetroTheme.pixelRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image banner (solo si hay URL) ────────────────
              if (hasImage)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: retro.line, width: 3),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.mod.imageUrl!,
                    width: double.infinity,
                    height: cardImageHeight,
                    fit: BoxFit.cover,
                    placeholder: (context, loadState) => Container(
                      color: retro.panelAlt,
                      height: cardImageHeight,
                    ),
                    errorWidget: (context, loadState, error) => Container(
                      color: retro.panelAlt,
                      height: cardImageHeight,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.extension_rounded,
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
                      style: TextStyle(
                        color: retro.ink,
                        fontFamily: RetroTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Author + recommended version
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _RetroMeta(
                          icon: Icons.person_rounded,
                          label: widget.mod.author,
                        ),
                        _RetroMeta(
                          icon: Icons.info_outline_rounded,
                          label: widget.mod.recommendedVersion,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Description (expandable)
                    Text(
                      widget.mod.description,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontFamily: RetroTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                    if (widget.mod.description.length > 150)
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = !_isExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _isExpanded ? 'SHOW LESS' : 'READ MORE',
                            style: TextStyle(
                              color: retro.gold,
                              fontFamily: RetroTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
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
                          color: retro.gold,
                        ),
                        label: Text(
                          isFav ? 'REMOVE FROM FAVORITES' : 'ADD TO FAVORITES',
                          style: TextStyle(
                            fontFamily: RetroTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: _toggleFavorite,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: retro.gold,
                          side: BorderSide(color: retro.gold, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Download button — botón de arcade sólido
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: retro.line, width: 3),
                          boxShadow: _downloading
                              ? []
                              : retro.hardShadow(dx: 4, dy: 4),
                        ),
                        child: ElevatedButton(
                          onPressed: _downloading ? null : _download,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: retro.red,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: retro.redDark,
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LinearProgressIndicator(
                                        value: _progress,
                                        backgroundColor: Colors.black
                                            .withValues(alpha: 0.35),
                                        color: retro.gold,
                                        minHeight: 4,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(_progress * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: RetroTheme.fontFamily,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
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
                                        fontFamily: RetroTheme.fontFamily,
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

// ── Small retro meta tag (author / version) ────────────────────────────────────

class _RetroMeta extends StatelessWidget {
  const _RetroMeta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: retro.gold),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: retro.inkDim,
            fontFamily: RetroTheme.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
                color: retro.panel,
                border: Border.all(color: retro.line, width: 3),
                boxShadow: retro.hardShadow(),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 30,
                color: retro.gold,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'NO OMM REBIRTH MODS YET',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: retro.ink,
                fontFamily: RetroTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for OMM Rebirth content.',
              style: TextStyle(
                color: retro.inkDim,
                fontFamily: RetroTheme.fontFamily,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _OmmSkeleton extends StatelessWidget {
  const _OmmSkeleton();

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      color: retro.void_,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 32),
        children: [
          ...List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _Bone(height: 340, radius: 3),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Shimmer.fromColors(
      baseColor: retro.panel,
      highlightColor: retro.panelAlt,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: retro.line, width: 3),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _OmmError extends StatelessWidget {
  const _OmmError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      color: retro.void_,
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
                  color: retro.panel,
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
                'FAILED TO LOAD OMM REBIRTH MODS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: retro.ink,
                  fontFamily: RetroTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  color: retro.inkDim,
                  fontFamily: RetroTheme.fontFamily,
                  fontSize: 12,
                ),
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
