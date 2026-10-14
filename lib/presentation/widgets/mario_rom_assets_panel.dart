import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme_design.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/mario_theme_assets_provider.dart';
import 'settings_expansion_group.dart';

class MarioRomAssetsPanel extends ConsumerWidget {
  const MarioRomAssetsPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    if (retro.design.id != AppThemeId.mario64) return const SizedBox.shrink();
    final state = ref.watch(marioThemeAssetsProvider);
    final notifier = ref.read(marioThemeAssetsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SettingsExpansionGroup(
        key: const PageStorageKey('mario-rom-assets'),
        title: l10n.marioRomTitle,
        subtitle: state.assets.available ? l10n.marioRomReady : l10n.marioRomBuiltIn,
        icon: Icons.videogame_asset_outlined,
        children: [
          Text(l10n.marioRomDescription, style: retro.body(size: 13)),
          const SizedBox(height: 12),
          if (state.busy) ...[
            LinearProgressIndicator(semanticsLabel: l10n.marioRomPreparing),
            const SizedBox(height: 8),
            Text(l10n.marioRomPreparing, style: retro.body(size: 13)),
            TextButton(onPressed: () async { await notifier.cancel(); }, child: Text(l10n.marioRomCancel)),
          ] else ...[
            FilledButton.icon(
              onPressed: () async { await notifier.perform('import'); },
              icon: const Icon(Icons.file_open_outlined),
              label: Text(l10n.marioRomImport),
            ),
            if (state.assets.available)
              TextButton.icon(
                onPressed: () async { await notifier.perform('remove'); },
                icon: const Icon(Icons.restore_rounded),
                label: Text(l10n.marioRomRemove),
              ),
          ],
          if (state.error != null)
            Padding(padding: const EdgeInsets.only(top: 8),
              child: Text(state.error == 'unsupported' ? l10n.marioRomUnsupported : l10n.marioRomFailed,
                style: retro.body(size: 13, color: retro.red))),
        ],
      ),
    );
  }
}
