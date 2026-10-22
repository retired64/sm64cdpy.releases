import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_design.dart';
import '../../services/manga_menu_audio.dart';
import 'theme_provider.dart';
import 'app_audio_settings_provider.dart';

final mangaMenuAudioProvider = Provider<MangaMenuAudio>((ref) => MangaMenuAudio());

final mangaMenuSoundsProvider = NotifierProvider<MangaMenuSoundsNotifier, bool>(
  MangaMenuSoundsNotifier.new,
);

/// Hive es la fuente persistente; solo el engine principal usa estos efectos.
class MangaMenuSoundsNotifier extends Notifier<bool> {
  static const storageKey = 'manga_menu_sounds';
  bool _saving = false;

  @override
  bool build() {
    try {
      return Hive.box<String>(AppConstants.settingsBoxKey).get(storageKey) != 'false';
    } catch (_) {
      return true;
    }
  }

  Future<bool> setEnabled(bool enabled) async {
    if (_saving) return false;
    _saving = true;
    try {
      await Hive.box<String>(AppConstants.settingsBoxKey).put(storageKey, '$enabled');
      if (!ref.mounted) return true;
      state = enabled;
      if (!enabled) await ref.read(mangaMenuAudioProvider).stop();
      return true;
    } catch (_) {
      return false;
    } finally {
      _saving = false;
    }
  }

  Future<void> play(String sound) async {
    if (!state || ref.read(themeDesignProvider).id != AppThemeId.retroManga) return;
    final volume = ref.read(appAudioSettingsProvider).effectsVolume;
    if (volume <= 0) return;
    await ref.read(mangaMenuAudioProvider).play(sound, volume: volume);
  }
}
