import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/platform/platform_environment.dart';
import '../overlay/overlay_bridge.dart';
import '../services/background_install_service.dart';
import '../services/app_version_service.dart';
import '../services/installation_library_projection_service.dart';
import '../services/update_service.dart';

/// Initializes shared persistence, then only the services supported by the
/// current host. Android behavior remains in its original order.
Future<void> bootstrapMainApp() async {
  await _bootstrapCommon();
  if (PlatformEnvironment.isAndroid) {
    await _bootstrapAndroid();
  }
}

Future<void> _bootstrapCommon() async {
  await AppVersionService.init();
  try {
    await Hive.initFlutter();
    await Hive.openBox<String>(AppConstants.settingsBoxKey);
    await Hive.openBox<dynamic>(AppConstants.installationLibraryBoxKey);
  } catch (error) {
    debugPrint('Hive initialization failed: $error');
  }
}

Future<void> _bootstrapAndroid() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  FileDownloader.setLogEnabled(kDebugMode);
  FileDownloader.setMaximumParallelDownloads(3);
  await UpdateService.init();
  BackgroundInstallService.instance.init();
  await InstallationLibraryProjectionService.instance.init();
  OverlayBridge.init();
}
