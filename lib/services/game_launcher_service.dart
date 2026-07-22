import 'dart:io' show Platform;

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';

class GameLauncherService {
  GameLauncherService._();

  static const _packageName = 'com.maniscat2.sm64coopdx';

  static Future<bool> isInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: _packageName,
      );
      return await intent.canResolveActivity() ?? false;
    } catch (e) {
      debugPrint('[GameLauncher] isInstalled error: $e');
      return false;
    }
  }

  static Future<bool> launch() async {
    if (!Platform.isAndroid) return false;
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: _packageName,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } catch (e) {
      debugPrint('[GameLauncher] launch error: $e');
      return false;
    }
  }
}
