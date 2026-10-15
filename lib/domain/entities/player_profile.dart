import 'package:flutter/material.dart';

enum PlayerPart { pants, shirt, gloves, shoes, hair, skin, cap, emblem }

@immutable
class PlayerPalette {
  const PlayerPalette(this.colors);

  static const mario = PlayerPalette([
    0xFF0000FF,
    0xFFFF0000,
    0xFFFFFFFF,
    0xFF721C0E,
    0xFF730600,
    0xFFFEC179,
    0xFFFF0000,
    0xFFFF0000,
  ]);

  final List<int> colors;
  Color operator [](PlayerPart part) => Color(colors[part.index]);
  PlayerPalette replace(PlayerPart part, Color color) {
    final next = List<int>.of(colors);
    next[part.index] = color.toARGB32() | 0xFF000000;
    return PlayerPalette(List.unmodifiable(next));
  }

  List<int> get platformColors =>
      colors.map((value) => value & 0xFFFFFF).toList(growable: false);
  @override
  bool operator ==(Object other) =>
      other is PlayerPalette &&
      List.generate(
        8,
        (i) => colors[i] == other.colors[i],
      ).every((value) => value);
  @override
  int get hashCode => Object.hashAll(colors);
}

@immutable
class PlayerProfile {
  const PlayerProfile({
    required this.name,
    required this.model,
    required this.palette,
  });
  final String name;
  final int model;
  final PlayerPalette palette;
  PlayerProfile copyWith({String? name, PlayerPalette? palette}) =>
      PlayerProfile(
        name: name ?? this.name,
        model: model,
        palette: palette ?? this.palette,
      );
  @override
  bool operator ==(Object other) =>
      other is PlayerProfile &&
      other.name == name &&
      other.model == model &&
      other.palette == palette;
  @override
  int get hashCode => Object.hash(name, model, palette);
}

@immutable
class PlayerPalettePreset {
  const PlayerPalettePreset({
    required this.id,
    required this.name,
    required this.writable,
    required this.palette,
  });
  final String id;
  final String name;
  final bool writable;
  final PlayerPalette palette;
}

@immutable
class PlayerProfileSnapshot {
  const PlayerProfileSnapshot({
    required this.status,
    this.revision,
    this.profile,
    this.presets = const [],
    this.backupAvailable = false,
  });
  final String status;
  final String? revision;
  final PlayerProfile? profile;
  final List<PlayerPalettePreset> presets;
  final bool backupAvailable;
}
