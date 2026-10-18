import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/retro_accent.dart';

final retroAccentProvider = NotifierProvider<RetroAccentNotifier, RetroAccent>(
  RetroAccentNotifier.new,
);

/// Main-engine preference only. The overlay retains its fixed visual design.
class RetroAccentNotifier extends Notifier<RetroAccent> {
  static const storageKey = 'retro_manga_accent';
  bool _saving = false;

  @override
  RetroAccent build() {
    if (!Hive.isBoxOpen(AppConstants.settingsBoxKey)) return RetroAccent.cyan;
    return RetroAccent.fromStorage(
      Hive.box<String>(AppConstants.settingsBoxKey).get(storageKey),
    );
  }

  Future<bool> select(RetroAccent accent) async {
    if (_saving) return false;
    _saving = true;
    try {
      await Hive.box<String>(AppConstants.settingsBoxKey).put(storageKey, accent.name);
      if (ref.mounted) state = accent;
      return true;
    } catch (_) {
      return false;
    } finally {
      _saving = false;
    }
  }
}
