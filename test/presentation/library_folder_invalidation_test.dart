import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/installation_library.dart';
import 'package:sm64cdpy/domain/repositories/installation_library_repository.dart';
import 'package:sm64cdpy/presentation/providers/installation_library_provider.dart';
import 'package:sm64cdpy/services/mod_installer.dart';

const before = InstallationLibrarySnapshot(
  receipts: [],
  history: [],
  issues: [],
);
const after = InstallationLibrarySnapshot(
  receipts: [],
  history: [],
  issues: [],
  discoveryTruncated: true,
);

class SlowLibrary implements InstallationLibraryRepository {
  int reads = 0;
  final oldResult = Completer<InstallationLibrarySnapshot>();
  final newResult = Completer<InstallationLibrarySnapshot>();
  @override
  Future<InstallationLibrarySnapshot> synchronize() async => before;
  @override
  Future<InstallationLibrarySnapshot> verifyAll() async {
    reads++;
    if (reads == 1) return before;
    return reads == 2 ? oldResult.future : newResult.future;
  }

  @override
  Future<InstallationLibrarySnapshot> discover({bool force = false}) async =>
      before;
  @override
  Future<InstallationLibrarySnapshot> verifyArtifact(
    String artifactKey,
  ) async => before;
  @override
  Future<InstallationLibrarySnapshot?> readCached() async => before;
  @override
  Future<InstallationLibrarySnapshot> clearHistory() async => before;
  @override
  Future<InstallationLibrarySnapshot> forgetContent(String contentKey) async =>
      before;
  @override
  Future<InstallationLibrarySnapshot> removeHistoryEvent(
    String workerId,
  ) async => before;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'changing folders drops the old projection and ignores its pending verification',
    () async {
      final repo = SlowLibrary();
      final container = ProviderContainer(
        overrides: [
          installationLibraryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      await container.read(installationLibraryProvider.future);
      final refreshing = container
          .read(installationLibraryProvider.notifier)
          .refresh();
      await Future<void>.delayed(Duration.zero);
      ModInstaller.invalidateInstallationLibrary('gameFolderChanged');
      await Future<void>.delayed(Duration.zero);
      expect(container.read(installationLibraryProvider).isLoading, isTrue);
      // Riverpod retains previous data during loading. Consumers must choose
      // the loading branch instead of rendering that retained projection.
      expect(
        container
            .read(installationLibraryProvider)
            .when(
              skipLoadingOnRefresh: false,
              skipLoadingOnReload: false,
              loading: () => 'loading',
              error: (_, _) => 'error',
              data: (_) => 'data',
            ),
        'loading',
      );
      repo.oldResult.complete(before);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(installationLibraryProvider).isLoading, isTrue);
      repo.newResult.complete(after);
      await refreshing;
      expect(
        container.read(installationLibraryProvider).value!.snapshot,
        same(after),
      );
      container.dispose();
    },
  );
}
