import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../overlay/overlay_bridge.dart';
import '../../core/theme/retro_theme.dart';
import '../../services/mod_installer.dart';
import '../../services/update_service.dart';
import '../../widgets/update_dialog.dart';

import '../providers/mod_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';

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
        SliverAppBar(
                backgroundColor: retro.background,
                surfaceTintColor: Colors.transparent,
                scrolledUnderElevation: 0,
                floating: true,
                snap: true,
                elevation: 0,
                shape: Border(bottom: BorderSide(color: retro.border, width: 3)),
                leading: const DrawerMenuButton(),
                title: Text(
                  l10n.settingsTitle,
                  style: retro.heading(size: 18, color: retro.accent),
                ),
              ),

              // ── Content ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList.list(
                  children: [
                    _RetroSectionKicker(retro: retro, label: l10n.settingsData, japanese: 'データ'),
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
                    _ModsFolderTile(),
                    _RetroGap(height: 6),
                    _DynosFolderTile(),
                    _AutoInstallToggle(),
                    _OverlayToggle(),

                    const SizedBox(height: 20),
                    _RetroSectionKicker(retro: retro, label: l10n.settingsAppearance, japanese: '外観'),
                    const SizedBox(height: 10),
                    _ThemeSelector(),
                    const SizedBox(height: 12),
                    _LocaleSelector(),

                    const SizedBox(height: 20),
                    _RetroSectionKicker(retro: retro, label: l10n.settingsAbout, japanese: '概要'),
                    const SizedBox(height: 10),
                    _CheckUpdateTile(),
                    _SettingsTile(
                      icon: Icons.open_in_browser_rounded,
                      title: l10n.settingsGoToReleases,
                      subtitle:
                          l10n.settingsViewAllVersions(UpdateService.currentVersion),
                      onTap: () => _launchUrl(context, AppConstants.githubReleasesUrl),
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
    final l10n = AppLocalizations.of(context);
    final accent = confirmColor ?? retro.accent;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: retro.surface,
          border: Border.all(color: retro.border, width: 3),
          boxShadow: retro.hardShadow(dx: 5, dy: 5),
        ),
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
                    decoration: BoxDecoration(
                      color: accent,
                      border: Border.all(color: retro.border, width: 2),
                    ),
                    child: Text(
                      confirmLabel,
                      style: TextStyle(
                        color: retro.background,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(japanese, style: retro.body(size: 11)),
          const SizedBox(height: 4),
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
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? retro.accent : retro.surfaceAlt,
          border: Border.all(color: retro.border, width: 2),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          color: value ? retro.background : retro.inkDim,
        ),
      ),
    );
  }
}

// ── Mods folder tile ───────────────────────────────────────────────────────

class _ModsFolderTile extends ConsumerStatefulWidget {
  const _ModsFolderTile();

  @override
  ConsumerState<_ModsFolderTile> createState() => _ModsFolderTileState();
}

class _ModsFolderTileState extends ConsumerState<_ModsFolderTile> {
  bool _loading = false;
  bool _hasFolder = false;
  String? _folderUri;

  final _installer = ModInstaller();

  @override
  void initState() {
    super.initState();
    _checkFolder();
  }

  Future<void> _checkFolder() async {
    try {
      final uri = await _installer.getSavedDirectoryUri();
      final has = await _installer.isDirectorySelected();
      if (mounted) {
        setState(() {
          _hasFolder = has;
          _folderUri = uri;
        });
      }
    } catch (e) {
      debugPrint('_ModsFolderTile._checkFolder: $e');
    }
  }

  Future<void> _selectFolder() async {
    setState(() => _loading = true);
    try {
      final uri = await _installer.openDirectoryPicker();
      if (!mounted) return;
      if (uri != null) {
        setState(() {
          _hasFolder = true;
          _folderUri = uri;
        });
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        AppSnackbar.success(
          context,
          message: l10n.settingsModsFolderSelected,
        );
      }
    } on ModInstallerException catch (e) {
      if (mounted) {
        AppSnackbar.error(context, message: e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmClear() async {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _RetroDialog(
        retro: retro,
        title: l10n.settingsClearModsFolderTitle,
        message: l10n.settingsClearModsFolderBody,
        confirmLabel: l10n.settingsClearButton,
        confirmColor: retro.red,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );

    if (confirmed == true) {
      await _installer.clearDirectorySelection();
      if (mounted) {
        setState(() {
          _hasFolder = false;
          _folderUri = null;
        });
        AppSnackbar.info(context, message: l10n.settingsModsFolderCleared);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return _RetroTileShell(
      retro: retro,
      onTap: _loading ? null : _selectFolder,
      onLongPress: _hasFolder ? _confirmClear : null,
      accentColor: _hasFolder ? retro.accent : null,
      leading: _loading
          ? _RetroSpinner(retro: retro)
          : _RetroIconBox(
              retro: retro,
              icon: _hasFolder
                  ? Icons.folder_special_rounded
                  : Icons.folder_open_rounded,
              accentColor: _hasFolder ? retro.accent : null,
            ),
      title: _hasFolder ? l10n.settingsModsFolder : l10n.settingsSelectModsFolder,
      titleColor: _hasFolder ? retro.accent : retro.ink,
      subtitle: _hasFolder
          ? l10n.settingsModsFolderHint
          : l10n.settingsModsFolderDesc,
      pathHint: _folderUri != null ? _displayPath(_folderUri!) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: retro.inkDim, size: 20),
    );
  }
}

// ── DynOS folder tile ────────────────────────────────────────────────────────

class _DynosFolderTile extends ConsumerStatefulWidget {
  const _DynosFolderTile();

  @override
  ConsumerState<_DynosFolderTile> createState() => _DynosFolderTileState();
}

class _DynosFolderTileState extends ConsumerState<_DynosFolderTile> {
  bool _loading = false;
  bool _hasFolder = false;
  String? _folderUri;

  final _installer = ModInstaller();

  @override
  void initState() {
    super.initState();
    _checkFolder();
  }

  Future<void> _checkFolder() async {
    try {
      final uri = await _installer.getSavedDynosUri();
      final has = await _installer.isDynosDirectorySelected();
      if (mounted) {
        setState(() {
          _hasFolder = has;
          _folderUri = uri;
        });
      }
    } catch (e) {
      debugPrint('_DynosFolderTile._checkFolder: $e');
    }
  }

  Future<void> _selectFolder() async {
    setState(() => _loading = true);
    try {
      final uri = await _installer.openDynosPicker();
      if (!mounted) return;
      if (uri != null) {
        setState(() {
          _hasFolder = true;
          _folderUri = uri;
        });
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        AppSnackbar.success(
          context,
          message: l10n.settingsDynosFolderSelected,
        );
      }
    } on ModInstallerException catch (e) {
      if (mounted) {
        AppSnackbar.error(context, message: e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmClear() async {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _RetroDialog(
        retro: retro,
        title: l10n.settingsClearDynosFolderTitle,
        message: l10n.settingsClearDynosFolderBody,
        confirmLabel: l10n.settingsClearButton,
        confirmColor: retro.red,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );

    if (confirmed == true) {
      await _installer.clearDynosSelection();
      if (mounted) {
        setState(() {
          _hasFolder = false;
          _folderUri = null;
        });
        AppSnackbar.info(context, message: l10n.settingsDynosFolderCleared);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return _RetroTileShell(
      retro: retro,
      onTap: _loading ? null : _selectFolder,
      onLongPress: _hasFolder ? _confirmClear : null,
      accentColor: _hasFolder ? retro.blue : null,
      leading: _loading
          ? _RetroSpinner(retro: retro)
          : _RetroIconBox(
              retro: retro,
              icon: _hasFolder
                  ? Icons.auto_awesome_rounded
                  : Icons.auto_awesome_outlined,
              accentColor: _hasFolder ? retro.blue : null,
            ),
      title: _hasFolder ? l10n.settingsDynosFolder : l10n.settingsSelectDynosFolder,
      titleColor: _hasFolder ? retro.blue : retro.ink,
      subtitle: _hasFolder
          ? l10n.settingsDynosFolderHint
          : l10n.settingsDynosFolderDesc,
      pathHint: _folderUri != null ? _displayPath(_folderUri!) : null,
      trailing: Icon(Icons.chevron_right_rounded, color: retro.inkDim, size: 20),
    );
  }
}

// ── Auto-install toggle ────────────────────────────────────────────────────

class _AutoInstallToggle extends ConsumerStatefulWidget {
  const _AutoInstallToggle();

  @override
  ConsumerState<_AutoInstallToggle> createState() => _AutoInstallToggleState();
}

class _AutoInstallToggleState extends ConsumerState<_AutoInstallToggle> {
  bool _autoInstall = false;

  @override
  void initState() {
    super.initState();
    _loadPref();
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.autoInstallModsKey, value);
    OverlayBridge.refreshAutoInstall();
    setState(() => _autoInstall = value);
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return _RetroTileShell(
      retro: retro,
      onTap: () => _toggle(!_autoInstall),
      accentColor: _autoInstall ? retro.accent : null,
      leading: _RetroIconBox(
        retro: retro,
        icon: Icons.auto_mode_rounded,
        accentColor: _autoInstall ? retro.accent : null,
      ),
      title: l10n.settingsAutoInstall,
      subtitle: _autoInstall
          ? l10n.settingsAutoInstallOn
          : l10n.settingsAutoInstallOff,
      trailing: _RetroSwitch(retro: retro, value: _autoInstall, onChanged: _toggle),
    );
  }
}

// ── Shared tile shell ─────────────────────────────────────────────────────────
// Contenedor común para todos los tiles de settings: borde duro, sombra
// desplazada suave, caja de ícono a la izquierda, título/subtítulo, trailing.

String _displayPath(String uri) {
  final parts = uri.split('/tree/');
  if (parts.length < 2) return uri;
  final decoded = Uri.decodeComponent(parts.last);
  return decoded.replaceFirst('primary:', '/');
}

class _RetroTileShell extends StatelessWidget {
  const _RetroTileShell({
    required this.retro,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.titleColor,
    this.accentColor,
    this.pathHint,
  });

  final RetroTheme retro;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? titleColor;
  final Color? accentColor;
  final String? pathHint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: retro.surface,
            border: Border.all(
              color: accentColor ?? retro.border,
              width: accentColor != null ? 2.5 : 2,
            ),
            boxShadow: retro.hardShadow(dx: 2, dy: 2),
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
                      style: TextStyle(
                        color: titleColor ?? retro.ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: retro.inkDim,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (pathHint != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        pathHint!,
                        style: TextStyle(
                          color: retro.inkDim,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
  const _RetroIconBox({required this.retro, required this.icon, this.accentColor});

  final RetroTheme retro;
  final IconData icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final c = accentColor ?? retro.inkDim;
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: retro.surfaceAlt,
        border: Border.all(color: c, width: 2),
      ),
      child: Icon(icon, color: c, size: 18),
    );
  }
}

class _RetroSpinner extends StatelessWidget {
  const _RetroSpinner({required this.retro});

  final RetroTheme retro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: retro.surfaceAlt,
        border: Border.all(color: retro.accent, width: 2),
      ),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: retro.accent),
      ),
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
      trailing: Icon(Icons.chevron_right_rounded, color: retro.inkDim, size: 20),
    );
  }
}

// ── Theme selector ────────────────────────────────────────────────────────────

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  static const _options = [
    (mode: ThemeMode.light, label: 'Light', icon: Icons.wb_sunny_rounded),
    (mode: ThemeMode.dark, label: 'Dark', icon: Icons.nightlight_round),
    (
      mode: ThemeMode.system,
      label: 'System',
      icon: Icons.brightness_auto_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border.all(color: retro.border, width: 2.5),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_rounded, size: 14, color: retro.accent),
              const SizedBox(width: 6),
              Text(
                l10n.settingsThemeMode,
                style: TextStyle(
                  color: retro.inkDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _options.asMap().entries.map((entry) {
              final i = entry.key;
              final opt = entry.value;
              final isSelected = themeMode == opt.mode;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                  child: _ThemeOptionTile(
                    retro: retro,
                    icon: opt.icon,
                    label: opt.label,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(opt.mode),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Language selector ─────────────────────────────────────────────────────────

class _LocaleSelector extends ConsumerStatefulWidget {
  const _LocaleSelector();

  @override
  ConsumerState<_LocaleSelector> createState() => _LocaleSelectorState();
}

class _LocaleSelectorState extends ConsumerState<_LocaleSelector> {
  bool _expanded = false;

  String _flag(String? tag) => switch (tag) {
        null => '🌐',
        'en_US' => '🇺🇸',
        'es_419' => '🇲🇽',
        'pt_BR' => '🇧🇷',
        _ => '🌐',
      };

  String _currentLabel(AppLocalizations l10n, String? tag) => switch (tag) {
        null => l10n.languageFollowSystem,
        'en_US' => l10n.languageEnglish,
        'es_419' => l10n.languageSpanish,
        'pt_BR' => l10n.languagePortuguese,
        _ => l10n.languageFollowSystem,
      };

  @override
  Widget build(BuildContext context) {
    final localeTag = ref.watch(localeNotifierProvider);
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: retro.surface,
        border: Border.all(color: retro.border, width: 2.5),
        boxShadow: retro.hardShadow(dx: 3, dy: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Icon(Icons.translate_rounded, size: 14, color: retro.accent),
                const SizedBox(width: 6),
                Text(
                  l10n.settingsLanguageMode,
                  style: TextStyle(
                    color: retro.inkDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(_flag(localeTag), style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 6),
                Text(
                  _currentLabel(l10n, localeTag),
                  style: TextStyle(
                    color: retro.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: _expanded ? retro.accent : retro.inkDim,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.hardEdge,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _options(l10n).map((opt) {
                        final isSelected = localeTag == opt.tag;
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(localeNotifierProvider.notifier)
                                .setLocale(opt.tag);
                            setState(() => _expanded = false);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? retro.accent : retro.surfaceAlt,
                              border: Border.all(
                                color: isSelected
                                    ? retro.border
                                    : retro.border.withValues(alpha: 0.4),
                                width: isSelected ? 2 : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(opt.flag,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    opt.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? retro.background
                                          : retro.ink,
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check,
                                      size: 16, color: retro.background),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  List<({String? tag, String label, String flag})> _options(
      AppLocalizations l10n) {
    return [
      (tag: null, label: l10n.languageFollowSystem, flag: '🌐'),
      (tag: 'en_US', label: l10n.languageEnglish, flag: '🇺🇸'),
      (tag: 'es_419', label: l10n.languageSpanish, flag: '🇲🇽'),
      (tag: 'pt_BR', label: l10n.languagePortuguese, flag: '🇧🇷'),
    ];
  }
}

class _ThemeOptionTile extends StatefulWidget {
  const _ThemeOptionTile({
    required this.retro,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final RetroTheme retro;
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ThemeOptionTile> createState() => _ThemeOptionTileState();
}

class _ThemeOptionTileState extends State<_ThemeOptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = widget.retro;
    final bg = widget.isSelected ? retro.accent : retro.surfaceAlt;
    final fg = widget.isSelected ? retro.background : retro.inkDim;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          final offset = 2.0 * _pressCtrl.value;
          return Transform.translate(offset: Offset(offset, offset), child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(
              color: widget.isSelected
                  ? retro.border
                  : retro.border.withValues(alpha: 0.4),
              width: widget.isSelected ? 2 : 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 18, color: fg),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: fg,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
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
      subtitle: _loading ? l10n.settingsDownloading : l10n.settingsDownloadLatest,
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
        builder: (_) => UpdateDialog(
          config: config,
          isForce: config.forceUpdate,
        ),
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
      subtitle: _loading ? l10n.settingsChecking : 'Current: v${UpdateService.currentVersion}',
    );
  }
}

// ── Shared helpers ──────────────────────────────────────────────────────────

class _RetroGap extends StatelessWidget {
  const _RetroGap({required this.height});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

// ── Overlay toggle ──────────────────────────────────────────────────────────

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
            closeIcon: IconSource.asset('packages/floaty_chatheads/assets/close.png'),
            closeBackground: IconSource.asset('packages/floaty_chatheads/assets/closeBg.png'),
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
      title: _active ? l10n.settingsOverlayActive : l10n.settingsOverlayInactive,
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
