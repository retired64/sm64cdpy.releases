import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/services/download_url_resolver.dart';
import 'package:sm64cdpy/services/download_source_preference_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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

  test('persisted R2 preference reverses the source order', () async {
    await DownloadSourcePreferenceService.write(
      DownloadSourcePreference.mirrorFirst,
    );
    final sources = await DownloadUrlResolver.instance.resolveDownloadSources(
      'https://example.test/mod.zip',
      availableMirrorUrl:
          'https://mods-cdn.sm64cdpy.org/mods/1/v1/main/mod.zip',
    );
    expect(sources, <String>[
      'https://mods-cdn.sm64cdpy.org/mods/1/v1/main/mod.zip',
      'https://example.test/mod.zip',
    ]);
  });

  test(
    'R2 preference falls back to origin when no mirror is available',
    () async {
      await DownloadSourcePreferenceService.write(
        DownloadSourcePreference.mirrorFirst,
      );
      expect(
        await DownloadUrlResolver.instance.resolveDownloadSources(
          'https://example.test/mod.zip',
        ),
        <String>['https://example.test/mod.zip'],
      );
    },
  );

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
