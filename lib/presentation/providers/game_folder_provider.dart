import 'dart:async';
import '../../services/background_install_service.dart';
import 'mod_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/game_folder_service.dart';
import '../../services/mod_installer.dart';

final gameFolderServiceProvider = Provider((ref) => GameFolderService());
final gameFolderProvider =
    NotifierProvider<GameFolderNotifier, GameFolderState>(
      GameFolderNotifier.new,
    );

class GameFolderState {
  const GameFolderState({
    this.connection = const GameFolderConnection(),
    this.busy = false,
    this.initialized = false,
    this.error,
  });
  final GameFolderConnection connection;
  final bool busy;
  final bool initialized;
  final String? error;
}

/// Native SharedPreferences/SAF is authority. This is only the main-engine projection.
class GameFolderNotifier extends Notifier<GameFolderState> {
  Future<void>? _startup;
  int _revision = 0;
  @override
  GameFolderState build() {
    ref.listen(bgInstallStateProvider, (previous, next) {
      bool active(Map<String, BgInstallInfo>? value) =>
          value?.values.any(
            (info) =>
                info.status == BgInstallStatus.pending ||
                info.status == BgInstallStatus.downloading ||
                info.status == BgInstallStatus.installing,
          ) ??
          false;
      if (active(previous) && !active(next)) unawaited(refresh());
    });
    return const GameFolderState();
  }

  Future<void> initialize() => _startup ??= refresh();
  Future<void> refresh() async {
    if (state.busy) return;
    final revision = ++_revision;
    try {
      final value = await ref
          .read(gameFolderServiceProvider)
          .call('getGameFolder');
      if (ref.mounted &&
          !state.busy &&
          revision == _revision &&
          value != null) {
        final changed =
            state.connection.connected != value.connected ||
            state.connection.unified != value.unified;
        state = GameFolderState(initialized: true, connection: value);
        if (changed)
          ModInstaller.invalidateInstallationLibrary('gameFolderAccessChanged');
      }
    } catch (_) {
      if (ref.mounted && !state.busy && revision == _revision)
        state = GameFolderState(
          initialized: true,
          connection: state.connection,
          error: 'access',
        );
    }
  }

  Future<bool> perform(String method) async {
    await initialize();
    if (!ref.mounted || state.busy) return false;
    final previous = state.connection;
    ++_revision;
    state = GameFolderState(
      initialized: true,
      connection: previous,
      busy: true,
    );
    try {
      final value = await ref.read(gameFolderServiceProvider).call(method);
      if (!ref.mounted) return false;
      state = GameFolderState(initialized: true, connection: value ?? previous);
      if (value != null && method != 'dismissGameFolderGuide') {
        ModInstaller.invalidateInstallationLibrary('gameFolderChanged');
      }
      return value != null;
    } catch (error) {
      if (ref.mounted)
        state = GameFolderState(
          initialized: true,
          connection: previous,
          error: error is PlatformException ? error.code : 'access',
        );
      return false;
    } finally {
      if (ref.mounted && state.busy)
        state = GameFolderState(
          initialized: true,
          connection: state.connection,
          error: state.error,
        );
    }
  }
}
