import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

enum DownloadSourcePreference {
  originalFirst,
  mirrorFirst;

  static DownloadSourcePreference fromStorage(String? value) =>
      value == mirrorFirst.name ? mirrorFirst : originalFirst;
}

/// Persistent authority for selecting the preferred mod download source.
///
/// Both Flutter engines can read SharedPreferences independently. The choice
/// changes source order only: the other valid source always remains a fallback.
class DownloadSourcePreferenceService {
  DownloadSourcePreferenceService._();

  static Future<DownloadSourcePreference> read() async {
    final preferences = await SharedPreferences.getInstance();
    return DownloadSourcePreference.fromStorage(
      preferences.getString(AppConstants.downloadSourcePreferenceKey),
    );
  }

  static Future<void> write(DownloadSourcePreference preference) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      AppConstants.downloadSourcePreferenceKey,
      preference.name,
    );
    if (!saved) {
      throw StateError('Could not persist download source preference');
    }
  }
}
