import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/install_identity.dart';
import 'package:sm64cdpy/domain/entities/omm_rebirth_entity.dart';
import 'package:sm64cdpy/overlay/overlay_sections.dart';

void main() {
  test(
    'general catalog overlay uses the same explicit file key as details',
    () {
      const item = OverlayModItem(
        id: '418',
        title: 'Sample',
        downloadOptions: [
          OverlayDownloadOption(
            url: 'https://example.test/sample.zip',
            filename: 'sample.zip',
            fileKey: 'version-0-file-2',
            versionLabel: 'v2.0',
          ),
        ],
        section: OverlaySection.all,
        installDestination: 'mods',
      );

      final identity = item.identityFor(item.downloadOptions.single);

      expect(identity.artifactId, 'file:version-0-file-2');
      expect(identity.artifactKey, endsWith('|file%3Aversion-0-file-2'));
    },
  );

  test('OMM app and overlay retain the same versioned identity', () {
    const mod = OmmRebirthEntity(
      id: 'omm-sample',
      title: 'OMM Sample',
      version: 'v3.0',
      recommendedVersion: 'v3.0',
      author: 'Author',
      description: 'Description',
      downloadUrl: 'https://example.test/omm.zip',
      tags: [],
      ratingCount: 0,
      isFeatured: false,
      addedAt: '2026-09-27',
    );
    final overlay = OverlayModItem.fromOmm(mod);
    final overlayIdentity = overlay.identityFor(overlay.downloadOptions.single);
    final appIdentity = InstallIdentity.forCatalogArtifact(
      section: InstallSection.omm,
      contentId: mod.id,
      downloadUrl: mod.downloadUrl,
      versionLabel: mod.version,
    );

    expect(overlayIdentity.artifactKey, appIdentity.artifactKey);
  });
}
