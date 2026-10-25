import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_design.dart';
import '../../core/theme/retro_accent.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/retro_accent_provider.dart';
import '../providers/theme_provider.dart';
import 'app_snackbar.dart';
import 'settings_expansion_group.dart';

class RetroAccentSelector extends ConsumerWidget {
  const RetroAccentSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeId = ref.watch(appearanceProvider).themeId;
    if (!themeId.isManga && themeId != AppThemeId.marioKart64) {
      return const SizedBox.shrink();
    }
    final selected = ref.watch(retroAccentProvider);
    final retro = RetroTheme.of(context);
    final l10n = AppLocalizations.of(context);
    final names = [
      l10n.retroAccentCyan,
      l10n.retroAccentBlue,
      l10n.retroAccentViolet,
      l10n.retroAccentPink,
      l10n.retroAccentCoral,
      l10n.retroAccentAmber,
      l10n.retroAccentGreen,
      l10n.retroAccentLime,
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SettingsExpansionGroup(
        key: const PageStorageKey('retro-accent-selector'),
        title: l10n.retroAccentTitle,
        subtitle: names[selected.index],
        icon: Icons.color_lens_outlined,
        children: [
          Text(retro.isDeluxe ? l10n.deluxeAccentDescription : l10n.retroAccentDescription, style: retro.body(size: 14)),
          const SizedBox(height: 12),
          for (final accent in RetroAccent.values)
            SettingsSelectionOption(
              key: ValueKey('retro-accent-${accent.name}'),
              label: names[accent.index],
              leading: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: retro.ink, width: 2),
                ),
              ),
              selected: accent == selected,
              onPressed: () async {
                final saved = await ref
                    .read(retroAccentProvider.notifier)
                    .select(accent);
                if (!context.mounted || saved) return;
                AppSnackbar.error(context, message: l10n.themeSaveFailed);
              },
            ),
        ],
      ),
    );
  }
}
