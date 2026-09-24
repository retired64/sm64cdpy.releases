import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/install_identity.dart';
import 'package:sm64cdpy/domain/entities/dynos_entity.dart';
import 'package:sm64cdpy/overlay/overlay_sections.dart';

void main() {
  group('InstallIdentity', () {
    test('uses stable source version and file ids when available', () {
      final identity = InstallIdentity.forCatalogArtifact(
        section: InstallSection.mods,
        contentId: 7,
        downloadUrl:
            'https://mods.sm64coopdx.com/mods/example.7/version/42/download?file=18',
        versionLabel: 'v1.0',
        fileName: 'mod.zip',
      );

      expect(identity.contentKey, 'v1|mods|7');
      expect(identity.artifactId, 'version:42:file:18');
      expect(identity.operationKey, 'v1|mods|7|version%3A42%3Afile%3A18');
    });

    test('falls back to a deterministic digest independent of title', () {
      final first = InstallIdentity.forCatalogArtifact(
        section: InstallSection.dynos,
        contentId: 'same-id',
        downloadUrl: 'https://example.test/releases/mod.zip',
        versionLabel: 'Alpha',
        fileName: 'mod.zip',
      );
      final second = InstallIdentity.forCatalogArtifact(
        section: InstallSection.dynos,
        contentId: 'same-id',
        downloadUrl: 'https://example.test/releases/mod.zip',
        versionLabel: 'Alpha',
        fileName: 'mod.zip',
      );

      expect(first, second);
      expect(
        first.artifactId,
        'sha256:a02c12b3e9ed2ebf233b6d09be6f60a0291b3432d62ec3a4c32c7ef6ad047620',
      );
    });

    test('same title or filename cannot collide across catalogue ids', () {
      InstallIdentity build(String id) => InstallIdentity.forCatalogArtifact(
        section: InstallSection.mods,
        contentId: id,
        downloadUrl: 'https://example.test/mod.zip',
        fileName: 'mod.zip',
      );

      expect(build('425').operationKey, isNot(build('1033').operationKey));
    });

    test('same destination does not merge DynOS and Touch Controls', () {
      InstallIdentity build(InstallSection section) =>
          InstallIdentity.forCatalogArtifact(
            section: section,
            contentId: 'shared',
            downloadUrl: 'https://example.test/pack.zip',
            fileName: 'pack.zip',
          );

      expect(
        build(InstallSection.dynos).operationKey,
        isNot(build(InstallSection.touchControls).operationKey),
      );
    });

    test('encodes delimiters and Unicode as RFC 3986 components', () {
      final identity = InstallIdentity.forCatalogArtifact(
        section: InstallSection.vip,
        contentId: 'id|con espacio/ñ',
        downloadUrl: 'https://example.test/mod.zip',
      );

      expect(identity.contentKey, 'v1|vip|id%7Ccon%20espacio%2F%C3%B1');
    });

    test('round trips its persisted map and rejects tampered keys', () {
      final identity = InstallIdentity.forCatalogArtifact(
        section: InstallSection.render96,
        contentId: 'render96-v4',
        downloadUrl: 'https://example.test/render.7z',
        versionLabel: '4.0',
        fileName: 'render.7z',
      );
      expect(InstallIdentity.fromMap(identity.toMap()), identity);

      final tampered = {...identity.toMap(), 'contentKey': 'v1|mods|wrong'};
      expect(() => InstallIdentity.fromMap(tampered), throwsFormatException);
    });

    test('catalogue reordering does not participate in identity', () {
      final before = InstallIdentity.forCatalogArtifact(
        section: InstallSection.mods,
        contentId: 12,
        downloadUrl:
            'https://mods.sm64coopdx.com/mods/example.12/version/315/download',
        versionLabel: 'v1.2',
        fileName: 'example.zip',
      );
      final after = InstallIdentity.forCatalogArtifact(
        section: InstallSection.mods,
        contentId: 12,
        downloadUrl:
            'https://mods.sm64coopdx.com/mods/example.12/version/315/download',
        versionLabel: 'v1.2',
        fileName: 'example.zip',
      );

      expect(before.operationKey, after.operationKey);
      expect(before.operationKey, isNot(contains('version-0-file-0')));
    });

    test('main app and overlay derive the same identity', () {
      const mod = DynosEntity(
        id: 'pack-1',
        title: 'Shared title',
        version: 'Alpha',
        author: 'Fixture',
        description: '',
        downloadUrl: 'https://example.test/dynos/pack.zip',
        tags: [],
        ratingCount: 0,
        addedAt: '',
      );
      final appIdentity = InstallIdentity.forCatalogArtifact(
        section: InstallSection.dynos,
        contentId: mod.id,
        downloadUrl: mod.downloadUrl,
        versionLabel: mod.version,
      );
      final overlayItem = OverlayModItem.fromDynos(mod);
      final overlayIdentity = overlayItem.identityFor(
        overlayItem.downloadOptions.single,
      );

      expect(overlayIdentity.operationKey, appIdentity.operationKey);
      expect(overlayIdentity.contentKey, appIdentity.contentKey);
    });
  });
}
