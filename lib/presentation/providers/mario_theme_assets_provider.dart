import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mario_theme_assets.dart';
import '../../services/mario_theme_assets_service.dart';

final marioThemeAssetsServiceProvider = Provider(
  (ref) => MarioThemeAssetsService(),
);
final marioThemeAssetsProvider =
    NotifierProvider<MarioThemeAssetsNotifier, MarioAssetsState>(
      MarioThemeAssetsNotifier.new,
    );

class MarioAssetsState {
  const MarioAssetsState({
    this.assets = const MarioThemeAssets(),
    this.busy = false,
    this.error,
    this.imported = 0,
  });
  final MarioThemeAssets assets;
  final bool busy;
  final String? error;
  final int imported;
}

class MarioThemeAssetsNotifier extends Notifier<MarioAssetsState> {
  Future<void>? _startup;
  @override
  MarioAssetsState build() => const MarioAssetsState();

  Future<void> initialize() => _startup ??= _initialize();
  Future<void> _initialize() async {
    try {
      final assets = await ref
          .read(marioThemeAssetsServiceProvider)
          .call('read');
      if (ref.mounted)
        state = MarioAssetsState(assets: assets ?? const MarioThemeAssets());
    } catch (_) {
      // Safe built-in theme when no channel is available (including widget tests).
    }
  }

  Future<void> perform(String method) async {
    if (state.busy) return;
    await initialize();
    if (!ref.mounted || state.busy) return;
    final previous = state;
    state = MarioAssetsState(
      assets: previous.assets,
      busy: true,
      imported: previous.imported,
    );
    try {
      final assets = await ref
          .read(marioThemeAssetsServiceProvider)
          .call(method);
      if (!ref.mounted) return;
      state = MarioAssetsState(
        assets: assets ?? previous.assets,
        imported:
            previous.imported +
            (method == 'import' && assets?.available == true ? 1 : 0),
      );
    } catch (error) {
      if (!ref.mounted) return;
      final code = error is PlatformException ? error.code : 'storage';
      state = MarioAssetsState(
        assets: previous.assets,
        imported: previous.imported,
        error: code == 'cancelled' ? null : code,
      );
    }
  }

  Future<void> cancel() async {
    if (!state.busy) return;
    try {
      await ref.read(marioThemeAssetsServiceProvider).cancel();
      // Busy is released only by the original native operation's terminal result.
    } catch (_) {
      /* Original operation still owns its terminal result. */
    }
  }
}
