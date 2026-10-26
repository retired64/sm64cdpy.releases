import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/guided_setup_service.dart';
import '../providers/auto_install_provider.dart';
import '../providers/audio_experience_provider.dart';
import '../providers/game_folder_provider.dart';
import 'game_setup_widgets.dart';
import 'mario_multicolor_label.dart';

const _welcomeAsset = 'assets/themes/manga_deluxe/onboarding/welcome-wave.webp';
const _startAsset = 'assets/themes/manga_deluxe/onboarding/start.webp';
const _laterAsset = 'assets/themes/manga_deluxe/onboarding/later.webp';
const _folderAsset = 'assets/themes/manga/navigation/library.webp';
const _audioAsset = 'assets/themes/manga/navigation/audio.webp';
const _readyAsset = 'assets/themes/manga/navigation/home-start-game.webp';

Future<void> showGuidedSetupFlow(
  BuildContext context, {
  bool allowDismiss = true,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _GuidedSetupDialog(allowDismiss: allowDismiss),
);

class _GuidedSetupDialog extends ConsumerStatefulWidget {
  const _GuidedSetupDialog({required this.allowDismiss});
  final bool allowDismiss;

  @override
  ConsumerState<_GuidedSetupDialog> createState() => _GuidedSetupDialogState();
}

class _GuidedSetupDialogState extends ConsumerState<_GuidedSetupDialog> {
  int _step = 0;
  bool _busy = false;
  String? _error;

  Future<void> _dismiss() async {
    await GuidedSetupService.dismiss();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _connectFolder() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final connected = await ref
        .read(gameFolderProvider.notifier)
        .perform('connectGameFolder');
    if (!mounted) return;
    setState(() => _busy = false);
    if (connected) {
      setState(() => _step = 2);
    } else {
      setState(() => _error = ref.read(gameFolderProvider).error ?? 'access');
    }
  }

  Future<void> _skipFolder() async {
    if (_busy) return;
    setState(() => _busy = true);
    await ref
        .read(gameFolderProvider.notifier)
        .perform('dismissGameFolderGuide');
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step = 2;
    });
  }

  Future<void> _setAutoInstall(bool enabled) async {
    if (_busy) return;
    setState(() => _busy = true);
    final saved = await ref
        .read(autoInstallProvider.notifier)
        .setEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (saved) _step = 3;
    });
  }

  Future<void> _setAudioExperience(bool enabled) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final saved = await ref.read(audioExperienceProvider).setEnabled(enabled);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (saved) {
        _step = 4;
      } else {
        _error = 'audio';
      }
    });
  }

  Future<void> _finish() async {
    await GuidedSetupService.complete();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    final titles = [
      l.guidedSetupWelcomeTitle,
      l.gameFolderTitle,
      l.autoInstallPromptTitle,
      l.guidedSetupAudioTitle,
      l.guidedSetupDoneTitle,
    ];
    final bodies = [
      l.guidedSetupWelcomeBody,
      l.gameFolderGuide,
      l.autoInstallPromptBody,
      l.guidedSetupAudioBody,
      l.guidedSetupDoneBody,
    ];
    final visualAssets = [
      _welcomeAsset,
      _folderAsset,
      _startAsset,
      _audioAsset,
      _readyAsset,
    ];

    return PopScope(
      canPop: false,
      child: Dialog.fullscreen(
        backgroundColor: retro.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: retro.surfaceDecoration(shadowDx: 5, shadowDy: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.guidedSetupProgress(_step + 1, 5),
                              style: retro.body(size: 14, color: retro.inkDim),
                            ),
                          ),
                          if (widget.allowDismiss && _step == 0)
                            IconButton(
                              tooltip: l.guidedSetupLater,
                              onPressed: _busy ? null : _dismiss,
                              icon: const Icon(Icons.close_rounded),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (_step + 1) / 5,
                        minHeight: 6,
                        color: retro.accent,
                        backgroundColor: retro.surfaceAlt,
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Image.asset(
                          visualAssets[_step],
                          width: _step == 0 ? 112 : 88,
                          height: _step == 0 ? 112 : 88,
                          filterQuality: FilterQuality.low,
                          excludeFromSemantics: true,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_step == 0)
                        MarioMulticolorLabel(
                          label: titles[_step],
                          fontSize: 28,
                          keyPrefix: 'guided-welcome-title',
                        )
                      else
                        MarioGameTitle(
                          text: titles[_step],
                          retro: retro,
                          size: 24,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        bodies[_step],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'FamiljenGrotesk',
                          fontSize: 17,
                          height: 1.5,
                          color: retro.ink,
                        ),
                      ),
                      if (_step == 1) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: retro.surfaceDecoration(
                            color: retro.surfaceAlt,
                            shadowDx: 1,
                            shadowDy: 1,
                          ),
                          child: Text(
                            'com.maniscat2.sm64coopdx/',
                            style: retro.body(size: 15),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 14),
                        GameSetupStatus(
                          label: _error == 'audio'
                              ? l.guidedSetupAudioSaveError
                              : l.gameFolderAccessLost,
                          icon: Icons.error_outline_rounded,
                          ready: false,
                        ),
                      ],
                      if (_busy) ...[
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          color: retro.accent,
                          backgroundColor: retro.surfaceAlt,
                        ),
                      ],
                      const SizedBox(height: 28),
                      if (_step == 0) ...[
                        GameSetupAction(
                          label: l.guidedSetupStart,
                          icon: Icons.arrow_forward_rounded,
                          imageAsset: _startAsset,
                          showTrailing: false,
                          marioLabel: true,
                          primary: true,
                          onPressed: _busy
                              ? null
                              : () => setState(() => _step = 1),
                        ),
                        if (widget.allowDismiss) ...[
                          const SizedBox(height: 12),
                          GameSetupAction(
                            label: l.guidedSetupLater,
                            icon: Icons.schedule_rounded,
                            imageAsset: _laterAsset,
                            marioLabel: true,
                            onPressed: _busy ? null : _dismiss,
                          ),
                        ],
                      ] else if (_step == 1) ...[
                        GameSetupAction(
                          label: l.gameFolderChoose,
                          icon: Icons.folder_open_rounded,
                          imageAsset: _folderAsset,
                          showTrailing: false,
                          marioLabel: true,
                          primary: true,
                          onPressed: _busy ? null : _connectFolder,
                        ),
                        const SizedBox(height: 12),
                        GameSetupAction(
                          label: l.gameFolderLater,
                          icon: Icons.schedule_rounded,
                          imageAsset: _laterAsset,
                          marioLabel: true,
                          onPressed: _busy ? null : _skipFolder,
                        ),
                      ] else if (_step == 2) ...[
                        GameSetupAction(
                          label: l.autoInstallPromptEnable,
                          icon: Icons.auto_mode_rounded,
                          imageAsset: _startAsset,
                          showTrailing: false,
                          marioLabel: true,
                          primary: true,
                          onPressed: _busy ? null : () => _setAutoInstall(true),
                        ),
                        const SizedBox(height: 12),
                        GameSetupAction(
                          label: l.autoInstallPromptDownloadOnly,
                          icon: Icons.download_outlined,
                          imageAsset: _laterAsset,
                          marioLabel: true,
                          onPressed: _busy
                              ? null
                              : () => _setAutoInstall(false),
                        ),
                      ] else if (_step == 3) ...[
                        GameSetupAction(
                          label: l.guidedSetupAudioOn,
                          icon: Icons.volume_up_rounded,
                          imageAsset: _audioAsset,
                          showTrailing: false,
                          marioLabel: true,
                          primary: true,
                          onPressed: _busy
                              ? null
                              : () => _setAudioExperience(true),
                        ),
                        const SizedBox(height: 12),
                        GameSetupAction(
                          label: l.guidedSetupAudioOff,
                          icon: Icons.volume_off_rounded,
                          imageAsset: _laterAsset,
                          marioLabel: true,
                          onPressed: _busy
                              ? null
                              : () => _setAudioExperience(false),
                        ),
                      ] else
                        GameSetupAction(
                          label: l.guidedSetupFinish,
                          icon: Icons.check_rounded,
                          imageAsset: _readyAsset,
                          showTrailing: false,
                          marioLabel: true,
                          primary: true,
                          onPressed: _busy ? null : _finish,
                        ),
                    ],
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
