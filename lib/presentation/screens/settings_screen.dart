import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';

import '../providers/mod_providers.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';

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
          _SectionLabel('Appearance'),
          _ThemeSelector(),

          const SizedBox(height: 20),
          _SectionLabel('About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App version',
            subtitle: AppConstants.appVersion,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You have no favourites to export.'),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final error = await ref
        .read(favouritesProvider.notifier)
        .exportFavourites();
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.added == 0
              ? 'Nothing new to import. ${parts.join(' · ')}'
              : 'Import complete · ${parts.join(' · ')}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Favourites cleared'),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  behavior: SnackBarBehavior.floating,
                ),
              );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cannot open URL: $url'),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database updated · $modCount mods$date'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Unknown error'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
        ),
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
