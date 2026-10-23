import 'manga_submenu_header.dart';
import 'deluxe_preferences.dart';
import 'manga_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_audio_settings_provider.dart';
import '../providers/manga_menu_audio_provider.dart';
import '../providers/theme_provider.dart';
import 'app_snackbar.dart';

/// Submenú local: cerrar no navega ni descarta cambios del editor de Jugador.
Future<void> showMangaAudioMenu(BuildContext context) async {
  final retro = RetroTheme.of(context);
  final l = AppLocalizations.of(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: retro.isDeluxe ? retro.background.withValues(alpha: 0.96) : retro.background,
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
    shape: RoundedRectangleBorder(
      borderRadius: retro.radius,
      side: BorderSide(color: retro.border, width: retro.borderWidth(2)),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: Column(
        key: const ValueKey('manga-audio-menu'),
        mainAxisSize: MainAxisSize.min,
        children: [
          MangaSubmenuHeader(
            title: l.mangaNavAudio,
            asset: 'assets/themes/manga/navigation/audio.webp',
            fallbackIcon: Icons.volume_up_outlined,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [MangaMenuSoundSetting(), DeluxeResetButton()],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class MangaMenuSoundSetting extends ConsumerStatefulWidget {
  const MangaMenuSoundSetting({super.key});

  @override
  ConsumerState<MangaMenuSoundSetting> createState() => _MangaMenuSoundSettingState();
}

class _MangaMenuSoundSettingState extends ConsumerState<MangaMenuSoundSetting> {
  double? _draft;
  double? _musicDraft;
  bool _saving = false;

  Future<void> _saveVolume(double value) async {
    setState(() => _saving = true);
    final saved = await ref.read(appAudioSettingsProvider.notifier).setEffectsVolume(value);
    if (!mounted) return;
    setState(() {
      _draft = null;
      _saving = false;
    });
    if (!saved) {
      AppSnackbar.error(context, message: AppLocalizations.of(context).themeSaveFailed);
      return;
    }
    // Una muestra al soltar; ninguna escritura ni reproducción por cada frame.
    await ref.read(mangaMenuAudioProvider).stop();
    if (!mounted) return;
    await ref.read(mangaMenuSoundsProvider.notifier).play('press');
  }

  Future<void> _saveMusic({double? volume, bool? enabled}) async {
    setState(() => _saving = true);
    final notifier = ref.read(appAudioSettingsProvider.notifier);
    final saved = volume != null
        ? await notifier.setMusicVolume(volume)
        : await notifier.setMusicEnabled(enabled!);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _musicDraft = null;
    });
    if (!saved) {
      AppSnackbar.error(context, message: AppLocalizations.of(context).themeSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(themeDesignProvider).id.isManga) {
      return const SizedBox.shrink();
    }
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    final enabled = ref.watch(mangaMenuSoundsProvider);
    final mix = ref.watch(appAudioSettingsProvider);
    final confirmedVolume = mix.effectsVolume;
    final musicVolume = _musicDraft ?? mix.musicVolume;
    final musicPercent = '${(musicVolume * 100).round()}%';
    final volume = _draft ?? confirmedVolume;
    final percent = '${(volume * 100).round()}%';
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: retro.surfaceDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ThemedSwitchListTile(
              key: const ValueKey('ambient-music-enabled'),
              title: Text(l.ambientMusicTitle, style: retro.heading(size: 14)),
              subtitle: Text(retro.isDeluxe ? l.deluxeMusicDescription : l.ambientMusicDescription, style: retro.body(size: 12)),
              secondary: Icon(Icons.music_note_outlined, color: retro.accentText),
              value: mix.musicEnabled,
              onChanged: _saving ? null : (value) => _saveMusic(enabled: value),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${l.ambientMusicVolume}: $musicPercent', style: retro.body(size: 14)),
                  Slider(
                    key: const ValueKey('ambient-music-volume'),
                    value: musicVolume,
                    divisions: 100,
                    label: musicPercent,
                    semanticFormatterCallback: (value) => '${(value * 100).round()}%',
                    onChanged: mix.musicEnabled && !_saving
                        ? (value) => setState(() => _musicDraft = value)
                        : null,
                    onChangeEnd: mix.musicEnabled && !_saving
                        ? (value) => _saveMusic(volume: value)
                        : null,
                  ),
                ],
              ),
            ),
            ThemedSwitchListTile(
              key: const ValueKey('manga-menu-sounds'),
              title: Text(l.mangaMenuSoundsTitle, style: retro.heading(size: 14)),
              subtitle: Text(l.mangaMenuSoundsDescription, style: retro.body(size: 12)),
              secondary: Icon(Icons.volume_up_outlined, color: retro.accentText),
              value: enabled,
              onChanged: _saving ? null : (value) async {
                final saved = await ref.read(mangaMenuSoundsProvider.notifier).setEnabled(value);
                if (!context.mounted || saved) return;
                AppSnackbar.error(context, message: l.themeSaveFailed);
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('${l.appEffectsVolume}: $percent', style: retro.body(size: 14)),
                  Slider(
                    key: const ValueKey('app-effects-volume'),
                    value: volume,
                    divisions: 100,
                    label: percent,
                    semanticFormatterCallback: (value) => '${(value * 100).round()}%',
                    onChanged: enabled && !_saving
                        ? (value) => setState(() => _draft = value)
                        : null,
                    onChangeEnd: enabled && !_saving ? _saveVolume : null,
                  ),
                  Text(l.appEffectsVolumeDescription, style: retro.body(size: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
