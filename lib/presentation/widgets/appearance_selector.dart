import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_catalog.dart';
import '../../core/theme/app_theme_design.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import 'app_snackbar.dart';

/// Bundled designs and brightness are independent choices. Saving is owned by
/// the provider, so rebuilding/navigating never creates a second writer.
class AppearanceSelector extends ConsumerWidget {
  const AppearanceSelector({super.key});

  String _name(AppLocalizations l10n, AppThemeId id) => switch (id) {
    AppThemeId.retroManga => l10n.themeRetroManga,
    AppThemeId.mario64 => l10n.themeMario64,
    AppThemeId.odyssey => l10n.themeOdyssey,
    AppThemeId.gamecube => l10n.themeGameCube,
  };

  Future<void> _select(
    BuildContext context,
    WidgetRef ref, {
    AppThemeId? id,
    ThemeMode? mode,
  }) async {
    final notifier = ref.read(appearanceProvider.notifier);
    final saved = id != null
        ? await notifier.setTheme(id)
        : await notifier.setThemeMode(mode!);
    if (!context.mounted) return;
    if (!saved) {
      AppSnackbar.error(
        context,
        message: AppLocalizations.of(context).themeSaveFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appearanceProvider);
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
        ExpansionTile(
          key: const PageStorageKey('bundled-theme-selector'),
          title: Text(l10n.settingsInterfaceTheme, style: retro.heading(size: 14)),
          subtitle: Text(_name(l10n, settings.themeId), style: retro.body(size: 12)),
          leading: Icon(Icons.palette_outlined, color: retro.accentText),
          childrenPadding: const EdgeInsets.all(12),
          children: [
            Text(l10n.settingsInterfaceThemeDesc, style: retro.body(size: 12)),
            const SizedBox(height: 12),
            for (final design in AppThemeCatalog.designs)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Semantics(
                  selected: design.id == settings.themeId,
                  child: OutlinedButton(
                    key: ValueKey('theme-${design.id.storageKey}'),
                    onPressed: settings.isSaving
                        ? null
                        : () async {
                            await _select(context, ref, id: design.id);
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      side: BorderSide(
                        color: design.id == settings.themeId
                            ? retro.accent
                            : retro.border,
                        width: retro.borderWidth(2),
                      ),
                    ),
                    child: Row(
                      children: [
                        _ThemePreview(design: design, isDark: retro.isDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_name(l10n, design.id), style: retro.heading(size: 14)),
                        ),
                        if (design.id == settings.themeId)
                          Icon(Icons.check_circle, color: retro.accentText),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: retro.surface,
            borderRadius: retro.radius,
            border: Border.all(color: retro.border, width: retro.borderWidth(2.5)),
            boxShadow: retro.hardShadow(dx: 3, dy: 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsThemeMode, style: retro.heading(size: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (mode, label, icon) in modes)
                    ChoiceChip(
                      key: ValueKey('theme-mode-${mode.name}'),
                      avatar: Icon(icon, size: 18),
                      label: Text(label),
                      selected: settings.mode == mode,
                      onSelected: settings.isSaving
                          ? null
                          : (_) async {
                              await _select(context, ref, mode: mode);
                            },
                      selectedColor: retro.accent,
                      labelStyle: retro.body(
                        size: 12,
                        color: settings.mode == mode ? retro.inkOnAccent : retro.ink,
                      ),
                      iconTheme: IconThemeData(
                        color: settings.mode == mode ? retro.inkOnAccent : retro.ink,
                      ),
                      checkmarkColor: retro.inkOnAccent,
                      shape: RoundedRectangleBorder(borderRadius: retro.radius),
                    ),
                ],
              ),
              if (settings.isSaving) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  semanticsLabel: l10n.themeSaving,
                  color: retro.accent,
                ),
              ],
            ],
          ),
        ),
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
          decoration: BoxDecoration(color: preview.background, borderRadius: preview.radius),
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(-preview.chipSkew),
              child: Container(
                decoration: BoxDecoration(
                  color: preview.surface,
                  borderRadius: preview.radius,
                  border: Border.all(color: preview.border, width: preview.borderWidth(2)),
                  boxShadow: preview.hardShadow(dx: 2, dy: 2),
                ),
                child: Center(
                  child: Icon(Icons.star, color: preview.accentText, size: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
