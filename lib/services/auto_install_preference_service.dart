import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

enum AutoInstallDecision { undecided, enabled, disabled }

/// Owns the durable auto-install decision.
///
/// Hive records the main app's explicit decision. SharedPreferences is the
/// interoperability mirror consumed by the overlay, native workers and legacy
/// download paths. Existing boolean choices are migrated without prompting.
class AutoInstallPreferenceService {
  AutoInstallPreferenceService._();

  static const String hiveKey = 'auto_install_decision';
  static AutoInstallDecision _decision = AutoInstallDecision.undecided;

  static AutoInstallDecision get decision => _decision;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = _readHiveDecision();

      if (stored != null) {
        _decision = stored;
        await prefs.setBool(
          AppConstants.autoInstallModsKey,
          stored == AutoInstallDecision.enabled,
        );
        return;
      }

      if (prefs.containsKey(AppConstants.autoInstallModsKey)) {
        _decision = prefs.getBool(AppConstants.autoInstallModsKey) == true
            ? AutoInstallDecision.enabled
            : AutoInstallDecision.disabled;
        await _writeHiveDecision(_decision);
        return;
      }

      _decision = AutoInstallDecision.undecided;
    } catch (error, stack) {
      _decision = AutoInstallDecision.undecided;
      debugPrint(
        'Failed to initialize auto-install preference: $error\n$stack',
      );
    }
  }

  static Future<void> setEnabled(bool enabled) async {
    final previous = _decision;
    final next = enabled
        ? AutoInstallDecision.enabled
        : AutoInstallDecision.disabled;
    await _writeHiveDecision(next);
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setBool(
        AppConstants.autoInstallModsKey,
        enabled,
      );
      if (!saved) throw StateError('SharedPreferences rejected auto-install');
      _decision = next;
    } catch (_) {
      await _writeHiveDecision(previous);
      rethrow;
    }
  }

  static AutoInstallDecision? _readHiveDecision() {
    try {
      if (!Hive.isBoxOpen(AppConstants.settingsBoxKey)) return null;
      return switch (Hive.box<String>(
        AppConstants.settingsBoxKey,
      ).get(hiveKey)) {
        'enabled' => AutoInstallDecision.enabled,
        'disabled' => AutoInstallDecision.disabled,
        _ => null,
      };
    } catch (error) {
      debugPrint('Failed to read auto-install decision from Hive: $error');
      return null;
    }
  }

  static Future<void> _writeHiveDecision(AutoInstallDecision decision) async {
    try {
      if (!Hive.isBoxOpen(AppConstants.settingsBoxKey)) return;
      final box = Hive.box<String>(AppConstants.settingsBoxKey);
      if (decision == AutoInstallDecision.undecided) {
        await box.delete(hiveKey);
      } else {
        await box.put(hiveKey, decision.name);
      }
    } catch (error) {
      debugPrint('Failed to write auto-install decision to Hive: $error');
    }
  }
}
