import '../entities/installation_library.dart';

abstract interface class InstallationLibraryRepository {
  Future<InstallationLibrarySnapshot> synchronize();
  Future<InstallationLibrarySnapshot> verifyAll();
  Future<InstallationLibrarySnapshot> verifyArtifact(String artifactKey);
  Future<InstallationLibrarySnapshot?> readCached();
  Future<InstallationLibrarySnapshot> clearHistory();
}
