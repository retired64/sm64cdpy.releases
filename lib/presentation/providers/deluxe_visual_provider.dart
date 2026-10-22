import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';

final deluxeMotionProvider = NotifierProvider<DeluxeMotionNotifier, bool>(DeluxeMotionNotifier.new);

/// Fondo estático por defecto; esta preferencia nunca altera otros temas.
class DeluxeMotionNotifier extends Notifier<bool> {
  static const storageKey = 'manga_deluxe_motion';
  bool _saving = false;
  @override
  bool build() {
    try {
      return Hive.box<String>(AppConstants.settingsBoxKey).get(storageKey) == 'true';
    } catch (_) { return false; }
  }

  Future<bool> select(bool value) async {
    if (_saving) return false;
    _saving = true;
    try {
      await Hive.box<String>(AppConstants.settingsBoxKey).put(storageKey, '$value');
      if (ref.mounted) state = value;
      return true;
    } catch (_) { return false; }
    finally { _saving = false; }
  }
}
