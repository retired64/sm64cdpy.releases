import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GameLauncherService {
  GameLauncherService._();

  static const _packageName = 'com.maniscat2.sm64coopdx';
  static const _channel = MethodChannel('sm64cdpy/launcher');

  static Future<bool> isInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('isInstalled') ?? false;
    } catch (e) {
      debugPrint('[GameLauncher] isInstalled error: $e');
      return false;
    }
  }

  static Future<bool> launch() async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('launch') ?? false;
    } catch (e) {
      debugPrint('[GameLauncher] launch error: $e');
      return false;
    }
  }
}
