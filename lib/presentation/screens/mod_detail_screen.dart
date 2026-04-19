import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/mod_entity.dart';
import '../providers/mod_providers.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class ModDetailScreen extends ConsumerWidget {
  const ModDetailScreen({super.key, required this.modId});

  final String modId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allModsProvider);

    return allAsync.when(
      loading: () => const _DetailSkeleton(),
      error: (e, _) => _DetailError(message: e.toString()),
      data: (mods) {
        final mod = mods.firstWhereOrNull((m) => m.id == modId);
        if (mod == null) return const _NotFoundView();
        return _DetailScaffold(mod: mod);
      },
    );
  }
}

// ── Main scaffold ─────────────────────────────────────────────────────────────

class _DetailScaffold extends ConsumerStatefulWidget {
  const _DetailScaffold({required this.mod});

  final ModEntity mod;

  @override
  ConsumerState<_DetailScaffold> createState() => _DetailScaffoldState();
}

class _DetailScaffoldState extends ConsumerState<_DetailScaffold>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  bool _descExpanded = false;
  bool _changelogExpanded = false;
  double _scrollOffset = 0;

  static const _heroHeight = 300.0;
  static const _appBarHeight = kToolbarHeight + 40;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollCtrl.offset);
      });

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  double get _heroOpacity {
    if (_scrollOffset <= 0) return 1.0;
    return (1 - (_scrollOffset / (_heroHeight * 0.6))).clamp(0.0, 1.0);
  }

  bool get _isAppBarSolid => _scrollOffset > (_heroHeight - _appBarHeight - 20);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(cs, isFav, isDark),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Cinematic hero ───────────────────────────────────
            SliverToBoxAdapter(
              child: _CinematicHero(
                mod: widget.mod,
                heroOpacity: _heroOpacity,
                height: _heroHeight,
              ),
            ),

            // ── Content card that overlaps the hero ──────────────
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -32),
                child: _ContentCard(
                  mod: widget.mod,
                  descExpanded: _descExpanded,
                  changelogExpanded: _changelogExpanded,
                  onExpandDesc: () =>
                      setState(() => _descExpanded = !_descExpanded),
                  onExpandChangelog: () =>
                      setState(() => _changelogExpanded = !_changelogExpanded),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme cs, bool isFav, bool isDark) {
    final bgColor = _isAppBarSolid ? cs.surface : Colors.transparent;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: bgColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                _GlassIconButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onTap: () => Navigator.of(context).pop(),
                  isAppBarSolid: _isAppBarSolid,
                  cs: cs,
                ),
                const Spacer(),
                _GlassIconButton(
                  icon: isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onTap: () => ref
                      .read(favouritesProvider.notifier)
                      .toggle(widget.mod.id),
                  isAppBarSolid: _isAppBarSolid,
                  cs: cs,
                  activeColor: isFav ? cs.primary : null,
                ),
                const SizedBox(width: 6),
                _GlassIconButton(
                  icon: Icons.share_rounded,
                  onTap: () => _share(widget.mod),
                  isAppBarSolid: _isAppBarSolid,
                  cs: cs,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _share(ModEntity mod) async {
    final uri = Uri.tryParse(mod.url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Glass icon button ─────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    required this.isAppBarSolid,
    required this.cs,
    this.activeColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isAppBarSolid;
  final ColorScheme cs;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        activeColor ?? (isAppBarSolid ? cs.onSurface : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isAppBarSolid
              ? cs.surfaceContainerHigh
              : Colors.black.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAppBarSolid
                ? cs.outline.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ── Cinematic hero ────────────────────────────────────────────────────────────

class _CinematicHero extends StatelessWidget {
  const _CinematicHero({
    required this.mod,
    required this.heroOpacity,
    required this.height,
  });

  final ModEntity mod;
  final double heroOpacity;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with parallax fade
          Opacity(
            opacity: heroOpacity.clamp(0.0, 1.0),
            child: Hero(
              tag: 'mod_img_${mod.id}',
              child: mod.imageUrl != null && mod.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: mod.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (_, _) =>
                          Container(color: cs.surfaceContainerHigh),
                      errorWidget: (_, _, _) => _HeroPlaceholder(cs: cs),
                    )
                  : _HeroPlaceholder(cs: cs),
            ),
          ),

          // Gradient overlay — top (status bar) + bottom (content fade)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.transparent,
                  Colors.transparent,
                  cs.surface.withValues(alpha: 0.7),
                  cs.surface,
                ],
                stops: const [0.0, 0.2, 0.55, 0.85, 1.0],
              ),
            ),
          ),

          // Featured badge — top right, below app bar
          if (mod.isFeatured)
            Positioned(
              top: kToolbarHeight + 12,
              right: 16,
              child: _FeaturedBadge(cs: cs),
            ),
        ],
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerHigh,
      child: Center(
        child: Icon(
          Icons.extension_rounded,
          size: 72,
          color: cs.outline.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: cs.primary),
          const SizedBox(width: 5),
          Text(
            'FEATURED',
            style: TextStyle(
              color: cs.primary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Content card ──────────────────────────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.mod,
    required this.descExpanded,
    required this.changelogExpanded,
    required this.onExpandDesc,
    required this.onExpandChangelog,
  });

  final ModEntity mod;
  final bool descExpanded;
  final bool changelogExpanded;
  final VoidCallback onExpandDesc;
  final VoidCallback onExpandChangelog;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + author ─────────────────────────────
                _TitleSection(mod: mod),

                const SizedBox(height: 20),

                // ── Stats bar ──────────────────────────────────
                _StatsBar(mod: mod),

                const SizedBox(height: 24),

                // ── Download CTA ───────────────────────────────
                _DownloadSection(
                  urls: mod.downloadUrls,
                  modUrl: mod.url,
                  modTitle: mod.title,
                ),

                const SizedBox(height: 28),

                // ── Screenshot gallery ─────────────────────────
                if (mod.descriptionImages.isNotEmpty) ...[
                  _SectionTitle(label: 'Screenshots'),
                  const SizedBox(height: 12),
                  _ScreenshotGallery(images: mod.descriptionImages),
                  const SizedBox(height: 28),
                ],

                // ── Tags ───────────────────────────────────────
                if (mod.tags.isNotEmpty) ...[
                  _SectionTitle(label: 'Tags'),
                  const SizedBox(height: 10),
                  _TagCloud(tags: mod.tags),
                  const SizedBox(height: 28),
                ],

                // ── About ──────────────────────────────────────
                if (mod.description.isNotEmpty) ...[
                  _SectionTitle(label: 'About'),
                  const SizedBox(height: 10),
                  _ExpandableText(
                    text: mod.description,
                    expanded: descExpanded,
                    onToggle: onExpandDesc,
                  ),
                  const SizedBox(height: 28),
                ],

                // ── Release info ───────────────────────────────
                if (mod.firstRelease != null || mod.lastUpdate != null) ...[
                  _ReleaseDates(
                    firstRelease: mod.firstRelease,
                    lastUpdate: mod.lastUpdate,
                  ),
                  const SizedBox(height: 28),
                ],

                // ── Changelog ─────────────────────────────────
                if (mod.updates.isNotEmpty) ...[
                  _ChangelogSection(
                    updates: mod.updates,
                    expanded: changelogExpanded,
                    onToggle: onExpandChangelog,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Title section ─────────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.mod});

  final ModEntity mod;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mod.title,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.person_rounded, size: 14, color: cs.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mod.author,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
              ),
              child: Text(
                'v${mod.version}',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.mod});

  final ModEntity mod;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              value: mod.rating?.star ?? '—',
              label: 'Rating',
              icon: Icons.star_rounded,
              iconColor: cs.secondary,
              cs: cs,
            ),
            _Divider(cs: cs),
            _StatCell(
              value: mod.downloads.compact,
              label: 'Downloads',
              icon: Icons.download_rounded,
              iconColor: cs.primary,
              cs: cs,
            ),
            _Divider(cs: cs),
            _StatCell(
              value: mod.views.compact,
              label: 'Views',
              icon: Icons.visibility_rounded,
              iconColor: cs.onSurfaceVariant,
              cs: cs,
            ),
            _Divider(cs: cs),
            _StatCell(
              value: mod.reviewCount.compact,
              label: 'Reviews',
              icon: Icons.rate_review_rounded,
              iconColor: cs.onSurfaceVariant,
              cs: cs,
            ),
          ],
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
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w800,
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

class _Divider extends StatelessWidget {
  const _Divider({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: cs.outline.withValues(alpha: 0.3),
    );
  }
}

// ── Download section ──────────────────────────────────────────────────────────

class _DownloadSection extends StatelessWidget {
  const _DownloadSection({
    required this.urls,
    required this.modUrl,
    required this.modTitle,
  });

  final List<String> urls;
  final String modUrl;
  final String modTitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayUrls = urls.isNotEmpty ? urls : [modUrl];

    if (displayUrls.length == 1) {
      return _PrimaryDownloadButton(
        url: displayUrls.first,
        modTitle: modTitle,
        cs: cs,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: 'Download files (${displayUrls.length})'),
        const SizedBox(height: 10),
        ...displayUrls.asMap().entries.map(
          (e) => _DownloadFileRow(
            index: e.key + 1,
            url: e.value,
            modTitle: modTitle,
            cs: cs,
          ),
        ),
      ],
    );
  }
}

class _PrimaryDownloadButton extends StatefulWidget {
  const _PrimaryDownloadButton({
    required this.url,
    required this.modTitle,
    required this.cs,
  });

  final String url;
  final String modTitle;
  final ColorScheme cs;

  @override
  State<_PrimaryDownloadButton> createState() => _PrimaryDownloadButtonState();
}

class _PrimaryDownloadButtonState extends State<_PrimaryDownloadButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  // ── Fake-progress animation ──────────────────────────────────────────────────
  // Simula avance lento hasta ~85 % mientras descarga.
  // Cuando termina, acelera hasta 100 % y luego oculta la UI.
  late AnimationController _fakeCtrl;
  late Animation<double> _fakeAnim;

  bool _downloading = false;
  double _progress = 0.0; // 0.0–1.0, fuente de verdad para la barra

  // Progreso real recibido del downloader (0.0–1.0).
  // Si es > 0 la barra lo sigue directamente; si es 0 usamos el fake.
  double _realProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));

    // Fake: avanza de 0 → 0.85 en ~18 s con curva easeOut (rápido al inicio,
    // luego se frena para "esperar" la descarga real).
    _fakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _fakeAnim = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(parent: _fakeCtrl, curve: Curves.easeOut),
    )..addListener(_onFakeTick);
  }

  void _onFakeTick() {
    if (!mounted || !_downloading) return;
    // Solo aplicamos el fake si el progreso real no ha llegado aún.
    if (_realProgress <= 0.0) {
      setState(() => _progress = _fakeAnim.value);
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _fakeCtrl.dispose();
    super.dispose();
  }

  /// Completa la barra suavemente hasta 1.0 y luego cierra el estado.
  Future<void> _finishProgress() async {
    if (!mounted) return;
    _fakeCtrl.stop();

    // Anima de donde esté hasta 1.0 en ~400 ms
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

    // Pequeña pausa para que el usuario vea el 100 %
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      setState(() {
        _downloading = false;
        _progress = 0.0;
        _realProgress = 0.0;
      });
    }
  }

  Future<void> _download() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _downloading = true;
      _progress = 0.0;
      _realProgress = 0.0;
    });

    // Arranca la animación fake inmediatamente
    _fakeCtrl.forward(from: 0.0);

    try {
      final uri = Uri.tryParse(widget.url);
      if (uri == null) throw Exception('Invalid URL');

      final filename = _inferFileName(widget.url, widget.modTitle);

      await FileDownloader.downloadFile(
        url: widget.url,
        name: filename,
        onProgress: (name, progress) {
          if (!mounted) return;
          final normalized = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          // Solo actualizamos si el real supera el fake (nunca retrocede)
          if (normalized > _progress) {
            setState(() {
              _realProgress = normalized;
              _progress = normalized;
            });
          }
        },
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          await _finishProgress();
          if (!mounted) return;
          final savedName = path.split('/').last;
          _showSnackBar(
            icon: Icons.check_circle_rounded,
            message: 'Descargado: $savedName',
            isError: false,
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
          _showSnackBar(
            icon: Icons.error_rounded,
            message: 'Error al descargar',
            isError: true,
          );
        },
      );
    } catch (e) {
      _fakeCtrl.stop();
      if (mounted) {
        setState(() {
          _downloading = false;
          _progress = 0.0;
          _realProgress = 0.0;
        });
        _showSnackBar(
          icon: Icons.error_rounded,
          message: 'Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _showSnackBar({
    required IconData icon,
    required String message,
    required bool isError,
  }) {
    final cs = widget.cs;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? cs.errorContainer : cs.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isError ? cs.onErrorContainer : cs.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? cs.onErrorContainer : cs.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;

    return GestureDetector(
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) {
        _scaleCtrl.reverse();
        _download();
      },
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, cs.primary.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _downloading
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          color: Colors.white,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(_progress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Download',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
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

class _DownloadFileRow extends StatefulWidget {
  const _DownloadFileRow({
    required this.index,
    required this.url,
    required this.modTitle,
    required this.cs,
  });

  final int index;
  final String url;
  final String modTitle;
  final ColorScheme cs;

  @override
  State<_DownloadFileRow> createState() => _DownloadFileRowState();
}

class _DownloadFileRowState extends State<_DownloadFileRow>
    with SingleTickerProviderStateMixin {
  bool _downloading = false;
  double _progress = 0.0;
  double _realProgress = 0.0;

  late AnimationController _fakeCtrl;
  late Animation<double> _fakeAnim;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _fakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _finishProgress() async {
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
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _downloading = false;
        _progress = 0.0;
        _realProgress = 0.0;
      });
    }
  }

  Future<void> _download() async {
    if (_downloading) return;

    HapticFeedback.lightImpact();
    setState(() {
      _downloading = true;
      _progress = 0.0;
      _realProgress = 0.0;
    });

    _fakeCtrl.forward(from: 0.0);

    try {
      final uri = Uri.tryParse(widget.url);
      if (uri == null) throw Exception('Invalid URL');

      final filename = _inferFileName(
        widget.url,
        widget.modTitle,
        index: widget.index,
      );

      await FileDownloader.downloadFile(
        url: widget.url,
        name: filename,
        onProgress: (name, progress) {
          if (!mounted) return;
          final normalized = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          if (normalized > _progress) {
            setState(() {
              _realProgress = normalized;
              _progress = normalized;
            });
          }
        },
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          await _finishProgress();
          if (!mounted) return;
          final savedName = path.split('/').last;
          _showSnackBar(
            icon: Icons.check_circle_rounded,
            message: 'Descargado: $savedName',
            isError: false,
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
          _showSnackBar(
            icon: Icons.error_rounded,
            message: 'Error al descargar',
            isError: true,
          );
        },
      );
    } catch (e) {
      _fakeCtrl.stop();
      if (mounted) {
        setState(() {
          _downloading = false;
          _progress = 0.0;
          _realProgress = 0.0;
        });
        _showSnackBar(
          icon: Icons.error_rounded,
          message: 'Error: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _showSnackBar({
    required IconData icon,
    required String message,
    required bool isError,
  }) {
    final cs = widget.cs;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? cs.errorContainer : cs.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isError ? cs.onErrorContainer : cs.onPrimaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isError ? cs.onErrorContainer : cs.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final filename = _inferFileName(
      widget.url,
      widget.modTitle,
      index: widget.index,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.insert_drive_file_rounded,
                  size: 16,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _downloading
                          ? 'Descargando ${(_progress * 100).toStringAsFixed(0)}%'
                          : 'Toca para descargar',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _downloading ? null : _download,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _downloading
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            value: _progress,
                            color: cs.primary,
                          ),
                        )
                      : Icon(
                          Icons.download_rounded,
                          size: 16,
                          color: cs.primary,
                        ),
                ),
              ),
            ],
          ),
          // Barra de progreso debajo de la fila (solo visible al descargar)
          if (_downloading) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 3,
                backgroundColor: cs.outline.withValues(alpha: 0.2),
                color: cs.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Screenshot gallery ────────────────────────────────────────────────────────

class _ScreenshotGallery extends StatefulWidget {
  const _ScreenshotGallery({required this.images});

  final List<String> images;

  @override
  State<_ScreenshotGallery> createState() => _ScreenshotGalleryState();
}

class _ScreenshotGalleryState extends State<_ScreenshotGallery> {
  int _activeIndex = 0;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _ctrl,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _activeIndex = i),
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () => _openFullscreen(context, i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: _activeIndex == i ? 0 : 10,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: widget.images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: cs.surfaceContainerHigh,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: cs.outline,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: cs.surfaceContainerHigh,
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: cs.outline,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Dot indicators
        if (widget.images.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _activeIndex == i ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _activeIndex == i
                      ? cs.primary
                      : cs.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _openFullscreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, _, _) => _FullscreenGallery(
          images: widget.images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }
}

// ── Fullscreen gallery ────────────────────────────────────────────────────────

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late int _current;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.95),
        body: Stack(
          children: [
            PageView.builder(
              controller: _ctrl,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => Center(
                child: InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[i],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Close + counter
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_current + 1} / ${widget.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag cloud ─────────────────────────────────────────────────────────────────

class _TagCloud extends StatelessWidget {
  const _TagCloud({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Expandable description ────────────────────────────────────────────────────

class _ExpandableText extends StatelessWidget {
  const _ExpandableText({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLong = text.length > AppConstants.descriptionMaxLen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: expanded || !isLong
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            text.truncate(AppConstants.descriptionMaxLen),
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 14,
              height: 1.65,
            ),
          ),
          secondChild: Text(
            text,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 14,
              height: 1.65,
            ),
          ),
        ),
        if (isLong) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expanded ? 'Show less' : 'Show more',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: cs.primary,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Release dates ─────────────────────────────────────────────────────────────

class _ReleaseDates extends StatelessWidget {
  const _ReleaseDates({this.firstRelease, this.lastUpdate});

  final String? firstRelease;
  final String? lastUpdate;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          if (firstRelease != null)
            Expanded(
              child: _DateCell(
                icon: Icons.rocket_launch_rounded,
                label: 'First Release',
                date: firstRelease!,
                cs: cs,
              ),
            ),
          if (firstRelease != null && lastUpdate != null)
            Container(
              width: 1,
              height: 36,
              color: cs.outline.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
          if (lastUpdate != null)
            Expanded(
              child: _DateCell(
                icon: Icons.update_rounded,
                label: 'Last Update',
                date: lastUpdate!,
                cs: cs,
              ),
            ),
        ],
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.icon,
    required this.label,
    required this.date,
    required this.cs,
  });

  final IconData icon;
  final String label;
  final String date;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatDate(date) ?? date,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Changelog section ─────────────────────────────────────────────────────────

class _ChangelogSection extends StatelessWidget {
  const _ChangelogSection({
    required this.updates,
    required this.expanded,
    required this.onToggle,
  });

  final List<ModUpdate> updates;
  final bool expanded;
  final VoidCallback onToggle;

  static const _previewCount = 3;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final visible = expanded ? updates : updates.take(_previewCount).toList();
    final hasMore = updates.length > _previewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(label: 'Changelog'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${updates.length}',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Timeline-style changelog
        ...visible.asMap().entries.map((entry) {
          final i = entry.key;
          final u = entry.value;
          final isLast = i == visible.length - 1 && (!hasMore || expanded);
          return _ChangelogEntry(
            update: u,
            index: updates.indexOf(u),
            isLast: isLast,
            cs: cs,
          );
        }),

        if (hasMore) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expanded
                          ? 'Collapse changelog'
                          : 'View all ${updates.length} updates',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: cs.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChangelogEntry extends StatelessWidget {
  const _ChangelogEntry({
    required this.update,
    required this.index,
    required this.isLast,
    required this.cs,
  });

  final ModUpdate update;
  final int index;
  final bool isLast;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: index == 0 ? cs.primary : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: index != 0
                      ? Border.all(color: cs.outline.withValues(alpha: 0.3))
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index == 0 ? Colors.white : cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: cs.outline.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (update.title != null)
                    Text(
                      update.title!,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  if (update.date != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatDate(update.date) ?? update.date!,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    update.changelog,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.55,
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

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: cs.onSurfaceVariant,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ── Skeleton loading ──────────────────────────────────────────────────────────

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        children: [
          _Shimmer(height: 300, radius: 0, isDark: isDark),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(height: 28, radius: 8, isDark: isDark),
                const SizedBox(height: 10),
                _Shimmer(height: 16, width: 160, radius: 6, isDark: isDark),
                const SizedBox(height: 20),
                _Shimmer(height: 80, radius: 16, isDark: isDark),
                const SizedBox(height: 20),
                _Shimmer(height: 54, radius: 16, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({
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
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ── Not found ─────────────────────────────────────────────────────────────────

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(backgroundColor: cs.surface),
      body: Center(
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
                Icons.search_off_rounded,
                size: 36,
                color: cs.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mod not found',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This mod may have been removed or the link is invalid.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Go back'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(backgroundColor: cs.surface),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: cs.primary),
              const SizedBox(height: 12),
              Text(
                'Failed to load mod',
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
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filename inference helpers ────────────────────────────────────────────────
//
// Estrategia en capas para obtener un nombre de archivo útil a partir de la
// URL de descarga. Necesario porque algunos mods usan redirecciones del tipo
// /mods/xxx/download?file=123 cuyo último segmento de path es literalmente
// "download", sin extensión.
//
//  1. La URL ya termina en un segmento con extensión válida → usarlo directo.
//  2. El query param "file" contiene un nombre con extensión válida → usarlo.
//  3. Fallback: nombre del mod sanitizado + ".zip".
//     (El servidor puede corregirlo vía Content-Disposition si la extensión
//      real fuera distinta, pero .zip cubre la gran mayoría de los mods.)

const _kValidExtensions = {'.zip', '.lua', '.rar', '.7z'};

/// Devuelve la extensión si pertenece a [_kValidExtensions], o '' si no.
String _validFileExtension(String name) {
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return '';
  final ext = name.substring(dot).toLowerCase();
  return _kValidExtensions.contains(ext) ? ext : '';
}

/// Convierte el título del mod en un nombre de archivo seguro para el SO.
/// Ejemplo: "Super Mario 64: Remix!" → "super-mario-64-remix"
String _sanitizeModTitle(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r"[^\w\s\-]"), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-|-$'), '')
      .trim();
}

/// Infiere el nombre de archivo para la descarga a partir de [url] y [modTitle].
/// [index] se usa como sufijo cuando hay múltiples archivos del mismo mod.
String _inferFileName(String url, String modTitle, {int? index}) {
  final uri = Uri.tryParse(url);

  if (uri != null) {
    // 1. Último segmento del path con extensión válida
    final lastSegment = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.last
        : '';
    if (lastSegment.isNotEmpty &&
        lastSegment != 'download' &&
        _validFileExtension(lastSegment).isNotEmpty) {
      return lastSegment;
    }

    // 2. Query param "file" con extensión válida
    final fileParam = uri.queryParameters['file'] ?? '';
    if (_validFileExtension(fileParam).isNotEmpty) {
      return fileParam;
    }
  }

  // 3. Fallback: nombre del mod sanitizado + índice opcional + .zip
  final base = _sanitizeModTitle(modTitle);
  final safeName = base.isNotEmpty ? base : 'mod';
  final suffix = index != null && index > 1 ? '-$index' : '';
  return '$safeName$suffix.zip';
}

extension _FirstWhereOrNull<E> on List<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
