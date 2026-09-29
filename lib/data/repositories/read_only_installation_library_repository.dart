import '../../domain/entities/installation_library.dart';
import '../../domain/repositories/installation_library_repository.dart';

/// Phase-1 Linux library implementation.
///
/// It deliberately exposes an empty snapshot instead of consulting Android's
/// MethodChannel. A filesystem-backed implementation replaces it in a later
/// phase; cached Android receipts are never presented as Linux evidence.
class ReadOnlyInstallationLibraryRepository
    implements InstallationLibraryRepository {
  static const _empty = InstallationLibrarySnapshot(
    receipts: [],
    history: [],
    issues: [],
  );

  @override
  Future<InstallationLibrarySnapshot> synchronize() async => _empty;

  @override
  Future<InstallationLibrarySnapshot> discover({bool force = false}) async =>
      _empty;

  @override
  Future<InstallationLibrarySnapshot> verifyAll() async => _empty;

  @override
  Future<InstallationLibrarySnapshot> verifyArtifact(
    String artifactKey,
  ) async => _empty;

  @override
  Future<InstallationLibrarySnapshot?> readCached() async => _empty;

  @override
  Future<InstallationLibrarySnapshot> clearHistory() async => _empty;

  @override
  Future<InstallationLibrarySnapshot> forgetContent(String contentKey) async =>
      _empty;

  @override
  Future<InstallationLibrarySnapshot> removeHistoryEvent(
    String workerId,
  ) async => _empty;
}
