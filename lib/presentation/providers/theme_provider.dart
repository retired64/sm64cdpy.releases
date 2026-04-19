import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Provider for managing theme mode (light/dark/system) with persistence
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    Future.microtask(() => _loadSavedTheme());
    return ThemeMode.system;
  }

  late final Box<String> _box;

  /// Load saved theme from Hive storage
  Future<void> _loadSavedTheme() async {
    try {
      _box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
      final savedTheme = _box.get('theme_mode', defaultValue: 'system');

      switch (savedTheme) {
        case 'light':
          state = ThemeMode.light;
        case 'dark':
          state = ThemeMode.dark;
        case 'system':
        default:
          state = ThemeMode.system;
      }
    } catch (e) {
      // If Hive fails, use system theme as default
      state = ThemeMode.system;
    }
  }

  /// Change theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    try {
      await _box.put('theme_mode', _themeModeToString(mode));
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

/// Convenience provider for getting the current ThemeData based on theme mode
final themeDataProvider = Provider<ThemeData>((ref) {
  final isDark = ref.watch(isDarkModeProvider);
  return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
});
