import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/install_identity.dart';
import 'package:sm64cdpy/domain/entities/installation_catalog.dart';
import 'package:sm64cdpy/domain/entities/installation_library.dart';

import '../helpers/installation_receipt_fixture.dart';

void main() {
  InstallationRecord receipt({
    String artifactKey = 'v1|mods|content-1|old',
    String version = 'v1.0',
    String filename = 'sample.zip',
  }) {
    final map = installationReceiptFixture(artifactKey: artifactKey);
    (map['displaySnapshot'] as Map<String, dynamic>)
      ..['versionLabel'] = version
      ..['filename'] = filename;
    return InstallationRecord.fromMap(map);
  }

  InstallationCatalogTarget target({
    required String url,
    required String version,
    String? filename,
    String? fileId,
  }) => InstallationCatalogTarget(
    identity: InstallIdentity.forCatalogArtifact(
      section: InstallSection.mods,
      contentId: 'content-1',
      downloadUrl: url,
      versionLabel: version,
      fileName: filename,
      explicitFileId: fileId,
    ),
    title: 'Sample',
    route: '/mod/content-1',
  );

  test('reports a verified unambiguous canonical update', () {
    final installed = receipt();
    final library = InstallationLibrarySnapshot(
      receipts: [installed],
      history: const [],
      issues: const [],
      verifications: {
        installed.artifactKey: InstallationVerification(
          artifactKey: installed.artifactKey,
          status: InstallationVerificationStatus.present,
          verifiedAt: DateTime.utc(2026, 9, 27),
        ),
      },
    );

    final updates = InstallationCatalogMatcher.updates(
      library: library,
      targets: [
        target(
          url: 'https://example.test/new.zip',
          version: 'v2.0',
          filename: 'sample.zip',
          fileId: 'new',
        ),
      ],
    );

    expect(updates, hasLength(1));
    expect(updates.single.installed, same(installed));
  });

  test('does not guess between ambiguous multi-file variants', () {
    final installed = receipt(filename: 'legacy.zip');
    final library = InstallationLibrarySnapshot(
      receipts: [installed],
      history: const [],
      issues: const [],
      verifications: {
        installed.artifactKey: InstallationVerification(
          artifactKey: installed.artifactKey,
          status: InstallationVerificationStatus.present,
          verifiedAt: DateTime.utc(2026, 9, 27),
        ),
      },
    );

    final updates = InstallationCatalogMatcher.updates(
      library: library,
      targets: [
        target(
          url: 'https://example.test/a.zip',
          version: 'v2.0',
          filename: 'a.zip',
          fileId: 'a',
        ),
        target(
          url: 'https://example.test/b.zip',
          version: 'v2.0',
          filename: 'b.zip',
          fileId: 'b',
        ),
      ],
    );

    expect(updates, isEmpty);
  });

  test('missing receipt is not advertised as an update', () {
    final installed = receipt();
    final library = InstallationLibrarySnapshot(
      receipts: [installed],
      history: const [],
      issues: const [],
      verifications: {
        installed.artifactKey: InstallationVerification(
          artifactKey: installed.artifactKey,
          status: InstallationVerificationStatus.missing,
          verifiedAt: DateTime.utc(2026, 9, 27),
        ),
      },
    );

    expect(
      InstallationCatalogMatcher.updates(
        library: library,
        targets: [
          target(
            url: 'https://example.test/new.zip',
            version: 'v2.0',
            filename: 'sample.zip',
            fileId: 'new',
          ),
        ],
      ),
      isEmpty,
    );
  });
}
