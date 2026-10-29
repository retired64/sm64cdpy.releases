import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/presentation/providers/download_source_preference_provider.dart';
import 'package:sm64cdpy/services/download_source_preference_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults to origin and persists a mirror-first choice', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(downloadSourcePreferenceProvider.future),
      DownloadSourcePreference.originalFirst,
    );
    expect(
      await container
          .read(downloadSourcePreferenceProvider.notifier)
          .setPreference(DownloadSourcePreference.mirrorFirst),
      isTrue,
    );
    expect(
      container.read(downloadSourcePreferenceProvider).value,
      DownloadSourcePreference.mirrorFirst,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(AppConstants.downloadSourcePreferenceKey),
      DownloadSourcePreference.mirrorFirst.name,
    );
  });

  test('a new provider container restores the persisted choice', () async {
    await DownloadSourcePreferenceService.write(
      DownloadSourcePreference.mirrorFirst,
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(downloadSourcePreferenceProvider.future),
      DownloadSourcePreference.mirrorFirst,
    );
  });
}
