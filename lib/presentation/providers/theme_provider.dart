import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme_catalog.dart';
import '../../core/theme/app_theme_design.dart';

const _themeIdKey = 'theme_id';
const _themeModeKey = 'theme_mode';

String? _readSetting(String key) {
  try {
    if (!Hive.isBoxOpen(AppConstants.settingsBoxKey)) return null;
    return Hive.box<String>(AppConstants.settingsBoxKey).get(key);
  } catch (error) {
    debugPrint('Failed to read appearance setting: $error');
    return null;
  }
}

@immutable
class AppearanceSettings {
  const AppearanceSettings({
    this.themeId = AppThemeId.retroManga,
    this.mode = ThemeMode.system,
    this.isSaving = false,
  });

  final AppThemeId themeId;
  final ThemeMode mode;
  final bool isSaving;
}

/// One writer for both appearance keys. A selection is only published after
/// persistence succeeds; concurrent taps are rejected until saving finishes.
class AppearanceNotifier extends Notifier<AppearanceSettings> {
  @override
  AppearanceSettings build() => AppearanceSettings(
    themeId: AppThemeId.fromStorage(_readSetting(_themeIdKey)),
    mode: switch (_readSetting(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    },
  );

  Future<bool> setTheme(AppThemeId id) => _save(themeId: id);
  Future<bool> setThemeMode(ThemeMode mode) => _save(mode: mode);

  Future<bool> _save({AppThemeId? themeId, ThemeMode? mode}) async {
    if (state.isSaving) return false;
    final previous = state;
    final nextId = themeId ?? previous.themeId;
    final nextMode = mode ?? previous.mode;
    final storedMode = switch (nextMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    if (nextId == previous.themeId &&
        nextMode == previous.mode &&
        _readSetting(_themeIdKey) == nextId.storageKey &&
        _readSetting(_themeModeKey) == storedMode) {
      return true;
    }
    state = AppearanceSettings(
      themeId: previous.themeId,
      mode: previous.mode,
      isSaving: true,
    );
    try {
      await Hive.box<String>(
        AppConstants.settingsBoxKey,
      ).putAll({_themeIdKey: nextId.storageKey, _themeModeKey: storedMode});
      if (ref.mounted) {
        state = AppearanceSettings(themeId: nextId, mode: nextMode);
      }
      return true;
    } catch (error, stack) {
      debugPrint('Failed to save appearance: $error\n$stack');
      if (ref.mounted) state = previous;
      return false;
    }
  }
}

final appearanceProvider =
    NotifierProvider<AppearanceNotifier, AppearanceSettings>(
      AppearanceNotifier.new,
    );

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(appearanceProvider.select((settings) => settings.mode)),
);

final themeDesignProvider = Provider<AppThemeDesign>(
  (ref) => AppThemeCatalog.resolve(
    ref.watch(appearanceProvider.select((settings) => settings.themeId)),
  ),
);

/// Provider for managing app locale (system/forced) with persistence.
///
/// State is a language tag string or null. When null, the app follows
/// the device's system locale. When non-null, the locale is forced
/// to the specified language tag (e.g. 'es_419', 'pt_BR', 'en_US').
class LocaleNotifier extends Notifier<String?> {
  @override
  String? build() {
    final saved = _readSetting('locale') ?? 'system';

    if (saved == 'system') return null;
    if (['en_US', 'es_419', 'pt_BR'].contains(saved)) return saved;
    return null;
  }

  Future<void> setLocale(String? tag) async {
    state = tag;

    try {
      await Hive.box<String>(
        AppConstants.settingsBoxKey,
      ).put('locale', tag ?? 'system');
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

final localeNotifierProvider = NotifierProvider<LocaleNotifier, String?>(
  () => LocaleNotifier(),
);
