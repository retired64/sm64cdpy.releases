class AppConstants {
  AppConstants._();

  static const String dbAssetPath = 'assets/db/database_sm64coopdx.json';
  static const String vipModsAssetPath = 'assets/db/vip.json';
  static const String dynosAssetPath = 'assets/db/dynos.json';
  static const String touchControlsAssetPath = 'assets/db/touch_controls.json';
  static const String favoritesBoxKey = 'favorites';
  static const String settingsBoxKey = 'settings';

  static const int pageSize = 6;
  static const int descriptionMaxLen = 200;
  static const int titleMaxLines = 2;

  static const String appName = 'SM64CDPY';
  static const String appVersion = '1.0.1';

  // ── External URLs ────────────────────────────────────────────────────────
  static const String githubReleasesUrl =
      'https://github.com/retired64/sm64cdpy.releases/releases';
  static const String dataSourceUrl = 'https://mods.sm64coopdx.com';

  // ── Remote JSON URLs for extra sections ──────────────────────────────────
  static const String vipModsRemoteUrl =
      'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/vip.json';
  static const String dynosRemoteUrl =
      'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/dynos.json';
  static const String touchControlsRemoteUrl =
      'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/touch_controls.json';

  // ── Social Links ─────────────────────────────────────────────────────────
  static const String youtubeUrl = 'https://www.youtube.com/@retired64';
  static const String discordUrl = 'https://discord.com/invite/thuhUH2WNX';
  static const String githubUrl = 'https://github.com/retired64';
}
