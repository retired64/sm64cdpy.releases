import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
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
                    _AutoInstallToggle(),

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
                          l10n.settingsViewAllVersions(AppConstants.appVersion),
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

  final _installer = ModInstaller();

  @override
  void initState() {
    super.initState();
    _checkFolder();
  }

  Future<void> _checkFolder() async {
    try {
      final has = await _installer.isDirectorySelected();
      if (mounted) {
        setState(() {
          _hasFolder = has;
        });
      }
    } catch (_) {}
  }

  Future<void> _selectFolder() async {
    setState(() => _loading = true);
    try {
      final uri = await _installer.openDirectoryPicker();
      if (!mounted) return;
      if (uri != null) {
        setState(() {
          _hasFolder = true;
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

class _LocaleSelector extends ConsumerWidget {
  const _LocaleSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Row(
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
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _localeOptions(l10n).asMap().entries.map((entry) {
              final i = entry.key;
              final opt = entry.value;
              final isSelected = localeTag == opt.tag;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                  child: _ThemeOptionTile(
                    retro: retro,
                    icon: opt.icon,
                    label: opt.label,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(localeNotifierProvider.notifier)
                        .setLocale(opt.tag),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<({String? tag, String label, IconData icon})> _localeOptions(
      AppLocalizations l10n) {
    return [
      (tag: null, label: l10n.languageFollowSystem, icon: Icons.language_rounded),
      (tag: 'en_US', label: l10n.languageEnglish, icon: Icons.flag_rounded),
      (tag: 'es_419', label: l10n.languageSpanish, icon: Icons.flag_rounded),
      (tag: 'pt_BR', label: l10n.languagePortuguese, icon: Icons.flag_rounded),
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
