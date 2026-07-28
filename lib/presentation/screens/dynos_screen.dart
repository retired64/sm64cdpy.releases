import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/dynos_entity.dart';
import '../providers/extra_providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';
import '../../l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../services/mod_installer.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

class DynosScreen extends ConsumerStatefulWidget {
  const DynosScreen({super.key});

  @override
  ConsumerState<DynosScreen> createState() => _DynosScreenState();
}

class _DynosScreenState extends ConsumerState<DynosScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynosAsync = ref.watch(allDynosProvider);

    return dynosAsync.when(
      loading: () => const _DynosSkeleton(),
      error: (e, _) => _DynosError(message: e.toString()),
      data: (mods) => _DynosBody(mods: mods, scrollCtrl: _scrollCtrl),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _DynosBody extends StatelessWidget {
  const _DynosBody({required this.mods, required this.scrollCtrl});

  final List<DynosEntity> mods;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

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
          leading: DrawerMenuButton(color: retro.blue),
          title: Text(
            l10n.dynosTitle,
            style: retro.heading(size: 16, color: retro.blue),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SkewChip(
                retro: retro,
                icon: Icons.memory_rounded,
                label: l10n.sharedModCount(mods.length),
                dense: true,
                selected: true,
                accentColor: retro.blue,
              ),
            ),
          ],
        ),

        // ── Section label ─────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
            child: Text('動的・カスタムMOD', style: retro.body(size: 12)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: SectionKicker(
              retro: retro,
              label: l10n.dynosSectionHeader,
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
                return DynosCard(mod: mod);
              },
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ── DynOS Card ──────────────────────────────────────────────────────────────

class DynosCard extends ConsumerStatefulWidget {
  const DynosCard({super.key, required this.mod});

  final DynosEntity mod;

  @override
  ConsumerState<DynosCard> createState() => _DynosCardState();
}

class _DynosCardState extends ConsumerState<DynosCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  bool _isExpanded = false;

  Timer? _longPressTimer;
  bool _isLongPressing = false;

  bool _downloading = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
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
    await toggleDynosFavourite(ref, widget.mod.id);
    if (!mounted) return;
    final isNowFav = ref.read(dynosFavouritesProvider).contains(widget.mod.id);
    AppSnackbar.info(
      context,
      message: isNowFav ? AppLocalizations.of(context).sharedAddedToFavorites : AppLocalizations.of(context).sharedRemovedFromFavorites,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _download() async {
    if (_downloading) return;
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
            title: Text(AppLocalizations.of(context).detailNotificationsNeeded,
                style: TextStyle(color: RetroTheme.of(ctx).ink)),
            content: Text(AppLocalizations.of(context).detailNotificationsBody,
                style: TextStyle(color: RetroTheme.of(ctx).inkDim)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(AppLocalizations.of(context).detailNotNow,
                    style: TextStyle(color: RetroTheme.of(ctx).ink)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(AppLocalizations.of(context).detailContinue),
              ),
            ],
          ),
        );
        if (proceed != true && mounted) {
          AppSnackbar.info(context, message: AppLocalizations.of(context).detailNotificationsSkipped);
        }
      }
      if (!mounted) return;
      final granted = await installer.requestNotificationPermission();
      if (!granted && mounted) {
        AppSnackbar.info(context, message: AppLocalizations.of(context).detailNotificationsDisabled);
      }
    }

    final url = widget.mod.downloadUrl;
    final rawName = widget.mod.title
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s\-]"), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .trim();
    final urlExt = url.split('.').last.split('?').first.toLowerCase();
    final ext = (urlExt == 'lua' || urlExt == 'zip') ? urlExt : 'zip';
    final filename = '${rawName.isNotEmpty ? rawName : 'mod'}.$ext';

    final hasDynosFolder = await installer.isDynosDirectorySelected();

    if (!hasDynosFolder) {
      final prefs = await SharedPreferences.getInstance();
      final autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;
      if (autoInstall && mounted) {
        final goToSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: RetroTheme.of(ctx).surfaceAlt,
            icon: Icon(Icons.folder_open_rounded, color: RetroTheme.of(ctx).accent, size: 28),
            title: Text(AppLocalizations.of(context).detailModsFolderNotSelected,
                style: TextStyle(color: RetroTheme.of(ctx).ink)),
            content: Text('You need to select a DynOS folder before installing DynOS packs.\n\nGo to Settings → Game Integration to select it.',
                style: TextStyle(color: RetroTheme.of(ctx).inkDim)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(AppLocalizations.of(context).detailCancel,
                    style: TextStyle(color: RetroTheme.of(ctx).ink)),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.settings, size: 16),
                label: Text(AppLocalizations.of(context).detailGoToSettings),
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
      await _downloadSimple(url, filename, installer, rawName);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

    if (autoInstall && mounted) {
      // Auto-install to dynos folder — download only, no background install for dynos yet
      if (!mounted) return;
      await _downloadSimple(url, filename, installer, rawName);
    } else if (mounted) {
      await _downloadSimple(url, filename, installer, rawName);
    }
  }

  Future<void> _downloadSimple(String url, String filename, ModInstaller installer, String rawName) async {
    if (!mounted) return;
    setState(() { _downloading = true; _progress = 0.0; });
    try {
      await FileDownloader.downloadFile(
        url: url, name: filename,
        onProgress: (name, progress) {
          if (!mounted) return;
          final normalized = (progress > 1.0 ? progress / 100.0 : progress).clamp(0.0, 1.0);
          setState(() => _progress = normalized);
        },
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          final savedName = path.split('/').last;
          String? copyError;
          try {
            if (await installer.isDynosDirectorySelected()) {
              if (savedName.toLowerCase().endsWith('.zip')) {
                final result = await installer.installModToDynosFolder(zipPath: path, modName: rawName);
                if (!result.success) copyError = result.errorMessage ?? AppLocalizations.of(context).detailInstallFailed;
              } else {
                await installer.copyFileToDynosFolder(sourcePath: path, targetName: savedName);
              }
            }
          } catch (e) {
            copyError = e.toString();
          }
          if (!mounted) return;
          setState(() { _downloading = false; _progress = 0.0; });
          if (copyError != null) {
            AppSnackbar.errorWithCopy(context,
                message: copyError,
                copyText: copyError);
          } else {
            AppSnackbar.success(context,
                message: AppLocalizations.of(context).detailSavedToFolder(savedName, AppLocalizations.of(context).navDynOS));
          }
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() { _downloading = false; _progress = 0.0; });
          AppSnackbar.errorWithCopy(context,
              message: AppLocalizations.of(context).detailError(error),
              copyText: error);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() { _downloading = false; _progress = 0.0; });
      AppSnackbar.errorWithCopy(context,
          message: AppLocalizations.of(context).detailError(e.toString()),
          copyText: e.toString());
    }
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final isFav = ref.watch(dynosFavouritesProvider).contains(widget.mod.id);
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
      onTap: () => setState(() => _isExpanded = !_isExpanded),
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
                      style: retro.heading(size: 16.5, letterSpacing: -0.2),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Author + version
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _RetroMeta(
                          icon: Icons.person_rounded,
                          label: widget.mod.author,
                          accentColor: retro.blue,
                        ),
                        _RetroMeta(
                          icon: Icons.tag_rounded,
                          label: widget.mod.version,
                          accentColor: retro.blue,
                        ),
                      ],
                    ),

                    // Rating (si viene informado)
                    if (widget.mod.rating != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 14, color: retro.blue),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.mod.rating!.toStringAsFixed(1)} (${widget.mod.ratingCount})',
                            style: TextStyle(
                              color: retro.inkDim,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Tags (si el mod trae alguno)
                    if (widget.mod.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: widget.mod.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: retro.blue,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  tag.toUpperCase(),
                                  style: TextStyle(
                                    color: retro.blue,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Description (expandable)
                    Text(
                      widget.mod.description,
                      style: retro.body(size: 13),
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
                            _isExpanded ? l10n.sharedShowLess : l10n.sharedReadMore,
                            style: TextStyle(
                              color: retro.blue,
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
                          color: retro.blue,
                        ),
                        label: Text(
                          isFav ? l10n.sharedRemoveFromFavorites : l10n.sharedAddToFavorites,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        onPressed: _toggleFavorite,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: retro.blue,
                          side: BorderSide(color: retro.blue, width: 2),
                          shape: const RoundedRectangleBorder(
                            borderRadius: RetroTheme.radius,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Download button — botón de arcade sólido azul
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
                            backgroundColor: retro.blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: retro.blue.withValues(
                              alpha: 0.55,
                            ),
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: _downloading
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LinearProgressIndicator(
                                      value: _progress,
                                      backgroundColor: retro.inkOnAccent.withValues(alpha: 0.25),
                                      color: retro.inkOnAccent,
                                      minHeight: 4,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${(_progress * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: retro.inkOnAccent),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.download_rounded, color: retro.inkOnAccent, size: 20),
                                    const SizedBox(width: 10),
                                    Text(l10n.sharedDownload, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: retro.inkOnAccent)),
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
  const _RetroMeta({
    required this.icon,
    required this.label,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: accentColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: retro.inkDim,
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
    final l10n = AppLocalizations.of(context);
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
                Icons.rocket_launch_rounded,
                size: 30,
                color: retro.blue,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.dynosEmpty,
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
              l10n.dynosEmptyHint,
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

class _DynosSkeleton extends StatelessWidget {
  const _DynosSkeleton();

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
              child: _Bone(height: 340),
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

class _DynosError extends StatelessWidget {
  const _DynosError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
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
                l10n.dynosFailedToLoad,
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
