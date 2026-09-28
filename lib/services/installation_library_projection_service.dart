import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/installation_library_repository_impl.dart';
import 'background_install_service.dart';

/// Keeps the rebuildable Hive projection fresh even before Library UI exists.
/// Native receipts remain authoritative; synchronization failures are retried
/// by the next invalidation or application start.
class InstallationLibraryProjectionService {
  InstallationLibraryProjectionService._();

  static final instance = InstallationLibraryProjectionService._();

  final _repository = InstallationLibraryRepositoryImpl();
  bool _initialized = false;
  bool _synchronizing = false;
  bool _synchronizeAgain = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    // App-process lifetime listeners: this singleton is never torn down while
    // the main engine is alive.
    BackgroundInstallService.instance.events.listen((event) {
      if (event is BgInstallCompleted) unawaited(synchronize());
    });
    // Folder invalidations do not change durable receipts/history. An active
    // Library provider consumes them and performs SAF verification; when the
    // screen is closed there is no reason to query a potentially slow provider.
    await synchronize();
  }

  Future<void> synchronize() async {
    if (_synchronizing) {
      _synchronizeAgain = true;
      return;
    }
    _synchronizing = true;
    try {
      do {
        _synchronizeAgain = false;
        try {
          // Startup/install invalidations rebuild durable receipt/history data.
          // Potentially slow SAF verification starts only when Library UI asks
          // for it, never before runApp or merely because a Worker completed.
          await _repository.synchronize();
        } catch (error, stack) {
          debugPrint(
            'Installation library synchronization failed: $error\n$stack',
          );
        }
      } while (_synchronizeAgain);
    } finally {
      _synchronizing = false;
    }
  }
}
