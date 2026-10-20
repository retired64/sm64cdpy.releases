import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/game_save_service.dart';
import 'game_folder_provider.dart';

final gameSaveServiceProvider = Provider((ref) => GameSaveService());
final gameSaveProvider = NotifierProvider<GameSaveNotifier, GameSaveState>(
  GameSaveNotifier.new,
);

class GameSaveState {
  const GameSaveState({
    this.data,
    this.busy = false,
    this.verified = false,
    this.error,
  });
  final Map<String, dynamic>? data;
  final bool busy;
  final bool verified;
  final String? error;
  bool get canMutate => data != null && verified && !busy && error == null;
}

class GameSaveNotifier extends Notifier<GameSaveState> {
  int _generation = 0;
  String? _connectionKey;
  @override
  GameSaveState build() {
    _connectionKey = ref.watch(
      gameFolderProvider.select((value) => value.connection.connectionKey),
    );
    _generation++;
    final cached = ref.read(gameSaveServiceProvider).readCached(_connectionKey);
    if (cached == null) return const GameSaveState();
    final generation = _generation;
    unawaited(
      Future<void>.delayed(
        Duration.zero,
      ).then((_) => _reconcileCached(generation)).catchError((Object _) {}),
    );
    return GameSaveState(data: cached, busy: true);
  }

  Future<void> _reconcileCached(int generation) async {
    try {
      final service = ref.read(gameSaveServiceProvider);
      final data = await service.read();
      if (!ref.mounted || generation != _generation) return;
      state = GameSaveState(data: data, verified: true);
      await _cacheSafely(service, data, generation);
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        state = GameSaveState(
          data: state.data,
          error: error is PlatformException ? error.code : 'access',
        );
      }
    }
  }

  Future<bool> run([Map<String, dynamic>? action]) async {
    if (state.busy) return false;
    final generation = _generation;
    final previous = state.data;
    state = GameSaveState(data: previous, busy: true, verified: state.verified);
    try {
      final service = ref.read(gameSaveServiceProvider);
      final data = action == null
          ? await service.read()
          : await service.change({
              'revision': previous?['revision'],
              'identity': previous?['identity'],
              ...action,
            });
      if (!ref.mounted || generation != _generation) return false;
      state = GameSaveState(data: data, verified: true);
      await _cacheSafely(service, data, generation);
      return true;
    } catch (error) {
      if (ref.mounted && generation == _generation) {
        state = GameSaveState(
          data: previous,
          error: error is PlatformException ? error.code : 'access',
        );
      }
      return false;
    }
  }

  Future<void> _cacheSafely(
    GameSaveService service,
    Map<String, dynamic> data,
    int generation,
  ) async {
    if (!ref.mounted || generation != _generation) return;
    try {
      await service.writeCached(_connectionKey, data);
    } catch (_) {
      // A disposable display cache must never turn a verified SAF read/write
      // into a visible failure.
    }
  }
}
