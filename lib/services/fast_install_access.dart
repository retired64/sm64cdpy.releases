import 'package:flutter/services.dart';

/// Permission is always read from Android; neither Flutter engine owns a cache.
class FastInstallAccess {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');

  Future<bool> supported() async =>
      await _channel.invokeMethod<bool>('supportsAllFilesAccess') ?? false;

  Future<bool> granted() async =>
      await _channel.invokeMethod<bool>('hasAllFilesAccess') ?? false;

  /// True only when already granted or confirmed by a legacy permission reply.
  /// Opening Android Settings is not a grant; callers recheck on resume.
  Future<bool> request() async =>
      await _channel.invokeMethod<bool>('requestAllFilesAccess') ?? false;
}
