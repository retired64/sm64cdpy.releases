import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../services/background_install_service.dart';
import '../services/download_url_resolver.dart';
import '../services/mod_installer.dart';

class OverlayBridge {
  OverlayBridge._();

  static bool _autoInstall = false;

  static void init() {
    FloatyChatheads.onData.listen(_onMessageFromOverlay);
    BackgroundInstallService.instance.events.listen(_forwardEventToOverlay);
    refreshAutoInstall();
  }

  static Future<void> refreshAutoInstall() async {
    final prefs = await SharedPreferences.getInstance();
    _autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;
  }

  static void _safeShare(Map<String, dynamic> data) {
    try {
      FloatyChatheads.shareData(data);
    } catch (e) {
      debugPrint('OverlayBridge shareData failed (overlay likely closed): $e');
    }
  }

  static Future<void> _onMessageFromOverlay(Object? data) async {
    if (data is! Map) return;
    final type = data['type'] as String?;
    if (type == null) return;

    try {
      switch (type) {
        case 'download_mod':
          await _handleDownload(data);
          break;
        case 'cancel_mod':
          await _handleCancel(data);
          break;
        case 'panel_opened':
          _sendActiveInstalls();
          break;
      }
    } catch (e, stack) {
      debugPrint('[OverlayBridge] Error handling type=$type: $e\n$stack');
    }
  }

  static Future<void> _handleDownload(Map data) async {
    final url = data['url'] as String?;
    final modTitle = data['modTitle'] as String?;
    final operationName = data['operationName'] as String?;
    final destination = data['installDestination'] as String? ?? 'mods';
    if (url == null || modTitle == null) return;

    final isDynos = destination == 'dynos';

    if (!_autoInstall) {
      _sendError(modTitle, 'auto_install_off');
      return;
    }

    final installer = ModInstaller();
    final hasFolder = isDynos
        ? await installer.isDynosDirectorySelected()
        : await installer.isDirectorySelected();

    if (!hasFolder) {
      _sendError(modTitle, 'no_folder');
      return;
    }

    final filename = await DownloadUrlResolver.instance.resolveDownloadFilename(
      url,
      modTitle,
    );
    final modName = operationName ?? sanitizeModTitle(modTitle);

    final chain = await BackgroundInstallService.instance
        .startDownloadAndInstall(
          url: url,
          modName: modName,
          fileName: filename,
          displayTitle: modTitle,
          installDestination: destination,
        );
    if (chain == null) _sendError(modTitle, 'start_failed');
  }

  static Future<void> _handleCancel(Map data) async {
    final modTitle = data['modTitle'] as String?;
    if (modTitle == null) return;
    final modName =
        data['operationName'] as String? ?? sanitizeModTitle(modTitle);
    final cancelled = await BackgroundInstallService.instance.cancelMod(
      modName,
    );
    if (!cancelled) _sendError(modTitle, 'cancel_failed');
  }

  static void _sendError(String modTitle, String error) {
    _safeShare({'type': 'install_error', 'modTitle': modTitle, 'error': error});
  }

  static void _sendActiveInstalls() {
    for (final info in BackgroundInstallService.instance.activeInstalls) {
      final modTitle = info.displayTitle ?? info.modName;
      final payload = <String, dynamic>{
        'type': 'install_progress',
        'modTitle': modTitle,
        'status': info.status == BgInstallStatus.downloading
            ? 'BgDownloadProgress'
            : 'BgInstallProgress',
      };
      if (info.downloadProgress != null) {
        payload['progress'] = info.downloadProgress;
      } else if (info.current != null &&
          info.total != null &&
          info.total! > 0) {
        payload['progress'] = ((info.current! / info.total!) * 100).round();
      }
      _safeShare(payload);
    }
  }

  static void _forwardEventToOverlay(BgInstallEvent event) {
    final modTitle =
        BackgroundInstallService.instance
            .getInfo(event.modName)
            ?.displayTitle ??
        event.modName;

    final payload = <String, dynamic>{
      'type': 'install_progress',
      'modTitle': modTitle,
      'status': event.runtimeType.toString(),
    };

    switch (event) {
      case BgDownloadProgress(progress: final p):
        payload['progress'] = p;
        break;
      case BgInstallProgress(current: final c, total: final t):
        payload['progress'] = t > 0 ? ((c / t) * 100).round() : 0;
        payload['phase'] = 'installing';
        break;
      case BgInstallCompleted(fileCount: final f, targetDir: final d):
        payload['status'] = 'completed';
        payload['fileCount'] = f;
        payload['targetDir'] = d;
        break;
      case BgOperationCancelled():
        payload['status'] = 'cancelled';
        break;
      case BgInstallError(error: final e):
        payload['type'] = 'install_error';
        payload['error'] = e;
        break;
      default:
        break;
    }

    _safeShare(payload);
  }
}
