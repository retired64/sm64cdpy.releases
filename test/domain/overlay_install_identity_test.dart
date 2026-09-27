import 'package:flutter_test/flutter_test.dart';
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
}
