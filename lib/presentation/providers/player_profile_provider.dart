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
    this.refreshing = false,
    this.error,
  });
  final String status;
  final PlayerProfile? confirmed;
  final PlayerProfile? draft;
  final String? revision;
  final List<PlayerPalettePreset> presets;
  final bool backupAvailable;
  final bool busy;
  final bool refreshing;
  final String? error;
  bool get dirty => confirmed != null && draft != confirmed;
}

class PlayerProfileNotifier extends Notifier<PlayerProfileState> {
  Future<void>? _loading;
  int _epoch = 0;
  @override
  PlayerProfileState build() => const PlayerProfileState();

  Future<void> load({bool force = false}) {
    if (_loading != null) return _loading!;
    if (state.busy || (!force && state.draft != null)) {
      return Future<void>.value();
    }
    final operation = _load();
    _loading = operation;
    return operation.whenComplete(() {
      if (identical(_loading, operation)) _loading = null;
    });
  }

  Future<void> _load() async {
    final epoch = ++_epoch;
    final service = ref.read(playerProfileServiceProvider);
    state = _copy(refreshing: true);
    bool current() => ref.mounted && epoch == _epoch;
    try {
      if (state.draft == null) {
        try {
          final cached = await service.cached();
          if (!current()) return;
          if (cached.profile != null) {
            state = PlayerProfileState(
              status: cached.status,
              confirmed: cached.profile,
              draft: cached.profile,
              // Preserve the cached baseline for conflict detection if the user
              // edits while refreshing; refreshing blocks every write action.
              revision: cached.revision,
              presets: cached.presets,
              refreshing: true,
            );
          }
        } catch (_) {
          // Missing/corrupt cache cannot prevent a real read or leave loading stuck.
        }
      }
      if (!current()) return;
      final value = await service.read();
      if (!current()) return;
      final edited = state.dirty;
      final previous = state;
      final preserveBaseline = edited &&
          previous.revision != null &&
          previous.confirmed != value.profile;
      state = PlayerProfileState(
        status: value.status,
        confirmed: value.profile == null
            ? null
            : (edited ? previous.confirmed : value.profile),
        draft: value.profile == null
            ? null
            : (edited ? previous.draft : value.profile),
        // Preserve the baseline when editing an already verified profile. If it
        // changed externally, native apply must reject that original revision.
        revision: value.profile == null
            ? null
            : (preserveBaseline ? previous.revision : value.revision),
        presets: value.profile == null ? const [] : previous.presets,
        backupAvailable: value.backupAvailable,
      );
      if (value.profile == null) return;
      try {
        final palettes = await service.palettes();
        if (!current()) return;
        state = PlayerProfileState(
          status: state.status,
          confirmed: state.confirmed,
          draft: state.draft,
          revision: state.revision,
          presets: palettes.presets,
          backupAvailable: state.backupAvailable,
          busy: state.busy,
          error: state.error,
        );
      } catch (_) {
        // Keep the last palette list; profile editing does not depend on scanning it.
      }
    } catch (error) {
      if (current()) {
        state = PlayerProfileState(
          status: 'access',
          confirmed: state.confirmed,
          draft: state.draft,
          // Cached/failed refresh data remains viewable, but cannot be written.
          presets: state.presets,
          error: error is PlatformException ? error.code : 'access',
        );
      }
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
    if (draft != null) {
      state = _copy(
        draft: draft.copyWith(palette: draft.palette.replace(part, color)),
      );
    }
  }

  void usePreset(PlayerPalettePreset preset) {
    final draft = state.draft;
    if (draft != null) {
      state = _copy(draft: draft.copyWith(palette: preset.palette));
    }
  }

  void reset() {
    state = _copy(draft: state.confirmed, error: null);
  }

  Future<bool> apply() async {
    final draft = state.draft;
    final revision = state.revision;
    if (draft == null || revision == null || state.busy || state.refreshing) {
      return false;
    }
    return _perform(
      () => ref
          .read(playerProfileServiceProvider)
          .apply(profile: draft, revision: revision),
    );
  }

  Future<bool> savePalette(String name, {bool overwrite = false}) async {
    final draft = state.draft;
    if (draft == null || state.busy || state.refreshing || state.revision == null) {
      return false;
    }
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
    if (state.busy || state.refreshing || state.revision == null) return false;
    return _perform(
      () => ref.read(playerProfileServiceProvider).deletePalette(id),
      preserveDraft: true,
    );
  }

  Future<bool> restore() async {
    if (state.busy || state.refreshing || state.revision == null) return false;
    return _perform(() => ref.read(playerProfileServiceProvider).restore());
  }

  Future<bool> _perform(
    Future<PlayerProfileSnapshot> Function() call, {
    bool preserveDraft = false,
  }) async {
    final draft = state.draft;
    ++_epoch; // Retire palette/refresh replies that began before this mutation.
    state = _copy(busy: true, error: null);
    try {
      final value = await call();
      if (!ref.mounted) return false;
      state = PlayerProfileState(
        status: value.status,
        confirmed: value.profile ?? state.confirmed,
        draft: preserveDraft ? draft : (value.profile ?? draft),
        revision: value.revision ?? state.revision,
        presets: value.presets,
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

  PlayerProfileState _copy({
    PlayerProfile? draft,
    bool? busy,
    bool? refreshing,
    String? error,
  }) =>
      PlayerProfileState(
        status: state.status,
        confirmed: state.confirmed,
        draft: draft ?? state.draft,
        revision: state.revision,
        presets: state.presets,
        backupAvailable: state.backupAvailable,
        busy: busy ?? state.busy,
        refreshing: refreshing ?? state.refreshing,
        error: error,
      );
}
