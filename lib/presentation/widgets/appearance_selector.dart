import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_catalog.dart';
import '../../core/theme/app_theme_design.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/mario_theme_assets_provider.dart';
import 'app_snackbar.dart';
import 'settings_expansion_group.dart';
import 'mario_rom_assets_panel.dart';

/// Bundled designs and brightness are independent choices. Saving is owned by
/// the provider, so rebuilding/navigating never creates a second writer.
class AppearanceSelector extends ConsumerWidget {
  const AppearanceSelector({super.key});

  String _name(AppLocalizations l10n, AppThemeId id) => switch (id) {
    AppThemeId.retroManga => l10n.themeRetroManga,
    AppThemeId.mario64 => l10n.themeMario64,
  };

  Future<void> _select(
    BuildContext context,
    WidgetRef ref, {
    AppThemeId? id,
    ThemeMode? mode,
  }) async {
    final notifier = ref.read(appearanceProvider.notifier);
    final saved = id != null
        ? await notifier.selectThemeWithRom(id)
        : await notifier.setThemeMode(mode!);
    if (!context.mounted) return;
    if (saved == false) {
      AppSnackbar.error(
        context,
        message: AppLocalizations.of(context).themeSaveFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceProvider);
    final preparingRom = ref.watch(marioThemeAssetsProvider).busy;
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final modes = [
      (ThemeMode.light, l10n.themeModeLight, Icons.wb_sunny_rounded),
      (ThemeMode.dark, l10n.themeModeDark, Icons.nightlight_round),
      (ThemeMode.system, l10n.themeModeSystem, Icons.brightness_auto_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsExpansionGroup(
          key: const PageStorageKey('bundled-theme-selector'),
          title: l10n.settingsInterfaceTheme,
          subtitle: _name(l10n, settings.themeId),
          icon: Icons.palette_outlined,
          children: [
            Text(l10n.settingsInterfaceThemeDesc, style: retro.body(size: 12)),
            const SizedBox(height: 12),
            for (final design in AppThemeCatalog.designs)
              SettingsSelectionOption(
                key: ValueKey('theme-${design.id.storageKey}'),
                label: _name(l10n, design.id),
                leading: _ThemePreview(design: design, isDark: retro.isDark),
                selected: design.id == settings.themeId,
                onPressed: settings.isSaving
                    ? null
                    : () async {
                        await _select(context, ref, id: design.id);
                      },
              ),
          ],
        ),
        const SizedBox(height: 12),
        SettingsExpansionGroup(
          key: const PageStorageKey('theme-mode-selector'),
          title: l10n.settingsThemeMode,
          subtitle: modes.firstWhere((option) => option.$1 == settings.mode).$2,
          icon: Icons.brightness_auto_outlined,
          children: [
            for (final (mode, label, icon) in modes)
              SettingsSelectionOption(
                key: ValueKey('theme-mode-${mode.name}'),
                label: label,
                leading: MarioGameIcon(icon, color: retro.accentText),
                selected: settings.mode == mode,
                onPressed: settings.isSaving
                    ? null
                    : () async {
                        await _select(context, ref, mode: mode);
                      },
              ),
          ],
        ),
        const MarioRomAssetsPanel(),
        if (settings.isSaving) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            semanticsLabel: preparingRom
                ? l10n.marioRomPreparing
                : l10n.themeSaving,
            color: retro.accent,
          ),
        ],
      ],
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.design, required this.isDark});

  final AppThemeDesign design;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final preview = RetroTheme(isDark, design: design);
    return ExcludeSemantics(
      child: SizedBox(
        width: 64,
        height: 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: preview.background,
            borderRadius: preview.radius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(-preview.chipSkew),
              child: Container(
                decoration: preview.surfaceDecoration(
                  border: 2,
                  shadowDx: 2,
                  shadowDy: 2,
                ),
                child: Center(
                  child: MarioGameIcon(
                    preview.design.playfulSelection
                        ? Icons.star_rounded
                        : Icons.star,
                    color: preview.design.playfulSelection
                        ? preview.secondaryAccent
                        : preview.accentText,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
