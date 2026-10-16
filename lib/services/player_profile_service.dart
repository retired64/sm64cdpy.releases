import 'package:flutter/services.dart';

import '../domain/entities/player_profile.dart';

class PlayerProfileService {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');

  Future<PlayerProfileSnapshot> read() => _call('getPlayerProfile');
  Future<PlayerProfileSnapshot> restore() => _call('restorePlayerConfig');

  Future<PlayerProfileSnapshot> apply({
    required PlayerProfile profile,
    required String revision,
  }) => _call('applyPlayerProfile', {
    'name': profile.name,
    'model': profile.model,
    'colors': profile.palette.platformColors,
    'revision': revision,
  });

  Future<PlayerProfileSnapshot> savePalette({
    required String name,
    required PlayerPalette palette,
    required bool overwrite,
  }) => _call('savePlayerPalette', {
    'name': name,
    'colors': palette.platformColors,
    'overwrite': overwrite,
  });

  Future<PlayerProfileSnapshot> deletePalette(String id) =>
      _call('deletePlayerPalette', {'id': id});

  Future<PlayerProfileSnapshot> _call(
    String method, [
    Map<String, Object?>? arguments,
  ]) async {
    final value = await _channel.invokeMapMethod<dynamic, dynamic>(
      method,
      arguments,
    );
    if (value == null) throw PlatformException(code: 'access');
    final profileMap = value['profile'] as Map?;
    PlayerProfile? profile;
    if (profileMap != null) {
      final colors = (profileMap['colors'] as List? ?? const [])
          .whereType<num>()
          .map((v) => 0xFF000000 | v.toInt())
          .toList(growable: false);
      if (colors.length == 8) {
        profile = PlayerProfile(
          name: profileMap['name'] as String? ?? 'Player',
          model: (profileMap['model'] as num?)?.toInt() ?? 0,
          palette: PlayerPalette(colors),
        );
      }
    }
    final presets = <PlayerPalettePreset>[];
    for (final raw in value['palettes'] as List? ?? const []) {
      if (raw is! Map) continue;
      final colors = (raw['colors'] as List? ?? const [])
          .whereType<num>()
          .map((v) => 0xFF000000 | v.toInt())
          .toList(growable: false);
      if (raw['id'] is String && raw['name'] is String && colors.length == 8) {
        presets.add(
          PlayerPalettePreset(
            id: raw['id'] as String,
            name: raw['name'] as String,
            writable: raw['writable'] == true,
            palette: PlayerPalette(colors),
          ),
        );
      }
    }
    return PlayerProfileSnapshot(
      status: value['status'] as String? ?? 'access',
      revision: value['revision'] as String?,
      profile: profile,
      presets: List.unmodifiable(presets),
      backupAvailable: value['backupAvailable'] == true,
    );
  }
}
