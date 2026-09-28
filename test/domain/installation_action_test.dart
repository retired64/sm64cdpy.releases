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

  test('external discovery never changes a catalog action without receipt', () {
    final state = InstallationActionSelector.select(
      identity: identity,
      operation: null,
      library: InstallationLibrarySnapshot(
        receipts: const [],
        history: const [],
        issues: const [],
        discoveries: [
          DiscoveredInstallation(
            discoveryKey: 'external-1',
            destination: 'mods',
            entryPath: 'same-title/main.lua',
            displayName: 'Same catalogue title',
            sourceType: 'folder',
            confidence: InstallationDiscoveryConfidence.exact,
            detectedAt: DateTime.utc(2026, 9, 26),
          ),
        ],
      ),
      libraryLoading: false,
    );

    expect(state.primaryAction, InstallationPrimaryAction.download);
    expect(state.receipt, isNull);
  });

  test('SAF states map to conservative actions', () {
    final expected = {
      InstallationVerificationStatus.missing: InstallationPrimaryAction.install,
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

  test(
    'older selected version is install, not reinstall, while content exists',
    () {
      final newerIdentity = InstallIdentity.forCatalogArtifact(
        section: InstallSection.mods,
        contentId: 'content-1',
        downloadUrl: 'https://example.test/version/3?file=1',
        versionLabel: 'v3.0',
        explicitVersionId: '3',
        explicitFileId: '1',
      );
      final value = installationReceiptFixture(
        artifactKey: newerIdentity.artifactKey,
      );
      (value['displaySnapshot'] as Map<String, dynamic>)['versionLabel'] =
          'v3.0';
      final newerReceipt = InstallationRecord.fromMap(value);
      final snapshot = InstallationLibrarySnapshot(
        receipts: [newerReceipt],
        history: const [],
        issues: const [],
        verifications: {
          newerIdentity.artifactKey: InstallationVerification(
            artifactKey: newerIdentity.artifactKey,
            status: InstallationVerificationStatus.present,
            verifiedAt: DateTime.utc(2026, 9, 27),
          ),
        },
      );

      final state = InstallationActionSelector.select(
        identity: identity,
        operation: null,
        library: snapshot,
        libraryLoading: false,
      );

      expect(state.primaryAction, InstallationPrimaryAction.install);
      expect(state.canReinstall, isFalse);
    },
  );

  test('version policy orders numeric versions and only equates prose', () {
    expect(InstallationVersionPolicy.compare('v1.9', 'v2.0'), greaterThan(0));
    expect(InstallationVersionPolicy.compare('release', 'RELEASE'), 0);
    expect(InstallationVersionPolicy.compare('alpha', 'beta'), isNull);
    expect(
      InstallationVersionPolicy.isReliableUpgrade('v2.0', 'v1.9'),
      isFalse,
    );
  });
}
