import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/download_source_preference_service.dart';

class DownloadSourcePreferenceNotifier
    extends AsyncNotifier<DownloadSourcePreference> {
  @override
  Future<DownloadSourcePreference> build() =>
      DownloadSourcePreferenceService.read();

  Future<bool> setPreference(DownloadSourcePreference preference) async {
    if (state.isLoading || state.value == preference) return !state.isLoading;
    final previous = state;
    state = const AsyncLoading<DownloadSourcePreference>();
    try {
      await DownloadSourcePreferenceService.write(preference);
      if (ref.mounted) state = AsyncData(preference);
      return true;
    } catch (error, stack) {
      debugPrint('Failed to save download source preference: $error\n$stack');
      if (ref.mounted) state = previous;
      return false;
    }
  }
}

final downloadSourcePreferenceProvider =
    AsyncNotifierProvider<
      DownloadSourcePreferenceNotifier,
      DownloadSourcePreference
    >(DownloadSourcePreferenceNotifier.new);
