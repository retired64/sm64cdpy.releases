import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/home_card_audio_provider.dart';
import 'app_snackbar.dart';
import 'manga_switch.dart';

class HomeCardSoundSetting extends ConsumerStatefulWidget {
  const HomeCardSoundSetting({super.key});
  @override
  ConsumerState<HomeCardSoundSetting> createState() => _HomeCardSoundSettingState();
}

class _HomeCardSoundSettingState extends ConsumerState<HomeCardSoundSetting> {
  double? _draft;
  bool _saving = false;

  Future<void> _save({bool? enabled, double? volume}) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final notifier = ref.read(homeCardSoundsProvider.notifier);
      final saved = enabled != null
          ? await notifier.setEnabled(enabled) : await notifier.setVolume(volume!);
      if (!mounted) return;
      if (!saved) {
        AppSnackbar.error(context, message: AppLocalizations.of(context).themeSaveFailed);
      } else if (volume != null) {
        // Solo una muestra al soltar; no se escribe ni reproduce por fotograma.
        await notifier.play();
      }
    } finally {
      if (mounted) setState(() { _saving = false; _draft = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isManga) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final settings = ref.watch(homeCardSoundsProvider);
    final volume = _draft ?? settings.volume;
    final percent = '${(volume * 100).round()}%';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ThemedSwitchListTile(
        key: const ValueKey('home-card-sounds-enabled'),
        title: Text(l.homeCardSoundsTitle, style: retro.heading(size: 14)),
        subtitle: Text(l.homeCardSoundsDescription, style: retro.body(size: 12)),
        secondary: Icon(Icons.view_carousel_outlined, color: retro.accentText),
        value: settings.enabled,
        onChanged: _saving ? null : (value) => _save(enabled: value),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('${l.homeCardSoundsVolume}: $percent', style: retro.body(size: 14)),
          Slider(
            key: const ValueKey('home-card-sounds-volume'),
            value: volume,
            divisions: 100,
            label: percent,
            semanticFormatterCallback: (value) => '${(value * 100).round()}%',
            onChanged: settings.enabled && !_saving
                ? (value) => setState(() => _draft = value) : null,
            onChangeEnd: settings.enabled && !_saving
                ? (value) => _save(volume: value) : null,
          ),
        ]),
      ),
    ]);
  }
}
