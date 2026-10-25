import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/presentation/providers/manga_menu_audio_provider.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'package:sm64cdpy/presentation/providers/app_audio_settings_provider.dart';
import 'package:sm64cdpy/presentation/providers/home_card_audio_provider.dart';
import 'package:sm64cdpy/services/manga_menu_audio.dart';

class _Audio extends MangaMenuAudio {
  final played = <String>[];
  final volumes = <double>[];
  int stops = 0;
  final stoppedSounds = <String>[];

  @override
  Future<void> play(String sound, {double volume = 0.05}) async {
    played.add(sound);
    volumes.add(volume);
  }

  @override
  Future<void> stop() async { stops++; }
  @override
  Future<void> stopSound(String sound) async { stoppedSounds.add(sound); }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sounds persist, mute immediately after save and remain Manga-only', () async {
    final directory = await Directory.systemTemp.createTemp('manga-audio-');
    Hive.init(directory.path);
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
    final audio = _Audio();
    final container = ProviderContainer(overrides: [
      mangaMenuAudioProvider.overrideWithValue(audio),
    ]);
    try {
      final sounds = container.read(mangaMenuSoundsProvider.notifier);
      expect(container.read(mangaMenuSoundsProvider), isTrue);
      await sounds.play('press');
      expect(audio.played, ['press']);
      expect(await sounds.setEnabled(false), isTrue);
      expect(audio.stops, 1);
      await sounds.play('slide');
      expect(audio.played, ['press']);
      final restored = ProviderContainer();
      try {
        expect(restored.read(mangaMenuSoundsProvider), isFalse);
      } finally {
        restored.dispose();
      }
      await sounds.setEnabled(true);
      await container.read(appearanceProvider.notifier).setTheme(AppThemeId.marioKart64);
      await sounds.play('press');
      expect(audio.played, ['press']);
      await container.read(appearanceProvider.notifier).setTheme(AppThemeId.retroManga);
      await sounds.play('slide');
      expect(audio.played, ['press', 'slide']);
      await container.read(appearanceProvider.notifier).setTheme(AppThemeId.mangaDeluxe);
      await sounds.play('press');
      expect(audio.played, ['press', 'slide', 'press']);
    } finally {
      container.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('internal gain persists, preserves mute and applies to every effect', () async {
    final directory = await Directory.systemTemp.createTemp('app-audio-volume-');
    Hive.init(directory.path);
    final box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
    final audio = _Audio();
    final container = ProviderContainer(overrides: [
      mangaMenuAudioProvider.overrideWithValue(audio),
    ]);
    try {
      expect(container.read(appAudioSettingsProvider).effectsVolume, 0.05);
      expect(container.read(appAudioSettingsProvider).musicVolume, 0.05);
      final settings = container.read(appAudioSettingsProvider.notifier);
      final sounds = container.read(mangaMenuSoundsProvider.notifier);
      expect(await settings.setMusicVolume(0.12), isTrue);
      expect(await settings.setMusicEnabled(false), isTrue);
      expect(await settings.setEffectsVolume(0.25), isTrue);
      expect(container.read(appAudioSettingsProvider).musicVolume, 0.12);
      expect(container.read(appAudioSettingsProvider).musicEnabled, isFalse);
      await sounds.play('press');
      await sounds.play('slide');
      expect(audio.volumes, [0.25, 0.25]);
      final restored = ProviderContainer();
      try {
        expect(restored.read(appAudioSettingsProvider).effectsVolume, 0.25);
        expect(restored.read(appAudioSettingsProvider).musicVolume, 0.12);
        expect(restored.read(appAudioSettingsProvider).musicEnabled, isFalse);
      } finally {
        restored.dispose();
      }
      await settings.setEffectsVolume(0);
      await sounds.play('press');
      expect(audio.played.length, 2);
      await settings.setEffectsVolume(2);
      expect(container.read(appAudioSettingsProvider).effectsVolume, 1);
      expect(await settings.setEffectsVolume(double.nan), isFalse);
      expect(container.read(appAudioSettingsProvider).effectsVolume, 1);
      await sounds.setEnabled(false);
      await settings.setEffectsVolume(0.5);
      await sounds.play('press');
      expect(audio.played.length, 2);
      expect(box.get(MangaMenuSoundsNotifier.storageKey), 'false');
      await box.close();
      expect(await settings.setEffectsVolume(0.1), isFalse);
      expect(container.read(appAudioSettingsProvider).effectsVolume, 0.5);
    } finally {
      container.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('invalid persisted gain safely restores the previous default', () async {
    final directory = await Directory.systemTemp.createTemp('app-audio-invalid-');
    Hive.init(directory.path);
    final box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
    try {
      for (final raw in ['NaN', 'Infinity', 'invalid']) {
        await box.put(AppAudioSettingsNotifier.effectsVolumeKey, raw);
        await box.put(HomeCardSoundsNotifier.volumeKey, raw);
        final container = ProviderContainer();
        try {
          expect(container.read(appAudioSettingsProvider).effectsVolume, 0.05);
          expect(container.read(homeCardSoundsProvider).volume, 0.45);
        } finally {
          container.dispose();
        }
      }
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('Home card sound persists independently and stops selectively', () async {
    final directory = await Directory.systemTemp.createTemp('home-card-audio-');
    Hive.init(directory.path);
    final box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
    final audio = _Audio();
    final container = ProviderContainer(overrides: [
      mangaMenuAudioProvider.overrideWithValue(audio),
    ]);
    try {
      final cards = container.read(homeCardSoundsProvider.notifier);
      final mix = container.read(appAudioSettingsProvider.notifier);
      expect(container.read(homeCardSoundsProvider).volume, 0.45);
      await cards.play();
      expect(audio.played, ['home_slide']);
      expect(audio.volumes, [0.45]);
      await container.read(mangaMenuSoundsProvider.notifier).setEnabled(false);
      await mix.setEffectsVolume(0);
      await mix.setMusicVolume(0.12);
      expect(await cards.setVolume(0.25), isTrue);
      await cards.play();
      expect(audio.volumes.last, 0.25);
      expect(await cards.setEnabled(false), isTrue);
      expect(audio.stoppedSounds.last, 'home_slide');
      final count = audio.played.length;
      await cards.play();
      expect(audio.played.length, count);
      final restored = ProviderContainer();
      try {
        expect(restored.read(homeCardSoundsProvider).enabled, isFalse);
        expect(restored.read(homeCardSoundsProvider).volume, 0.25);
      } finally { restored.dispose(); }
      expect(await cards.reset(), isTrue);
      expect(container.read(homeCardSoundsProvider).enabled, isTrue);
      expect(container.read(homeCardSoundsProvider).volume, 0.45);
      expect(container.read(appAudioSettingsProvider).effectsVolume, 0);
      expect(container.read(appAudioSettingsProvider).musicVolume, 0.12);
      for (final theme in [AppThemeId.minimal, AppThemeId.marioKart64]) {
        await container.read(appearanceProvider.notifier).setTheme(theme);
        await cards.play();
      }
      expect(audio.played.length, count);
      await container.read(appearanceProvider.notifier).setTheme(AppThemeId.mangaDeluxe);
      await cards.play();
      expect(audio.played.length, count + 1);
      await cards.setVolume(0);
      await cards.play();
      expect(audio.played.length, count + 1);
      expect(await cards.setVolume(double.nan), isFalse);
      expect(await cards.setVolume(2), isTrue);
      expect(container.read(homeCardSoundsProvider).volume, 1);
      await box.close();
      expect(await cards.setEnabled(false), isFalse);
      expect(container.read(homeCardSoundsProvider).enabled, isTrue);
    } finally {
      container.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('effects are bundled and requests reach the native channel', () async {
    for (final file in ['menu-button-press.wav', 'slide.mp3', 'home-cards-slide.mp3']) {
      final data = await rootBundle.load('assets/audio/manga/$file');
      expect(data.lengthInBytes, greaterThan(0));
    }
    const channel = MethodChannel('sm64cdpy/manga_menu_audio');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final audio = MangaMenuAudio();
    await audio.prepare();
    await audio.play('press');
    await audio.play('slide');
    await audio.play('press', volume: 0.2);
    await audio.stop();
    await audio.play('home_slide', volume: 0.45);
    await audio.stopSound('home_slide');
    expect(calls.map((call) => call.method), ['prepare', 'play', 'play', 'play', 'stop', 'play', 'stopSound']);
    expect(calls[1].arguments, {'sound': 'press', 'volume': 0.05});
    expect(calls[2].arguments, {'sound': 'slide', 'volume': 0.05});
    expect(calls[3].arguments, {'sound': 'press', 'volume': 0.2});
    expect(calls[5].arguments, {'sound': 'home_slide', 'volume': 0.45});
    expect(calls[6].arguments, {'sound': 'home_slide'});
  });

  test('optional native audio failures do not escape to navigation', () async {
    const channel = MethodChannel('sm64cdpy/manga_menu_audio');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'audio-unavailable');
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final audio = MangaMenuAudio();
    await expectLater(audio.prepare(), completes);
    await expectLater(audio.play('press'), completes);
    await expectLater(audio.stop(), completes);
    await expectLater(audio.stopSound('home_slide'), completes);
  });
}
