import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/background_install_service.dart';
import '../../services/mod_installer.dart';
import '../providers/game_mod_activation_provider.dart';

class GameModActivationPanel extends ConsumerStatefulWidget {
  const GameModActivationPanel({super.key});
  @override
  ConsumerState<GameModActivationPanel> createState() => _GameModActivationPanelState();
}

class _GameModActivationPanelState extends ConsumerState<GameModActivationPanel> with WidgetsBindingObserver {
  bool _busy = false;
  bool _expanded = false;
  int _visible = 20;
  String? _error;
  StreamSubscription<BgInstallEvent>? _subscription;
  StreamSubscription<String>? _folderSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _folderSubscription = ModInstaller.libraryInvalidations.listen((_) => unawaited(_refresh()));
    _subscription = BackgroundInstallService.instance.events.listen((event) {
      if (mounted) setState(() {});
      if (event is BgInstallCompleted) unawaited(_refresh());
    });
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _folderSubscription?.cancel();
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refresh());
  }
  Future<void> _refresh() => _run(() => ref.read(gameModActivationProvider.notifier).refresh());
  Future<void> _run(Future<void> Function() action) async {
    if (_busy || !mounted) return;
    setState(() { _busy = true; _error = null; });
    try { await action(); }
    on PlatformException catch (error) { if (mounted) setState(() => _error = error.code); }
    catch (_) { if (mounted) setState(() => _error = 'access'); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  Future<void> _change(String name, bool enabled) async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    bool? confirmed;
    try { confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(l10n.gameModsTitle), content: Text(l10n.gameModsConfirm),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.gameModsCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.gameModsApply))],
    )); } finally { if (mounted) setState(() => _busy = false); }
    if (!mounted || confirmed != true) return;
    await _run(() => ref.read(gameModActivationProvider.notifier).perform('setGameModActivation', {'name': name, 'enabled': enabled}));
    if (mounted && _error == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).gameModsSaved)));
    }
  }
  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    bool? confirmed;
    try { confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text(l10n.gameModsRestore), content: Text(l10n.gameModsRestoreConfirm),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.gameModsCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.gameModsRestore))],
    )); } finally { if (mounted) setState(() => _busy = false); }
    if (!mounted || confirmed != true) return;
    await _run(() => ref.read(gameModActivationProvider.notifier).perform('restoreGameModConfig'));
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final value = ref.watch(gameModActivationProvider);
    final installing = BackgroundInstallService.instance.activeInstalls.isNotEmpty;
    final snapshot = value.asData?.value;
    final status = _error ?? snapshot?.status;
    final message = switch (status) {
      'ready' => l10n.gameModsHint,
      'unselected' => l10n.gameModsSelectHint,
      'conflict' => l10n.gameModsConflict,
      'invalid' => l10n.gameModsBlocked,
      'size' => l10n.gameModsSize,
      'installing' => l10n.gameModsInstalling,
      'mismatch' => l10n.gameModsMismatch,
      'write' || 'verify' => l10n.gameModsWriteError,
      'limit' || 'format' => l10n.gameModsFormat,
      _ => l10n.gameModsAccess,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: retro.surface, borderRadius: retro.radius,
        border: Border.all(color: retro.border.withValues(alpha: 0.45))),
      child: ExpansionTile(
        title: Text(l10n.gameModsTitle, style: retro.heading(size: 15)),
        subtitle: Text(l10n.gameModsSubtitle, style: retro.body(size: 11)),
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) { setState(() => _expanded = expanded); if (expanded) unawaited(_refresh()); },
        childrenPadding: const EdgeInsets.all(12),
        children: [
          Text(message, style: retro.body(size: 12)),
          if (installing) Text(l10n.gameModsInstalling, style: retro.body(size: 12)),
          if (_busy || value.isLoading) const LinearProgressIndicator(),
          Wrap(spacing: 8, children: [
            TextButton.icon(onPressed: _busy ? null : () => _run(() => ref.read(gameModActivationProvider.notifier).perform('selectGameUserFolder')),
              icon: const Icon(Icons.folder_open), label: Text(l10n.gameModsSelect)),
            if (snapshot?.status != 'unselected') TextButton(onPressed: _busy ? null : () => _run(() => ref.read(gameModActivationProvider.notifier).perform('clearGameUserFolder')), child: Text(l10n.gameModsDisconnect)),
            IconButton(tooltip: l10n.libraryRefresh, onPressed: _busy ? null : _refresh, icon: const Icon(Icons.refresh)),
            if (snapshot?.backupAvailable == true || _error == 'write' || _error == 'verify') TextButton(onPressed: _busy ? null : _restore, child: Text(l10n.gameModsRestore)),
          ]),
          if (snapshot?.status == 'ready') ...[
            if (snapshot!.mods.isEmpty) Text(l10n.gameModsEmpty),
            for (final mod in snapshot.mods.take(_visible)) SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(mod.title, style: retro.body(size: 14)),
              subtitle: Text('${mod.name}\n${mod.selectable ? (mod.enabled ? l10n.gameModsEnabled : l10n.gameModsDisabled) : l10n.gameModsBlocked}', style: retro.body(size: 11)),
              value: mod.enabled,
              onChanged: _busy || installing || !mod.selectable ? null : (enabled) => _change(mod.name, enabled),
            ),
            if (snapshot.mods.length > _visible) TextButton(onPressed: () => setState(() => _visible += 20), child: Text(l10n.gameModsMore)),
          ],
        ],
      ),
    );
  }
}
