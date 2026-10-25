import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  Future<bool> setTheme(AppThemeId id) =>
      _save(themeId: AppThemeId.fromStorage(id.storageKey));
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
  static const supportedTags = ['en_US', 'es_419', 'pt_BR', 'fr', 'it'];
  static const _native = MethodChannel('sm64cdpy/launcher');
  bool _saving = false;

  static String? _savedTag() {
    final saved = _readSetting('locale');
    return supportedTags.contains(saved) ? saved : null;
  }

  /// Hive owns the preference; refresh Android's durable projection at startup.
  /// This does not initialize or send data to the floating engine.
  static Future<void> synchronizeNativeLocale() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(
      AppConstants.appLocaleKey,
      _savedTag() ?? 'system',
    )) {
      throw StateError('Could not mirror app language');
    }
    await _refreshNative();
  }

  static Future<void> _refreshNative() async {
    try {
      await _native.invokeMethod<void>('refreshNotificationLanguage');
    } on MissingPluginException {
      // Widget tests have no Android activity.
    } on PlatformException catch (error) {
      // The saved preference is still read by every future notification.
      debugPrint('Could not refresh notification channel names: $error');
    }
  }

  @override
  String? build() {
    return _savedTag();
  }

  Future<void> setLocale(String? tag) async {
    if (tag != null && !supportedTags.contains(tag)) {
      throw ArgumentError.value(tag, 'tag', 'Unsupported app language');
    }
    if (_saving) return;
    _saving = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final previousMirror = prefs.getString(AppConstants.appLocaleKey);
      if (!await prefs.setString(AppConstants.appLocaleKey, tag ?? 'system')) {
        throw StateError('Could not mirror app language');
      }
      try {
        await Hive.box<String>(
          AppConstants.settingsBoxKey,
        ).put('locale', tag ?? 'system');
      } catch (_) {
        if (previousMirror == null) {
          await prefs.remove(AppConstants.appLocaleKey);
        } else {
          await prefs.setString(AppConstants.appLocaleKey, previousMirror);
        }
        rethrow;
      }
      if (ref.mounted) state = tag;
      // The durable preference and provider state are already committed. The
      // Android notification-channel projection is best effort and handles
      // its own platform failures, so it must not hold the selector open.
      unawaited(_refreshNative());
    } finally {
      _saving = false;
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
