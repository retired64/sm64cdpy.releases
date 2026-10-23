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
      if (mode == CoopSessionMode.join) await _remember(code);
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

  Future<List<String>> recentCodes() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getStringList(_recentKey) ?? const [];
  }

  Future<void> clearRecentCodes() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_recentKey);
  }

  Future<void> _remember(String code) async {
    final preferences = await SharedPreferences.getInstance();
    final previous = preferences.getStringList(_recentKey) ?? const [];
    await preferences.setStringList(
      _recentKey,
      [code, ...previous.where((item) => item != code)].take(4).toList(),
    );
  }
}
