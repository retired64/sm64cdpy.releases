import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/game_mod_activation.dart';

final gameModGatewayProvider = Provider((ref) => GameModActivation());
final gameModActivationProvider =
    AsyncNotifierProvider<GameModActivationNotifier, GameModSnapshot>(
      GameModActivationNotifier.new,
    );

class GameModActivationNotifier extends AsyncNotifier<GameModSnapshot> {
  bool _busy = false;
  Future<void>? _startup;
  @override
  Future<GameModSnapshot> build() {
    final initial = ref.read(gameModGatewayProvider).read();
    _startup = _settled(initial);
    return initial;
  }

  Future<void> _settled(Future<GameModSnapshot> initial) async {
    try {
      await initial;
    } catch (_) {
      /* build exposes the initial error. */
    }
  }

  Future<void> refresh() async {
    if (_busy) return;
    _busy = true;
    try {
      await _startup;
      if (!ref.mounted) return;
      final result = await ref.read(gameModGatewayProvider).read();
      if (ref.mounted) state = AsyncData(result);
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
      rethrow;
    } finally {
      _busy = false;
    }
  }

  Future<void> perform(String method, [Map<String, Object>? arguments]) async {
    if (_busy) throw StateError('A configuration operation is already pending');
    _busy = true;
    try {
      await _startup;
      if (!ref.mounted) return;
      final result = await ref
          .read(gameModGatewayProvider)
          .call(method, arguments);
      if (result != null && ref.mounted) state = AsyncData(result);
    } finally {
      _busy = false;
    }
  }
}
