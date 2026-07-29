class AppConstants {
  AppConstants._();

  static const String dbAssetPath = 'assets/db/database_sm64coopdx.json';
  static const String vipModsAssetPath = 'assets/db/vip.json';
  static const String dynosAssetPath = 'assets/db/dynos.json';
  static const String touchControlsAssetPath = 'assets/db/touch_controls.json';
  static const String ommRebirthAssetPath = 'assets/db/omm.json';
  static const String settingsBoxKey = 'settings';

  static const int pageSize = 6;
  static const int descriptionMaxLen = 200;
  static const int descriptionMaxLines = 3;
  static const int titleMaxLines = 2;

  static const String appName = 'SM64CDPY';

  // ── External URLs ────────────────────────────────────────────────────────
  static const String githubReleasesUrl =
      'https://github.com/retired64/sm64cdpy.releases/releases';
  static const String githubReleasesLatestUrl =
      'https://github.com/retired64/sm64cdpy.releases/releases/latest';
  static const String dataSourceUrl = 'https://mods.sm64coopdx.com';
  static const String officialweb = 'https://sm64coopdx.com';

  // ── Remote JSON URLs for extra sections ──────────────────────────────────
  static const String vipModsRemoteUrl =
      'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/vip.json';
  static const String dynosRemoteUrl =
      'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/dynos.json';
  static const String touchControlsRemoteUrl =
      'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/touch_controls.json';
  static const String ommRebirthRemoteUrl =
      'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/omm.json';

  // ── Social Links ─────────────────────────────────────────────────────────
  static const String youtubeUrl = 'https://www.youtube.com/@retired64';
  static const String discordUrl = 'https://discord.com/invite/thuhUH2WNX';
  static const String discordPort = 'https://discord.gg/TJVKHS4';
  static const String discordPortAndroid = 'https://discord.gg/ePsHjqF3Qr';
  static const String githubUrl = 'https://github.com/retired64';

  // ── Links Resource ────────────────────────────────────────────────────────
  static const String wikiUrl = 'https://github.com/ManIsCat2/sm64coopdx/wiki';
  static const String toolsAndAddonsUrl =
      'https://github.com/coop-deluxe/sm64coopdx/tree/main/docs/lua';
  static const String maniscat2Github =
      'https://github.com/ManIsCat2/sm64coopdx';

  // ── Mod Installer ───────────────────────────────────────────────────────
  /// Clave en SharedPreferences para el estado de auto-instalación.
  static const String autoInstallModsKey = 'auto_install_mods';

  /// Clave en SharedPreferences para el set de IDs de mods favoritos (JSON).
  static const String favouritesKey = 'favourites';

  /// Clave en SharedPreferences para la URI del directorio de mods seleccionado.
  static const String modsDirectoryUriKey = 'mods_directory_uri';

  /// Clave en SharedPreferences para la URI del directorio dynos seleccionado.
  static const String dynosDirectoryUriKey = 'dynos_directory_uri';
}
