import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import 'manga_menu_audio_provider.dart';
import 'theme_provider.dart';

class HomeCardSoundSettings {
  const HomeCardSoundSettings({this.enabled = true, this.volume = 0.45});
  final bool enabled;
  final double volume;
}

final homeCardSoundsProvider =
    NotifierProvider<HomeCardSoundsNotifier, HomeCardSoundSettings>(
      HomeCardSoundsNotifier.new,
    );

/// Hive es autoridad; solo el engine principal reproduce este efecto breve.
class HomeCardSoundsNotifier extends Notifier<HomeCardSoundSettings> {
  static const enabledKey = 'audio_home_cards_enabled';
  static const volumeKey = 'audio_home_cards_volume';
  bool _saving = false;

  @override
  HomeCardSoundSettings build() {
    try {
      final box = Hive.box<String>(AppConstants.settingsBoxKey);
      final raw = double.tryParse(box.get(volumeKey) ?? '');
      return HomeCardSoundSettings(
        enabled: box.get(enabledKey) != 'false',
        volume: raw != null && raw.isFinite
            ? raw.clamp(0.0, 1.0).toDouble()
            : 0.45,
      );
    } catch (_) {
      return const HomeCardSoundSettings();
    }
  }

  Future<bool> setEnabled(bool value) => _save(enabled: value);
  Future<bool> setVolume(double value) => _save(volume: value);
  Future<bool> reset() => _save(enabled: true, volume: 0.45);

  Future<bool> _save({bool? enabled, double? volume}) async {
    if (_saving || (volume != null && !volume.isFinite)) return false;
    _saving = true;
    try {
      final next = HomeCardSoundSettings(
        enabled: enabled ?? state.enabled,
        volume: volume?.clamp(0.0, 1.0).toDouble() ?? state.volume,
      );
      await Hive.box<String>(
        AppConstants.settingsBoxKey,
      ).putAll({enabledKey: '${next.enabled}', volumeKey: '${next.volume}'});
      if (!ref.mounted) return true;
      state = next;
      if (!next.enabled || next.volume == 0) {
        await ref.read(mangaMenuAudioProvider).stopSound('home_slide');
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      _saving = false;
    }
  }

  Future<void> play() async {
    if (!state.enabled ||
        state.volume <= 0 ||
        !ref.read(themeDesignProvider).id.isManga) {
      return;
    }
    // El adaptador captura errores de plataforma: el gesto nunca espera al audio.
    await ref
        .read(mangaMenuAudioProvider)
        .play('home_slide', volume: state.volume);
  }
}
