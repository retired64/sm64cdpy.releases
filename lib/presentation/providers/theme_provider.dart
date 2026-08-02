import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Provider for managing theme mode (light/dark/system) with persistence
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box<String>(AppConstants.settingsBoxKey);
    final savedTheme = box.get('theme_mode', defaultValue: 'system');

    return switch (savedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  /// Change theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    try {
      await Hive.box<String>(AppConstants.settingsBoxKey)
          .put('theme_mode', _themeModeToString(mode));
    } catch (e) {
      // Silently fail if storage is unavailable
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Toggle between light and dark (skip system)
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Check if dark theme should be used based on current mode and system preference
  bool get isDarkMode {
    switch (state) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  /// Get the current theme mode as a display string
  String get displayName {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Convert ThemeMode to string for storage
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Provider that exposes the current theme mode
final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  () => ThemeNotifier(),
);

/// Provider that provides whether dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeModeProvider.notifier).isDarkMode;
});

/// Provider for managing app locale (system/forced) with persistence.
///
/// State is a language tag string or null. When null, the app follows
/// the device's system locale. When non-null, the locale is forced
/// to the specified language tag (e.g. 'es_419', 'pt_BR', 'en_US').
class LocaleNotifier extends Notifier<String?> {
  @override
  String? build() {
    final box = Hive.box<String>(AppConstants.settingsBoxKey);
    final saved = box.get('locale', defaultValue: 'system');

    if (saved == 'system') return null;
    if (['en_US', 'es_419', 'pt_BR'].contains(saved)) return saved;
    return null;
  }

  Future<void> setLocale(String? tag) async {
    state = tag;

    try {
      await Hive.box<String>(AppConstants.settingsBoxKey)
          .put('locale', tag ?? 'system');
    } catch (e) {
      debugPrint('Failed to save locale preference: $e');
    }

    // Réplica en SharedPreferences para que el overlay engine
    // (segundo isolate) pueda leer la preferencia sin inicializar Hive.
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.appLocaleKey, tag ?? 'system');
    } catch (e) {
      debugPrint('Failed to mirror locale to SharedPreferences: $e');
    }
  }

  Locale? get locale => state != null ? localeFromTag(state!) : null;

  static Locale? localeFromTag(String tag) {
    final parts = tag.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(tag);
  }
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, String?>(() => LocaleNotifier());
