import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/contracts/installation_backend.dart';
import 'package:sm64cdpy/domain/contracts/platform_capabilities.dart';
import 'package:sm64cdpy/domain/entities/install_identity.dart';

void main() {
  late _FakeInstallationBackend backend;

  setUp(() {
    backend = _FakeInstallationBackend();
  });

  tearDown(() async {
    await backend.close();
  });

  test('a backend can expose the complete shared success sequence', () async {
    final request = _request();
    final events = <InstallationOperationStatus>[];
    final subscription = backend.events.listen(
      (snapshot) => events.add(snapshot.status),
    );

    final accepted = await backend.start(request);
    expect(accepted.status, InstallationOperationStatus.pending);

    await backend.complete(accepted.operationId);
    await subscription.cancel();

    expect(events, [
      InstallationOperationStatus.pending,
      InstallationOperationStatus.downloading,
      InstallationOperationStatus.installing,
      InstallationOperationStatus.completed,
    ]);
    expect(backend.activeOperations, isEmpty);
  });

  test('cancellation resolves only after cancelled is terminal', () async {
    final accepted = await backend.start(_request());
    final terminal = await backend.cancel(accepted.operationId);

    expect(terminal.status, InstallationOperationStatus.cancelled);
    expect(terminal.status.isTerminal, isTrue);
    expect(backend.activeOperations, isEmpty);
  });

  test('reconciliation returns only active operations', () async {
    final first = await backend.start(_request(contentId: 'first'));
    final second = await backend.start(_request(contentId: 'second'));
    await backend.cancel(first.operationId);

    final restored = await backend.reconcile();

    expect(restored, hasLength(1));
    expect(restored.single.operationId, second.operationId);
    expect(restored.single.status.isActive, isTrue);
  });

  test('platform capabilities do not claim Android features on Linux', () {
    expect(PlatformCapabilities.android.usesSaf, isTrue);
    expect(PlatformCapabilities.android.supportsFloatingOverlay, isTrue);
    expect(PlatformCapabilities.android.supportsApkOta, isTrue);

    expect(PlatformCapabilities.linuxMvp.usesXdgPaths, isTrue);
    expect(
      PlatformCapabilities.linuxMvp.supportsOsBackgroundExecution,
      isFalse,
    );
    expect(PlatformCapabilities.linuxMvp.survivesProcessTermination, isFalse);
    expect(PlatformCapabilities.linuxMvp.supportsFloatingOverlay, isFalse);
    expect(PlatformCapabilities.linuxMvp.supportsApkOta, isFalse);
  });
}

InstallationRequest _request({String contentId = '42'}) {
  const url = 'https://example.invalid/mod.zip';
  return InstallationRequest(
    identity: InstallIdentity.forCatalogArtifact(
      section: InstallSection.mods,
      contentId: contentId,
      downloadUrl: url,
      versionLabel: '1.0.0',
      fileName: 'mod.zip',
    ),
    source: RemoteInstallationSource(
      resolvedUri: Uri.parse(url),
      fileName: 'mod.zip',
    ),
    destination: InstallationDestination.mods,
    targetName: 'sample-mod',
    displayTitle: 'Sample mod',
  );
}

class _FakeInstallationBackend implements InstallationBackend {
  final _events = StreamController<InstallationOperationSnapshot>.broadcast(
    sync: true,
  );
  final _operations = <String, InstallationOperationSnapshot>{};
  var _nextId = 0;

  @override
  PlatformCapabilities get capabilities => PlatformCapabilities.linuxMvp;

  @override
  Stream<InstallationOperationSnapshot> get events => _events.stream;

  Iterable<InstallationOperationSnapshot> get activeOperations =>
      _operations.values.where((operation) => operation.status.isActive);

  @override
  Future<InstallationOperationSnapshot> start(
    InstallationRequest request,
  ) async {
    final snapshot = InstallationOperationSnapshot(
      operationId: 'fake-${_nextId++}',
      request: request,
      status: InstallationOperationStatus.pending,
    );
    _publish(snapshot);
    return snapshot;
  }

  Future<void> complete(String operationId) async {
    final operation = _operations[operationId]!;
    _publish(
      InstallationOperationSnapshot(
        operationId: operationId,
        request: operation.request,
        status: InstallationOperationStatus.downloading,
        progress: 50,
      ),
    );
    _publish(
      InstallationOperationSnapshot(
        operationId: operationId,
        request: operation.request,
        status: InstallationOperationStatus.installing,
        current: 1,
        total: 2,
      ),
    );
    _publish(
      InstallationOperationSnapshot(
        operationId: operationId,
        request: operation.request,
        status: InstallationOperationStatus.completed,
        targetPath: '/tmp/sample-mod',
      ),
    );
  }

  @override
  Future<InstallationOperationSnapshot> cancel(String operationId) async {
    final operation = _operations[operationId]!;
    _publish(
      InstallationOperationSnapshot(
        operationId: operationId,
        request: operation.request,
        status: InstallationOperationStatus.cancelling,
      ),
    );
    final terminal = InstallationOperationSnapshot(
      operationId: operationId,
      request: operation.request,
      status: InstallationOperationStatus.cancelled,
    );
    _publish(terminal);
    return terminal;
  }

  @override
  Future<List<InstallationOperationSnapshot>> reconcile() async =>
      List.unmodifiable(activeOperations);

  void _publish(InstallationOperationSnapshot snapshot) {
    _operations[snapshot.operationId] = snapshot;
    _events.add(snapshot);
  }

  Future<void> close() => _events.close();
}
