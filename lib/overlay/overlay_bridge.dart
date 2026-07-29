import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../services/background_install_service.dart';
import '../services/download_url_resolver.dart';
import '../services/mod_installer.dart';

class OverlayBridge {
  OverlayBridge._();

  static final Map<String, String> _titleByModName = {};

  static void init() {
    FloatyChatheads.onData.listen(_onMessageFromOverlay);
    BackgroundInstallService.instance.events.listen(_forwardEventToOverlay);
  }

  // ── Messages FROM overlay → handled here ──────────────────────────────

  static Future<void> _onMessageFromOverlay(Object? data) async {
    if (data is! Map) return;
    final type = data['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'download_mod':
        await _handleDownload(data);
        break;
    }
  }

  static Future<void> _handleDownload(Map data) async {
    final url = data['url'] as String?;
    final modTitle = data['modTitle'] as String?;
    if (url == null || modTitle == null) return;

    // Check mods folder is selected (required for SAF install)
    final installer = ModInstaller();
    final hasFolder = await installer.isDirectorySelected();
    if (!hasFolder) {
      FloatyChatheads.shareData({
        'type': 'install_error',
        'modTitle': modTitle,
        'error': 'no_folder',
      });
      return;
    }

    // Check auto-install from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;
    if (!autoInstall) {
      FloatyChatheads.shareData({
        'type': 'install_error',
        'modTitle': modTitle,
        'error': 'auto_install_off',
      });
      return;
    }

    // Resolve filename (async, may do network request)
    final filename = await DownloadUrlResolver.instance
        .resolveDownloadFilename(url, modTitle);

    final modName = sanitizeModTitle(modTitle);

    // Store raw title so we can translate sanitized modName back
    _titleByModName[modName] = modTitle;

    await BackgroundInstallService.instance.startDownloadAndInstall(
      url: url,
      modName: modName,
      fileName: filename,
    );
  }

  // ── Events FROM native → forwarded to overlay ──────────────────────────

  static void _forwardEventToOverlay(BgInstallEvent event) {
    final modTitle = _titleByModName[event.modName] ?? event.modName;

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

    FloatyChatheads.shareData(payload);
  }
}
