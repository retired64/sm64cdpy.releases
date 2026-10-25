import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GameLauncherService {
  GameLauncherService._();

  static const _channel = MethodChannel('sm64cdpy/launcher');
  // Permite simular Android en pruebas Flutter sin invocar canales en web u
  // otras plataformas. En el dispositivo conserva la restricción a Android.
  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<bool> isInstalled() async {
    if (!_isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isInstalled') ?? false;
    } catch (e) {
      debugPrint('[GameLauncher] isInstalled error: $e');
      return false;
    }
  }

  static Future<bool> launch() async {
    if (!_isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('launch') ?? false;
    } catch (e) {
      debugPrint('[GameLauncher] launch error: $e');
      return false;
    }
  }
}
