/// Features that the presentation layer may expose on the current platform.
///
/// This contract is deliberately independent from Flutter's target-platform
/// APIs. Platform composition chooses one immutable value during bootstrap;
/// widgets consume capabilities instead of scattering operating-system checks.
class PlatformCapabilities {
  const PlatformCapabilities({
    required this.usesSaf,
    required this.usesXdgPaths,
    required this.supportsAutomaticInstall,
    required this.supportsOsBackgroundExecution,
    required this.survivesProcessTermination,
    required this.supportsFloatingOverlay,
    required this.supportsApkOta,
    required this.supportsOpenFolder,
    required this.supportsSystemNotifications,
  });

  static const android = PlatformCapabilities(
    usesSaf: true,
    usesXdgPaths: false,
    supportsAutomaticInstall: true,
    supportsOsBackgroundExecution: true,
    survivesProcessTermination: true,
    supportsFloatingOverlay: true,
    supportsApkOta: true,
    supportsOpenFolder: false,
    supportsSystemNotifications: true,
  );

  static const linuxMvp = PlatformCapabilities(
    usesSaf: false,
    usesXdgPaths: true,
    supportsAutomaticInstall: true,
    supportsOsBackgroundExecution: false,
    survivesProcessTermination: false,
    supportsFloatingOverlay: false,
    supportsApkOta: false,
    supportsOpenFolder: true,
    supportsSystemNotifications: false,
  );

  final bool usesSaf;
  final bool usesXdgPaths;
  final bool supportsAutomaticInstall;
  final bool supportsOsBackgroundExecution;
  final bool survivesProcessTermination;
  final bool supportsFloatingOverlay;
  final bool supportsApkOta;
  final bool supportsOpenFolder;
  final bool supportsSystemNotifications;
}
