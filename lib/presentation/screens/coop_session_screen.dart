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
import '../widgets/manga_navigation_scope.dart';

class CoopSessionScreen extends ConsumerStatefulWidget {
  const CoopSessionScreen({super.key});

  @override
  ConsumerState<CoopSessionScreen> createState() => _CoopSessionScreenState();
}

class _CoopSessionScreenState extends ConsumerState<CoopSessionScreen> {
  final _code = TextEditingController();
  List<String> _recent = const [];
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final values = await ref.read(coopSessionProvider.notifier).recentCodes();
    if (mounted) setState(() => _recent = values);
  }

  Future<void> _create() async {
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
    final value = _normalized(_code.text);
    if (!_valid(value)) {
      AppSnackbar.error(
        context,
        message: AppLocalizations.of(context).coopNoCode,
      );
      return;
    }
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

  static String _normalized(String input) {
    final raw = input
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z0-9]'), '')
        .replaceAll(RegExp('[IL]'), '1')
        .replaceAll('O', '0');
    return raw.length == 8 ? '${raw.substring(0, 4)}-${raw.substring(4)}' : raw;
  }

  static bool _valid(String code) =>
      RegExp(r'^[0-9A-HJKMNP-TV-Z]{4}-[0-9A-HJKMNP-TV-Z]{4}$').hasMatch(code);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final state = ref.watch(coopSessionProvider);
    return RetroFixedHeaderView(
      title: Text(l.coopTitle, style: retro.heading(size: 22)),
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
                    children: [
                      MarioGameIcon(
                        Icons.group_outlined,
                        color: retro.accentText,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.coopTitle,
                          style: retro.heading(size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l.coopIntro, style: retro.body(size: 15, height: 1.45)),
                  const SizedBox(height: 12),
                  Text(
                    l.coopPrivacy,
                    style: retro.body(
                      size: 13,
                      color: retro.inkDim,
                      height: 1.4,
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
        _Panel(
          child: GameSetupStatus(
            label: state.gameInstalled == true
                ? l.coopGameReady
                : l.coopGameMissing,
            icon: Icons.sports_esports_outlined,
            ready: state.gameInstalled,
          ),
        ),
        const SizedBox(height: 14),
        GameSetupAction(
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
              Text(l.coopJoin, style: retro.heading(size: 18)),
              const SizedBox(height: 12),
              TextField(
                controller: _code,
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
                        style: retro.body(size: 13, color: retro.inkDim),
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
                        label: Text(code),
                        onPressed: () => setState(() => _code.text = code),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              GameSetupAction(
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
                  Expanded(child: Text(status, style: retro.heading(size: 18))),
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
                style: retro.body(size: 15),
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
                            style: retro.body(size: 14),
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
        GameSetupAction(
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
        GameSetupAction(
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

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
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
            child: Text(message, style: retro.body(size: 14, color: retro.red)),
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
