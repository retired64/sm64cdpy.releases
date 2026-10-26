import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_audio_settings_provider.dart';
import 'home_card_audio_provider.dart';
import 'manga_menu_audio_provider.dart';

final audioExperienceProvider = Provider<AudioExperienceController>(
  AudioExperienceController.new,
);

/// Applies the onboarding's single audio choice through every canonical writer.
/// Individual volume preferences remain untouched for later fine tuning.
class AudioExperienceController {
  AudioExperienceController(this._ref);

  final Ref _ref;

  Future<bool> setEnabled(bool enabled) async {
    final previousMusic = _ref.read(appAudioSettingsProvider).musicEnabled;
    final previousMenu = _ref.read(mangaMenuSoundsProvider);
    final previousCards = _ref.read(homeCardSoundsProvider).enabled;
    final music = _ref.read(appAudioSettingsProvider.notifier);
    final menu = _ref.read(mangaMenuSoundsProvider.notifier);
    final cards = _ref.read(homeCardSoundsProvider.notifier);

    final musicSaved = await music.setMusicEnabled(enabled);
    final menuSaved = await menu.setEnabled(enabled);
    final cardsSaved = await cards.setEnabled(enabled);
    if (musicSaved && menuSaved && cardsSaved) return true;

    await music.setMusicEnabled(previousMusic);
    await menu.setEnabled(previousMenu);
    await cards.setEnabled(previousCards);
    return false;
  }
}
