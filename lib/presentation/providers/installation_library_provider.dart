import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/installation_library_repository_impl.dart';
import '../../domain/entities/installation_library.dart';
import '../../domain/repositories/installation_library_repository.dart';
import '../../services/background_install_service.dart';
import '../../services/mod_installer.dart';

enum InstallationLibraryLoadStatus { ready, partial }

class InstallationLibraryState {
  const InstallationLibraryState({
    required this.status,
    required this.snapshot,
  });

  final InstallationLibraryLoadStatus status;
  final InstallationLibrarySnapshot snapshot;
}

final installationLibraryRepositoryProvider =
    Provider<InstallationLibraryRepository>(
      (ref) => InstallationLibraryRepositoryImpl(),
    );

class InstallationLibraryNotifier
    extends AsyncNotifier<InstallationLibraryState> {
  StreamSubscription<BgInstallEvent>? _installSubscription;
  StreamSubscription<String>? _settingsSubscription;
  bool _refreshing = false;
  bool _refreshRequested = false;
  bool _discoveryRequested = false;
  bool _forceDiscoveryRequested = false;

  @override
  Future<InstallationLibraryState> build() async {
    _installSubscription = BackgroundInstallService.instance.events.listen((
      event,
    ) {
      if (event is BgInstallCompleted) unawaited(refresh());
    });
    _settingsSubscription = ModInstaller.libraryInvalidations.listen((reason) {
      final folderChanged =
          reason.contains('FolderChanged') || reason.contains('FolderCleared');
      unawaited(
        refresh(discover: folderChanged, forceDiscovery: folderChanged),
      );
    });
    ref.onDispose(() {
      _installSubscription?.cancel();
      _settingsSubscription?.cancel();
    });
    _refreshing = true;
    try {
      InstallationLibraryState next;
      do {
        _refreshRequested = false;
        final discover = _discoveryRequested;
        final forceDiscovery = _forceDiscoveryRequested;
        _discoveryRequested = false;
        _forceDiscoveryRequested = false;
        next = await _load(discover: discover, forceDiscovery: forceDiscovery);
      } while (_refreshRequested);
      return next;
    } finally {
      _refreshing = false;
    }
  }

  Future<InstallationLibraryState> _load({
    bool discover = false,
    bool forceDiscovery = false,
  }) async {
    // Scanning while WorkManager is writing could misclassify a partial mod as
    // external. Receipt reconciliation after completion is authoritative, so
    // defer discovery until no installation is active.
    if (discover && BackgroundInstallService.instance.activeInstalls.isEmpty) {
      await ref
          .read(installationLibraryRepositoryProvider)
          .discover(force: forceDiscovery);
    }
    final snapshot = await ref
        .read(installationLibraryRepositoryProvider)
        .verifyAll();
    return InstallationLibraryState(
      status: snapshot.isPartial
          ? InstallationLibraryLoadStatus.partial
          : InstallationLibraryLoadStatus.ready,
      snapshot: snapshot,
    );
  }

  Future<void> verifyArtifact(String artifactKey) async {
    if (!ref.mounted) return;
    state = await AsyncValue.guard(() async {
      final snapshot = await ref
          .read(installationLibraryRepositoryProvider)
          .verifyArtifact(artifactKey);
      return InstallationLibraryState(
        status: snapshot.isPartial
            ? InstallationLibraryLoadStatus.partial
            : InstallationLibraryLoadStatus.ready,
        snapshot: snapshot,
      );
    });
  }

  Future<void> refresh({
    bool discover = false,
    bool forceDiscovery = false,
  }) async {
    if (!ref.mounted) return;
    if (_refreshing) {
      _refreshRequested = true;
      _discoveryRequested = _discoveryRequested || discover;
      _forceDiscoveryRequested = _forceDiscoveryRequested || forceDiscovery;
      return;
    }
    _refreshing = true;
    var pendingDiscover = discover;
    var pendingForceDiscovery = forceDiscovery;
    try {
      do {
        _refreshRequested = false;
        final shouldDiscover = pendingDiscover || _discoveryRequested;
        final shouldForceDiscovery =
            pendingForceDiscovery || _forceDiscoveryRequested;
        pendingDiscover = false;
        pendingForceDiscovery = false;
        _discoveryRequested = false;
        _forceDiscoveryRequested = false;
        final next = await AsyncValue.guard(
          () => _load(
            discover: shouldDiscover,
            forceDiscovery: shouldForceDiscovery,
          ),
        );
        if (ref.mounted) state = next;
      } while (_refreshRequested && ref.mounted);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> clearHistory() async {
    state = const AsyncLoading<InstallationLibraryState>();
    state = await AsyncValue.guard(() async {
      final snapshot = await ref
          .read(installationLibraryRepositoryProvider)
          .clearHistory();
      return InstallationLibraryState(
        status: snapshot.isPartial
            ? InstallationLibraryLoadStatus.partial
            : InstallationLibraryLoadStatus.ready,
        snapshot: snapshot,
      );
    });
  }

  Future<void> forgetContent(String contentKey) => _mutate(
    () => ref
        .read(installationLibraryRepositoryProvider)
        .forgetContent(contentKey),
  );

  Future<void> removeHistoryEvent(String workerId) => _mutate(
    () => ref
        .read(installationLibraryRepositoryProvider)
        .removeHistoryEvent(workerId),
  );

  Future<void> _mutate(
    Future<InstallationLibrarySnapshot> Function() operation,
  ) async {
    final previous = state;
    state = const AsyncLoading<InstallationLibraryState>();
    try {
      final snapshot = await operation();
      if (!ref.mounted) return;
      state = AsyncData(
        InstallationLibraryState(
          status: snapshot.isPartial
              ? InstallationLibraryLoadStatus.partial
              : InstallationLibraryLoadStatus.ready,
          snapshot: snapshot,
        ),
      );
    } catch (_) {
      if (ref.mounted) state = previous;
      rethrow;
    }
  }
}

final installationLibraryProvider =
    AsyncNotifierProvider<
      InstallationLibraryNotifier,
      InstallationLibraryState
    >(InstallationLibraryNotifier.new);
