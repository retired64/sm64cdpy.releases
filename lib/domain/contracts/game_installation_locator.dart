enum GameDataRootOrigin { automaticXdg, userOverride }

enum GameDataRootStatus { valid, missing, readOnly, invalid }

class GameDataRoot {
  const GameDataRoot({
    required this.path,
    required this.modsPath,
    required this.dynosPacksPath,
    required this.origin,
    required this.status,
  });

  final String path;
  final String modsPath;
  final String dynosPacksPath;
  final GameDataRootOrigin origin;
  final GameDataRootStatus status;
}

/// Locates and validates SM64CoopDX data without assuming that SM64CDPY's own
/// application-support directory is the game's directory.
abstract interface class GameInstallationLocator {
  Future<GameDataRoot> locate();

  Future<GameDataRoot> selectOverride(String absolutePath);

  Future<GameDataRoot> resetToAutomatic();
}
