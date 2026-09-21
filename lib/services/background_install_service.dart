import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mod_installer.dart';

enum BgInstallStatus {
  pending,
  downloading,
  installing,
  completed,
  cancelled,
  error,
}

enum BgOperationPhase { downloading, installing }

sealed class BgInstallEvent {
  const BgInstallEvent({required this.modName, required this.workId});
  final String modName;
  final String workId;
}

class BgInstallStarted extends BgInstallEvent {
  const BgInstallStarted({required super.modName, required super.workId});
}

class BgInstallPending extends BgInstallEvent {
  const BgInstallPending({
    required super.modName,
    required super.workId,
    required this.phase,
  });
  final BgOperationPhase phase;
}

class BgDownloadProgress extends BgInstallEvent {
  const BgDownloadProgress({
    required super.modName,
    required super.workId,
    required this.progress,
  });
  final int progress;
}

class BgDownloadCompleted extends BgInstallEvent {
  const BgDownloadCompleted({required super.modName, required super.workId});
}

class BgInstallProgress extends BgInstallEvent {
  const BgInstallProgress({
    required super.modName,
    required super.workId,
    required this.current,
    required this.total,
  });
  final int current;
  final int total;
}

class BgInstallCompleted extends BgInstallEvent {
  const BgInstallCompleted({
    required super.modName,
    required super.workId,
    required this.fileCount,
    required this.targetDir,
  });
  final int fileCount;
  final String targetDir;
}

class BgOperationCancelled extends BgInstallEvent {
  const BgOperationCancelled({required super.modName, required super.workId});
}

class BgInstallError extends BgInstallEvent {
  const BgInstallError({
    required super.modName,
    required super.workId,
    required this.error,
  });
  final String error;
}

class BgInstallInfo {
  const BgInstallInfo({
    required this.modName,
    required this.status,
    this.phase,
    this.workId,
    this.downloadProgress,
    this.current,
    this.total,
    this.fileCount,
    this.targetDir,
    this.error,
    this.displayTitle,
    this.downloadWorkId,
    this.installWorkId,
    this.installDestination,
  });

  final String modName;
  final BgInstallStatus status;
  final BgOperationPhase? phase;
  final String? workId;
  final int? downloadProgress;
  final int? current;
  final int? total;
  final int? fileCount;
  final String? targetDir;
  final String? error;
  final String? displayTitle;
  final String? downloadWorkId;
  final String? installWorkId;
  final String? installDestination;
}

class BackgroundInstallService {
  BackgroundInstallService._();

  static final BackgroundInstallService instance = BackgroundInstallService._();

  static const _eventChannel = EventChannel('mods.sm64cdpy/mod_install_events');

  final _controller = StreamController<BgInstallEvent>.broadcast();
  Stream<BgInstallEvent> get events => _controller.stream;

  final _infoMap = <String, BgInstallInfo>{};

  bool _initialized = false;
  Future<void> _ready = Future.value();

  static const _prefsKey = 'bg_install_info';

  Future<void> get ready => _ready;

  Map<String, BgInstallInfo> get snapshot => Map.unmodifiable(_infoMap);

  void init() {
    if (_initialized) return;
    _initialized = true;

    _ready = _restoreAndReconcile();

    _eventChannel.receiveBroadcastStream().listen(
      _onNativeEvent,
      onError: (e) => debugPrint('BgInstall event error: $e'),
    );
  }

  Future<void> _restoreAndReconcile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List<dynamic>;
      for (final entry in list) {
        if (entry is! Map<String, dynamic>) continue;
        final statusStr = entry['status'] as String? ?? 'pending';
        _infoMap.putIfAbsent(
          entry['modName'] as String,
          () => BgInstallInfo(
            modName: entry['modName'] as String,
            status: switch (statusStr) {
              'downloading' => BgInstallStatus.downloading,
              'installing' => BgInstallStatus.installing,
              'completed' => BgInstallStatus.completed,
              'cancelled' => BgInstallStatus.cancelled,
              'error' => BgInstallStatus.error,
              _ => BgInstallStatus.pending,
            },
            workId: entry['workId'] as String?,
            displayTitle: entry['displayTitle'] as String?,
            downloadWorkId: entry['downloadWorkId'] as String?,
            installWorkId: entry['installWorkId'] as String?,
            installDestination: entry['installDestination'] as String?,
          ),
        );
      }

      final operations = _infoMap.values
          .where(
            (info) => info.downloadWorkId != null || info.installWorkId != null,
          )
          .map(
            (info) => <String, String>{
              'modName': info.modName,
              if (info.downloadWorkId != null)
                'downloadWorkId': info.downloadWorkId!,
              if (info.installWorkId != null)
                'installWorkId': info.installWorkId!,
            },
          )
          .toList();
      final snapshots = await ModInstaller().reconcileBackgroundOperations(
        operations,
      );
      for (final info in List<BgInstallInfo>.from(_infoMap.values)) {
        _applyReconciledState(info, snapshots);
      }
    } catch (e) {
      debugPrint('BgInstall restore failed: $e');
    }
  }

  void _applyReconciledState(
    BgInstallInfo info,
    Map<String, NativeWorkSnapshot> snapshots,
  ) {
    final download = info.downloadWorkId == null
        ? null
        : snapshots[info.downloadWorkId];
    final install = info.installWorkId == null
        ? null
        : snapshots[info.installWorkId];

    Map<String, dynamic>? event;
    if (install?.state == 'SUCCEEDED') {
      event = {
        'type': 'install_completed',
        'phase': 'installing',
        'workId': install!.workId,
        'fileCount': install.fileCount ?? 0,
        'targetDir': install.targetDir ?? info.modName,
      };
    } else if (install?.state == 'FAILED') {
      event = {
        'type': 'error',
        'phase': 'installing',
        'workId': install!.workId,
        'error': install.error ?? 'Installation failed',
      };
    } else if (install?.state == 'CANCELLED' ||
        download?.state == 'CANCELLED') {
      event = {
        'type': 'cancelled',
        'phase': install?.state == 'CANCELLED' ? 'installing' : 'downloading',
        'workId': install?.workId ?? download?.workId ?? '',
      };
    } else if (download?.state == 'FAILED') {
      event = {
        'type': 'error',
        'phase': 'downloading',
        'workId': download!.workId,
        'error': download.error ?? 'Download failed',
      };
    } else if (install?.state == 'RUNNING') {
      event = {
        'type': 'install_progress',
        'phase': 'installing',
        'workId': install!.workId,
        'current': install.current ?? 0,
        'total': install.total ?? 0,
      };
    } else if (download?.state == 'RUNNING') {
      event = {
        'type': 'download_progress',
        'phase': 'downloading',
        'workId': download!.workId,
        'progress': download.progress ?? 0,
      };
    } else if (install != null || download != null) {
      final installing = download?.state == 'SUCCEEDED';
      event = {
        'type': 'pending',
        'phase': installing ? 'installing' : 'downloading',
        'workId': installing
            ? (install?.workId ?? '')
            : (download?.workId ?? ''),
      };
    }

    if (event == null) {
      _infoMap.remove(info.modName);
    } else {
      _onNativeEvent({...event, 'modName': info.modName});
    }
  }

  Future<void> _persistToPrefs() async {
    final list = _infoMap.entries
        .where(
          (e) =>
              e.value.status != BgInstallStatus.completed &&
              e.value.status != BgInstallStatus.cancelled,
        )
        .map(
          (e) => {
            'modName': e.key,
            'status': e.value.status.name,
            'workId': e.value.workId,
            if (e.value.downloadWorkId != null)
              'downloadWorkId': e.value.downloadWorkId,
            if (e.value.installWorkId != null)
              'installWorkId': e.value.installWorkId,
            if (e.value.installDestination != null)
              'installDestination': e.value.installDestination,
            if (e.value.displayTitle != null)
              'displayTitle': e.value.displayTitle,
          },
        )
        .toList();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(list));
    } catch (_) {}
  }

  BgInstallInfo? getInfo(String modName) => _infoMap[modName];

  bool isInstalling(String modName) {
    final info = _infoMap[modName];
    return info != null &&
        (info.status == BgInstallStatus.installing ||
            info.status == BgInstallStatus.downloading ||
            info.status == BgInstallStatus.pending);
  }

  List<BgInstallInfo> get activeInstalls => _infoMap.values
      .where(
        (i) =>
            i.status == BgInstallStatus.downloading ||
            i.status == BgInstallStatus.installing ||
            i.status == BgInstallStatus.pending,
      )
      .toList();

  Future<bool> cancelMod(String modName) async {
    final installer = ModInstaller();
    final cancelled = await installer.cancelModOperation(modName: modName);
    if (!cancelled) return false;
    final previous = _infoMap[modName];
    final info = BgInstallInfo(
      modName: modName,
      status: BgInstallStatus.cancelled,
      displayTitle: previous?.displayTitle,
      downloadWorkId: previous?.downloadWorkId,
      installWorkId: previous?.installWorkId,
      installDestination: previous?.installDestination,
    );
    _infoMap[modName] = info;
    _controller.add(BgOperationCancelled(modName: modName, workId: ''));
    await _persistToPrefs();
    _scheduleCleanup(modName);
    return true;
  }

  Future<ModChainResult?> startDownloadAndInstall({
    required String url,
    required String modName,
    required String fileName,
    String? displayTitle,
    String? notificationTitle,
    String installDestination = 'mods',
  }) async {
    final installer = ModInstaller();

    try {
      final chainResult = await installer.downloadAndInstallMod(
        url: url,
        modName: modName,
        fileName: fileName,
        displayTitle: displayTitle,
        notificationTitle: notificationTitle,
        installDestination: installDestination,
      );

      if (chainResult == null) return null;

      final info = BgInstallInfo(
        modName: modName,
        status: BgInstallStatus.downloading,
        phase: BgOperationPhase.downloading,
        workId: chainResult.downloadWorkId,
        downloadProgress: 0,
        displayTitle: displayTitle,
        downloadWorkId: chainResult.downloadWorkId,
        installWorkId: chainResult.installWorkId,
        installDestination: installDestination,
      );
      _infoMap[modName] = info;

      _controller.add(
        BgInstallStarted(modName: modName, workId: chainResult.downloadWorkId),
      );

      await _persistToPrefs();

      return chainResult;
    } catch (e) {
      _infoMap[modName] = BgInstallInfo(
        modName: modName,
        status: BgInstallStatus.error,
        error: e.toString(),
        displayTitle: displayTitle,
        installDestination: installDestination,
      );
      _controller.add(
        BgInstallError(modName: modName, workId: '', error: e.toString()),
      );
      await _persistToPrefs();
      _scheduleCleanup(modName);
      return null;
    }
  }

  Future<String?> startInstall({
    required String zipPath,
    required String modName,
  }) async {
    final installer = ModInstaller();

    try {
      final workId = await installer.installModBackground(
        zipPath: zipPath,
        modName: modName,
      );

      if (workId == null) return null;

      final info = BgInstallInfo(
        modName: modName,
        status: BgInstallStatus.installing,
        workId: workId,
      );
      _infoMap[modName] = info;

      _controller.add(BgInstallStarted(modName: modName, workId: workId));

      return workId;
    } catch (e) {
      _infoMap[modName] = BgInstallInfo(
        modName: modName,
        status: BgInstallStatus.error,
        error: e.toString(),
      );
      _controller.add(
        BgInstallError(modName: modName, workId: '', error: e.toString()),
      );
      return null;
    }
  }

  void _onNativeEvent(dynamic event) {
    if (event is! Map) return;

    final map = Map<String, dynamic>.from(event);
    final modName = map['modName'] as String?;
    final workId = map['workId'] as String?;
    final type = map['type'] as String?;
    final phaseStr = map['phase'] as String?;
    final phase = phaseStr == 'installing'
        ? BgOperationPhase.installing
        : BgOperationPhase.downloading;

    if (modName == null) return;
    final previousInfo = _infoMap[modName];

    switch (type) {
      case 'download_progress':
        final progress = map['progress'] as int? ?? 0;
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.downloading,
          phase: phase,
          workId: workId,
          downloadProgress: progress,
        );
        _controller.add(
          BgDownloadProgress(
            modName: modName,
            workId: workId ?? '',
            progress: progress,
          ),
        );

      case 'download_completed':
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.downloading,
          phase: phase,
          workId: workId,
          downloadProgress: 100,
        );
        _controller.add(
          BgDownloadCompleted(modName: modName, workId: workId ?? ''),
        );

      case 'install_progress':
        final current = map['current'] as int? ?? 0;
        final total = map['total'] as int? ?? 0;
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.installing,
          phase: phase,
          workId: workId,
          current: current,
          total: total,
        );
        _controller.add(
          BgInstallProgress(
            modName: modName,
            workId: workId ?? '',
            current: current,
            total: total,
          ),
        );

      case 'install_completed':
        final fileCount = map['fileCount'] as int? ?? 0;
        final targetDir = map['targetDir'] as String? ?? modName;
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.completed,
          phase: phase,
          workId: workId,
          fileCount: fileCount,
          targetDir: targetDir,
        );
        _controller.add(
          BgInstallCompleted(
            modName: modName,
            workId: workId ?? '',
            fileCount: fileCount,
            targetDir: targetDir,
          ),
        );
        _scheduleCleanup(modName);

      case 'cancelled':
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.cancelled,
          phase: phase,
          workId: workId,
        );
        _controller.add(
          BgOperationCancelled(modName: modName, workId: workId ?? ''),
        );
        _scheduleCleanup(modName);

      case 'error':
        final error = map['error'] as String? ?? 'Operation failed';
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.error,
          phase: phase,
          workId: workId,
          error: error,
        );
        _controller.add(
          BgInstallError(modName: modName, workId: workId ?? '', error: error),
        );
        _scheduleCleanup(modName);

      case 'pending':
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.pending,
          phase: phase,
          workId: workId,
        );
        _controller.add(
          BgInstallPending(
            modName: modName,
            workId: workId ?? '',
            phase: phase,
          ),
        );

      // ── Legacy event types (from installModBackground standalone) ──────
      case 'progress':
        final current = map['current'] as int? ?? 0;
        final total = map['total'] as int? ?? 0;
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.installing,
          phase: BgOperationPhase.installing,
          workId: workId,
          current: current,
          total: total,
        );
        _controller.add(
          BgInstallProgress(
            modName: modName,
            workId: workId ?? '',
            current: current,
            total: total,
          ),
        );

      case 'completed':
        final fileCount = map['fileCount'] as int? ?? 0;
        final targetDir = map['targetDir'] as String? ?? modName;
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.completed,
          phase: BgOperationPhase.installing,
          workId: workId,
          fileCount: fileCount,
          targetDir: targetDir,
        );
        _controller.add(
          BgInstallCompleted(
            modName: modName,
            workId: workId ?? '',
            fileCount: fileCount,
            targetDir: targetDir,
          ),
        );
        _scheduleCleanup(modName);
    }

    // Los eventos nativos solo transportan progreso. La identidad y metadata
    // visible pertenecen a la operación original y deben sobrevivir cada
    // reemplazo de BgInstallInfo (especialmente para el segundo engine).
    final currentInfo = _infoMap[modName];
    if (currentInfo != null && previousInfo != null) {
      _infoMap[modName] = BgInstallInfo(
        modName: currentInfo.modName,
        status: currentInfo.status,
        phase: currentInfo.phase,
        workId: currentInfo.workId,
        downloadProgress: currentInfo.downloadProgress,
        current: currentInfo.current,
        total: currentInfo.total,
        fileCount: currentInfo.fileCount,
        targetDir: currentInfo.targetDir,
        error: currentInfo.error,
        displayTitle: currentInfo.displayTitle ?? previousInfo.displayTitle,
        downloadWorkId:
            currentInfo.downloadWorkId ?? previousInfo.downloadWorkId,
        installWorkId: currentInfo.installWorkId ?? previousInfo.installWorkId,
        installDestination:
            currentInfo.installDestination ?? previousInfo.installDestination,
      );
    }
    unawaited(_persistToPrefs());
  }

  void _scheduleCleanup(String modName) {
    Future.delayed(const Duration(seconds: 8), () {
      final info = _infoMap[modName];
      if (info != null &&
          info.status != BgInstallStatus.downloading &&
          info.status != BgInstallStatus.installing &&
          info.status != BgInstallStatus.pending) {
        _infoMap.remove(modName);
        unawaited(_persistToPrefs());
      }
    });
  }
}
