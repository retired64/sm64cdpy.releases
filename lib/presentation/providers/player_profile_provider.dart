import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/player_profile.dart';
import '../../services/player_profile_service.dart';

final playerProfileServiceProvider = Provider((ref) => PlayerProfileService());
final playerProfileProvider =
    NotifierProvider<PlayerProfileNotifier, PlayerProfileState>(
      PlayerProfileNotifier.new,
    );

class PlayerProfileState {
  const PlayerProfileState({
    this.status = 'loading',
    this.confirmed,
    this.draft,
    this.revision,
    this.presets = const [],
    this.backupAvailable = false,
    this.busy = false,
    this.error,
  });
  final String status;
  final PlayerProfile? confirmed;
  final PlayerProfile? draft;
  final String? revision;
  final List<PlayerPalettePreset> presets;
  final bool backupAvailable;
  final bool busy;
  final String? error;
  bool get dirty => confirmed != null && draft != confirmed;
}

class PlayerProfileNotifier extends Notifier<PlayerProfileState> {
  Future<void>? _loading;
  @override
  PlayerProfileState build() => const PlayerProfileState();

  Future<void> load({bool force = false}) {
    if (!force && _loading != null) return _loading!;
    final operation = _load();
    _loading = operation;
    return operation.whenComplete(() {
      if (identical(_loading, operation)) _loading = null;
    });
  }

  Future<void> _load() async {
    final oldDraft = state.dirty ? state.draft : null;
    state = PlayerProfileState(
      status: state.status,
      confirmed: state.confirmed,
      draft: state.draft,
      revision: state.revision,
      presets: state.presets,
      backupAvailable: state.backupAvailable,
      busy: true,
    );
    try {
      final value = await ref.read(playerProfileServiceProvider).read();
      if (!ref.mounted) return;
      state = PlayerProfileState(
        status: value.status,
        confirmed: value.profile,
        draft: oldDraft ?? value.profile,
        revision: value.revision,
        presets: value.presets,
        backupAvailable: value.backupAvailable,
      );
    } on PlatformException catch (error) {
      if (ref.mounted)
        state = PlayerProfileState(
          status: state.status,
          confirmed: state.confirmed,
          draft: state.draft,
          revision: state.revision,
          presets: state.presets,
          error: error.code,
        );
    }
  }

  void setName(String value) {
    final draft = state.draft;
    if (draft != null) state = _copy(draft: draft.copyWith(name: value));
  }

  void setModel(int value) {
    final draft = state.draft;
    if (draft != null && value >= 0 && value <= 4) {
      state = _copy(draft: draft.copyWith(model: value));
    }
  }

  void setColor(PlayerPart part, Color color) {
    final draft = state.draft;
    if (draft != null)
      state = _copy(
        draft: draft.copyWith(palette: draft.palette.replace(part, color)),
      );
  }

  void usePreset(PlayerPalettePreset preset) {
    final draft = state.draft;
    if (draft != null)
      state = _copy(draft: draft.copyWith(palette: preset.palette));
  }

  void reset() {
    state = _copy(draft: state.confirmed, error: null);
  }

  Future<bool> apply() async {
    final draft = state.draft;
    final revision = state.revision;
    if (draft == null || revision == null || state.busy) return false;
    return _perform(
      () => ref
          .read(playerProfileServiceProvider)
          .apply(profile: draft, revision: revision),
    );
  }

  Future<bool> savePalette(String name, {bool overwrite = false}) async {
    final draft = state.draft;
    if (draft == null || state.busy) return false;
    return _perform(
      () => ref
          .read(playerProfileServiceProvider)
          .savePalette(
            name: name,
            palette: draft.palette,
            overwrite: overwrite,
          ),
      preserveDraft: true,
    );
  }

  Future<bool> deletePalette(String id) async {
    if (state.busy) return false;
    return _perform(
      () => ref.read(playerProfileServiceProvider).deletePalette(id),
      preserveDraft: true,
    );
  }

  Future<bool> restore() async {
    if (state.busy) return false;
    return _perform(() => ref.read(playerProfileServiceProvider).restore());
  }

  Future<bool> _perform(
    Future<PlayerProfileSnapshot> Function() call, {
    bool preserveDraft = false,
  }) async {
    final draft = state.draft;
    state = _copy(busy: true, error: null);
    try {
      final value = await call();
      if (!ref.mounted) return false;
      state = PlayerProfileState(
        status: value.status,
        confirmed: value.profile ?? state.confirmed,
        draft: preserveDraft ? draft : (value.profile ?? draft),
        revision: value.revision ?? state.revision,
        presets: value.presets.isEmpty ? state.presets : value.presets,
        backupAvailable: value.backupAvailable,
      );
      return true;
    } on PlatformException catch (error) {
      if (ref.mounted) state = _copy(busy: false, error: error.code);
      return false;
    } catch (_) {
      if (ref.mounted) state = _copy(busy: false, error: 'access');
      return false;
    }
  }

  PlayerProfileState _copy({PlayerProfile? draft, bool? busy, String? error}) =>
      PlayerProfileState(
        status: state.status,
        confirmed: state.confirmed,
        draft: draft ?? state.draft,
        revision: state.revision,
        presets: state.presets,
        backupAvailable: state.backupAvailable,
        busy: busy ?? state.busy,
        error: error,
      );
}
