import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'mod_installer.dart';

enum BgInstallStatus { pending, downloading, installing, completed, cancelled, error }

enum BgOperationPhase { downloading, installing }

sealed class BgInstallEvent {
  const BgInstallEvent({required this.modName, required this.workId});
  final String modName;
  final String workId;
}

class BgInstallStarted extends BgInstallEvent {
  const BgInstallStarted({required super.modName, required super.workId});
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
  const BgOperationCancelled({
    required super.modName,
    required super.workId,
  });
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
}

class BackgroundInstallService {
  BackgroundInstallService._();

  static final BackgroundInstallService instance = BackgroundInstallService._();

  static const _eventChannel = EventChannel('mods.sm64cdpy/mod_install_events');

  final _controller = StreamController<BgInstallEvent>.broadcast();
  Stream<BgInstallEvent> get events => _controller.stream;

  final _infoMap = <String, BgInstallInfo>{};

  StreamSubscription? _eventSub;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _eventSub = _eventChannel.receiveBroadcastStream().listen(
      _onNativeEvent,
      onError: (e) => debugPrint('BgInstall event error: $e'),
    );
  }

  void dispose() {
    _eventSub?.cancel();
    _controller.close();
    _infoMap.clear();
    _initialized = false;
  }

  BgInstallInfo? getInfo(String modName) => _infoMap[modName];

  bool isInstalling(String modName) {
    final info = _infoMap[modName];
    return info != null &&
        (info.status == BgInstallStatus.installing ||
         info.status == BgInstallStatus.downloading);
  }

  List<BgInstallInfo> get activeInstalls =>
      _infoMap.values
          .where((i) => i.status == BgInstallStatus.downloading ||
                       i.status == BgInstallStatus.installing)
          .toList();

  void cancelMod(String modName) {
    final installer = ModInstaller();
    installer.cancelModOperation(modName: modName);
    final info = BgInstallInfo(
      modName: modName,
      status: BgInstallStatus.cancelled,
    );
    _infoMap[modName] = info;
    _controller.add(
      BgOperationCancelled(modName: modName, workId: ''),
    );
    _scheduleCleanup(modName);
  }

  Future<ModChainResult?> startDownloadAndInstall({
    required String url,
    required String modName,
    required String fileName,
  }) async {
    final installer = ModInstaller();

    try {
      final chainResult = await installer.downloadAndInstallMod(
        url: url,
        modName: modName,
        fileName: fileName,
      );

      if (chainResult == null) return null;

      final info = BgInstallInfo(
        modName: modName,
        status: BgInstallStatus.downloading,
        phase: BgOperationPhase.downloading,
        workId: chainResult.downloadWorkId,
        downloadProgress: 0,
      );
      _infoMap[modName] = info;

      _controller.add(
        BgInstallStarted(
          modName: modName,
          workId: chainResult.downloadWorkId,
        ),
      );

      return chainResult;
    } catch (e) {
      _infoMap[modName] = BgInstallInfo(
        modName: modName,
        status: BgInstallStatus.error,
        error: e.toString(),
      );
      _controller.add(
        BgInstallError(
          modName: modName,
          workId: '',
          error: e.toString(),
        ),
      );
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

      _controller.add(
        BgInstallStarted(modName: modName, workId: workId),
      );

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
          BgDownloadCompleted(
            modName: modName,
            workId: workId ?? '',
          ),
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
          BgOperationCancelled(
            modName: modName,
            workId: workId ?? '',
          ),
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
          BgInstallError(
            modName: modName,
            workId: workId ?? '',
            error: error,
          ),
        );
        _scheduleCleanup(modName);

      case 'pending':
        _infoMap[modName] = BgInstallInfo(
          modName: modName,
          status: BgInstallStatus.pending,
          phase: phase,
          workId: workId,
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
  }

  void _scheduleCleanup(String modName) {
    Future.delayed(const Duration(seconds: 8), () {
      final info = _infoMap[modName];
      if (info != null &&
          info.status != BgInstallStatus.downloading &&
          info.status != BgInstallStatus.installing &&
          info.status != BgInstallStatus.pending) {
        _infoMap.remove(modName);
      }
    });
  }
}
