import 'dart:io';

import '../../domain/contracts/platform_capabilities.dart';

/// The single composition point for host-platform decisions.
///
/// Presentation code consumes [capabilities]. OS checks must not be copied
/// throughout screens or cards.
class PlatformEnvironment {
  PlatformEnvironment._();

  static bool get isAndroid => Platform.isAndroid;
  static bool get isLinux => Platform.isLinux;

  static PlatformCapabilities get capabilities {
    if (isAndroid) return PlatformCapabilities.android;
    if (isLinux) return PlatformCapabilities.linuxReadOnly;
    return PlatformCapabilities.linuxReadOnly;
  }
}
