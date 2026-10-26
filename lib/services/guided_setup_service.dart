import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';

enum GuidedSetupStatus { pending, completed, dismissed }

/// Durable record of the educational flow only.
///
/// Android and SAF remain authoritative for every capability. This service
/// never persists whether a permission is currently granted.
class GuidedSetupService {
  GuidedSetupService._();

  static const int currentVersion = 1;
  static const String _key = 'guided_setup_v$currentVersion';
  static GuidedSetupStatus _status = GuidedSetupStatus.pending;

  static GuidedSetupStatus get status => _status;
  static bool get needsPrompt => _status == GuidedSetupStatus.pending;

  static Future<void> init() async {
    if (!Hive.isBoxOpen(AppConstants.settingsBoxKey)) return;
    final value = Hive.box<String>(AppConstants.settingsBoxKey).get(_key);
    _status = switch (value) {
      'completed' => GuidedSetupStatus.completed,
      'dismissed' => GuidedSetupStatus.dismissed,
      _ => GuidedSetupStatus.pending,
    };
  }

  static Future<void> complete() => _write(GuidedSetupStatus.completed);
  static Future<void> dismiss() => _write(GuidedSetupStatus.dismissed);
  static Future<void> reset() => _write(GuidedSetupStatus.pending);

  static Future<void> _write(GuidedSetupStatus value) async {
    _status = value;
    if (!Hive.isBoxOpen(AppConstants.settingsBoxKey)) return;
    await Hive.box<String>(AppConstants.settingsBoxKey).put(_key, value.name);
  }
}
