import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
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

  static Future<void> _onMessageFromOverlay(Object? data) async {
    if (data is! Map) return;
    final type = data['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'download_mod':
        await _handleDownload(data);
        break;
      case 'panel_opened':
        _sendActiveInstalls();
        break;
    }
  }

  static Future<void> _handleDownload(Map data) async {
    final url = data['url'] as String?;
    final modTitle = data['modTitle'] as String?;
    final section = data['section'] as String? ?? 'all';
    if (url == null || modTitle == null) return;

    final isDynos = section == 'dynos' || section == 'touchControls';
    final prefs = await SharedPreferences.getInstance();
    final autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;

    if (!autoInstall) {
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

    final filename = await DownloadUrlResolver.instance
        .resolveDownloadFilename(url, modTitle);
    final modName = sanitizeModTitle(modTitle);
    _titleByModName[modName] = modTitle;

    if (isDynos) {
      await _handleDynosDownload(
        url: url,
        modTitle: modTitle,
        modName: modName,
        filename: filename,
      );
    } else {
      await BackgroundInstallService.instance.startDownloadAndInstall(
        url: url,
        modName: modName,
        fileName: filename,
      );
    }
  }

  static Future<void> _handleDynosDownload({
    required String url,
    required String modTitle,
    required String modName,
    required String filename,
  }) async {
    try {
      FileDownloader.downloadFile(
        url: url,
        name: filename,
        onDownloadCompleted: (path) async {
          try {
            _sendProgress(modTitle, 'BgInstallProgress', 0);
            final installer = ModInstaller();
            await installer.installModToDynosFolder(
              zipPath: path,
              modName: modName,
            );
            _sendProgress(modTitle, 'completed', 100);
          } catch (e) {
            _sendError(modTitle, 'Install failed: $e');
          }
        },
        onDownloadError: (error) {
          _sendError(modTitle, 'Download failed: $error');
        },
        onProgress: (name, progress) {
          final pct = (progress > 1.0 ? progress / 100.0 : progress)
              .clamp(0.0, 1.0);
          _sendProgress(modTitle, 'BgDownloadProgress', (pct * 100).round());
        },
      );
    } catch (e) {
      _sendError(modTitle, 'Failed to start download: $e');
    }
  }

  static void _sendProgress(String modTitle, String status, int progress) {
    FloatyChatheads.shareData({
      'type': 'install_progress',
      'modTitle': modTitle,
      'status': status,
      'progress': progress,
    });
  }

  static void _sendError(String modTitle, String error) {
    FloatyChatheads.shareData({
      'type': 'install_error',
      'modTitle': modTitle,
      'error': error,
    });
  }

  static void _sendActiveInstalls() {
    for (final info in BackgroundInstallService.instance.activeInstalls) {
      final modTitle = _titleByModName[info.modName] ?? info.modName;
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
      FloatyChatheads.shareData(payload);
    }
  }

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
        _titleByModName.remove(event.modName);
        payload['status'] = 'completed';
        payload['fileCount'] = f;
        payload['targetDir'] = d;
        break;
      case BgOperationCancelled():
        _titleByModName.remove(event.modName);
        payload['status'] = 'cancelled';
        break;
      case BgInstallError(error: final e):
        _titleByModName.remove(event.modName);
        payload['type'] = 'install_error';
        payload['error'] = e;
        break;
      default:
        break;
    }

    FloatyChatheads.shareData(payload);
  }
}
