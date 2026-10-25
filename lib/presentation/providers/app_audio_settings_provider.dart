import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

/// Mezcla interna independiente: efectos y música conservan sus propios niveles.
class AppAudioSettings {
  const AppAudioSettings({
    this.effectsVolume = 0.05,
    this.musicVolume = 0.05,
    this.musicEnabled = true,
  });
  final double effectsVolume;
  final double musicVolume;
  final bool musicEnabled;
}

final appAudioSettingsProvider =
    NotifierProvider<AppAudioSettingsNotifier, AppAudioSettings>(
      AppAudioSettingsNotifier.new,
    );

class AppAudioSettingsNotifier extends Notifier<AppAudioSettings> {
  static const effectsVolumeKey = 'audio_effects_volume';
  static const musicVolumeKey = 'audio_music_volume';
  static const musicEnabledKey = 'audio_music_enabled';
  bool _saving = false;

  @override
  AppAudioSettings build() {
    try {
      final box = Hive.box<String>(AppConstants.settingsBoxKey);
      double gain(String key, double fallback) {
        final value = double.tryParse(box.get(key) ?? '');
        return value != null && value.isFinite
            ? value.clamp(0.0, 1.0).toDouble()
            : fallback;
      }

      return AppAudioSettings(
        effectsVolume: gain(effectsVolumeKey, 0.05),
        musicVolume: gain(musicVolumeKey, 0.05),
        musicEnabled: box.get(musicEnabledKey) != 'false',
      );
    } catch (_) {
      return const AppAudioSettings();
    }
  }

  Future<bool> setEffectsVolume(double value) => _save(effects: value);
  Future<bool> setMusicVolume(double value) => _save(music: value);
  Future<bool> setMusicEnabled(bool value) => _save(enabled: value);

  Future<bool> _save({double? effects, double? music, bool? enabled}) async {
    if (_saving ||
        (effects != null && !effects.isFinite) ||
        (music != null && !music.isFinite)) {
      return false;
    }
    _saving = true;
    final next = AppAudioSettings(
      effectsVolume: effects?.clamp(0.0, 1.0).toDouble() ?? state.effectsVolume,
      musicVolume: music?.clamp(0.0, 1.0).toDouble() ?? state.musicVolume,
      musicEnabled: enabled ?? state.musicEnabled,
    );
    try {
      await Hive.box<String>(AppConstants.settingsBoxKey).putAll({
        effectsVolumeKey: '${next.effectsVolume}',
        musicVolumeKey: '${next.musicVolume}',
        musicEnabledKey: '${next.musicEnabled}',
      });
      if (ref.mounted) state = next;
      return true;
    } catch (_) {
      return false;
    } finally {
      _saving = false;
    }
  }
}
