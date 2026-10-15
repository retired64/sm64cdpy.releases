import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/background_install_service.dart';
import '../../services/game_mod_activation.dart';
import '../../services/mod_installer.dart';

final gameModGatewayProvider = Provider((ref) => GameModActivation());
final gameModActivationProvider =
    AsyncNotifierProvider<GameModActivationNotifier, GameModSnapshot>(
      GameModActivationNotifier.new,
    );

class GameModActivationNotifier extends AsyncNotifier<GameModSnapshot> {
  bool _busy = false;
  DateTime? _lastLoadedAt;
  Future<void>? _startup;
  Future<void>? _refreshing;
  StreamSubscription<BgInstallEvent>? _installSubscription;
  StreamSubscription<String>? _invalidationSubscription;
  @override
  Future<GameModSnapshot> build() {
    _installSubscription = BackgroundInstallService.instance.events.listen((event) {
      if (event is BgInstallCompleted) _lastLoadedAt = null;
    });
    _invalidationSubscription = ModInstaller.libraryInvalidations.listen((_) {
      _lastLoadedAt = null;
    });
    ref.onDispose(() {
      final subscription = _installSubscription;
      if (subscription != null) {
        unawaited(subscription.cancel().catchError((Object _) {}));
      }
      _installSubscription = null;
      final invalidationSubscription = _invalidationSubscription;
      if (invalidationSubscription != null) {
        unawaited(invalidationSubscription.cancel().catchError((Object _) {}));
      }
      _invalidationSubscription = null;
    });
    final initial = ref.read(gameModGatewayProvider).read().then((snapshot) {
      _lastLoadedAt = DateTime.now();
      return snapshot;
    });
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
    if (_busy) {
      final currentRefresh = _refreshing;
      if (currentRefresh != null) await currentRefresh;
      return;
    }
    _busy = true;
    final operation = _reload();
    _refreshing = operation;
    try {
      await operation;
    } finally {
      _refreshing = null;
      _busy = false;
    }
  }

  Future<void> _reload() async {
    try {
      await _startup;
      if (!ref.mounted) return;
      final result = await ref.read(gameModGatewayProvider).read();
      if (ref.mounted) {
        _lastLoadedAt = DateTime.now();
        state = AsyncData(result);
      }
    } catch (error, stack) {
      if (ref.mounted) state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<void> refreshIfStale({
    Duration maxAge = const Duration(seconds: 30),
  }) async {
    await _startup;
    final loadedAt = _lastLoadedAt;
    if (loadedAt != null && DateTime.now().difference(loadedAt) < maxAge) return;
    await refresh();
  }

  void invalidateFreshness() {
    _lastLoadedAt = null;
  }

  Future<void> perform(String method, [Map<String, Object>? arguments]) async {
    await _startup;
    if (_busy && _refreshing != null) await _refreshing;
    if (_busy) throw StateError('A configuration operation is already pending');
    _busy = true;
    try {
      if (!ref.mounted) return;
      final result = await ref
          .read(gameModGatewayProvider)
          .call(method, arguments);
      if (result != null && ref.mounted) {
        if (method == 'setGameModActivation') {
          final current = state.asData?.value;
          final name = arguments?['name'] as String?;
          final kind = arguments?['kind'] as String? ?? 'lua';
          final enabled = arguments?['enabled'] as bool?;
          if (result.mods.isNotEmpty) {
            state = AsyncData(result);
          } else if (current != null && name != null && enabled != null) {
            state = AsyncData(
              current.withActivation(
                name: name,
                kind: kind,
                enabled: enabled,
                backupAvailable: result.backupAvailable,
              ),
            );
          } else {
            state = AsyncData(result);
          }
        } else {
          state = AsyncData(result);
        }
        _lastLoadedAt = DateTime.now();
      }
    } finally {
      _busy = false;
    }
  }
}
