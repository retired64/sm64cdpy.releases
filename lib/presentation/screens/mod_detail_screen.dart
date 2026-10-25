import '../widgets/catalog_error_details.dart';
import '../widgets/deluxe_backdrop.dart';
import '../widgets/deluxe_content.dart';
import '../../services/deluxe_links.dart';

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
import '../../core/utils/mod_description_translation.dart';
import '../../l10n/app_localizations.dart';
import '../../domain/entities/mod_entity.dart';
import '../../domain/entities/install_identity.dart';
import '../../domain/entities/installation_action.dart';
import '../../domain/entities/mod_version_resolver.dart';
import '../../services/background_install_service.dart';
import '../../services/download_url_resolver.dart';
import '../../services/mod_installer.dart';
import '../providers/mod_providers.dart';
import '../providers/installation_action_provider.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/post_install_dialog.dart';
import '../widgets/installation_action_presentation.dart';
import '../widgets/dynos_install_flow.dart';

/// Fuente de lectura exclusiva de Deluxe, sin alterar títulos ni otros temas.
TextStyle _detailReadingStyle(
  RetroTheme retro,
  TextStyle base, {
  double scale = 1,
}) {
  if (!retro.isDeluxe) return base;
  return base.copyWith(
    fontFamily: 'FamiljenGrotesk',
    fontFamilyFallback: const ['Roboto'],
    fontWeight: FontWeight.w400,
    fontSize: ((base.fontSize ?? 16) < 16 ? 16 : base.fontSize!) * scale,
    letterSpacing: 0,
    height: 1.5,
  );
}

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

class _DetailScaffoldState extends ConsumerState<_DetailScaffold> {
  late final ScrollController _scrollCtrl;

  bool _descExpanded = false;
  bool _changelogExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final isFav = ref.watch(favouritesProvider).contains(widget.mod.id);

    return Scaffold(
      backgroundColor: retro.isMario ? Colors.transparent : retro.background,
      appBar: _buildAppBar(retro, isFav),
      body: DeluxeScene(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _ModHeader(mod: widget.mod),
              ),
            ),
            if (retro.isDeluxe && DeluxeLinks.hasDemo(widget.mod))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: const DeluxeDemoButton(),
                ),
              ),
            SliverToBoxAdapter(
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

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RetroTheme retro, bool isFav) {
    final bgColor = retro.background;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: retro.systemUiStyle,
        child: Container(
          color: bgColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  _GlassIconButton(
                    icon: Icons.arrow_back_ios_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    isAppBarSolid: true,
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
                    isAppBarSolid: true,
                    retro: retro,
                    activeColor: isFav ? retro.accentText : null,
                  ),
                  const SizedBox(width: 6),
                  _GlassIconButton(
                    icon: Icons.share_rounded,
                    onTap: () => _share(widget.mod),
                    isAppBarSolid: true,
                    retro: retro,
                  ),
                ],
              ),
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
    final retro = RetroTheme.of(context);
    final iconColor = activeColor ?? (isAppBarSolid ? retro.ink : Colors.white);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: retro.gameDecoration(
          BoxDecoration(
            borderRadius: retro.radius,
            color: isAppBarSolid
                ? retro.surfaceAlt
                : Colors.black.withValues(alpha: 0.42),
            border: Border.all(
              color: isAppBarSolid
                  ? retro.border.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.3),
              width: retro.borderWidth(1.5),
            ),
          ),
        ),
        child: MarioGameIcon(icon, size: 18, color: iconColor),
      ),
    );
  }
}

// ── Hero: fondo sólido + avatar bordeado ────────────────────────────────────
// Fondo de color sólido con el avatar del mod superpuesto abajo a la
// izquierda.

/// A bounded cover and title share one menu panel; no banner or overlap.
class _ModHeader extends StatelessWidget {
  const _ModHeader({required this.mod});
  final ModEntity mod;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final hasImage = mod.imageUrl?.isNotEmpty ?? false;
    final cover = Container(
      key: const ValueKey('mod-detail-cover'),
      width: 112,
      height: 112,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(3),
      decoration: retro.surfaceDecoration(border: 2, shadowDx: 2, shadowDy: 2),
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: mod.imageUrl!,
              fit: BoxFit.contain,
              memCacheWidth: 336,
              maxWidthDiskCache: 448,
              placeholder: (_, _) => _HeroPlaceholder(retro: retro),
              errorWidget: (_, _, _) => _HeroPlaceholder(retro: retro),
            )
          : _HeroPlaceholder(retro: retro),
    );
    return Container(
      key: const ValueKey('mod-detail-header'),
      padding: const EdgeInsets.all(16),
      decoration: retro.surfaceDecoration(shadowDx: 3, shadowDy: 3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 420 ||
              MediaQuery.textScalerOf(context).scale(16) > 22) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    cover,
                    if (mod.isFeatured)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: RetroBadgeDot(
                          retro: retro,
                          icon: Icons.star_rounded,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _TitleSection(mod: mod),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  cover,
                  if (mod.isFeatured)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: RetroBadgeDot(
                        retro: retro,
                        icon: Icons.star_rounded,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(child: _TitleSection(mod: mod)),
            ],
          );
        },
      ),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.retro});

  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      color: retro.surfaceAlt,
      child: Center(
        child: MarioGameIcon(
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatsBar(mod: mod),
          const SizedBox(height: 16),
          _DetailPanel(
            children: [
              _VersionAccordion(
                modId: mod.id,
                versions: mod.versions,
                downloadUrls: mod.downloadUrls,
                modUrl: mod.url,
                modTitle: mod.title,
              ),
            ],
          ),
          if (mod.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              children: [
                _AboutDescription(
                  mod: mod,
                  expanded: descExpanded,
                  onToggle: onExpandDesc,
                ),
              ],
            ),
          ],
          if (mod.descriptionImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              children: [
                _SectionTitle(label: l10n.detailScreenshots),
                const SizedBox(height: 12),
                _ScreenshotGallery(images: mod.descriptionImages),
              ],
            ),
          ],
          if (mod.descriptionVideos.any((video) => video.isYouTube)) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              children: [
                _SectionTitle(label: l10n.detailYoutubeVideos),
                const SizedBox(height: 12),
                _DescriptionVideoGallery(
                  videos: mod.descriptionVideos
                      .where((video) => video.isYouTube)
                      .toList(growable: false),
                ),
              ],
            ),
          ],
          if (mod.descriptionVideos.any((video) => !video.isYouTube)) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              children: [
                _SectionTitle(label: l10n.detailDirectVideos),
                const SizedBox(height: 12),
                _DescriptionVideoGallery(
                  videos: mod.descriptionVideos
                      .where((video) => !video.isYouTube)
                      .toList(growable: false),
                ),
              ],
            ),
          ],
          if (mod.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              children: [
                _SectionTitle(label: l10n.detailTags),
                const SizedBox(height: 12),
                _TagCloud(tags: mod.tags),
              ],
            ),
          ],
          if (mod.threadUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => launchUrl(
                Uri.parse(mod.threadUrl),
                mode: LaunchMode.externalApplication,
              ),
              icon: const MarioGameIcon(Icons.forum_outlined, size: 18),
              label: Text(l10n.detailViewDiscussion),
            ),
          ],
          if (mod.firstRelease != null || mod.lastUpdate != null) ...[
            const SizedBox(height: 16),
            _ReleaseDates(
              firstRelease: mod.firstRelease,
              lastUpdate: mod.lastUpdate,
            ),
          ],
          if (mod.updates.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailPanel(
              children: [
                _ChangelogSection(
                  updates: mod.updates,
                  expanded: changelogExpanded,
                  onToggle: onExpandChangelog,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: RetroTheme.of(
      context,
    ).surfaceDecoration(shadowDx: 2, shadowDy: 2),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

// ── Title section ─────────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.mod});

  final ModEntity mod;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final titleStyle = retro.heading(
      size: retro.isMario ? 19 : 22,
      letterSpacing: 0,
      height: 1.3,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título limpio, sin efecto estampado.
        Text(
          catalogTitle(mod.title, AppLocalizations.of(context).sharedUntitled),
          style: titleStyle,
          softWrap: true,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: retro.gameDecoration(
                BoxDecoration(borderRadius: retro.radius, color: retro.accent),
              ),
              child: MarioGameIcon(
                Icons.person_rounded,
                size: 14,
                color: retro.inkOnAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: mod.authorUrl.isEmpty
                    ? null
                    : () => launchUrl(
                        Uri.parse(mod.authorUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                child: Text(
                  mod.author,
                  style: _detailReadingStyle(
                    retro,
                    retro.body(
                      size: 14,
                      weight: FontWeight.w700,
                      color: retro.ink,
                    ),
                    scale: 0.75,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 10),
            RetroTag(
              retro: retro,
              label: 'v${mod.version.replaceFirst(RegExp(r'^v'), '')}',
            ),
          ],
        ),
        if (mod.category.isNotEmpty) ...[
          const SizedBox(height: 10),
          RetroTag(retro: retro, label: retro.displayLabel(mod.category)),
        ],
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
    final l10n = AppLocalizations.of(context);

    return Container(
      key: const ValueKey('mod-detail-stats'),
      padding: const EdgeInsets.all(14),
      decoration: retro.surfaceDecoration(shadowDx: 2, shadowDy: 2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns =
              constraints.maxWidth >= 560 &&
                  MediaQuery.textScalerOf(context).scale(16) <= 22
              ? 4
              : 2;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 18,
            children: [
              SizedBox(
                width: width,
                child: _StatCell(
                  value:
                      mod.rating?.starFor(
                        AppLocalizations.of(context).localeName,
                      ) ??
                      '—',
                  label: l10n.detailRating,
                  icon: Icons.star_rounded,
                  iconColor: retro.amber,
                  retro: retro,
                ),
              ),
              SizedBox(
                width: width,
                child: _StatCell(
                  value: mod.downloads.compactFor(
                    AppLocalizations.of(context).localeName,
                  ),
                  label: l10n.detailDownloads,
                  icon: Icons.download_rounded,
                  iconColor: retro.accentText,
                  retro: retro,
                ),
              ),
              SizedBox(
                width: width,
                child: _StatCell(
                  value: mod.views.compactFor(
                    AppLocalizations.of(context).localeName,
                  ),
                  label: l10n.detailViews,
                  icon: Icons.visibility_rounded,
                  iconColor: retro.inkDim,
                  retro: retro,
                ),
              ),
              SizedBox(
                width: width,
                child: _StatCell(
                  value: mod.reviewCount.compactFor(
                    AppLocalizations.of(context).localeName,
                  ),
                  label: l10n.detailReviews,
                  icon: Icons.rate_review_rounded,
                  iconColor: retro.inkDim,
                  retro: retro,
                ),
              ),
            ],
          );
        },
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
    final retro = RetroTheme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MarioGameIcon(icon, size: 16, color: iconColor),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: retro.ink,
            fontSize: retro.isMario ? 17 : 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: retro.inkDim,
            fontSize: retro.isMario ? 16 : 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VersionAccordion extends StatefulWidget {
  const _VersionAccordion({
    required this.modId,
    required this.versions,
    required this.downloadUrls,
    required this.modUrl,
    required this.modTitle,
  });

  final String modId;
  final List<ModVersionEntity> versions;
  final List<String> downloadUrls;
  final String modUrl;
  final String modTitle;

  @override
  State<_VersionAccordion> createState() => _VersionAccordionState();
}

class _VersionAccordionState extends State<_VersionAccordion> {
  AppLocalizations? _l10n;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    _l10n = AppLocalizations.of(context);

    if (widget.versions.isNotEmpty) {
      return _buildVersionList(retro);
    }

    final displayUrls = widget.downloadUrls.isNotEmpty
        ? widget.downloadUrls
        : [widget.modUrl];

    if (displayUrls.length == 1) {
      return _PrimaryDownloadButton(
        url: displayUrls.first,
        modId: widget.modId,
        fileKey: 'primary',
        modTitle: widget.modTitle,
        retro: retro,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: _l10n!.detailDownloadFiles(displayUrls.length)),
        const SizedBox(height: 10),
        ...displayUrls.asMap().entries.map(
          (e) => _BuildDownloadButton(
            url: e.value,
            modId: widget.modId,
            fileKey: 'file-${e.key}',
            modTitle: widget.modTitle,
            retro: retro,
            label: '${e.key + 1}. ${_extractFilename(e.value)}',
          ),
        ),
      ],
    );
  }

  Widget _buildVersionList(RetroTheme retro) {
    final latest = resolveLatestDownloadableVersion(widget.versions);
    if (latest == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(label: _l10n!.detailVersions(widget.versions.length)),
          const SizedBox(height: 10),
          ...widget.versions.asMap().entries.map(
            (entry) => _VersionCard(
              modId: widget.modId,
              modTitle: widget.modTitle,
              versionIndex: entry.key,
              version: entry.value,
              initiallyExpanded: entry.key == 0,
            ),
          ),
        ],
      );
    }
    final previous = widget.versions
        .asMap()
        .entries
        .where(
          (entry) =>
              entry.key != latest.versionIndex &&
              (entry.value.files.any(
                    (file) => file.downloadUrl.trim().isNotEmpty,
                  ) ||
                  entry.value.folderUrl.trim().isNotEmpty),
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label: _l10n!.detailVersions(widget.versions.length)),
        const SizedBox(height: 10),
        Text(
          _l10n!.detailLatestVersion,
          style: retro.body(
            size: 10,
            weight: FontWeight.w800,
            color: retro.accentText,
          ),
        ),
        const SizedBox(height: 6),
        _VersionCard(
          modId: widget.modId,
          modTitle: widget.modTitle,
          versionIndex: latest.versionIndex,
          version: latest.version,
          initiallyExpanded: true,
          collapsible: false,
        ),
        if (previous.isNotEmpty) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showVersionHistory(previous),
              icon: const MarioGameIcon(Icons.history_rounded, size: 18),
              label: Text(_l10n!.detailViewPreviousVersions(previous.length)),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showVersionHistory(
    List<MapEntry<int, ModVersionEntity>> previous,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.94,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: RetroTheme.of(context).gameDecoration(
                BoxDecoration(
                  color: RetroTheme.of(context).inkDim.withValues(alpha: 0.4),
                  borderRadius: RetroTheme.of(context).radius,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _l10n!.detailPreviousVersions,
                      style: RetroTheme.of(
                        context,
                      ).heading(size: 17, weight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const MarioGameIcon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: previous.length,
                itemBuilder: (context, index) {
                  final entry = previous[index];
                  return _VersionCard(
                    modId: widget.modId,
                    modTitle: widget.modTitle,
                    versionIndex: entry.key,
                    version: entry.value,
                  );
                },
              ),
            ),
          ],
        ),
      ),
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
    } catch (e) {
      debugPrint('_extractFilename: $e');
    }
    return url.split('/').last;
  }
}

class _VersionCard extends StatefulWidget {
  const _VersionCard({
    required this.modId,
    required this.modTitle,
    required this.versionIndex,
    required this.version,
    this.initiallyExpanded = false,
    this.collapsible = true,
  });

  final String modId;
  final String modTitle;
  final int versionIndex;
  final ModVersionEntity version;
  final bool initiallyExpanded;
  final bool collapsible;

  @override
  State<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends State<_VersionCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final files = widget.version.files.asMap().entries.where(
      (entry) => entry.value.downloadUrl.trim().isNotEmpty,
    );
    final folderUrl = widget.version.folderUrl.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: retro.gameDecoration(
        BoxDecoration(
          color: retro.surfaceAlt,
          borderRadius: retro.radius,
          border: Border.all(color: retro.border.withValues(alpha: 0.4)),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: retro.radius,
            onTap: widget.collapsible
                ? () => setState(() => _expanded = !_expanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (widget.collapsible) ...[
                    MarioGameIcon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: retro.ink,
                    ),
                    const SizedBox(width: 8),
                  ],
                  RetroTag(
                    retro: retro,
                    label: widget.version.version.isEmpty
                        ? l10n.detailVersionFallback
                        : widget.version.version,
                  ),
                  Text(
                    formatDate(
                          widget.version.releaseDate,
                          locale: l10n.localeName,
                        ) ??
                        widget.version.releaseDate,
                    style: retro.body(size: 11, color: retro.inkDim),
                  ),
                  if (widget.version.downloads > 0) ...[
                    const SizedBox(width: 10),
                    MarioGameIcon(
                      Icons.download_rounded,
                      size: 13,
                      color: retro.accentText,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.version.downloads.toString(),
                      style: retro.body(size: 11, weight: FontWeight.w700),
                    ),
                  ],
                  if (widget.version.rating != null) ...[
                    const SizedBox(width: 8),
                    MarioGameIcon(
                      Icons.star_rounded,
                      size: 13,
                      color: retro.amber,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.version.rating!.starFor(
                        AppLocalizations.of(context).localeName,
                      ),
                      style: retro.body(size: 11, weight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded)
            ...files.map(
              (fileEntry) => Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: _PrimaryDownloadButton(
                  url: fileEntry.value.downloadUrl,
                  modId: widget.modId,
                  fileKey: fileEntry.value.id,
                  versionId: widget.version.id,
                  legacyFileKeys: [
                    'version-${widget.versionIndex}-file-${fileEntry.key}',
                  ],
                  modTitle: widget.modTitle,
                  filename: fileEntry.value.filename,
                  versionLabel: widget.version.version,
                  retro: retro,
                ),
              ),
            ),
          if (_expanded && folderUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(folderUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const MarioGameIcon(
                    Icons.open_in_new_rounded,
                    size: 17,
                  ),
                  label: Text(l10n.detailOpenExternalFolder),
                ),
              ),
            ),
          if (_expanded && files.isEmpty && folderUrl.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                l10n.detailSourceUnavailable,
                style: retro.body(size: 11, color: retro.inkDim),
              ),
            ),
        ],
      ),
    );
  }
}

class _BuildDownloadButton extends ConsumerStatefulWidget {
  const _BuildDownloadButton({
    required this.url,
    required this.modId,
    required this.fileKey,
    required this.modTitle,
    required this.retro,
    required this.label,
  });

  final String url;
  final String modId;
  final String fileKey;
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
  AppLocalizations? _l10n;

  InstallIdentity get _identity => InstallIdentity.forCatalogArtifact(
    section: InstallSection.mods,
    contentId: widget.modId,
    downloadUrl: widget.url,
    explicitFileId: widget.fileKey,
  );

  String get _operationName => _identity.operationKey;

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
            title: Text(
              _l10n!.detailNotificationsNeeded,
              style: TextStyle(color: RetroTheme.of(ctx).ink),
            ),
            content: Text(
              _l10n!.detailNotificationsBody,
              style: TextStyle(color: RetroTheme.of(ctx).inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  _l10n!.detailNotNow,
                  style: TextStyle(color: RetroTheme.of(ctx).ink),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(_l10n!.detailContinue),
              ),
            ],
          ),
        );
        if (proceed != true && mounted) {
          AppSnackbar.info(context, message: _l10n!.detailNotificationsSkipped);
        }
      }

      if (!mounted) return;
      final granted = await _installer.requestNotificationPermission();
      if (!granted && mounted) {
        AppSnackbar.info(context, message: _l10n!.detailNotificationsDisabled);
      }
    }

    final modName = _operationName;
    final resolvedUrl = await DownloadUrlResolver.instance.resolveDownloadUrl(
      widget.url,
    );
    final filename = await DownloadUrlResolver.instance.resolveDownloadFilename(
      resolvedUrl,
      widget.modTitle,
    );

    final hasFolder = await _installer.isDirectorySelected();

    if (!hasFolder) {
      final prefs = await SharedPreferences.getInstance();
      final autoInstall =
          prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

      if (autoInstall && mounted) {
        final goToSettings = await showModsFolderRequiredDialog(context);
        if (goToSettings && mounted) {
          GoRouter.of(context).go('/settings');
        }
        return;
      }

      if (!mounted) return;
      await _downloadWithFileDownloader(resolvedUrl, filename);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

    if (autoInstall && mounted) {
      final chain = await BackgroundInstallService.instance
          .startDownloadAndInstall(
            url: resolvedUrl,
            modName: modName,
            fileName: filename,
            displayTitle: widget.modTitle,
            identity: _identity,
          );
      if (!mounted) return;
      if (chain != null) {
        AppSnackbar.info(context, message: _l10n!.detailDownloading(filename));
      } else {
        // Fallback: el encolado de WorkManager falló silenciosamente
        // (ej. restricciones de Android 14+). Descargamos y extraemos inline.
        await _downloadToModsFolder(
          _installer,
          resolvedUrl,
          filename,
          extract: true,
          modName: modName,
        );
      }
    } else if (mounted) {
      await _downloadToModsFolder(_installer, resolvedUrl, filename);
    }
  }

  Future<void> _downloadToModsFolder(
    ModInstaller installer,
    String url,
    String filename, {
    bool extract = false,
    String? modName,
  }) async {
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
          final normalized = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          setState(() => _localProgress = normalized);
        },
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          final savedName = path.split('/').last;
          String? copyError;
          try {
            if (extract && savedName.toLowerCase().endsWith('.zip')) {
              final result = await installer.installMod(
                zipPath: path,
                modName: modName ?? savedName,
              );
              if (!result.success) {
                copyError = result.errorMessage ?? _l10n!.detailInstallFailed;
              }
            } else {
              await installer.copyFileToModsFolder(
                sourcePath: path,
                targetName: savedName,
              );
            }
          } catch (e) {
            copyError = e.toString();
          }
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          if (copyError != null) {
            AppSnackbar.errorWithCopy(
              context,
              message: AppLocalizations.of(context).detailInstallFailed,
              copyText: copyError,
            );
          } else {
            AppSnackbar.success(
              context,
              message: _l10n!.detailSavedToFolder(savedName, 'mod'),
            );
          }
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.errorWithCopy(
            context,
            message: friendlyDownloadError(_l10n!, error),
            copyText: error,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localDownloading = false;
        _localProgress = 0.0;
      });
      AppSnackbar.errorWithCopy(
        context,
        message: friendlyDownloadError(_l10n!, e),
        copyText: e.toString(),
      );
    }
  }

  Future<void> _downloadWithFileDownloader(String url, String filename) async {
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
          final normalized = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          setState(() => _localProgress = normalized);
        },
        onDownloadCompleted: (path) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          final savedName = path.split('/').last;
          AppSnackbar.success(
            context,
            message: _l10n!.detailDownloadedType(savedName, 'mod'),
          );
          showPostInstallDialog(context);
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.errorWithCopy(
            context,
            message: friendlyDownloadError(_l10n!, error),
            copyText: error,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localDownloading = false;
        _localProgress = 0.0;
      });
      AppSnackbar.errorWithCopy(
        context,
        message: friendlyDownloadError(_l10n!, e),
        copyText: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    _l10n = AppLocalizations.of(context);
    final actionState = ref.watch(installationActionProvider(_identity));
    final action = actionState.primaryAction;
    final isDownloading = _localDownloading || actionState.isOperationActive;
    final progress = _localDownloading ? _localProgress : actionState.progress;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: retro.gameDecoration(
        BoxDecoration(
          color: retro.surface,
          borderRadius: retro.radius,
          border: Border.all(color: retro.border.withValues(alpha: 0.4)),
        ),
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
                  child: isDownloading
                      ? CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 2.5,
                          color: retro.accent,
                          backgroundColor: retro.border,
                        )
                      : MarioGameIcon(
                          Icons.insert_drive_file_rounded,
                          size: 28,
                          color: retro.accentText,
                        ),
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
            height: retro.isMario ? null : 34,
            child: FilledButton.icon(
              onPressed:
                  (_localDownloading && !actionState.isOperationActive) ||
                      action == InstallationPrimaryAction.checking ||
                      action == InstallationPrimaryAction.installed
                  ? null
                  : () => runCanonicalInstallationAction(
                      context: context,
                      ref: ref,
                      state: actionState,
                      onTransfer: _download,
                    ),
              icon: MarioGameIcon(action.icon, size: 14),
              label: Text(action.label(_l10n!)),
              style: FilledButton.styleFrom(
                backgroundColor: retro.accent,
                foregroundColor: retro.inkOnAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: retro.radius,
                  side: retro.usesComicSurfaces
                      ? BorderSide(
                          color: retro.border,
                          width: retro.borderWidth(2),
                        )
                      : BorderSide.none,
                ),
                textStyle: TextStyle(
                  fontSize: retro.isMario ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
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
    required this.modId,
    required this.fileKey,
    required this.modTitle,
    required this.retro,
    this.filename,
    this.versionLabel,
    this.versionId,
    this.legacyFileKeys = const <String>[],
  });

  final String url;
  final String modId;
  final String fileKey;
  final String modTitle;
  final RetroTheme retro;
  final String? filename;
  final String? versionLabel;
  final String? versionId;
  final List<String> legacyFileKeys;

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
  AppLocalizations? _l10n;

  InstallIdentity get _identity => InstallIdentity.forCatalogArtifact(
    section: InstallSection.mods,
    contentId: widget.modId,
    downloadUrl: widget.url,
    versionLabel: widget.versionLabel,
    fileName: widget.filename,
    explicitVersionId: widget.versionId,
    explicitFileId: widget.fileKey,
    legacyExplicitFileIds: widget.legacyFileKeys,
  );

  String get _operationName => _identity.operationKey;

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
            backgroundColor: RetroTheme.of(ctx).surfaceAlt,
            title: Text(
              _l10n!.detailNotificationsNeeded,
              style: TextStyle(color: RetroTheme.of(ctx).ink),
            ),
            content: Text(
              _l10n!.detailNotificationsBody,
              style: TextStyle(color: RetroTheme.of(ctx).inkDim),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  _l10n!.detailNotNow,
                  style: TextStyle(color: RetroTheme.of(ctx).ink),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(_l10n!.detailContinue),
              ),
            ],
          ),
        );

        if (proceed != true && mounted) {
          AppSnackbar.info(context, message: _l10n!.detailNotificationsSkipped);
        }
      }

      if (!mounted) return;
      final granted = await installer.requestNotificationPermission();
      if (!granted && mounted) {
        AppSnackbar.info(context, message: _l10n!.detailNotificationsDisabled);
      }
    }

    final modName = _operationName;
    final resolvedUrl = await DownloadUrlResolver.instance.resolveDownloadUrl(
      widget.url,
    );
    final filename =
        widget.filename ??
        await DownloadUrlResolver.instance.resolveDownloadFilename(
          resolvedUrl,
          widget.modTitle,
        );

    final hasFolder = await installer.isDirectorySelected();

    if (!hasFolder) {
      final prefs = await SharedPreferences.getInstance();
      final autoInstall =
          prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

      if (autoInstall && mounted) {
        final goToSettings = await showModsFolderRequiredDialog(context);
        if (goToSettings && mounted) {
          GoRouter.of(context).go('/settings');
        }
        return;
      }

      if (!mounted) return;
      await _downloadWithFileDownloader(resolvedUrl, filename);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

    if (autoInstall && mounted) {
      final chain = await BackgroundInstallService.instance
          .startDownloadAndInstall(
            url: resolvedUrl,
            modName: modName,
            fileName: filename,
            displayTitle: widget.modTitle,
            notificationTitle:
                widget.versionLabel == null || widget.versionLabel!.isEmpty
                ? widget.modTitle
                : '${widget.modTitle} · ${widget.versionLabel}',
            identity: _identity,
          );
      if (!mounted) return;
      if (chain != null) {
        AppSnackbar.info(context, message: _l10n!.detailDownloading(filename));
      } else {
        // Fallback: el encolado de WorkManager falló silenciosamente
        // (ej. restricciones de Android 14+). Descargamos y extraemos inline.
        await _downloadToModsFolder(
          installer,
          resolvedUrl,
          filename,
          extract: true,
          modName: modName,
        );
      }
    } else if (mounted) {
      await _downloadToModsFolder(installer, resolvedUrl, filename);
    }
  }

  Future<void> _downloadToModsFolder(
    ModInstaller installer,
    String url,
    String filename, {
    bool extract = false,
    String? modName,
  }) async {
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
          final normalized = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          setState(() => _localProgress = normalized);
        },
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          final savedName = path.split('/').last;
          String? copyError;
          try {
            if (extract && savedName.toLowerCase().endsWith('.zip')) {
              final result = await installer.installMod(
                zipPath: path,
                modName: modName ?? savedName,
              );
              if (!result.success) {
                copyError = result.errorMessage ?? _l10n!.detailInstallFailed;
              }
            } else {
              await installer.copyFileToModsFolder(
                sourcePath: path,
                targetName: savedName,
              );
            }
          } catch (e) {
            copyError = e.toString();
          }
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          if (copyError != null) {
            AppSnackbar.errorWithCopy(
              context,
              message: AppLocalizations.of(context).detailInstallFailed,
              copyText: copyError,
            );
          } else {
            AppSnackbar.success(
              context,
              message: _l10n!.detailSavedToFolder(savedName, 'mod'),
            );
          }
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.errorWithCopy(
            context,
            message: friendlyDownloadError(_l10n!, error),
            copyText: error,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localDownloading = false;
        _localProgress = 0.0;
      });
      AppSnackbar.errorWithCopy(
        context,
        message: friendlyDownloadError(_l10n!, e),
        copyText: e.toString(),
      );
    }
  }

  Future<void> _downloadWithFileDownloader(String url, String filename) async {
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
          final normalized = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          setState(() => _localProgress = normalized);
        },
        onDownloadCompleted: (path) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          final savedName = path.split('/').last;
          AppSnackbar.success(
            context,
            message: _l10n!.detailDownloadedType(savedName, 'mod'),
          );
          showPostInstallDialog(context);
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _localDownloading = false;
            _localProgress = 0.0;
          });
          AppSnackbar.errorWithCopy(
            context,
            message: friendlyDownloadError(_l10n!, error),
            copyText: error,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localDownloading = false;
        _localProgress = 0.0;
      });
      AppSnackbar.errorWithCopy(
        context,
        message: friendlyDownloadError(_l10n!, e),
        copyText: e.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    _l10n = AppLocalizations.of(context);
    final actionState = ref.watch(installationActionProvider(_identity));
    final action = actionState.primaryAction;
    final info = actionState.operation;
    final isActive = _localDownloading || actionState.isOperationActive;
    final downloadProgress = _localDownloading
        ? (_localProgress * 100).round()
        : (info?.status == BgInstallStatus.downloading
              ? info?.downloadProgress
              : null);
    final isInstalling =
        info != null && info.status == BgInstallStatus.installing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => _scaleCtrl.forward(),
          onTapUp: (_) async {
            _scaleCtrl.reverse();
            if ((!_localDownloading || actionState.isOperationActive) &&
                action != InstallationPrimaryAction.checking &&
                action != InstallationPrimaryAction.installed) {
              await runCanonicalInstallationAction(
                context: context,
                ref: ref,
                state: actionState,
                onTransfer: _download,
              );
            }
          },
          onTapCancel: () => _scaleCtrl.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: retro.gameDecoration(
                BoxDecoration(
                  color: isActive
                      ? retro.accent.withValues(alpha: 0.12)
                      : retro.accent.withValues(alpha: 0.12),
                  border: Border.all(
                    color: retro.accent,
                    width: retro.borderWidth(2),
                  ),
                  borderRadius: retro.radius,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MarioGameIcon(
                      isActive ? Icons.downloading_rounded : action.icon,
                      color: retro.accentText,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        isActive
                            ? '${downloadProgress ?? (_localProgress * 100).round()}% · ${action.label(_l10n!)}'
                            : action.label(_l10n!),
                        textAlign: TextAlign.center,
                        style: retro.isMario
                            ? retro.body(size: 18, color: retro.accentText)
                            : retro.heading(size: 15, color: retro.accentText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: retro.gameDecoration(
              BoxDecoration(
                color: retro.accent.withValues(alpha: 0.08),
                borderRadius: retro.radius,
                border: Border.all(color: retro.accent.withValues(alpha: 0.15)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: isInstalling
                      ? null
                      : downloadProgress != null
                      ? downloadProgress / 100.0
                      : null,
                  backgroundColor: retro.accent.withValues(alpha: 0.15),
                  color: retro.accent,
                  minHeight: 4,
                ),
                const SizedBox(height: 8),
                Text(
                  isInstalling
                      ? info.total != null && info.total! > 0
                            ? _l10n!.detailFilesProgress(
                                info.current ?? 0,
                                info.total!,
                              )
                            : _l10n!.detailExtracting
                      : _l10n!.detailDownloadingBannerType('mod'),
                  style: retro.body(
                    size: 12,
                    weight: FontWeight.w600,
                    color: retro.inkDim,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (actionState.canReinstall)
          TextButton.icon(
            onPressed: _download,
            icon: const MarioGameIcon(Icons.refresh_rounded, size: 15),
            label: Text(_l10n!.installationReinstall),
          ),
      ],
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
    final galleryHeight =
        (MediaQuery.orientationOf(context) == Orientation.landscape)
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
                    borderRadius: retro.radius,
                    child: CachedNetworkImage(
                      imageUrl: widget.images[i],
                      fit: BoxFit.cover,
                      memCacheWidth: 720,
                      maxWidthDiskCache: 960,
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
                        child: MarioGameIcon(
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
                decoration: retro.gameDecoration(
                  BoxDecoration(
                    color: _activeIndex == i
                        ? retro.accent
                        : retro.border.withValues(alpha: 0.3),
                    borderRadius: retro.radius,
                  ),
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

class _DescriptionVideoGallery extends StatelessWidget {
  const _DescriptionVideoGallery({required this.videos});

  final List<ModVideoEntity> videos;

  Future<void> _open(ModVideoEntity video) async {
    final uri = Uri.tryParse(video.url);
    if (uri == null || uri.scheme != 'https') return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: videos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final video = videos[index];
          return Semantics(
            button: true,
            label: video.isYouTube
                ? '${l10n.socialYouTube} ${index + 1}'
                : '${l10n.detailDirectVideos} ${index + 1}',
            child: InkWell(
              onTap: () => _open(video),
              borderRadius: retro.radius,
              child: Container(
                width: 220,
                clipBehavior: Clip.antiAlias,
                decoration: retro.surfaceDecoration(shadowDx: 2, shadowDy: 2),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (video.thumbnailUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 720,
                        maxWidthDiskCache: 960,
                        placeholder: (_, _) =>
                            ColoredBox(color: retro.surfaceAlt),
                        errorWidget: (_, _, _) => ColoredBox(
                          color: retro.surfaceAlt,
                          child: MarioGameIcon(
                            Icons.ondemand_video_rounded,
                            color: retro.accentText,
                          ),
                        ),
                      )
                    else
                      ColoredBox(
                        color: retro.surfaceAlt,
                        child: MarioGameIcon(
                          Icons.movie_outlined,
                          size: 42,
                          color: retro.accentText,
                        ),
                      ),
                    ColoredBox(color: Colors.black.withValues(alpha: 0.16)),
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xD9FF0000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
    final retro = RetroTheme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
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
                          decoration: retro.gameDecoration(
                            BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: retro.radius,
                            ),
                          ),
                          child: const MarioGameIcon(
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
                        decoration: retro.gameDecoration(
                          BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: retro.radius,
                          ),
                        ),
                        child: Text(
                          '${_current + 1} / ${widget.images.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: retro.isMario ? 16 : 13,
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
          decoration: retro.gameDecoration(
            BoxDecoration(
              color: retro.surfaceAlt,
              borderRadius: retro.radius,
              border: Border.all(color: retro.border.withValues(alpha: 0.35)),
            ),
          ),
          child: Text(
            tag,
            style: _detailReadingStyle(
              retro,
              TextStyle(
                color: retro.inkDim,
                fontSize: retro.isMario ? 16 : 12,
                fontWeight: FontWeight.w600,
              ),
              scale: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Translatable description ──────────────────────────────────────────────────

class _AboutDescription extends StatefulWidget {
  const _AboutDescription({
    required this.mod,
    required this.expanded,
    required this.onToggle,
  });

  final ModEntity mod;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  State<_AboutDescription> createState() => _AboutDescriptionState();
}

class _AboutDescriptionState extends State<_AboutDescription> {
  bool _showOriginal = false;
  String? _localeTag;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    if (_localeTag != localeTag) {
      _localeTag = localeTag;
      _showOriginal = false;
    }
  }

  @override
  void didUpdateWidget(covariant _AboutDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mod.id != widget.mod.id ||
        oldWidget.mod.descriptionTranslations !=
            widget.mod.descriptionTranslations) {
      _showOriginal = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeTag =
        _localeTag ?? Localizations.localeOf(context).toLanguageTag();
    final translation = resolveDescriptionTranslation(
      description: widget.mod.description,
      translations: widget.mod.descriptionTranslations,
      localeTag: localeTag,
    );
    final showingTranslation = translation != null && !_showOriginal;
    final toggleTooltip = _showOriginal
        ? l10n.detailDescriptionViewTranslation
        : l10n.detailDescriptionViewOriginal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: KeyedSubtree(
                key: const ValueKey('mod-description-about-heading'),
                child: _SectionTitle(label: l10n.detailAbout),
              ),
            ),
            if (translation != null) ...[
              const SizedBox(width: 4),
              IconButton(
                key: const ValueKey('mod-description-language-toggle'),
                tooltip: toggleTooltip,
                onPressed: () => setState(() => _showOriginal = !_showOriginal),
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.all(8),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                icon: Image.asset(
                  'assets/icons/translate.webp',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        _ExpandableText(
          text: showingTranslation ? translation : widget.mod.description,
          expanded: widget.expanded,
          onToggle: widget.onToggle,
        ),
      ],
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
    final l10n = AppLocalizations.of(context);
    final isLong = text.length > AppConstants.descriptionMaxLen;

    final baseStyle = _detailReadingStyle(
      retro,
      TextStyle(
        color: retro.inkDim,
        fontSize: retro.isMario ? 18 : 14,
        fontFamily: retro.isMario ? 'Roboto' : retro.bodyFamily,
        letterSpacing: 0,
        height: 1.5,
      ),
      scale: 0.75,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: expanded || !isLong
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            text,
            maxLines: AppConstants.descriptionMaxLines,
            overflow: TextOverflow.ellipsis,
            style: baseStyle,
          ),
          secondChild: Text(text, style: baseStyle),
        ),
        if (isLong) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    expanded ? l10n.detailShowLess : l10n.detailShowMore,
                    style: TextStyle(
                      color: retro.accentText,
                      fontSize: retro.isMario ? 16 : 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                MarioGameIcon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: retro.accentText,
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
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useStackedLayout = constraints.maxWidth < 360 || textScale > 1.15;

        final firstCell = firstRelease == null
            ? null
            : _DateCell(
                icon: Icons.rocket_launch_rounded,
                label: l10n.detailFirstRelease,
                date: firstRelease!,
                retro: retro,
                boxed: useStackedLayout,
              );
        final lastCell = lastUpdate == null
            ? null
            : _DateCell(
                icon: Icons.update_rounded,
                label: l10n.detailLastUpdate,
                date: lastUpdate!,
                retro: retro,
                boxed: useStackedLayout,
              );

        if (useStackedLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ?firstCell,
              if (firstCell != null && lastCell != null)
                const SizedBox(height: 8),
              ?lastCell,
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: retro.gameDecoration(
            BoxDecoration(
              color: retro.surface,
              borderRadius: retro.radius,
              border: Border.all(color: retro.border.withValues(alpha: 0.35)),
            ),
          ),
          child: Row(
            children: [
              if (firstCell != null) Expanded(child: firstCell),
              if (firstCell != null && lastCell != null)
                Container(
                  width: 1,
                  height: 40,
                  color: retro.border.withValues(alpha: 0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
              if (lastCell != null) Expanded(child: lastCell),
            ],
          ),
        );
      },
    );
  }
}

class _DateCell extends StatelessWidget {
  const _DateCell({
    required this.icon,
    required this.label,
    required this.date,
    required this.retro,
    this.boxed = false,
  });

  final IconData icon;
  final String label;
  final String date;
  final RetroTheme retro;
  final bool boxed;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final content = Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: retro.gameDecoration(
            BoxDecoration(color: retro.surfaceAlt, borderRadius: retro.radius),
          ),
          child: MarioGameIcon(icon, size: 14, color: retro.inkDim),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _detailReadingStyle(
                  retro,
                  TextStyle(
                    color: retro.inkDim,
                    fontSize: retro.isMario ? 16 : 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: retro.isMario ? 0 : 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatDate(date, locale: l10n.localeName) ?? date,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _detailReadingStyle(
                  retro,
                  TextStyle(
                    color: retro.ink,
                    fontSize: retro.isMario ? 16 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (!boxed) return content;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: retro.gameDecoration(
        BoxDecoration(
          color: retro.surface,
          borderRadius: retro.radius,
          border: Border.all(color: retro.border.withValues(alpha: 0.35)),
        ),
      ),
      child: content,
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
    final l10n = AppLocalizations.of(context);
    final visible = expanded ? updates : updates.take(_previewCount).toList();
    final hasMore = updates.length > _previewCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionTitle(label: l10n.detailChangelog),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: retro.gameDecoration(
                BoxDecoration(
                  color: retro.surfaceAlt,
                  borderRadius: retro.radius,
                ),
              ),
              child: Text(
                '${updates.length}',
                style: TextStyle(
                  color: retro.inkDim,
                  fontSize: retro.isMario ? 16 : 11,
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
              decoration: retro.gameDecoration(
                BoxDecoration(
                  color: retro.surfaceAlt,
                  borderRadius: retro.radius,
                  border: Border.all(
                    color: retro.border.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      expanded
                          ? l10n.detailCollapseChangelog
                          : l10n.detailViewAllUpdates(updates.length),
                      style: TextStyle(
                        color: retro.accentText,
                        fontSize: retro.isMario ? 16 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    MarioGameIcon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: retro.accentText,
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
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
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
                decoration: retro.gameDecoration(
                  BoxDecoration(
                    color: index == 0 ? retro.accent : retro.surfaceAlt,
                    borderRadius: retro.radius,
                    border: index != 0
                        ? Border.all(color: retro.border.withValues(alpha: 0.3))
                        : null,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index == 0 ? retro.inkOnAccent : retro.inkDim,
                      fontSize: retro.isMario ? 16 : 11,
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
                        fontSize: retro.isMario ? 17 : 14,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  if (update.date != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatDate(update.date, locale: l10n.localeName) ??
                          update.date!,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontSize: retro.isMario ? 16 : 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    update.changelog,
                    style: TextStyle(
                      color: retro.inkDim,
                      fontSize: retro.isMario ? 16 : 13,
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
      retro.displayLabel(label),
      style: retro.isMario
          ? retro.body(size: 17, color: retro.accentText)
          : TextStyle(
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
        decoration: retro.gameDecoration(
          BoxDecoration(color: retro.surface, borderRadius: retro.radius),
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
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

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
              decoration: retro.gameDecoration(
                BoxDecoration(
                  color: retro.surfaceAlt,
                  borderRadius: retro.radius,
                ),
              ),
              child: MarioGameIcon(
                Icons.search_off_rounded,
                size: 36,
                color: retro.border,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.detailModNotFound,
              style: TextStyle(
                color: retro.ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.detailModNotFoundBody,
              style: TextStyle(color: retro.inkDim, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const MarioGameIcon(Icons.arrow_back_rounded, size: 16),
              label: Text(l10n.detailGoBack),
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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: retro.background,
      appBar: AppBar(backgroundColor: retro.background),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MarioGameIcon(
                Icons.error_outline_rounded,
                size: 48,
                color: retro.accentText,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.detailFailedToLoad,
                style: TextStyle(
                  color: retro.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              CatalogErrorDetails(
                details: message,
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
