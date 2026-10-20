import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/services/game_launcher_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('sm64cdpy/launcher');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('Android launches and queries the native channel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return true;
    });
    expect(await GameLauncherService.launch(), isTrue);
    expect(await GameLauncherService.isInstalled(), isTrue);
    expect(calls, ['launch', 'isInstalled']);
  });

  test('Android preserves an explicit missing game result', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    messenger.setMockMethodCallHandler(channel, (_) async => false);
    expect(await GameLauncherService.launch(), isFalse);
    expect(await GameLauncherService.isInstalled(), isFalse);
  });

  test('non-Android platforms never invoke the channel', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return true;
    });
    for (final platform in TargetPlatform.values.where((value) => value != TargetPlatform.android)) {
      debugDefaultTargetPlatformOverride = platform;
      expect(await GameLauncherService.launch(), isFalse);
      expect(await GameLauncherService.isInstalled(), isFalse);
    }
    expect(calls, 0);
  });

  test('native errors and null replies stay recoverable', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    messenger.setMockMethodCallHandler(channel, (_) async => throw PlatformException(code: 'unavailable'));
    expect(await GameLauncherService.launch(), isFalse);
    messenger.setMockMethodCallHandler(channel, (_) async => null);
    expect(await GameLauncherService.isInstalled(), isFalse);
  });
}
