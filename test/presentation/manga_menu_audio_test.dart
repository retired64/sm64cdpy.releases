import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/presentation/providers/manga_menu_audio_provider.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'package:sm64cdpy/services/manga_menu_audio.dart';

class _Audio extends MangaMenuAudio {
  final played = <String>[];
  int stops = 0;

  @override
  Future<void> play(String sound) async => played.add(sound);

  @override
  Future<void> stop() async { stops++; }
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
    } finally {
      container.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('effects are bundled and requests reach the native channel', () async {
    for (final file in ['menu-button-press.wav', 'slide.mp3']) {
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
    await audio.stop();
    expect(calls.map((call) => call.method), ['prepare', 'play', 'play', 'stop']);
    expect(calls[1].arguments, {'sound': 'press'});
    expect(calls[2].arguments, {'sound': 'slide'});
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
  });
}
