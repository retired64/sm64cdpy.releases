import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../domain/entities/touch_control_entity.dart';
import '../../domain/entities/install_identity.dart';
import '../../domain/entities/installation_action.dart';
import '../../services/background_install_service.dart';
import '../../services/download_url_resolver.dart';
import '../../services/mod_installer.dart';
import '../providers/extra_providers.dart';
import '../providers/installation_action_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/dynos_install_flow.dart';
import '../widgets/installation_action_presentation.dart';
import '../../l10n/app_localizations.dart';

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
          leading: DrawerMenuButton(color: retro.accent),
          title: Text(
            l10n.touchTitle,
            style: retro.heading(size: 16, color: retro.accent),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SkewChip(
                retro: retro,
                icon: Icons.touch_app_rounded,
                label: l10n.touchModCount(mods.length),
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
              label: l10n.touchSectionHeader,
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
  double _progress = 0.0;

  InstallIdentity get _identity => InstallIdentity.forCatalogArtifact(
    section: InstallSection.touchControls,
    contentId: widget.mod.id,
    downloadUrl: widget.mod.downloadUrl,
  );

  String get _operationName => _identity.operationKey;

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
    await toggleTouchFavourite(ref, widget.mod.id);
    if (!mounted) return;
    final isNowFav = ref.read(touchFavouritesProvider).contains(widget.mod.id);
    AppSnackbar.info(
      context,
      message: isNowFav
          ? AppLocalizations.of(context).sharedAddedToFavorites
          : AppLocalizations.of(context).sharedRemovedFromFavorites,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> _download() async {
    if (_downloading) return;
    HapticFeedback.mediumImpact();

    final installer = ModInstaller();

    final prefs = await SharedPreferences.getInstance();
    final autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;
    final hasFolder = await installer.isDynosDirectorySelected();
    final resolvedUrl = await DownloadUrlResolver.instance.resolveDownloadUrl(
      widget.mod.downloadUrl,
    );
    final filename = await DownloadUrlResolver.instance.resolveDownloadFilename(
      resolvedUrl,
      widget.mod.title,
    );
    final operationName = _operationName;

    if (autoInstall) {
      if (!hasFolder) {
        if (!mounted) return;
        final goToSettings = await showDynosFolderRequiredDialog(context);
        if (goToSettings && mounted) GoRouter.of(context).go('/settings');
        return;
      }

      final hasPermission = await installer.hasNotificationPermission();
      if (!hasPermission && mounted) {
        final granted = await installer.requestNotificationPermission();
        if (!granted && mounted) {
          AppSnackbar.info(
            context,
            message: AppLocalizations.of(context).detailNotificationsDisabled,
          );
        }
      }

      final chain = await BackgroundInstallService.instance
          .startDownloadAndInstall(
            url: resolvedUrl,
            modName: operationName,
            fileName: filename,
            displayTitle: widget.mod.title,
            installDestination: 'dynos',
            identity: _identity,
          );
      if (!mounted) return;
      if (chain == null) {
        AppSnackbar.error(
          context,
          message: AppLocalizations.of(context).detailInstallFailed,
        );
      } else {
        AppSnackbar.info(
          context,
          message: AppLocalizations.of(context).detailInstallQueued(filename),
        );
      }
      return;
    }

    setState(() {
      _downloading = true;
      _progress = 0.0;
    });

    try {
      await FileDownloader.downloadFile(
        url: resolvedUrl,
        name: filename,
        onProgress: (name, progress) {
          if (!mounted) return;
          final normalized = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          setState(() => _progress = normalized);
        },
        onDownloadCompleted: (path) async {
          if (!mounted) return;
          final l10n = AppLocalizations.of(context);
          final savedName = path.split('/').last;
          setState(() {
            _downloading = false;
            _progress = 0.0;
          });
          final installNow = await confirmDynosInstall(
            context,
            name: widget.mod.title,
          );
          if (!mounted) return;
          if (!installNow) {
            AppSnackbar.success(
              context,
              message: l10n.detailDownloadedNotInstalled(savedName),
            );
            return;
          }

          if (!await installer.isDynosDirectorySelected()) {
            if (!mounted) return;
            final goToSettings = await showDynosFolderRequiredDialog(context);
            if (goToSettings && mounted) GoRouter.of(context).go('/settings');
            if (mounted) {
              AppSnackbar.info(
                context,
                message: l10n.detailDownloadedNotInstalled(savedName),
              );
            }
            return;
          }

          if (mounted) setState(() => _downloading = true);
          final installError = await installDownloadedDynosFile(
            installer: installer,
            path: path,
            modName: operationName,
            fallbackError: l10n.detailInstallFailed,
          );
          if (!mounted) return;
          setState(() {
            _downloading = false;
            _progress = 0.0;
          });
          if (installError != null) {
            AppSnackbar.errorWithCopy(
              context,
              message: installError,
              copyText: installError,
            );
          } else {
            AppSnackbar.success(
              context,
              message: l10n.detailSavedToFolder(savedName, l10n.navDynOS),
            );
          }
        },
        onDownloadError: (error) {
          if (!mounted) return;
          setState(() {
            _downloading = false;
            _progress = 0.0;
          });
          AppSnackbar.errorWithCopy(
            context,
            message: friendlyDownloadError(AppLocalizations.of(context), error),
            copyText: error,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _progress = 0.0;
      });
      AppSnackbar.errorWithCopy(
        context,
        message: friendlyDownloadError(AppLocalizations.of(context), e),
        copyText: e.toString(),
      );
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
    final isFav = ref.watch(touchFavouritesProvider).contains(widget.mod.id);
    final actionState = ref.watch(installationActionProvider(_identity));
    final action = actionState.primaryAction;
    final isDownloading = _downloading || actionState.isOperationActive;
    final visibleProgress = _downloading ? _progress : actionState.progress;
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
                          isFav
                              ? l10n.sharedRemoveFromFavorites
                              : l10n.sharedAddToFavorites,
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
                          boxShadow: isDownloading
                              ? []
                              : retro.hardShadow(dx: 4, dy: 4),
                        ),
                        child: ElevatedButton(
                          onPressed:
                              (_downloading &&
                                      !actionState.isOperationActive) ||
                                  action ==
                                      InstallationPrimaryAction.checking ||
                                  action == InstallationPrimaryAction.installed
                              ? null
                              : () => runCanonicalInstallationAction(
                                  context: context,
                                  ref: ref,
                                  state: actionState,
                                  onTransfer: _download,
                                ),
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
                          child: isDownloading
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      LinearProgressIndicator(
                                        value: visibleProgress,
                                        backgroundColor: retro.background
                                            .withValues(alpha: 0.3),
                                        color: retro.background,
                                        minHeight: 4,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        visibleProgress == null
                                            ? action.label(l10n)
                                            : '${(visibleProgress * 100).toStringAsFixed(0)}% · ${action.label(l10n)}',
                                        style: TextStyle(
                                          color: retro.background,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(action.icon, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      action.label(l10n),
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
                    if (actionState.canReinstall)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _download,
                          icon: const Icon(Icons.refresh_rounded, size: 15),
                          label: Text(l10n.installationReinstall),
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
                Icons.touch_app_outlined,
                size: 30,
                color: retro.accent,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.touchEmpty,
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
              l10n.touchEmptyHint,
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
                l10n.touchFailedToLoad,
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
