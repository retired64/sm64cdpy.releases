import '../widgets/manga_switch.dart';
import '../widgets/game_folder_card.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_theme.dart';
import '../../services/update_service.dart';
import '../../services/fast_install_access.dart';
import '../../widgets/update_dialog.dart';

import '../providers/mod_providers.dart';
import '../providers/auto_install_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/appearance_selector.dart';
import '../widgets/locale_selector.dart';
import '../widgets/settings_expansion_group.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        // ── App bar ───────────────────────────────────────
        RetroPinnedAppBar(
          title: Text(
            l10n.settingsTitle,
            style: retro.heading(size: 18, color: retro.accentText),
          ),
        ),

        // ── Content ───────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          sliver: SliverList.list(
            children: [
              _RetroSectionKicker(
                retro: retro,
                label: l10n.settingsData,
                japanese: 'データ',
              ),
              const SizedBox(height: 10),
              _ReloadDatabaseTile(),
              _SettingsTile(
                icon: Icons.delete_outline_rounded,
                title: l10n.settingsClearFavourites,
                subtitle: l10n.settingsClearFavouritesDesc,
                destructive: true,
                onTap: () => _confirmClearFavourites(context, ref),
              ),
              _SettingsTile(
                icon: Icons.upload_rounded,
                title: l10n.settingsExportFavourites,
                subtitle: l10n.settingsExportFavouritesDesc,
                onTap: () => _exportFavourites(context, ref),
              ),
              _SettingsTile(
                icon: Icons.download_rounded,
                title: l10n.settingsImportFavourites,
                subtitle: l10n.settingsImportFavouritesDesc,
                onTap: () => _importFavourites(context, ref),
              ),

              const SizedBox(height: 20),
              _RetroSectionKicker(
                retro: retro,
                label: l10n.settingsGameIntegration,
                japanese: 'ゲーム連携',
              ),
              const SizedBox(height: 10),
              const GameFolderCard(),
              const _FastInstallTile(),
              _AutoInstallToggle(),
              _OverlayToggle(),

              const SizedBox(height: 20),
              _RetroSectionKicker(
                retro: retro,
                label: l10n.settingsAppearance,
                japanese: '外観',
              ),
              const SizedBox(height: 10),
              const AppearanceSelector(),
              const SizedBox(height: 12),
              const LocaleSelector(),

              const SizedBox(height: 20),
              _RetroSectionKicker(
                retro: retro,
                label: l10n.settingsAbout,
                japanese: '概要',
              ),
              const SizedBox(height: 10),
              _CheckUpdateTile(),
              _SettingsTile(
                icon: Icons.open_in_browser_rounded,
                title: l10n.settingsGoToReleases,
                subtitle: l10n.settingsViewAllVersions(
                  UpdateService.currentVersion,
                ),
                onTap: () =>
                    _launchUrl(context, AppConstants.githubReleasesUrl),
              ),
              _SettingsTile(
                icon: Icons.extension_rounded,
                title: l10n.settingsDataSource,
                subtitle: 'mods.sm64coopdx.com',
                onTap: () => _launchUrl(context, AppConstants.dataSourceUrl),
              ),
            ],
          ),
        ),
        const MangaNavigationSliverInset(),
      ],
    );
  }

  Future<void> _exportFavourites(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final count = ref.read(favouritesProvider).length;
    if (count == 0) {
      if (!context.mounted) return;
      AppSnackbar.info(context, message: l10n.settingsNoFavouritesToExport);
      return;
    }

    final error = await ref
        .read(favouritesProvider.notifier)
        .exportFavourites();
    if (!context.mounted) return;

    if (error != null) {
      AppSnackbar.error(context, message: error);
    }
    // Si error == null el share sheet ya se abrió; no hace falta snackbar.
  }

  Future<void> _importFavourites(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final allModsAsync = ref.read(allModsProvider);
    final knownIds = allModsAsync.maybeWhen(
      data: (mods) => mods.map((m) => m.id).toSet(),
      orElse: () => <String>{},
    );

    final result = await ref
        .read(favouritesProvider.notifier)
        .importFavourites(knownIds);

    if (!context.mounted) return;
    if (result.cancelled) return;

    if (result.error != null) {
      AppSnackbar.error(context, message: result.error!);
      return;
    }

    final parts = <String>[];
    if (result.added > 0) parts.add(l10n.settingsImportAdded(result.added));
    if (result.skippedDuplicate > 0) {
      parts.add(l10n.settingsImportAlreadySaved(result.skippedDuplicate));
    }
    if (result.skippedUnknown > 0) {
      parts.add(l10n.settingsImportNotFound(result.skippedUnknown));
    }

    AppSnackbar.success(
      context,
      message: result.added == 0
          ? '${l10n.settingsImportNothingNew}  ${parts.join(' · ')}'
          : '${l10n.settingsImportComplete} · ${parts.join(' · ')}',
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) _showUrlError(context, url);
    }
  }

  void _confirmClearFavourites(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => _RetroDialog(
        retro: retro,
        title: l10n.settingsClearFavouritesTitle,
        message: l10n.settingsClearFavouritesBody,
        confirmLabel: l10n.settingsClearButton,
        confirmColor: retro.red,
        onConfirm: () {
          // Toggle off all current favourites
          final favIds = Set<String>.from(ref.read(favouritesProvider));
          for (final id in favIds) {
            ref.read(favouritesProvider.notifier).toggle(id);
          }
          Navigator.of(ctx).pop();
          AppSnackbar.success(context, message: l10n.settingsFavouritesCleared);
        },
      ),
    );
  }

  void _showUrlError(BuildContext context, String url) {
    final l10n = AppLocalizations.of(context);
    AppSnackbar.error(context, message: l10n.settingsCannotOpenUrl(url));
  }
}

// ── Retro dialog ──────────────────────────────────────────────────────────────
// Diálogo de confirmación con borde duro y sombra desplazada, en vez del
// AlertDialog Material redondeado por defecto.

class _RetroDialog extends StatelessWidget {
  const _RetroDialog({
    required this.retro,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.confirmColor,
  });

  final RetroTheme retro;
  final String title;
  final String message;
  final String confirmLabel;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final accent = confirmColor ?? retro.accent;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: retro.settingsPanel(width: 3, dx: 5, dy: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: retro.heading(size: 15)),
            const SizedBox(height: 12),
            Text(message, style: retro.body(size: 13)),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Text(
                      l10n.settingsCancel,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: retro.gameDecoration(
                      BoxDecoration(
                        borderRadius: retro.radius,
                        color: accent,
                        border: Border.all(
                          color: retro.border,
                          width: retro.borderWidth(2),
                        ),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: TextStyle(
                        fontFamily: retro.headingFamily,
                        color: retro.onColor(accent),
                        fontSize: 12,
                        fontWeight: retro.design.headingWeight,
                        letterSpacing: 0.4,
                      ),
                    ),
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

// ── Section kicker wrapper ────────────────────────────────────────────────────

class _RetroSectionKicker extends StatelessWidget {
  const _RetroSectionKicker({
    required this.retro,
    required this.label,
    required this.japanese,
  });

  final RetroTheme retro;
  final String label;
  final String japanese;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (retro.design.softSettingsPanels || retro.usesMinimalSurfaces) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Row(
          children: [
            MarioGameIcon(
              retro.design.playfulSelection ? Icons.star_rounded : Icons.circle,
              size: retro.design.playfulSelection ? 18 : 6,
              color: retro.design.playfulSelection
                  ? retro.secondaryAccent
                  : retro.accentText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: retro.heading(
                  size: 13,
                  weight: FontWeight.w800,
                  color: retro.inkDim,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (retro.showJapaneseDecorations) ...[
            Text(japanese, style: retro.body(size: 11)),
            const SizedBox(height: 4),
          ],
          SectionKicker(retro: retro, label: label),
        ],
      ),
    );
  }
}

// ── Retro switch ──────────────────────────────────────────────────────────────
// Toggle cuadrado, sin esquinas redondeadas, coherente con el resto del
// sistema visual (nada de pills suaves tipo Material).

class _RetroSwitch extends StatelessWidget {
  const _RetroSwitch({
    required this.retro,
    required this.value,
    required this.onChanged,
  });

  final RetroTheme retro;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (retro.showJapaneseDecorations) {
      return MangaSwitch(value: value, onChanged: onChanged);
    }
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: retro.gameDecoration(
          BoxDecoration(
            borderRadius: retro.radius,
            color: value ? retro.accent : retro.surfaceAlt,
            border: Border.all(
              color: retro.border,
              width: retro.borderWidth(retro.design.softSettingsPanels ? 1 : 2),
            ),
            boxShadow: const [],
          ),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          decoration: retro.gameDecoration(
            BoxDecoration(
              color: value ? retro.inkOnAccent : retro.inkDim,
              borderRadius:
                  retro.design.softSettingsPanels || retro.usesMinimalSurfaces
                  ? BorderRadius.circular(8)
                  : BorderRadius.zero,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Mods folder tile ───────────────────────────────────────────────────────

// ── Auto-install toggle ────────────────────────────────────────────────────

class _AutoInstallToggle extends ConsumerWidget {
  const _AutoInstallToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final preference = ref.watch(autoInstallProvider);
    final autoInstall = preference.isEnabled;
    void toggle(bool value) {
      ref.read(autoInstallProvider.notifier).setEnabled(value);
    }

    return _RetroTileShell(
      retro: retro,
      onTap: preference.isSaving ? null : () => toggle(!autoInstall),
      accentColor: autoInstall ? retro.accent : null,
      leading: _RetroIconBox(
        retro: retro,
        icon: Icons.auto_mode_rounded,
        accentColor: autoInstall ? retro.accent : null,
      ),
      title: l10n.settingsAutoInstall,
      subtitle: autoInstall
          ? l10n.settingsAutoInstallOn
          : l10n.settingsAutoInstallOff,
      trailing: _RetroSwitch(
        retro: retro,
        value: autoInstall,
        onChanged: preference.isSaving ? null : toggle,
      ),
    );
  }
}

// ── Shared tile shell ─────────────────────────────────────────────────────────
// Contenedor común para todos los tiles de settings: borde duro, sombra
// desplazada suave, caja de ícono a la izquierda, título/subtítulo, trailing.

class _RetroTileShell extends StatelessWidget {
  const _RetroTileShell({
    required this.retro,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.accentColor,
  });

  final RetroTheme retro;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: retro.usesMinimalSurfaces ? 4 : 12,
            vertical: retro.usesMinimalSurfaces ? 12 : 12,
          ),
          decoration: retro.settingsPanel(
            borderColor: accentColor,
            width: accentColor != null ? 2.5 : 2,
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: retro.isMario
                          ? retro.body(size: 16, color: titleColor ?? retro.ink)
                          : TextStyle(
                              color: titleColor ?? retro.ink,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: retro.isMario
                          ? retro.body(size: 14)
                          : TextStyle(
                              color: retro.inkDim,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _RetroIconBox extends StatelessWidget {
  const _RetroIconBox({
    required this.retro,
    required this.icon,
    this.accentColor,
  });

  final RetroTheme retro;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final c = accentColor ?? retro.inkDim;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: retro.gameDecoration(
        BoxDecoration(
          borderRadius: retro.radius,
          color: retro.design.softSettingsPanels || retro.usesMinimalSurfaces
              ? retro.accent.withValues(alpha: 0.08)
              : retro.surfaceAlt,
          border: Border.all(
            color: c,
            width: retro.borderWidth(
              retro.design.softSettingsPanels || retro.usesMinimalSurfaces
                  ? 1
                  : 2,
            ),
          ),
        ),
      ),
      child: MarioGameIcon(icon, color: c, size: 18),
    );
  }
}

class _RetroSpinner extends StatelessWidget {
  const _RetroSpinner({required this.retro});

  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: retro.gameDecoration(
        BoxDecoration(
          borderRadius: retro.radius,
          color: retro.design.softSettingsPanels || retro.usesMinimalSurfaces
              ? retro.accent.withValues(alpha: 0.08)
              : retro.surfaceAlt,
          border: Border.all(
            color: retro.accent,
            width: retro.borderWidth(
              retro.design.softSettingsPanels || retro.usesMinimalSurfaces
                  ? 1
                  : 2,
            ),
          ),
        ),
      ),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: retro.accent),
      ),
    );
  }
}

/// Optional acceleration. Denial never blocks the existing SAF workflow.
class _FastInstallTile extends StatefulWidget {
  const _FastInstallTile();
  @override
  State<_FastInstallTile> createState() => _FastInstallTileState();
}

class _FastInstallTileState extends State<_FastInstallTile>
    with WidgetsBindingObserver {
  final _access = FastInstallAccess();
  bool _visible = false;
  bool _launching = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refresh());
  }

  @override
  void dispose() {
    ++_generation;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    try {
      final supported = await _access.supported();
      final granted = supported && await _access.granted();
      if (mounted && generation == _generation) {
        setState(() => _visible = supported && !granted);
      }
    } catch (_) {
      // Missing/unavailable platform support leaves ordinary SAF installation usable.
      if (mounted && generation == _generation)
        setState(() => _visible = false);
    }
  }

  Future<void> _request() async {
    if (_launching) return;
    setState(() => _launching = true);
    try {
      await _access.request();
      if (!mounted) return;
      await _refresh();
    } catch (_) {
      if (mounted)
        AppSnackbar.error(
          context,
          message: AppLocalizations.of(context).fastInstallAccessError,
        );
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return _SettingsTile(
      icon: Icons.speed_rounded,
      title: l.fastInstallTitle,
      subtitle: l.fastInstallDescription,
      onTap: _launching ? null : () => unawaited(_request()),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final accent = destructive ? retro.red : retro.accent;

    return _RetroTileShell(
      retro: retro,
      onTap: onTap,
      leading: _RetroIconBox(retro: retro, icon: icon, accentColor: accent),
      title: title,
      titleColor: destructive ? retro.red : retro.ink,
      subtitle: subtitle,
      trailing: MarioGameIcon(
        Icons.chevron_right_rounded,
        color: retro.inkDim,
        size: 20,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ReloadDatabaseTile
// Descarga el JSON desde GitHub y muestra progreso inline en el tile.
// Usa StatefulWidget propio para no convertir todo SettingsScreen.
// ─────────────────────────────────────────────────────────────────────────────
class _ReloadDatabaseTile extends ConsumerStatefulWidget {
  const _ReloadDatabaseTile();

  @override
  ConsumerState<_ReloadDatabaseTile> createState() =>
      _ReloadDatabaseTileState();
}

class _ReloadDatabaseTileState extends ConsumerState<_ReloadDatabaseTile> {
  bool _loading = false;

  Future<void> _reload() async {
    if (_loading) return;
    setState(() => _loading = true);

    final datasource = ref.read(localDatasourceProvider);
    final result = await datasource.fetchRemote();

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      ref.invalidate(allModsProvider);
      FloatyChatheads.shareData({'type': 'db_reloaded'});

      final modCount = result.modCount ?? 0;
      final date = result.generatedAt?.isNotEmpty == true
          ? ' · Generated ${result.generatedAt}'
          : '';

      final l10n = AppLocalizations.of(context);
      AppSnackbar.success(
        context,
        message: l10n.settingsDatabaseUpdated(modCount, date),
      );
    } else {
      final l10n = AppLocalizations.of(context);
      AppSnackbar.error(
        context,
        message: result.errorMessage ?? l10n.settingsUnknownError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return _RetroTileShell(
      retro: retro,
      onTap: _loading ? null : _reload,
      leading: _loading
          ? _RetroSpinner(retro: retro)
          : _RetroIconBox(retro: retro, icon: Icons.cloud_download_rounded),
      title: l10n.settingsReloadDatabase,
      subtitle: _loading
          ? l10n.settingsDownloading
          : l10n.settingsDownloadLatest,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CheckUpdateTile
// Consulta la GitHub Releases API y muestra el diálogo de actualización
// si hay una versión nueva disponible.
// ─────────────────────────────────────────────────────────────────────────────
class _CheckUpdateTile extends StatefulWidget {
  const _CheckUpdateTile();

  @override
  State<_CheckUpdateTile> createState() => _CheckUpdateTileState();
}

class _CheckUpdateTileState extends State<_CheckUpdateTile> {
  bool _loading = false;

  Future<void> _check() async {
    if (_loading) return;
    setState(() => _loading = true);

    final config = await UpdateService.checkForUpdates();

    if (!mounted) return;
    setState(() => _loading = false);

    if (config != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            UpdateDialog(config: config, isForce: config.forceUpdate),
      );
    } else {
      final l10n = AppLocalizations.of(context);
      AppSnackbar.info(
        context,
        message: l10n.settingsUpToDate(UpdateService.currentVersion),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return _RetroTileShell(
      retro: retro,
      onTap: _loading ? null : _check,
      leading: _loading
          ? _RetroSpinner(retro: retro)
          : _RetroIconBox(retro: retro, icon: Icons.system_update_rounded),
      title: l10n.settingsCheckForUpdates,
      subtitle: _loading
          ? l10n.settingsChecking
          : 'Current: v${UpdateService.currentVersion}',
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

class _OverlayToggle extends ConsumerStatefulWidget {
  const _OverlayToggle();

  @override
  ConsumerState<_OverlayToggle> createState() => _OverlayToggleState();
}

class _OverlayToggleState extends ConsumerState<_OverlayToggle> {
  bool _active = false;
  bool _loading = false;
  StreamSubscription<String>? _closeSub;

  @override
  void initState() {
    super.initState();
    _check();
    _closeSub = FloatyChatheads.onClosed.listen((_) {
      if (mounted) setState(() => _active = false);
    });
  }

  @override
  void dispose() {
    _closeSub?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    final active = await FloatyChatheads.isActive();
    if (mounted) setState(() => _active = active);
  }

  Future<void> _toggle() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (_active) {
        await FloatyChatheads.closeChatHead();
      } else {
        final granted = await FloatyChatheads.requestPermission();
        if (!granted) {
          if (mounted) setState(() => _loading = false);
          return;
        }
        await FloatyChatheads.showChatHead(
          entryPoint: 'overlayMain',
          contentWidth: 260,
          contentHeight: 340,
          persistOnAppClose: true,
          assets: const ChatHeadAssets(
            icon: IconSource.asset('assets/icons/floating_icon.png'),
            closeIcon: IconSource.asset(
              'packages/floaty_chatheads/assets/close.png',
            ),
            closeBackground: IconSource.asset(
              'packages/floaty_chatheads/assets/closeBg.png',
            ),
          ),
        );
      }
      await _check();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start overlay. Check permissions.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return _RetroTileShell(
      retro: retro,
      onTap: _loading ? null : _toggle,
      accentColor: _active ? retro.accent : null,
      leading: _loading
          ? _RetroSpinner(retro: retro)
          : _RetroIconBox(
              retro: retro,
              icon: _active
                  ? Icons.picture_in_picture_alt_rounded
                  : Icons.picture_in_picture_rounded,
              accentColor: _active ? retro.accent : null,
            ),
      title: _active
          ? l10n.settingsOverlayActive
          : l10n.settingsOverlayInactive,
      subtitle: _active
          ? l10n.settingsOverlayActiveDesc
          : l10n.settingsOverlayInactiveDesc,
      trailing: _loading
          ? null
          : _RetroSwitch(
              retro: retro,
              value: _active,
              onChanged: (_) => _toggle(),
            ),
    );
  }
}
