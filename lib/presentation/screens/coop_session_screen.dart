import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../domain/entities/coop_session.dart';
import '../../l10n/app_localizations.dart';
import '../providers/coop_session_provider.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/game_setup_widgets.dart';
import '../widgets/coop_play_visuals.dart';
import '../widgets/manga_navigation_scope.dart';

class CoopSessionScreen extends ConsumerStatefulWidget {
  const CoopSessionScreen({super.key});

  @override
  ConsumerState<CoopSessionScreen> createState() => _CoopSessionScreenState();
}

class _CoopSessionScreenState extends ConsumerState<CoopSessionScreen>
    with WidgetsBindingObserver {
  final _code = TextEditingController();
  List<String> _recent = const [];
  CoopBatteryOptimizationState? _battery;
  bool _starting = false;
  bool _batteryBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadRecent());
    unawaited(_loadBatteryStatus());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _code.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_loadBatteryStatus());
    }
  }

  Future<void> _loadRecent() async {
    try {
      final values = await ref.read(coopSessionProvider.notifier).recentCodes();
      if (mounted) setState(() => _recent = values);
    } catch (_) {
      // Recent codes are a convenience and must not block the Play screen.
    }
  }

  Future<void> _loadBatteryStatus() async {
    try {
      final value = await ref
          .read(coopSessionProvider.notifier)
          .batteryOptimizationStatus();
      if (mounted) setState(() => _battery = value);
    } catch (_) {
      // This optional Android capability must never block multiplayer setup.
    }
  }

  Future<void> _configureBatteryOptimization() async {
    final current = _battery;
    if (current == null || _batteryBusy) return;
    setState(() => _batteryBusy = true);
    try {
      final value = current.ignored
          ? await ref
                .read(coopSessionProvider.notifier)
                .openBatteryOptimizationSettings()
          : await ref
                .read(coopSessionProvider.notifier)
                .requestBatteryOptimizationExemption();
      if (!value.settingsOpened && !value.ignored && mounted) {
        AppSnackbar.error(
          context,
          message: AppLocalizations.of(context).coopBatteryOpenError,
        );
      }
      if (mounted) setState(() => _battery = value);
    } on PlatformException {
      if (mounted) {
        AppSnackbar.error(
          context,
          message: AppLocalizations.of(context).coopBatteryOpenError,
        );
      }
    } finally {
      if (mounted) setState(() => _batteryBusy = false);
    }
  }

  Future<void> _create() async {
    if (!await _ensureNetworkConsent()) return;
    if (!mounted) return;
    setState(() => _starting = true);
    try {
      final code = await ref.read(coopSessionProvider.notifier).generateCode();
      await ref
          .read(coopSessionProvider.notifier)
          .start(CoopSessionMode.host, code);
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _join() async {
    final value = normalizeCoopCode(_code.text);
    if (!isValidCoopCode(value)) {
      AppSnackbar.error(
        context,
        message: AppLocalizations.of(context).coopNoCode,
      );
      return;
    }
    if (!await _ensureNetworkConsent()) return;
    if (!mounted) return;
    setState(() => _starting = true);
    try {
      await ref
          .read(coopSessionProvider.notifier)
          .start(CoopSessionMode.join, value);
      await _loadRecent();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<bool> _ensureNetworkConsent({bool forceReview = false}) async {
    final notifier = ref.read(coopSessionProvider.notifier);
    try {
      if (!forceReview && await notifier.networkConsentAccepted()) return true;
    } catch (_) {
      // A damaged preference must fall back to explicit consent.
    }
    if (!mounted) return false;
    final l = AppLocalizations.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.coopConsentTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.coopConsentIntro),
              const SizedBox(height: 16),
              _ConsentPoint(
                icon: Icons.lock_outline_rounded,
                text: l.coopConsentEncrypted,
              ),
              const SizedBox(height: 12),
              _ConsentPoint(icon: Icons.public_rounded, text: l.coopConsentIp),
              const SizedBox(height: 12),
              _ConsentPoint(
                icon: Icons.cloud_outlined,
                text: l.coopConsentThirdParty,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.coopConsentCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.coopConsentAccept),
          ),
        ],
      ),
    );
    if (accepted != true) return false;
    try {
      await notifier.acceptNetworkConsent();
      return true;
    } catch (_) {
      if (mounted) {
        AppSnackbar.error(context, message: l.coopConsentSaveError);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final state = ref.watch(coopSessionProvider);
    return RetroFixedHeaderView(
      title: CoopPlayTitle(label: l.coopTitle, size: 22),
      child: SafeArea(
        top: false,
        bottom: !MangaNavigationScope.of(context),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            28 + mangaNavigationScrollInset(context),
          ),
          children: [
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (retro.isManga) ...[
                        const CoopPlayIcon(size: 48),
                        const SizedBox(width: 12),
                      ],
                      Expanded(child: Text(l.coopIntro,
                        style: coopPlayBody(retro, size: 14, height: 1.4))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    leading: Icon(Icons.shield_outlined, color: retro.accentText),
                    title: Text(l.coopConsentTitle,
                      style: coopPlayBody(retro, size: 13, color: retro.inkDim)),
                    children: [Text(l.coopPrivacy,
                      style: coopPlayBody(retro, size: 13, color: retro.inkDim))],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => _ensureNetworkConsent(forceReview: true),
                      icon: const Icon(Icons.privacy_tip_outlined),
                      label: Text(l.coopConsentReview),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!state.phase.active)
              _setup(context, state)
            else
              _session(context, state),
          ],
        ),
      ),
    );
  }

  Widget _setup(BuildContext context, CoopSessionState state) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final enabled = state.initialized && !_starting;
    return Column(
      children: [
        if (state.gameInstalled == false) ...[
          _Panel(
            key: const ValueKey('coop-game-missing'),
            child: GameSetupStatus(
              label: l.coopGameMissing,
              icon: Icons.sports_esports_outlined,
              ready: false,
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (_battery case final battery? when battery.supported && !battery.ignored) ...[
          const SizedBox(height: 14),
          _Panel(
            key: const ValueKey('coop-battery-help'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GameSetupStatus(
                  label: l.coopBatteryTitle,
                  icon: Icons.battery_saver_outlined,
                  detail: battery.ignored
                      ? l.coopBatteryAllowed
                      : l.coopBatteryDescription,
                  ready: battery.ignored,
                ),
                const SizedBox(height: 12),
                CoopPlayAction(
                  label: battery.ignored
                      ? l.coopBatteryManage
                      : l.coopBatteryAllow,
                  icon: Icons.settings_rounded,
                  onPressed: _batteryBusy
                      ? null
                      : _configureBatteryOptimization,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        CoopPlayAction(
          label: l.coopCreate,
          icon: Icons.add_link_rounded,
          primary: true,
          onPressed: enabled ? _create : null,
        ),
        const SizedBox(height: 14),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                if (retro.isManga) ...[
                  const CoopPlayIcon(asset: 'explore', size: 36),
                  const SizedBox(width: 10),
                ],
                Expanded(child: CoopPlayTitle(label: l.coopJoin, size: 18)),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: _code,
                style: coopPlayBody(retro, size: 18, color: retro.ink),
                enabled: enabled,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9-]')),
                  LengthLimitingTextInputFormatter(9),
                ],
                decoration: InputDecoration(
                  labelText: l.coopCode,
                  hintText: l.coopCodeHint,
                ),
                onSubmitted: (_) => enabled ? _join() : null,
              ),
              if (_recent.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.coopRecent,
                        style: coopPlayBody(retro, size: 13, color: retro.inkDim),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await ref
                            .read(coopSessionProvider.notifier)
                            .clearRecentCodes();
                        if (mounted) setState(() => _recent = const []);
                      },
                      child: Text(l.coopClearRecent),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final code in _recent)
                      ActionChip(
                        label: Text(code, style: coopPlayBody(retro, size: 14)),
                        onPressed: () => setState(() => _code.text = code),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              CoopPlayAction(
                label: l.coopJoin,
                icon: Icons.login_rounded,
                onPressed: enabled ? _join : null,
              ),
            ],
          ),
        ),
        if (state.phase == CoopSessionPhase.failed &&
            state.message != null) ...[
          const SizedBox(height: 14),
          _ErrorPanel(message: state.message!),
        ],
      ],
    );
  }

  Widget _session(BuildContext context, CoopSessionState state) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final code = state.code ?? '';
    final status = switch (state.phase) {
      CoopSessionPhase.waiting => l.coopWaiting,
      CoopSessionPhase.connecting => l.coopConnecting,
      CoopSessionPhase.connected => l.coopConnected,
      CoopSessionPhase.reconnecting => l.coopReconnecting,
      CoopSessionPhase.failed => state.message ?? l.coopNetworkError,
      _ => l.coopPreparing,
    };
    return Column(
      children: [
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _Pulse(active: state.phase != CoopSessionPhase.failed),
                  const SizedBox(width: 10),
                  Expanded(child: CoopPlayTitle(label: status, size: 18)),
                ],
              ),
              if (state.mode == CoopSessionMode.host && code.isNotEmpty) ...[
                const SizedBox(height: 18),
                Semantics(
                  label: '${l.coopCode}: $code',
                  child: SelectableText(
                    code,
                    textAlign: TextAlign.center,
                    style: retro.heading(size: 30, color: retro.accentText),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    AppSnackbar.success(context, message: l.coopCopied);
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l.coopCopy),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                l.coopPeers(state.peers.length),
                style: coopPlayBody(retro, size: 15),
              ),
              if (state.peers.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final peer in state.peers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          peer.reconnecting
                              ? Icons.sync_rounded
                              : Icons.person_rounded,
                          color: peer.reconnecting
                              ? retro.amber
                              : retro.accentText,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            peer.id.length > 6
                                ? peer.id.substring(0, 6)
                                : peer.id,
                            style: coopPlayBody(retro, size: 14),
                          ),
                        ),
                        if (peer.route != null)
                          Chip(
                            label: Text(
                              peer.route == 'relay'
                                  ? l.coopRelay
                                  : l.coopDirect,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DiagnosticsPanel(state: state),
        const SizedBox(height: 14),
        _Panel(
          child: GameSetupStatus(
            label: state.mode == CoopSessionMode.host
                ? l.coopHostInstruction
                : l.coopJoinInstruction(state.port ?? 7777),
            icon: Icons.info_outline_rounded,
            detail: state.gameInstalled == false ? l.coopGameMissing : null,
            ready: state.gameInstalled,
          ),
        ),
        const SizedBox(height: 14),
        CoopPlayAction(
          label: l.coopOpenGame,
          icon: Icons.play_arrow_rounded,
          primary: true,
          onPressed: state.gameInstalled == true
              ? () async {
                  final opened = await ref
                      .read(coopSessionProvider.notifier)
                      .openGame();
                  if (!opened && context.mounted) {
                    AppSnackbar.error(context, message: l.coopGameMissing);
                  }
                }
              : null,
        ),
        const SizedBox(height: 10),
        CoopPlayAction(
          label: l.coopStop,
          icon: Icons.stop_circle_outlined,
          onPressed: state.phase == CoopSessionPhase.stopping
              ? null
              : () => ref.read(coopSessionProvider.notifier).stop(),
        ),
      ],
    );
  }
}

class _ConsentPoint extends StatelessWidget {
  const _ConsentPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: retro.accentText),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: retro.body(size: 14, height: 1.4))),
      ],
    );
  }
}

class _DiagnosticsPanel extends StatelessWidget {
  const _DiagnosticsPanel({required this.state});

  final CoopSessionState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final diagnostics = state.diagnostics;
    return RepaintBoundary(
      child: _Panel(
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 8),
          title: CoopPlayTitle(label: l.coopDiagnosticsTitle, size: 16),
          leading: Icon(Icons.monitor_heart_outlined, color: retro.accentText),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l.coopDiagnosticsSignal(state.trackers),
                style: coopPlayBody(retro, size: 13, color: retro.inkDim),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l.coopDiagnosticsPackets(
                  diagnostics.toGame,
                  diagnostics.toPage,
                ),
                style: coopPlayBody(retro, size: 13, color: retro.inkDim),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                l.coopDiagnosticsDelay(
                  diagnostics.upDelayAverageMs,
                  diagnostics.upDelayMaxMs,
                ),
                style: coopPlayBody(retro, size: 13, color: retro.inkDim),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: retro.surfaceDecoration(shadowDx: 3, shadowDy: 3),
      child: child,
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return _Panel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: retro.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: coopPlayBody(retro, size: 14, color: retro.red)),
          ),
        ],
      ),
    );
  }
}

class _Pulse extends StatelessWidget {
  const _Pulse({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? retro.accentText : retro.red,
      ),
    );
  }
}
