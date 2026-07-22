import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../core/utils/extensions.dart';
import '../../domain/entities/mod_entity.dart';
import '../../services/background_install_service.dart';
import '../../services/mod_installer.dart';
import '../providers/mod_providers.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/post_install_dialog.dart';

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

  double _heroHeight = 300.0;
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
    _heroHeight = (MediaQuery.orientationOf(context) ==
            Orientation.landscape)
        ? (MediaQuery.sizeOf(context).height * 0.45).clamp(200.0, 280.0)
        : 300.0;

    final retro = RetroTheme.of(context);
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: retro.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(retro, isFav, isDark),
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

            // ── Background install status banner ────
            SliverToBoxAdapter(
              child: _InstallStatusBanner(
                modTitle: widget.mod.title,
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

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RetroTheme retro, bool isFav, bool isDark) {
    final bgColor = _isAppBarSolid ? retro.background : Colors.transparent;

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
                  retro: retro,
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
                  retro: retro,
                  activeColor: isFav ? retro.accent : null,
                ),
                const SizedBox(width: 6),
                _GlassIconButton(
                  icon: Icons.share_rounded,
                  onTap: () => _share(widget.mod),
                  isAppBarSolid: _isAppBarSolid,
                  retro: retro,
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

// ── App bar icon button ────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    required this.isAppBarSolid,
    required this.retro,
    this.activeColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isAppBarSolid;
  final RetroTheme retro;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        activeColor ?? (isAppBarSolid ? retro.ink : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isAppBarSolid
              ? retro.surfaceAlt
              : Colors.black.withValues(alpha: 0.42),
          border: Border.all(
            color: isAppBarSolid
                ? retro.border.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ── Hero: fondo sólido + avatar bordeado ────────────────────────────────────
// Fondo de color sólido con el avatar del mod superpuesto abajo a la
// izquierda.

class _CinematicHero extends StatelessWidget {
  const _CinematicHero({
    required this.mod,
    required this.heroOpacity,
    required this.height,
  });

  final ModEntity mod;
  final double heroOpacity;
  final double height;

  static const _avatarSize = 84.0;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final hasImage = mod.imageUrl != null && mod.imageUrl!.isNotEmpty;

    return SizedBox(
      height: height,
      child: Opacity(
        opacity: heroOpacity.clamp(0.0, 1.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: retro.accent),

            // Scrim superior sutil — asegura contraste de los botones del
            // app bar sin importar en qué punto de la franja caigan.
            const Align(
              alignment: Alignment.topCenter,
              child: _TopScrim(),
            ),

            // Costura hacia la content card, que se superpone por debajo.
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, retro.background],
                  ),
                ),
              ),
            ),

            // Avatar del mod
            Positioned(
              left: 20,
              bottom: 22,
              child: Container(
                width: _avatarSize,
                height: _avatarSize,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: retro.surfaceAlt,
                  border: Border.all(color: retro.border, width: 3),
                  boxShadow: retro.hardShadow(),
                ),
                child: hasImage
                    ? Hero(
                        tag: 'mod_img_${mod.id}',
                        child: CachedNetworkImage(
                          imageUrl: mod.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) =>
                              Container(color: retro.surfaceAlt),
                          errorWidget: (_, _, _) => _HeroPlaceholder(retro: retro),
                        ),
                      )
                    : _HeroPlaceholder(retro: retro),
              ),
            ),

            // Insignia "featured" — círculo superpuesto en la esquina del avatar
            if (mod.isFeatured)
              Positioned(
                left: 20 + _avatarSize - 16,
                bottom: 22 + _avatarSize - 16,
                child: RetroBadgeDot(retro: retro, icon: Icons.star_rounded),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight + 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.28),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.retro});

  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: retro.surfaceAlt,
      child: Center(
        child: Icon(
          Icons.extension_rounded,
          size: 32,
          color: retro.inkDim,
        ),
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
    final retro = RetroTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border(top: BorderSide(color: retro.border, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

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
                _VersionAccordion(
                  versions: mod.versions,
                  downloadUrls: mod.downloadUrls,
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
    final retro = RetroTheme.of(context);
    final titleStyle = retro.heading(size: 25, letterSpacing: -0.4, height: 1.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título "estampado": una copia desplazada en el acento detrás del
        // texto principal — el efecto de doble impresión de la referencia.
        Stack(
          children: [
            Positioned(
              left: 2.5,
              top: 2.5,
              child: Text(mod.title, style: titleStyle.copyWith(color: retro.accent)),
            ),
            Text(mod.title, style: titleStyle),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: retro.accent),
              child: Icon(Icons.person_rounded, size: 14, color: retro.background),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mod.author,
                style: retro.body(size: 14, weight: FontWeight.w700, color: retro.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            RetroTag(retro: retro, label: 'v${mod.version.replaceFirst(RegExp(r'^v'), '')}'),
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
    final retro = RetroTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.border.withValues(alpha: 0.35)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              value: mod.rating?.star ?? '—',
              label: 'Rating',
              icon: Icons.star_rounded,
              iconColor: retro.amber,
              retro: retro,
            ),
            _Divider(retro: retro),
            _StatCell(
              value: mod.downloads.compact,
              label: 'Downloads',
              icon: Icons.download_rounded,
              iconColor: retro.accent,
              retro: retro,
            ),
            _Divider(retro: retro),
            _StatCell(
              value: mod.views.compact,
              label: 'Views',
              icon: Icons.visibility_rounded,
              iconColor: retro.inkDim,
              retro: retro,
            ),
            _Divider(retro: retro),
            _StatCell(
              value: mod.reviewCount.compact,
              label: 'Reviews',
              icon: Icons.rate_review_rounded,
              iconColor: retro.inkDim,
              retro: retro,
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
    required this.retro,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final RetroTheme retro;

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
              color: retro.ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: retro.inkDim,
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
  const _Divider({required this.retro});

  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: retro.border.withValues(alpha: 0.3),
    );
  }
}

// ── Download section ──────────────────────────────────────────────────────────

class _VersionAccordion extends StatefulWidget {
  const _VersionAccordion({
    required this.versions,
    required this.downloadUrls,
    required this.modUrl,
    required this.modTitle,
  });

  final List<ModVersionEntity> versions;
  final List<String> downloadUrls;
  final String modUrl;
  final String modTitle;

  @override
  State<_VersionAccordion> createState() => _VersionAccordionState();
}

class _VersionAccordionState extends State<_VersionAccordion> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    if (widget.versions.isNotEmpty) {
      return _buildVersionList(retro);
    }

    final displayUrls =
        widget.downloadUrls.isNotEmpty ? widget.downloadUrls : [widget.modUrl];

    if (displayUrls.length == 1) {
      return _PrimaryDownloadButton(
        url: displayUrls.first,
        modTitle: widget.modTitle,
        retro: retro,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: 'Download files (${displayUrls.length})'),
        const SizedBox(height: 10),
        ...displayUrls.asMap().entries.map(
          (e) => _BuildDownloadButton(
            url: e.value,
            modTitle: widget.modTitle,
            retro: retro,
            label: '${e.key + 1}. ${_extractFilename(e.value)}',
          ),
        ),
      ],
    );
  }

  Widget _buildVersionList(RetroTheme retro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: 'Versions (${widget.versions.length})'),
        const SizedBox(height: 10),
        ...widget.versions.asMap().entries.map((entry) {
          final idx = entry.key;
          final v = entry.value;
          final isExpanded = _expandedIndex == idx;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: retro.surfaceAlt,
              borderRadius: RetroTheme.radius,
              border: Border.all(color: retro.border.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                InkWell(
                  borderRadius: RetroTheme.radius,
                  onTap: () =>
                      setState(() => _expandedIndex = isExpanded ? null : idx),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          isExpanded
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 20,
                          color: retro.ink,
                        ),
                        const SizedBox(width: 8),
                        RetroTag(
                          retro: retro,
                          label: v.version.isEmpty ? 'v?' : v.version,
                        ),
                        const Spacer(),
                        Text(
                          v.releaseDate,
                          style: retro.body(size: 11, color: retro.inkDim),
                        ),
                        if (v.downloads > 0) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.download_rounded,
                              size: 13, color: retro.accent),
                          const SizedBox(width: 3),
                          Text(
                            v.downloads.toString(),
                            style: retro.body(
                                size: 11, weight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  ...v.files.map(
                    (f) => Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: _PrimaryDownloadButton(
                        url: f.downloadUrl,
                        modTitle: '${widget.modTitle} — ${f.filename}',
                        retro: retro,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  static String _extractFilename(String url) {
    try {
      final uri = Uri.parse(url);
      final segs = uri.pathSegments;
      if (segs.isNotEmpty) {
        final last = segs.last;
        if (last.isNotEmpty && last.contains('.')) return last;
      }
    } catch (_) {}
    return url.split('/').last;
  }
}

class _BuildDownloadButton extends ConsumerStatefulWidget {
  const _BuildDownloadButton({
    required this.url,
    required this.modTitle,
    required this.retro,
    required this.label,
  });

  final String url;
  final String modTitle;
  final RetroTheme retro;
  final String label;

  @override
  ConsumerState<_BuildDownloadButton> createState() =>
      _BuildDownloadButtonState();
}

class _BuildDownloadButtonState extends ConsumerState<_BuildDownloadButton>
    with SingleTickerProviderStateMixin {
  final _installer = ModInstaller();
  bool _localDownloading = false;
  double _localProgress = 0.0;

  Future<void> _download() async {
    HapticFeedback.lightImpact();

    final hasPermission = await _installer.hasNotificationPermission();

    if (!hasPermission && mounted) {
      final showRationale = await _installer.shouldShowNotificationRationale();
      if (showRationale) {
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: RetroTheme.of(ctx).surfaceAlt,
            title: Text('Notifications needed',
                style: TextStyle(color: RetroTheme.of(ctx).ink)),
            content: Text(
              'We need notification permission to show download '
              'and installation progress, even if you leave the app.',
              style: TextStyle(color: RetroTheme.of(ctx).inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Not now',
                    style: TextStyle(color: RetroTheme.of(ctx).ink)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
        if (proceed != true && mounted) {
          AppSnackbar.info(
            context,
            message:
                'You won\'t see progress outside the app. Grant permission in Settings to enable notifications.',
          );
        }
      }

      if (!mounted) return;
      final granted = await _installer.requestNotificationPermission();
      if (!granted && mounted) {
        AppSnackbar.info(
          context,
          message:
              'Notifications not enabled. You won\'t see download progress outside the app.',
        );
      }
    }

    final modName = _sanitizeModTitle(widget.modTitle);
    final filename = _inferFileName(widget.url, widget.modTitle);

    final hasFolder = await _installer.isDirectorySelected();

    if (!hasFolder) {
      final prefs = await SharedPreferences.getInstance();
      final autoInstall =
          prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

      if (autoInstall && mounted) {
        final goToSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: RetroTheme.of(ctx).surfaceAlt,
            icon: Icon(Icons.folder_open_rounded,
                color: RetroTheme.of(ctx).accent, size: 28),
            title: Text('Mods folder not selected',
                style: TextStyle(color: RetroTheme.of(ctx).ink)),
            content: Text(
              'You need to select a mods folder before '
              'installing mods to the game.\n\n'
              'Go to Settings → Game Integration to select it.',
              style: TextStyle(color: RetroTheme.of(ctx).inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel',
                    style: TextStyle(color: RetroTheme.of(ctx).ink)),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Go to Settings'),
              ),
            ],
          ),
        );
        if (goToSettings == true && mounted) {
          GoRouter.of(context).push('/settings');
        }
        return;
      }

      if (!mounted) return;
      await _downloadWithFileDownloader(widget.url, filename);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final autoInstall =
        prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

    if (autoInstall && mounted) {
      BackgroundInstallService.instance.startDownloadAndInstall(
        url: widget.url,
        modName: modName,
        fileName: filename,
      );
      if (!mounted) return;
      AppSnackbar.info(context, message: 'Downloading "$filename"...');
    } else if (mounted) {
      await _downloadToModsFolder(_installer, widget.url, filename);
    }
  }

  Future<void> _downloadToModsFolder(
      ModInstaller installer, String url, String filename) async {
    try {
      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          final savedName = path.split('/').last;
          await installer.copyFileToModsFolder(
            sourcePath: path,
            targetName: savedName,
          );
          if (!mounted) return;
          AppSnackbar.success(
              context, message: 'Saved to mods folder: $savedName');
        },
        onDownloadError: (error) {
          if (!mounted) return;
          AppSnackbar.error(context, message: 'Download failed');
        },
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.error(context, message: 'Error: ${e.toString()}');
    }
  }

  Future<void> _downloadWithFileDownloader(
      String url, String filename) async {
    if (!mounted) return;
    setState(() {
      _localDownloading = true;
      _localProgress = 0.0;
    });
    try {
      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        onProgress: (name, progress) {
          if (!mounted) return;
          final normalized =
              (progress > 1.0 ? progress / 100.0 : progress).clamp(0.0, 1.0);
          setState(() => _localProgress = normalized);
        },
        onDownloadCompleted: (path) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          final savedName = path.split('/').last;
          AppSnackbar.success(context, message: 'Downloaded: $savedName');
          showPostInstallDialog(context);
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.error(context, message: 'Download failed');
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localDownloading = false;
        _localProgress = 0.0;
      });
      AppSnackbar.error(context, message: 'Error: ${e.toString()}');
    }
  }

  String _sanitizeModTitle(String raw) =>
      raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();

  String _inferFileName(String url, String modTitle) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      if (path.contains('/download')) {
        final segs = uri.pathSegments;
        if (segs.length >= 2) {
          return '${modTitle.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}_${segs[segs.length - 1]}.zip';
        }
      }
      final last = path.split('/').last;
      if (last.isNotEmpty && last.contains('.')) return last;
      return '${modTitle.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.zip';
    } catch (_) {
      return '${modTitle.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.zip';
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.border.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: _localDownloading
                      ? CircularProgressIndicator(
                          value: _localProgress,
                          strokeWidth: 2.5,
                          color: retro.accent,
                          backgroundColor: retro.border,
                        )
                      : Icon(Icons.insert_drive_file_rounded,
                          size: 28, color: retro.accent),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    widget.label,
                    style: retro.body(size: 11.5, color: retro.inkDim),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 34,
            child: FilledButton.icon(
              onPressed: _download,
              icon: const Icon(Icons.download_rounded, size: 14),
              label: const Text('Download'),
              style: FilledButton.styleFrom(
                backgroundColor: retro.accent,
                foregroundColor: retro.background,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryDownloadButton extends ConsumerStatefulWidget {
  const _PrimaryDownloadButton({
    required this.url,
    required this.modTitle,
    required this.retro,
  });

  final String url;
  final String modTitle;
  final RetroTheme retro;

  @override
  ConsumerState<_PrimaryDownloadButton> createState() =>
      _PrimaryDownloadButtonState();
}

class _PrimaryDownloadButtonState extends ConsumerState<_PrimaryDownloadButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scale;

  bool _localDownloading = false;
  double _localProgress = 0.0;

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
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    HapticFeedback.mediumImpact();

    final installer = ModInstaller();
    final hasPermission = await installer.hasNotificationPermission();

    if (!hasPermission && mounted) {
      final showRationale = await installer.shouldShowNotificationRationale();
      if (showRationale) {
        if (!mounted) return;
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor:
                RetroTheme.of(ctx).surfaceAlt,
            title: Text(
              'Notifications needed',
              style: TextStyle(color: RetroTheme.of(ctx).ink),
            ),
            content: Text(
              'We need notification permission to show download '
              'and installation progress, even if you leave the app.',
              style: TextStyle(
                  color: RetroTheme.of(ctx).inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Not now',
                    style: TextStyle(
                        color: RetroTheme.of(ctx).ink)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        );

        if (proceed != true && mounted) {
          AppSnackbar.info(
            context,
            message: 'You won\'t see progress outside the app. Grant permission in Settings to enable notifications.',
          );
        }
      }

      if (!mounted) return;
      final granted = await installer.requestNotificationPermission();
      if (!granted && mounted) {
        AppSnackbar.info(
          context,
          message: 'Notifications not enabled. You won\'t see download progress outside the app.',
        );
      }
    }

    final modName = _sanitizeModTitle(widget.modTitle);
    final filename = _inferFileName(widget.url, widget.modTitle);

    final hasFolder = await installer.isDirectorySelected();

    if (!hasFolder) {
      final prefs = await SharedPreferences.getInstance();
      final autoInstall =
          prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

      if (autoInstall && mounted) {
        final goToSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor:
                RetroTheme.of(ctx).surfaceAlt,
            icon: Icon(Icons.folder_open_rounded,
                color: RetroTheme.of(ctx).accent, size: 28),
            title: Text(
              'Mods folder not selected',
              style:
                  TextStyle(color: RetroTheme.of(ctx).ink),
            ),
            content: Text(
              'You need to select a mods folder before '
              'installing mods to the game.\n\n'
              'Go to Settings → Game Integration to select it.',
              style: TextStyle(
                  color: RetroTheme.of(ctx).inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel',
                    style: TextStyle(
                        color: RetroTheme.of(ctx).ink)),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('Go to Settings'),
              ),
            ],
          ),
        );
        if (goToSettings == true && mounted) {
          GoRouter.of(context).push('/settings');
        }
        return;
      }

      if (!mounted) return;
      await _downloadWithFileDownloader(widget.url, filename);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final autoInstall =
        prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

    if (autoInstall && mounted) {
      BackgroundInstallService.instance.startDownloadAndInstall(
        url: widget.url,
        modName: modName,
        fileName: filename,
      );
      if (!mounted) return;
      AppSnackbar.info(
        context,
        message: 'Downloading "$filename"...',
      );
    } else if (mounted) {
      await _downloadToModsFolder(installer, widget.url, filename);
    }
  }

  Future<void> _downloadToModsFolder(
      ModInstaller installer, String url, String filename) async {
    if (!mounted) return;
    setState(() {
      _localDownloading = true;
      _localProgress = 0.0;
    });
    try {
      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        onProgress: (name, progress) {
          if (!mounted) return;
          final normalized =
              (progress > 1.0 ? progress / 100.0 : progress).clamp(0.0, 1.0);
          setState(() => _localProgress = normalized);
        },
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          final savedName = path.split('/').last;
          await installer.copyFileToModsFolder(
            sourcePath: path,
            targetName: savedName,
          );
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.success(context,
              message: 'Saved to mods folder: $savedName');
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.error(context, message: 'Download failed');
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localDownloading = false;
        _localProgress = 0.0;
      });
      AppSnackbar.error(context, message: 'Error: ${e.toString()}');
    }
  }

  Future<void> _downloadWithFileDownloader(
      String url, String filename) async {
    if (!mounted) return;
    setState(() {
      _localDownloading = true;
      _localProgress = 0.0;
    });
    try {
      await FileDownloader.downloadFile(
        url: url,
        name: filename,
        onProgress: (name, progress) {
          if (!mounted) return;
          final normalized =
              (progress > 1.0 ? progress / 100.0 : progress).clamp(0.0, 1.0);
          setState(() => _localProgress = normalized);
        },
        onDownloadCompleted: (path) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          final savedName = path.split('/').last;
          AppSnackbar.success(context, message: 'Downloaded: $savedName');
          showPostInstallDialog(context);
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.error(context, message: 'Download failed');
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localDownloading = false;
        _localProgress = 0.0;
      });
      AppSnackbar.error(context, message: 'Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = widget.retro;
    final modName = _sanitizeModTitle(widget.modTitle);
    final info = ref.watch(bgInstallStateProvider)[modName];
    final isActive = _localDownloading ||
        (info != null &&
            (info.status == BgInstallStatus.downloading ||
             info.status == BgInstallStatus.installing));
    final downloadProgress = _localDownloading
        ? (_localProgress * 100).round()
        : (info?.status == BgInstallStatus.downloading
            ? info?.downloadProgress
            : null);

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
            color: retro.accent,
            border: Border.all(color: retro.border, width: 3),
            boxShadow: retro.hardShadow(),
          ),
          child: Center(
            child: isActive
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: downloadProgress != null
                              ? downloadProgress / 100.0
                              : null,
                          backgroundColor: retro.background.withValues(
                            alpha: 0.3,
                          ),
                          color: retro.background,
                          minHeight: 4,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _localDownloading
                              ? 'Downloading ${(_localProgress * 100).toStringAsFixed(0)}%'
                              : info?.status == BgInstallStatus.downloading
                                  ? 'Downloading ${downloadProgress ?? 0}%'
                                  : 'Installing...',
                          style: retro.heading(size: 11, color: retro.background),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: retro.background,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'DOWNLOAD',
                        style: retro.heading(size: 15, color: retro.background),
                      ),
                    ],
                  ),
          ),
        ),
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
    final retro = RetroTheme.of(context);
    final galleryHeight = (MediaQuery.orientationOf(context) ==
            Orientation.landscape)
        ? 140.0
        : 200.0;

    return Column(
      children: [
        SizedBox(
          height: galleryHeight,
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
                    borderRadius: RetroTheme.radius,
                    child: CachedNetworkImage(
                      imageUrl: widget.images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: retro.surfaceAlt,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: retro.border,
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: retro.surfaceAlt,
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: retro.border,
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
                      ? retro.accent
                      : retro.border.withValues(alpha: 0.3),
                  borderRadius: RetroTheme.radius,
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
                          borderRadius: RetroTheme.radius,
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
                        borderRadius: RetroTheme.radius,
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
    final retro = RetroTheme.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: retro.surfaceAlt,
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border.withValues(alpha: 0.35)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: retro.inkDim,
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
    final retro = RetroTheme.of(context);
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
              color: retro.inkDim,
              fontSize: 14,
              height: 1.65,
            ),
          ),
          secondChild: Text(
            text,
            style: TextStyle(
              color: retro.inkDim,
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
                    color: retro.accent,
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
                  color: retro.accent,
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
    final retro = RetroTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: retro.surface,
        borderRadius: RetroTheme.radius,
        border: Border.all(color: retro.border.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          if (firstRelease != null)
            Expanded(
              child: _DateCell(
                icon: Icons.rocket_launch_rounded,
                label: 'First Release',
                date: firstRelease!,
                retro: retro,
              ),
            ),
          if (firstRelease != null && lastUpdate != null)
            Container(
              width: 1,
              height: 36,
              color: retro.border.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
          if (lastUpdate != null)
            Expanded(
              child: _DateCell(
                icon: Icons.update_rounded,
                label: 'Last Update',
                date: lastUpdate!,
                retro: retro,
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
    required this.retro,
  });

  final IconData icon;
  final String label;
  final String date;
  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: retro.surfaceAlt,
            borderRadius: RetroTheme.radius,
          ),
          child: Icon(icon, size: 14, color: retro.inkDim),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: retro.inkDim,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formatDate(date) ?? date,
              style: TextStyle(
                color: retro.ink,
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
    final retro = RetroTheme.of(context);
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
                color: retro.surfaceAlt,
                borderRadius: RetroTheme.radius,
              ),
              child: Text(
                '${updates.length}',
                style: TextStyle(
                  color: retro.inkDim,
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
            retro: retro,
          );
        }),

        if (hasMore) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: retro.surfaceAlt,
                borderRadius: RetroTheme.radius,
                border: Border.all(color: retro.border.withValues(alpha: 0.3)),
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
                        color: retro.accent,
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
                      color: retro.accent,
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
    required this.retro,
  });

  final ModUpdate update;
  final int index;
  final bool isLast;
  final RetroTheme retro;

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
                  color: index == 0 ? retro.accent : retro.surfaceAlt,
                  borderRadius: RetroTheme.radius,
                  border: index != 0
                      ? Border.all(color: retro.border.withValues(alpha: 0.3))
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index == 0 ? retro.background : retro.inkDim,
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
                    color: retro.border.withValues(alpha: 0.2),
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
                        color: retro.ink,
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
                        color: retro.inkDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    update.changelog,
                    style: TextStyle(
                      color: retro.inkDim,
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
    final retro = RetroTheme.of(context);

    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: retro.inkDim,
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
    final retro = RetroTheme.of(context);

    return Scaffold(
      backgroundColor: retro.background,
      body: SingleChildScrollView(
        child: Column(
        children: [
          _Shimmer(height: 300),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Shimmer(height: 28),
                const SizedBox(height: 10),
                _Shimmer(height: 16, width: 160),
                const SizedBox(height: 20),
                _Shimmer(height: 80),
                const SizedBox(height: 20),
                _Shimmer(height: 54),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.height, this.width});

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
        decoration: BoxDecoration(color: retro.surface, borderRadius: RetroTheme.radius),
      ),
    );
  }
}

// ── Not found ─────────────────────────────────────────────────────────────────

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Scaffold(
      backgroundColor: retro.background,
      appBar: AppBar(backgroundColor: retro.background),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: retro.surfaceAlt,
                borderRadius: RetroTheme.radius,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 36,
                color: retro.border,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mod not found',
              style: TextStyle(
                color: retro.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'This mod may have been removed or the link is invalid.',
              style: TextStyle(color: retro.inkDim, fontSize: 13),
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
    final retro = RetroTheme.of(context);

    return Scaffold(
      backgroundColor: retro.background,
      appBar: AppBar(backgroundColor: retro.background),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: retro.accent),
              const SizedBox(height: 12),
              Text(
                'Failed to load mod',
                style: TextStyle(
                  color: retro.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: retro.inkDim, fontSize: 12),
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

// ── Background install status banner ───────────────────────────────────────────

class _InstallStatusBanner extends ConsumerWidget {
  const _InstallStatusBanner({required this.modTitle});

  final String modTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final modName = _sanitizeModTitle(modTitle);
    final state = ref.watch(bgInstallStateProvider);
    final info = state[modName];

    if (info == null) return const SizedBox.shrink();

    switch (info.status) {
      case BgInstallStatus.downloading:
        final progress = info.downloadProgress ?? 0;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: retro.accent.withValues(alpha: 0.15),
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress > 0 ? progress / 100.0 : null,
                  color: retro.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Downloading mod...',
                      style: TextStyle(
                        color: retro.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$progress%',
                      style: TextStyle(
                        color: retro.inkDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case BgInstallStatus.installing:
        final progressText = info.total != null && info.total! > 0
            ? '${info.current ?? 0}/${info.total} files'
            : 'Extracting...';
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: retro.accent.withValues(alpha: 0.15),
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: retro.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installing mod...',
                      style: TextStyle(
                        color: retro.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progressText,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case BgInstallStatus.completed:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: retro.accent.withValues(alpha: 0.08),
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.accent.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 20, color: retro.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installation complete',
                      style: TextStyle(
                        color: retro.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.fileCount ?? 0} files extracted to "${info.targetDir ?? modName}"',
                      style: TextStyle(
                        color: retro.inkDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case BgInstallStatus.error:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: retro.red.withValues(alpha: 0.4),
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.red.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_rounded, size: 20, color: retro.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installation failed',
                      style: TextStyle(
                        color: retro.ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (info.error != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.error!,
                        style: TextStyle(
                          color: retro.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );

      case BgInstallStatus.cancelled:
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: retro.surfaceAlt.withValues(alpha: 0.6),
            borderRadius: RetroTheme.radius,
            border: Border.all(color: retro.border.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.cancel_rounded, size: 20, color: retro.inkDim),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Operation cancelled',
                  style: TextStyle(
                    color: retro.inkDim,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

      case BgInstallStatus.pending:
        return const SizedBox.shrink();
    }
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

    // 2. Si el último segmento NO es "download" y tiene nombre con valor,
    //    añadir .zip (preserva puntos, ej: "retro-triple-baka-pack.418" → ".zip")
    if (lastSegment.isNotEmpty &&
        lastSegment != 'download' &&
        _validFileExtension(lastSegment).isEmpty &&
        lastSegment.length > 2 &&
        !RegExp(r'^\d+$').hasMatch(lastSegment)) {
      return '$lastSegment.zip';
    }

    // 3. Query param "file" con extensión válida
    final fileParam = uri.queryParameters['file'] ?? '';
    if (_validFileExtension(fileParam).isNotEmpty) {
      return fileParam;
    }
  }

  // 4. Fallback: nombre del mod sanitizado + índice opcional + .zip
  final base = _sanitizeModTitle(modTitle);
  final safeName = base.isNotEmpty ? base : 'mod';
  final suffix = index != null && index > 1 ? '-$index' : '';
  return '$safeName$suffix.zip';
}

