import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/services/download_url_resolver.dart';

void main() {
  test('keeps the origin first and adds one HTTPS mirror', () async {
    final sources = await DownloadUrlResolver.instance.resolveDownloadSources(
      'https://example.test/mod.zip',
      availableMirrorUrl:
          'https://mods-cdn.sm64cdpy.org/mods/1/v1/main/mod.zip',
    );
    expect(sources, <String>[
      'https://example.test/mod.zip',
      'https://mods-cdn.sm64cdpy.org/mods/1/v1/main/mod.zip',
    ]);
  });

  test('rejects non-HTTPS and duplicate fallback URLs', () async {
    final resolver = DownloadUrlResolver.instance;
    expect(
      await resolver.resolveDownloadSources(
        'https://example.test/mod.zip',
        availableMirrorUrl: 'http://mirror.test/mod.zip',
      ),
      <String>['https://example.test/mod.zip'],
    );
    expect(
      await resolver.resolveDownloadSources(
        'https://example.test/mod.zip',
        availableMirrorUrl: 'https://example.test/mod.zip',
      ),
      <String>['https://example.test/mod.zip'],
    );
  });
}
