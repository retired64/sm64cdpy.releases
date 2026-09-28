import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/services/update_config.dart';

void main() {
  group('UpdateConfig.fromGithubRelease', () {
    test('keeps force-update detection without exposing release notes', () {
      final config = UpdateConfig.fromGithubRelease({
        'tag_name': 'v1.8.1',
        'body': 'Public release notes live on the website.\n\n[FORCE]',
        'assets': [
          {
            'name': 'Sm64CDPYv1.8.1-arm64.apk',
            'browser_download_url': 'https://example.test/arm64.apk',
            'size': 42,
          },
        ],
      }, AbiType.arm64);

      expect(config.latestVersion, '1.8.1');
      expect(config.updateUrl, 'https://example.test/arm64.apk');
      expect(config.apkSize, 42);
      expect(config.forceUpdate, isTrue);
    });

    test('does not force a regular release', () {
      final config = UpdateConfig.fromGithubRelease({
        'tag_name': 'v1.8.1',
        'body': 'Release notes are available on sm64cdpy.org.',
        'assets': <Object?>[],
      }, AbiType.arm64);

      expect(config.forceUpdate, isFalse);
    });
  });
}
