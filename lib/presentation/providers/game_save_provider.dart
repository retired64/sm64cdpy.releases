import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/game_save_service.dart';
import 'game_folder_provider.dart';

final gameSaveServiceProvider = Provider((ref) => GameSaveService());
final gameSaveProvider = NotifierProvider<GameSaveNotifier, GameSaveState>(
  GameSaveNotifier.new,
);

class GameSaveState {
  const GameSaveState({this.data, this.busy = false, this.error});
  final Map<String, dynamic>? data;
  final bool busy;
  final String? error;
}

class GameSaveNotifier extends Notifier<GameSaveState> {
  int _generation = 0;
  @override
  GameSaveState build() {
    ref.watch(
      gameFolderProvider.select((value) => value.connection.connectionKey),
    );
    _generation++;
    return const GameSaveState();
  }

  Future<bool> run([Map<String, dynamic>? action]) async {
    if (state.busy) return false;
    final generation = _generation;
    final previous = state.data;
    state = GameSaveState(data: previous, busy: true);
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
      state = GameSaveState(data: data);
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
}
