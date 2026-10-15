import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/game_folder_provider.dart';
import 'app_snackbar.dart';
import 'game_setup_widgets.dart';
import 'settings_expansion_group.dart';

/// Every entry point explains why the system folder picker is being opened.
Future<bool> connectGameFolder(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showGameSetupDialog(
    context,
    title: l10n.gameFolderTitle,
    body: l10n.gameFolderGuide,
    confirm: l10n.gameFolderChoose,
    cancel: l10n.gameFolderLater,
    icon: Icons.folder_open_rounded,
    showFolder: true,
  );
  if (!context.mounted || confirmed != true) return false;
  final result = await ref
      .read(gameFolderProvider.notifier)
      .perform('connectGameFolder');
  if (!context.mounted) return result;
  final error = ref.read(gameFolderProvider).error;
  if (error != null)
    AppSnackbar.error(
      context,
      message: error == 'installing'
          ? l10n.gameFolderBusy
          : error == 'folder'
          ? l10n.gameFolderInvalid
          : l10n.gameFolderAccessLost,
    );
  return result;
}

Future<bool> disconnectGameFolder(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showGameSetupDialog(
    context,
    title: l10n.gameFolderDisconnect,
    body: l10n.gameFolderDisconnectBody,
    confirm: l10n.gameFolderDisconnect,
    cancel: l10n.gameModsCancel,
    icon: Icons.link_off_rounded,
  );
  if (!context.mounted || confirmed != true) return false;
  final done = await ref
      .read(gameFolderProvider.notifier)
      .perform('disconnectGameFolder');
  if (!context.mounted) return done;
  if (!done)
    AppSnackbar.error(
      context,
      message: ref.read(gameFolderProvider).error == 'installing'
          ? l10n.gameFolderBusy
          : l10n.gameFolderAccessLost,
    );
  return done;
}

class GameFolderCard extends ConsumerStatefulWidget {
  const GameFolderCard({super.key, this.optional = false});
  final bool optional;
  @override
  ConsumerState<GameFolderCard> createState() => _GameFolderCardState();
}

class _GameFolderCardState extends ConsumerState<GameFolderCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    await ref.read(gameFolderProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameFolderProvider);
    if (!state.initialized) return const SizedBox.shrink();
    final folder = state.connection;
    if (widget.optional && (folder.connected || folder.dismissed))
      return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final warning = folder.status == 'access' || state.error == 'access';
    final details = <Widget>[
      if (!folder.connected)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            l10n.gameFolderSummary,
            style: retro.body(size: 16, height: 1.5),
          ),
        ),
      if (folder.status == 'installing' || state.error == 'installing')
        GameSetupStatus(
          label: l10n.gameFolderBusy,
          icon: Icons.hourglass_top_rounded,
        ),
      if (state.error == 'folder')
        GameSetupStatus(
          label: l10n.gameFolderInvalid,
          icon: Icons.folder_off_outlined,
        ),
      if (warning)
        GameSetupStatus(
          label: l10n.gameFolderAccessLost,
          icon: Icons.folder_off_outlined,
        ),
      if (folder.connected && !folder.fullAccess)
        GameSetupStatus(label: l10n.gameFolderUpgrade, icon: Icons.drive_file_move_outline_rounded),
      if (folder.connected) ...[
        if (folder.fullAccess) GameSetupStatus(
          label: l10n.gameFolderResolved,
          icon: Icons.folder_copy_outlined,
          ready: folder.mods && folder.dynos,
        ),
        GameSetupStatus(
          label: folder.config
              ? l10n.gameFolderConfigReady
              : l10n.gameFolderConfigMissing,
          icon: Icons.tune_rounded,
          ready: folder.config,
        ),
        GameSetupStatus(
          label: folder.rom
              ? l10n.gameFolderRomFound
              : l10n.gameFolderRomMissing,
          icon: Icons.videogame_asset_outlined,
          ready: folder.rom,
        ),
      ],
      AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: state.busy
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(
                  color: retro.accent,
                  backgroundColor: retro.surfaceAlt,
                ),
              )
            : const SizedBox.shrink(),
      ),
      const SizedBox(height: 12),
      GameSetupAction(
        label: folder.connected ? l10n.gameFolderChange : l10n.gameFolderChoose,
        icon: Icons.folder_open_rounded,
        primary: true,
        onPressed: state.busy
            ? null
            : () async {
                await connectGameFolder(context, ref);
              },
      ),
      if (widget.optional) ...[
        const SizedBox(height: 12),
        GameSetupAction(
          label: l10n.gameFolderLater,
          icon: Icons.arrow_forward_rounded,
          onPressed: state.busy
              ? null
              : () async {
                  await ref
                      .read(gameFolderProvider.notifier)
                      .perform('dismissGameFolderGuide');
                },
        ),
      ],
      if (!widget.optional && folder.connected) ...[
        const SizedBox(height: 12),
        GameSetupAction(
          label: l10n.gameFolderDisconnect,
          icon: Icons.link_off_rounded,
          onPressed: state.busy
              ? null
              : () async {
                  await disconnectGameFolder(context, ref);
                },
        ),
      ],
    ];
    if (!widget.optional) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SettingsExpansionGroup(
          key: const PageStorageKey('game-folder-connection'),
          title: l10n.gameFolderTitle,
          subtitle: warning
              ? l10n.gameFolderAccessLost
              : folder.connected
              ? l10n.gameFolderConnected
              : l10n.gameFolderChoose,
          icon: warning
              ? Icons.folder_off_outlined
              : Icons.sports_esports_rounded,
          children: details,
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: retro.surfaceDecoration(shadowDx: 3, shadowDy: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarioGameIcon(
                Icons.sports_esports_rounded,
                color: retro.accentText,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MarioGameTitle(
                  text: l10n.gameFolderTitle,
                  retro: retro,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...details,
        ],
      ),
    );
  }
}
