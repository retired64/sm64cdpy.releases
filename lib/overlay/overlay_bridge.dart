import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/installation_library_repository_impl.dart';
import '../domain/entities/install_identity.dart';
import '../domain/entities/installation_library.dart';
import '../services/background_install_service.dart';
import '../services/download_url_resolver.dart';
import '../services/installation_library_update_bus.dart';
import '../services/mod_installer.dart';

class OverlayBridge {
  OverlayBridge._();

  static bool _autoInstall = false;
  static bool _initialized = false;
  static bool _panelOpen = false;
  static int _libraryRequestId = 0;
  static int _libraryRefreshDepth = 0;
  static final _libraryRepository = InstallationLibraryRepositoryImpl();

  static void init() {
    if (_initialized) return;
    _initialized = true;
    FloatyChatheads.onData.listen(_onMessageFromOverlay);
    BackgroundInstallService.instance.events.listen(_forwardEventToOverlay);
    InstallationLibraryUpdateBus.snapshots.listen((snapshot) {
      if (_panelOpen && _libraryRefreshDepth == 0) {
        _sendLibrarySnapshot(snapshot, ++_libraryRequestId);
      }
    });
    ModInstaller.libraryInvalidations.listen((_) {
      if (_panelOpen) unawaited(_refreshLibrary(verify: true));
    });
    unawaited(refreshAutoInstall());
  }

  static Future<void> refreshAutoInstall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoInstall = prefs.getBool(AppConstants.autoInstallModsKey) ?? false;
    } catch (error, stack) {
      debugPrint(
        '[OverlayBridge] Failed to refresh auto-install: $error\n$stack',
      );
    }
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
          _panelOpen = true;
          _sendActiveInstalls();
          unawaited(_refreshLibrary(verify: true, announceLoading: true));
          break;
        case 'panel_closed':
          _panelOpen = false;
          break;
        case 'verify_installation':
          final artifactKey = data['artifactKey'] as String?;
          if (artifactKey != null && artifactKey.isNotEmpty) {
            await _refreshLibrary(
              verify: true,
              artifactKey: artifactKey,
              announceLoading: true,
            );
          }
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
    final versionLabel = data['versionLabel'] as String?;
    final destination = data['installDestination'] as String? ?? 'mods';
    if (url == null || modTitle == null) return;

    InstallIdentity? identity;
    try {
      identity = InstallIdentity.fromMap(data);
    } catch (error) {
      debugPrint('[OverlayBridge] Legacy/invalid identity: $error');
    }
    final isDynos = destination == 'dynos';

    if (!_autoInstall) {
      _sendError(modTitle, 'auto_install_off', identity: identity);
      return;
    }

    final installer = ModInstaller();
    final hasFolder = isDynos
        ? await installer.isDynosDirectorySelected()
        : await installer.isDirectorySelected();

    if (!hasFolder) {
      _sendError(modTitle, 'no_folder', identity: identity);
      return;
    }

    final resolvedUrl = await DownloadUrlResolver.instance.resolveDownloadUrl(
      url,
    );
    final filename = await DownloadUrlResolver.instance.resolveDownloadFilename(
      resolvedUrl,
      modTitle,
    );
    final modName =
        identity?.operationKey ?? operationName ?? sanitizeModTitle(modTitle);

    final chain = await BackgroundInstallService.instance
        .startDownloadAndInstall(
          url: resolvedUrl,
          modName: modName,
          identity: identity,
          fileName: filename,
          displayTitle: modTitle,
          notificationTitle: versionLabel == null || versionLabel.trim().isEmpty
              ? modTitle
              : '$modTitle · $versionLabel',
          installDestination: destination,
        );
    if (chain == null) {
      _sendError(modTitle, 'start_failed', identity: identity);
    }
  }

  static Future<void> _handleCancel(Map data) async {
    final modTitle = data['modTitle'] as String?;
    if (modTitle == null) return;
    final modName =
        data['operationName'] as String? ?? sanitizeModTitle(modTitle);
    InstallIdentity? identity;
    try {
      identity = InstallIdentity.fromMap(data);
    } catch (_) {
      identity = null;
    }
    final cancelled = await BackgroundInstallService.instance.cancelMod(
      modName,
    );
    if (!cancelled) {
      _sendError(modTitle, 'cancel_failed', identity: identity);
    }
  }

  static void _sendError(
    String modTitle,
    String error, {
    InstallIdentity? identity,
  }) {
    _safeShare({
      'type': 'install_error',
      'modTitle': modTitle,
      'error': error,
      if (identity != null) ...identity.toMap(),
    });
  }

  static void _sendActiveInstalls() {
    for (final info in BackgroundInstallService.instance.activeInstalls) {
      final modTitle = info.displayTitle ?? info.modName;
      final payload = <String, dynamic>{
        'type': 'install_progress',
        'modTitle': modTitle,
        'status': switch (info.status) {
          BgInstallStatus.pending => 'BgInstallPending',
          BgInstallStatus.downloading => 'BgDownloadProgress',
          BgInstallStatus.installing => 'BgInstallProgress',
          _ => info.status.name,
        },
        if (info.identity != null) ...info.identity!.toMap(),
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
      if (BackgroundInstallService.instance.getInfo(event.modName)?.identity !=
          null)
        ...BackgroundInstallService.instance
            .getInfo(event.modName)!
            .identity!
            .toMap(),
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
    if (event is BgInstallCompleted && _panelOpen) {
      // The native receipt exists before SUCCEEDED/install_completed. Re-read
      // and verify it so the overlay moves from transient completion to the
      // same durable Installed/Update state used by the main engine.
      unawaited(_refreshLibrary(verify: true));
    }
  }

  static Future<void> _refreshLibrary({
    required bool verify,
    String? artifactKey,
    bool announceLoading = false,
  }) async {
    if (!_panelOpen) return;
    final requestId = ++_libraryRequestId;
    if (announceLoading) {
      _safeShare({
        'type': 'installation_library_loading',
        'requestId': requestId,
      });
    }

    _libraryRefreshDepth++;
    try {
      final snapshot = verify
          ? artifactKey == null
                ? await _libraryRepository.verifyAll()
                : await _libraryRepository.verifyArtifact(artifactKey)
          : await _libraryRepository.synchronize();
      if (_panelOpen) _sendLibrarySnapshot(snapshot, requestId);
    } catch (error, stack) {
      debugPrint('[OverlayBridge] Library refresh failed: $error\n$stack');
      if (_panelOpen) {
        _safeShare({
          'type': 'installation_library_error',
          'requestId': requestId,
        });
      }
    } finally {
      _libraryRefreshDepth--;
    }
  }

  static void _sendLibrarySnapshot(
    InstallationLibrarySnapshot snapshot,
    int requestId,
  ) {
    _safeShare({
      'type': 'installation_library_snapshot',
      'requestId': requestId,
      'snapshot': snapshot.toOverlayMap(),
    });
  }
}
