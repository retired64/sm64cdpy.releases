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

  @override
  Future<InstallationLibraryState> build() async {
    _installSubscription = BackgroundInstallService.instance.events.listen((
      event,
    ) {
      if (event is BgInstallCompleted) unawaited(refresh());
    });
    _settingsSubscription = ModInstaller.libraryInvalidations.listen((_) {
      unawaited(refresh());
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
        next = await _load();
      } while (_refreshRequested);
      return next;
    } finally {
      _refreshing = false;
    }
  }

  Future<InstallationLibraryState> _load() async {
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

  Future<void> refresh() async {
    if (!ref.mounted) return;
    if (_refreshing) {
      _refreshRequested = true;
      return;
    }
    _refreshing = true;
    try {
      do {
        _refreshRequested = false;
        final next = await AsyncValue.guard(_load);
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
}

final installationLibraryProvider =
    AsyncNotifierProvider<
      InstallationLibraryNotifier,
      InstallationLibraryState
    >(InstallationLibraryNotifier.new);
