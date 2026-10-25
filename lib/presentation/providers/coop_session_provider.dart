import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/coop_session.dart';
import '../../services/coop_session_service.dart';

final coopSessionServiceProvider = Provider(
  (ref) => const CoopSessionService(),
);
final coopSessionProvider =
    NotifierProvider<CoopSessionNotifier, CoopSessionState>(
      CoopSessionNotifier.new,
    );

class CoopSessionNotifier extends Notifier<CoopSessionState> {
  static const _recentKey = 'coop_recent_join_codes';
  static const _networkConsentKey = 'coop_network_consent';
  StreamSubscription<CoopSessionState>? _subscription;

  @override
  CoopSessionState build() {
    _subscription = ref
        .read(coopSessionServiceProvider)
        .events
        .listen(_accept, onError: _error);
    ref.onDispose(() => unawaited(_subscription?.cancel()));
    unawaited(_initialize());
    return const CoopSessionState();
  }

  Future<void> _initialize() async {
    final service = ref.read(coopSessionServiceProvider);
    try {
      final snapshot = await service.snapshot();
      final installed = await service.gameInstalled();
      _accept(snapshot.copyWith(gameInstalled: installed));
    } catch (error) {
      _error(error);
    }
  }

  void _accept(CoopSessionState next) {
    if (!ref.mounted || (state.initialized && next.revision < state.revision)) {
      return;
    }
    state = next.copyWith(
      gameInstalled: next.gameInstalled ?? state.gameInstalled,
    );
  }

  void _error(Object error) {
    if (!ref.mounted) return;
    state = CoopSessionState.fromMap({
      'phase': 'failed',
      'message': error is PlatformException ? error.message : error.toString(),
      'revision': state.revision + 1,
      'initialized': true,
      'gameInstalled': state.gameInstalled,
    });
  }

  Future<String> generateCode() =>
      ref.read(coopSessionServiceProvider).generateCode();

  Future<void> start(
    CoopSessionMode mode,
    String code, {
    bool relayOnly = false,
  }) async {
    try {
      _accept(
        await ref
            .read(coopSessionServiceProvider)
            .start(mode: mode, code: code, relayOnly: relayOnly),
      );
      if (mode == CoopSessionMode.join) {
        await _remember(normalizeCoopCode(code));
      }
    } catch (error) {
      _error(error);
    }
  }

  Future<void> stop() async {
    try {
      _accept(await ref.read(coopSessionServiceProvider).stop());
    } catch (error) {
      _error(error);
    }
  }

  Future<bool> openGame() => ref.read(coopSessionServiceProvider).openGame();

  Future<CoopBatteryOptimizationState> batteryOptimizationStatus() =>
      ref.read(coopSessionServiceProvider).batteryOptimizationStatus();

  Future<CoopBatteryOptimizationState> requestBatteryOptimizationExemption() =>
      ref
          .read(coopSessionServiceProvider)
          .requestBatteryOptimizationExemption();

  Future<CoopBatteryOptimizationState> openBatteryOptimizationSettings() =>
      ref.read(coopSessionServiceProvider).openBatteryOptimizationSettings();

  Future<List<String>> recentCodes() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_recentKey) ?? const [];
    final normalized = _normalizedRecent(stored);
    if (!_sameCodes(stored, normalized)) {
      await preferences.setStringList(_recentKey, normalized);
    }
    return normalized;
  }

  Future<void> clearRecentCodes() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_recentKey);
  }

  Future<bool> networkConsentAccepted() async {
    final preferences = await SharedPreferences.getInstance();
    return isValidCoopNetworkConsent(preferences.getString(_networkConsentKey));
  }

  Future<void> acceptNetworkConsent() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _networkConsentKey,
      encodeCoopNetworkConsent(),
    );
    if (!saved) throw StateError('Could not persist network consent');
  }

  Future<void> _remember(String code) async {
    final preferences = await SharedPreferences.getInstance();
    final previous = preferences.getStringList(_recentKey) ?? const [];
    await preferences.setStringList(
      _recentKey,
      _normalizedRecent([code, ...previous]),
    );
  }

  List<String> _normalizedRecent(Iterable<String> values) {
    final result = <String>[];
    for (final value in values) {
      final normalized = normalizeCoopCode(value);
      if (isValidCoopCode(normalized) && !result.contains(normalized)) {
        result.add(normalized);
      }
      if (result.length == 4) break;
    }
    return result;
  }

  bool _sameCodes(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}
