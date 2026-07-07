import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../services/mod_installer.dart';
import '../../services/update_service.dart';
import '../../widgets/update_dialog.dart';

import '../providers/mod_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_snackbar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AppDrawer(currentRoute: '/settings'),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel('Data'),
          _ReloadDatabaseTile(),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            title: 'Clear favourites',
            subtitle: 'Remove all saved mods',
            destructive: true,
            onTap: () => _confirmClearFavourites(context, ref),
          ),
          _SettingsTile(
            icon: Icons.upload_rounded,
            title: 'Export favourites',
            subtitle: 'Share your saved mods',
            onTap: () => _exportFavourites(context, ref),
          ),
          _SettingsTile(
            icon: Icons.download_rounded,
            title: 'Import favourites',
            subtitle: 'Restore from a previously exported file',
            onTap: () => _importFavourites(context, ref),
          ),

          const SizedBox(height: 12),
          _SectionLabel('Game Integration'),
          _ModsFolderTile(),
          _AutoInstallToggle(),

          const SizedBox(height: 12),
          _SectionLabel('Appearance'),
          _ThemeSelector(),

          const SizedBox(height: 20),
          _SectionLabel('About'),
          _CheckUpdateTile(),
          _SettingsTile(
            icon: Icons.open_in_browser_rounded,
            title: 'Go to releases',
            subtitle: 'View all versions on GitHub · v${AppConstants.appVersion}',
            onTap: () => _launchUrl(context, AppConstants.githubReleasesUrl),
          ),
          _SettingsTile(
            icon: Icons.extension_rounded,
            title: 'Data source',
            subtitle: 'mods.sm64coopdx.com',
            onTap: () => _launchUrl(context, AppConstants.dataSourceUrl),
          ),
        ],
      ),
    );
  }

  Future<void> _exportFavourites(BuildContext context, WidgetRef ref) async {
    final count = ref.read(favouritesProvider).length;
    if (count == 0) {
      if (!context.mounted) return;
      AppSnackbar.info(context, message: 'You have no favourites to export.');
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
    if (result.added > 0) parts.add('${result.added} added');
    if (result.skippedDuplicate > 0) {
      parts.add('${result.skippedDuplicate} already saved');
    }
    if (result.skippedUnknown > 0) {
      parts.add('${result.skippedUnknown} not found in catalogue');
    }

    AppSnackbar.success(
      context,
      message: result.added == 0
          ? 'Nothing new to import. ${parts.join(' · ')}'
          : 'Import complete · ${parts.join(' · ')}',
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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
        title: Text(
          'Clear favourites?',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        content: Text(
          'This will remove all your saved mods. This action cannot be undone.',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              // Toggle off all current favourites
              final favIds = Set<String>.from(ref.read(favouritesProvider));
              for (final id in favIds) {
                ref.read(favouritesProvider.notifier).toggle(id);
              }
              Navigator.of(ctx).pop();
              AppSnackbar.success(context, message: 'Favourites cleared');
            },
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUrlError(BuildContext context, String url) {
    AppSnackbar.error(context, message: 'Cannot open URL: $url');
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
        AppSnackbar.success(
          context,
          message: 'Mods folder selected. Mods will be installed here.',
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
        title: Text(
          'Clear mods folder?',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        content: Text(
          'You will need to select the folder again before installing mods to the game.',
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Clear',
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _installer.clearDirectorySelection();
      if (mounted) {
        setState(() {
          _hasFolder = false;
        });
        AppSnackbar.info(context, message: 'Mods folder selection cleared.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: ListTile(
        leading: Icon(
          _hasFolder ? Icons.folder_special_rounded : Icons.folder_open_rounded,
          color: _hasFolder ? cs.primary : cs.onSurfaceVariant,
          size: 20,
        ),
        title: Text(
          _hasFolder ? 'Mods folder' : 'Select mods folder',
          style: TextStyle(
            color: _hasFolder ? cs.primary : cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _hasFolder
              ? 'Tap to change \u00b7 Long-press to clear'
              : 'Choose where to install downloaded mods',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: _loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
            : Icon(Icons.chevron_right, color: cs.onSurfaceVariant, size: 20),
        onTap: _loading ? null : _selectFolder,
        onLongPress: _hasFolder ? () => _confirmClear() : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: SwitchListTile(
        secondary: Icon(
          Icons.auto_mode_rounded,
          color: _autoInstall ? cs.primary : cs.onSurfaceVariant,
          size: 20,
        ),
        title: Text(
          'Auto-install after download',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _autoInstall
              ? 'Mods will be automatically installed to the game folder'
              : 'You will be asked after each download',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        value: _autoInstall,
        onChanged: _toggle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
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
    final titleColor = destructive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    final iconColor = destructive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

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
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Appearance',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: _options.map((opt) {
                final isSelected = themeMode == opt.mode;
                return Expanded(
                  child: _ThemeOptionTile(
                    icon: opt.icon,
                    label: opt.label,
                    isSelected: isSelected,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(opt.mode),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatefulWidget {
  const _ThemeOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ThemeOptionTile> createState() => _ThemeOptionTileState();
}

class _ThemeOptionTileState extends State<_ThemeOptionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: widget.isSelected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: cs.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            border: widget.isSelected
                ? Border.all(color: cs.outline.withValues(alpha: 0.18), width: 0.8)
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  key: ValueKey(widget.isSelected),
                  size: 20,
                  color: widget.isSelected
                      ? cs.primary
                      : cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isSelected
                      ? cs.onSurface
                      : cs.onSurfaceVariant.withValues(alpha: 0.65),
                  fontSize: 12,
                  fontWeight: widget.isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
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
      // Refresh del provider para que toda la UI recargue con los nuevos datos
      ref.invalidate(allModsProvider);

      final modCount = result.modCount ?? 0;
      final date = result.generatedAt?.isNotEmpty == true
          ? ' · Generated ${result.generatedAt}'
          : '';

      AppSnackbar.success(
        context,
        message: 'Database updated · $modCount mods$date',
      );
    } else {
      AppSnackbar.error(
        context,
        message: result.errorMessage ?? 'Unknown error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: ListTile(
        leading: _loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
            : Icon(
                Icons.cloud_download_rounded,
                color: cs.onSurfaceVariant,
                size: 20,
              ),
        title: Text(
          'Reload database',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _loading ? 'Downloading...' : 'Download latest mod list',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: _loading ? null : _reload,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
      AppSnackbar.info(
        context,
        message: 'You\'re up to date · v${UpdateService.currentVersion}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline),
      ),
      child: ListTile(
        leading: _loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
            : Icon(
                Icons.system_update_rounded,
                color: cs.onSurfaceVariant,
                size: 20,
              ),
        title: Text(
          'Check for updates',
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _loading ? 'Checking...' : 'Current: v${UpdateService.currentVersion}',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: _loading ? null : _check,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
