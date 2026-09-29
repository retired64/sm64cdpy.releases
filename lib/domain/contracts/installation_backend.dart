import '../entities/install_identity.dart';
import 'platform_capabilities.dart';

enum InstallationDestination {
  mods('mods'),
  dynos('dynos');

  const InstallationDestination(this.wireName);

  final String wireName;
}

sealed class InstallationSource {
  const InstallationSource();
}

class RemoteInstallationSource extends InstallationSource {
  const RemoteInstallationSource({
    required this.resolvedUri,
    required this.fileName,
  });

  /// Final URI after the shared indirect-download resolver has run.
  final Uri resolvedUri;
  final String fileName;
}

class LocalInstallationSource extends InstallationSource {
  const LocalInstallationSource({required this.absolutePath});

  final String absolutePath;
}

class InstallationRequest {
  const InstallationRequest({
    required this.identity,
    required this.source,
    required this.destination,
    required this.targetName,
    required this.displayTitle,
  });

  final InstallIdentity identity;
  final InstallationSource source;
  final InstallationDestination destination;

  /// Sanitized final directory or filename selected by the caller.
  final String targetName;
  final String displayTitle;
}

enum InstallationOperationStatus {
  requested,
  pending,
  downloading,
  installing,
  completed,
  failed,
  cancelling,
  cancelled;

  bool get isTerminal => switch (this) {
    completed || failed || cancelled => true,
    _ => false,
  };

  bool get isActive => !isTerminal;
}

class InstallationOperationSnapshot {
  const InstallationOperationSnapshot({
    required this.operationId,
    required this.request,
    required this.status,
    this.progress,
    this.current,
    this.total,
    this.targetPath,
    this.error,
  }) : assert(progress == null || (progress >= 0 && progress <= 100)),
       assert(current == null || current >= 0),
       assert(total == null || total >= 0),
       assert(
         status != InstallationOperationStatus.failed || error != null,
         'A failed operation must explain its error.',
       ),
       assert(
         status != InstallationOperationStatus.completed || targetPath != null,
         'A completed installation must report its target path.',
       );

  final String operationId;
  final InstallationRequest request;
  final InstallationOperationStatus status;
  final int? progress;
  final int? current;
  final int? total;
  final String? targetPath;
  final String? error;
}

/// Platform-neutral boundary for download and installation operations.
///
/// Android will adapt MethodChannel, WorkManager and SAF to this interface.
/// Linux will implement the same semantics using its operation journal,
/// filesystem staging and atomic publication. The interface does not pretend
/// those mechanisms are equivalent; only their observable product contract is
/// shared.
abstract interface class InstallationBackend {
  PlatformCapabilities get capabilities;

  /// Ordered state changes for every operation owned by this backend.
  Stream<InstallationOperationSnapshot> get events;

  /// Accepts a new operation and returns its first durable/observable state.
  Future<InstallationOperationSnapshot> start(InstallationRequest request);

  /// Requests cancellation and resolves only after a terminal state is known.
  Future<InstallationOperationSnapshot> cancel(String operationId);

  /// Reconstructs known non-terminal work after the application starts.
  Future<List<InstallationOperationSnapshot>> reconcile();
}
