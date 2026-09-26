import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/install_identity.dart';
import 'package:sm64cdpy/domain/entities/installation_action.dart';
import 'package:sm64cdpy/domain/entities/installation_library.dart';
import 'package:sm64cdpy/services/background_install_service.dart';

import '../helpers/installation_receipt_fixture.dart';

void main() {
  final identity = InstallIdentity.forCatalogArtifact(
    section: InstallSection.mods,
    contentId: 'content-1',
    downloadUrl: 'https://example.test/version/1?file=1',
    versionLabel: 'v2.0',
    explicitVersionId: '1',
    explicitFileId: '1',
  );

  InstallationRecord receipt({String version = 'v1.0'}) {
    final value = installationReceiptFixture(artifactKey: identity.artifactKey);
    (value['displaySnapshot'] as Map<String, dynamic>)['versionLabel'] =
        version;
    return InstallationRecord.fromMap(value);
  }

  InstallationLibrarySnapshot library(
    InstallationRecord record, {
    InstallationVerificationStatus? status,
  }) => InstallationLibrarySnapshot(
    receipts: [record],
    history: const [],
    issues: const [],
    verifications: status == null
        ? const {}
        : {
            identity.artifactKey: InstallationVerification(
              artifactKey: identity.artifactKey,
              status: status,
              verifiedAt: DateTime.utc(2026, 9, 25),
            ),
          },
  );

  test('active WorkManager operation wins and exposes progress', () {
    final state = InstallationActionSelector.select(
      identity: identity,
      operation: BgInstallInfo(
        modName: identity.operationKey,
        status: BgInstallStatus.downloading,
        downloadProgress: 42,
      ),
      library: library(
        receipt(),
        status: InstallationVerificationStatus.present,
      ),
      libraryLoading: false,
    );
    expect(state.primaryAction, InstallationPrimaryAction.cancel);
    expect(state.progress, .42);
  });

  test('absence of receipt means download even after transient completion', () {
    final state = InstallationActionSelector.select(
      identity: identity,
      operation: BgInstallInfo(
        modName: identity.operationKey,
        status: BgInstallStatus.completed,
      ),
      library: const InstallationLibrarySnapshot(
        receipts: [],
        history: [],
        issues: [],
      ),
      libraryLoading: false,
    );
    expect(state.primaryAction, InstallationPrimaryAction.download);
  });

  test('SAF states map to conservative actions', () {
    final expected = {
      InstallationVerificationStatus.missing:
          InstallationPrimaryAction.reinstall,
      InstallationVerificationStatus.unknown: InstallationPrimaryAction.verify,
      InstallationVerificationStatus.folderNotSelected:
          InstallationPrimaryAction.selectFolder,
      InstallationVerificationStatus.permissionRevoked:
          InstallationPrimaryAction.selectFolder,
    };
    for (final entry in expected.entries) {
      final state = InstallationActionSelector.select(
        identity: identity,
        operation: null,
        library: library(receipt(), status: entry.key),
        libraryLoading: false,
      );
      expect(state.primaryAction, entry.value);
    }
  });

  test('present receipt only updates for a reliably newer numeric version', () {
    final update = InstallationActionSelector.select(
      identity: identity,
      operation: null,
      library: library(
        receipt(),
        status: InstallationVerificationStatus.present,
      ),
      libraryLoading: false,
    );
    expect(update.primaryAction, InstallationPrimaryAction.update);

    for (final installedVersion in ['release one', 'v3.0', 'v2.0-beta']) {
      final state = InstallationActionSelector.select(
        identity: identity,
        operation: null,
        library: library(
          receipt(version: installedVersion),
          status: InstallationVerificationStatus.present,
        ),
        libraryLoading: false,
      );
      expect(state.primaryAction, InstallationPrimaryAction.installed);
      expect(state.canReinstall, isTrue);
    }
  });

  test('new artifact can update a verified older artifact of same content', () {
    final olderIdentity = InstallIdentity.forCatalogArtifact(
      section: InstallSection.mods,
      contentId: 'content-1',
      downloadUrl: 'https://example.test/version/0?file=1',
      versionLabel: 'v1.0',
      explicitVersionId: '0',
      explicitFileId: '1',
    );
    final value = installationReceiptFixture(
      artifactKey: olderIdentity.artifactKey,
    );
    (value['displaySnapshot'] as Map<String, dynamic>)['versionLabel'] = 'v1.0';
    final oldReceipt = InstallationRecord.fromMap(value);
    final snapshot = InstallationLibrarySnapshot(
      receipts: [oldReceipt],
      history: const [],
      issues: const [],
      verifications: {
        olderIdentity.artifactKey: InstallationVerification(
          artifactKey: olderIdentity.artifactKey,
          status: InstallationVerificationStatus.present,
          verifiedAt: DateTime.utc(2026, 9, 25),
        ),
      },
    );

    final state = InstallationActionSelector.select(
      identity: identity,
      operation: null,
      library: snapshot,
      libraryLoading: false,
    );

    expect(state.primaryAction, InstallationPrimaryAction.update);
    expect(state.verification?.artifactKey, olderIdentity.artifactKey);
  });
}
