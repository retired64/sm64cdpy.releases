/// Features that the presentation layer may expose on the current platform.
///
/// This contract is deliberately independent from Flutter's target-platform
/// APIs. Platform composition chooses one immutable value during bootstrap;
/// widgets consume capabilities instead of scattering operating-system checks.
class PlatformCapabilities {
  const PlatformCapabilities({
    required this.usesSaf,
    required this.usesXdgPaths,
    required this.supportsContentTransfers,
    required this.supportsAutomaticInstall,
    required this.supportsOsBackgroundExecution,
    required this.survivesProcessTermination,
    required this.supportsFloatingOverlay,
    required this.supportsApkOta,
    required this.supportsOpenFolder,
    required this.supportsSystemNotifications,
    required this.supportsGameLaunch,
  });

  static const android = PlatformCapabilities(
    usesSaf: true,
    usesXdgPaths: false,
    supportsContentTransfers: true,
    supportsAutomaticInstall: true,
    supportsOsBackgroundExecution: true,
    survivesProcessTermination: true,
    supportsFloatingOverlay: true,
    supportsApkOta: true,
    supportsOpenFolder: false,
    supportsSystemNotifications: true,
    supportsGameLaunch: true,
  );

  static const linuxMvp = PlatformCapabilities(
    usesSaf: false,
    usesXdgPaths: true,
    supportsContentTransfers: true,
    supportsAutomaticInstall: true,
    supportsOsBackgroundExecution: false,
    survivesProcessTermination: false,
    supportsFloatingOverlay: false,
    supportsApkOta: false,
    supportsOpenFolder: true,
    supportsSystemNotifications: false,
    supportsGameLaunch: false,
  );

  /// Transitional capabilities for the catalogue-only Linux shell.
  ///
  /// Installation becomes available only after the filesystem backend is
  /// implemented in later roadmap phases. Keeping this value separate avoids
  /// advertising the final MVP before its guarantees exist.
  static const linuxReadOnly = PlatformCapabilities(
    usesSaf: false,
    usesXdgPaths: true,
    supportsContentTransfers: false,
    supportsAutomaticInstall: false,
    supportsOsBackgroundExecution: false,
    survivesProcessTermination: false,
    supportsFloatingOverlay: false,
    supportsApkOta: false,
    supportsOpenFolder: false,
    supportsSystemNotifications: false,
    supportsGameLaunch: false,
  );

  final bool usesSaf;
  final bool usesXdgPaths;
  final bool supportsContentTransfers;
  final bool supportsAutomaticInstall;
  final bool supportsOsBackgroundExecution;
  final bool survivesProcessTermination;
  final bool supportsFloatingOverlay;
  final bool supportsApkOta;
  final bool supportsOpenFolder;
  final bool supportsSystemNotifications;
  final bool supportsGameLaunch;
}
