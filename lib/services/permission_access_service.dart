import 'package:floaty_chatheads/floaty_chatheads.dart';

import '../domain/entities/coop_session.dart';
import 'coop_session_service.dart';
import 'fast_install_access.dart';
import 'mod_installer.dart';

class PermissionAccessSnapshot {
  const PermissionAccessSnapshot({
    required this.notifications,
    required this.overlay,
    required this.allFilesSupported,
    required this.allFiles,
    required this.batterySupported,
    required this.batteryUnrestricted,
  });

  final bool notifications;
  final bool overlay;
  final bool allFilesSupported;
  final bool allFiles;
  final bool batterySupported;
  final bool batteryUnrestricted;
}

/// Reads special-access state directly from Android on every refresh.
class PermissionAccessService {
  PermissionAccessService({
    ModInstaller? installer,
    FastInstallAccess? fastInstall,
    CoopSessionService? coop,
  }) : _installer = installer ?? ModInstaller(),
       _fastInstall = fastInstall ?? FastInstallAccess(),
       _coop = coop ?? const CoopSessionService();

  final ModInstaller _installer;
  final FastInstallAccess _fastInstall;
  final CoopSessionService _coop;

  Future<PermissionAccessSnapshot> snapshot() async {
    final notifications = await _safe(_installer.hasNotificationPermission);
    final overlay = await _safe(FloatyChatheads.checkPermission);
    final allFilesSupported = await _safe(_fastInstall.supported);
    final allFiles = allFilesSupported && await _safe(_fastInstall.granted);
    final battery = await _battery();
    return PermissionAccessSnapshot(
      notifications: notifications,
      overlay: overlay,
      allFilesSupported: allFilesSupported,
      allFiles: allFiles,
      batterySupported: battery.supported,
      batteryUnrestricted: battery.ignored,
    );
  }

  Future<bool> requestNotifications() =>
      _safe(_installer.requestNotificationPermission);
  Future<bool> requestOverlay() => _safe(FloatyChatheads.requestPermission);
  Future<bool> requestAllFiles() => _safe(_fastInstall.request);

  Future<CoopBatteryOptimizationState> requestBattery() async {
    try {
      return await _coop.requestBatteryOptimizationExemption();
    } catch (_) {
      return const CoopBatteryOptimizationState(
        supported: false,
        ignored: false,
      );
    }
  }

  Future<CoopBatteryOptimizationState> _battery() async {
    try {
      return await _coop.batteryOptimizationStatus();
    } catch (_) {
      return const CoopBatteryOptimizationState(
        supported: false,
        ignored: false,
      );
    }
  }

  Future<bool> _safe(Future<bool> Function() operation) async {
    try {
      return await operation();
    } catch (_) {
      return false;
    }
  }
}
