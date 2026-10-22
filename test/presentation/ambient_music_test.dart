import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/presentation/providers/app_audio_settings_provider.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'package:sm64cdpy/presentation/widgets/ambient_music_coordinator.dart';
import 'package:sm64cdpy/services/ambient_music.dart';

class _Music extends AmbientMusic {
  final calls = <({bool enabled, double volume})>[];
  @override
  Future<void> configure({required bool enabled, required double volume}) async {
    calls.add((enabled: enabled, volume: volume));
  }
}

class _Mix extends AppAudioSettingsNotifier {
  @override
  AppAudioSettings build() => const AppAudioSettings();
  @override
  Future<bool> setMusicVolume(double value) async {
    state = AppAudioSettings(musicVolume: value, musicEnabled: state.musicEnabled);
    return true;
  }
  @override
  Future<bool> setMusicEnabled(bool value) async {
    state = AppAudioSettings(musicVolume: state.musicVolume, musicEnabled: value);
    return true;
  }
}

class _Appearance extends AppearanceNotifier {
  @override
  AppearanceSettings build() => const AppearanceSettings();
  @override
  Future<bool> setTheme(AppThemeId id) async {
    state = AppearanceSettings(themeId: id);
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('music follows confirmed mix and Manga theme, stops on teardown', (tester) async {
    final music = _Music();
    final container = ProviderContainer(overrides: [
      ambientMusicProvider.overrideWithValue(music),
      appAudioSettingsProvider.overrideWith(_Mix.new),
      appearanceProvider.overrideWith(_Appearance.new),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AmbientMusicCoordinator(child: Text('App'))),
    ));
    await tester.pump();
    expect(music.calls.last, (enabled: true, volume: 0.18));
    await container.read(appAudioSettingsProvider.notifier).setMusicVolume(0.1);
    await tester.pump();
    expect(music.calls.last, (enabled: true, volume: 0.1));
    await container.read(appAudioSettingsProvider.notifier).setMusicEnabled(false);
    await tester.pump();
    expect(music.calls.last.enabled, isFalse);
    await container.read(appAudioSettingsProvider.notifier).setMusicEnabled(true);
    await container.read(appearanceProvider.notifier).setTheme(AppThemeId.mangaDeluxe);
    await tester.pump();
    expect(music.calls.last, (enabled: true, volume: 0.1));
    await container.read(appearanceProvider.notifier).setTheme(AppThemeId.minimal);
    await tester.pump();
    expect(music.calls.last.enabled, isFalse);
    await container.read(appearanceProvider.notifier).setTheme(AppThemeId.retroManga);
    await tester.pump();
    expect(music.calls.last, (enabled: true, volume: 0.1));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(music.calls.last, (enabled: false, volume: 0.0));
  });

  test('ambient asset and native configuration contract', () async {
    final asset = await rootBundle.load('assets/audio/manga/ambiente2.opus');
    expect(String.fromCharCodes(asset.buffer.asUint8List(asset.offsetInBytes, 4)), 'OggS');
    const channel = MethodChannel('sm64cdpy/ambient_music');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async { calls.add(call); return null; });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final music = AmbientMusic();
    await music.configure(enabled: true, volume: 0.18);
    await music.configure(enabled: false, volume: 2);
    expect(calls.first.method, 'configure');
    expect(calls.first.arguments, {'enabled': true, 'volume': 0.18});
    expect(calls.last.arguments, {'enabled': false, 'volume': 1.0});
    messenger.setMockMethodCallHandler(channel, (_) async { throw PlatformException(code: 'unavailable'); });
    await expectLater(music.configure(enabled: true, volume: 0.18), completes);
  });
}
