import '../providers/game_folder_provider.dart';
import 'game_folder_card.dart';
import 'game_setup_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/mario_theme_assets_provider.dart';
import 'settings_expansion_group.dart';

class MarioRomAssetsPanel extends ConsumerWidget {
  const MarioRomAssetsPanel({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final retro = RetroTheme.of(context);
    if (!retro.isMario) return const SizedBox.shrink();
    final state = ref.watch(marioThemeAssetsProvider);
    final notifier = ref.read(marioThemeAssetsProvider.notifier);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SettingsExpansionGroup(
        key: const PageStorageKey('mario-rom-assets'),
        title: l10n.marioRomTitle,
        subtitle: state.assets.complete
            ? l10n.marioRomReady
            : state.assets.available
            ? l10n.marioRomUpgrade
            : l10n.marioRomBuiltIn,
        icon: Icons.videogame_asset_outlined,
        children: [
          Text(l10n.marioRomDescription, style: retro.body(size: 13)),
          const SizedBox(height: 12),
          if (state.busy) ...[
            LinearProgressIndicator(semanticsLabel: l10n.marioRomPreparing),
            const SizedBox(height: 8),
            Text(l10n.marioRomPreparing, style: retro.body(size: 13)),
            GameSetupAction(
              icon: Icons.close_rounded,
              onPressed: () async {
                await notifier.cancel();
              },
              label: l10n.marioRomCancel,
            ),
          ] else ...[
            GameSetupAction(
              primary: true,
              onPressed: () async {
                await ref.read(gameFolderProvider.notifier).initialize();
                if (!context.mounted) return;
                if (!ref.read(gameFolderProvider).connection.connected) {
                  if (!await connectGameFolder(context, ref) ||
                      !context.mounted)
                    return;
                }
                await notifier.perform('import');
              },
              icon: Icons.videogame_asset_outlined,
              label: l10n.marioRomImport,
            ),
            if (state.assets.available) ...[
              const SizedBox(height: 12),
              GameSetupAction(
                onPressed: () async {
                  await notifier.perform('remove');
                },
                icon: Icons.restore_rounded,
                label: l10n.marioRomRemove,
              ),
            ],
          ],
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                state.error == 'unsupported'
                    ? l10n.marioRomUnsupported
                    : state.error == 'rom_missing'
                    ? l10n.gameFolderRomMissing
                    : state.error == 'game_folder'
                    ? l10n.gameFolderAccessLost
                    : l10n.marioRomFailed,
                style: retro.body(size: 13, color: retro.red),
              ),
            ),
        ],
      ),
    );
  }
}
