class AppSecondaryDestination {
  const AppSecondaryDestination();
}

abstract final class AppNavigationPolicy {
  static const primaryPaths = <String>{
    '/',
    '/catalogue',
    '/popular',
    '/favourites',
    '/library',
    '/player',
    '/game-tool/play-2p2',
    '/game-tool/save-file',
    '/game-tool/rom-preparer',
    '/settings',
    '/how-to-play',
    '/links-resource',
    '/disclaimer',
    '/vip',
    '/dynos',
    '/touch-controls',
    '/omm-rebirth',
    '/render96',
  };

  static bool isPrimaryLocation(Uri uri) => primaryPaths.contains(uri.path);

  static bool isSecondaryLocation(Uri uri) => !isPrimaryLocation(uri);

  static String? parentOf(String path) => switch (path) {
    '/settings/permissions' => '/settings',
    _ => null,
  };
}
