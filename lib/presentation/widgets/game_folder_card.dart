import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/game_folder_provider.dart';
import 'app_snackbar.dart';

/// Every entry point explains why the system folder picker is being opened.
Future<bool> connectGameFolder(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(scrollable: true,
    title: Text(l10n.gameFolderTitle),
    content: Text(l10n.gameFolderGuide, style: RetroTheme.of(dialogContext).body(size: 16)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.gameFolderLater)),
      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.gameFolderChoose)),
    ],
  ));
  if (!context.mounted || confirmed != true) return false;
  final result = await ref.read(gameFolderProvider.notifier).perform('connectGameFolder');
  if (!context.mounted) return result;
  final error = ref.read(gameFolderProvider).error;
  if (error != null) AppSnackbar.error(context, message: error == 'installing'
    ? l10n.gameFolderBusy : error == 'folder' ? l10n.gameFolderInvalid : l10n.gameFolderAccessLost);
  return result;
}

Future<bool> disconnectGameFolder(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(scrollable: true,
    title: Text(l10n.gameFolderDisconnect), content: Text(l10n.gameFolderDisconnectBody, style: RetroTheme.of(dialogContext).body(size: 16)),
    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l10n.gameModsCancel)),
      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l10n.gameFolderDisconnect))]));
  if (!context.mounted || confirmed != true) return false;
  final done = await ref.read(gameFolderProvider.notifier).perform('disconnectGameFolder');
  if (!context.mounted) return done;
  if (!done) AppSnackbar.error(context, message: ref.read(gameFolderProvider).error == 'installing'
    ? l10n.gameFolderBusy : l10n.gameFolderAccessLost);
  return done;
}

class GameFolderCard extends ConsumerStatefulWidget {
  const GameFolderCard({super.key, this.optional = false});
  final bool optional;
  @override
  ConsumerState<GameFolderCard> createState() => _GameFolderCardState();
}
class _GameFolderCardState extends ConsumerState<GameFolderCard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); super.dispose(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }
  Future<void> _refresh() async { await ref.read(gameFolderProvider.notifier).refresh(); }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameFolderProvider);
    if (!state.initialized) return const SizedBox.shrink();
    final folder = state.connection;
    if (widget.optional && (folder.connected || folder.dismissed)) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: retro.surfaceDecoration(shadowDx: 2, shadowDy: 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(folder.connected ? l10n.gameFolderConnected : l10n.gameFolderTitle, style: retro.heading(size: 16)),
        const SizedBox(height: 10),
        Text(folder.connected && folder.unified ? l10n.gameFolderResolved : l10n.gameFolderSummary, style: retro.body(size: 16)),
        if (folder.status == 'installing') Text(l10n.gameFolderBusy, style: retro.body(size: 16)),
        if (folder.status == 'access') Text(l10n.gameFolderAccessLost, style: retro.body(size: 16, color: retro.red)),
        if (folder.connected) ...[
          const SizedBox(height: 8),
          Text(folder.config ? l10n.gameFolderConfigReady : l10n.gameFolderConfigMissing, style: retro.body(size: 16)),
          Text(folder.rom ? l10n.gameFolderRomFound : l10n.gameFolderRomMissing, style: retro.body(size: 16)),
        ],
        if (state.busy) const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: LinearProgressIndicator()),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: state.busy ? null : () async { await connectGameFolder(context, ref); },
          icon: const MarioGameIcon(Icons.folder_open_rounded),
          label: Text(folder.connected ? l10n.gameFolderChange : l10n.gameFolderChoose)),
        if (widget.optional)
          TextButton(onPressed: state.busy ? null : () async {
            await ref.read(gameFolderProvider.notifier).perform('dismissGameFolderGuide');
          }, child: Text(l10n.gameFolderLater)),
        if (!widget.optional && folder.connected)
          TextButton(onPressed: state.busy ? null : () async {
            await disconnectGameFolder(context, ref);
          }, child: Text(l10n.gameFolderDisconnect)),
      ]),
    );
  }
}
