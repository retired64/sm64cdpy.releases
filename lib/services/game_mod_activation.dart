import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';

class GameModEntry {
  const GameModEntry({
    required this.name,
    required this.title,
    required this.enabled,
    required this.selectable,
    this.blockedReason,
    this.kind = 'lua',
    this.origin = 'user',
    this.author,
    this.category,
    this.versionLabel,
    this.description,
  });
  factory GameModEntry.fromMap(Map<dynamic, dynamic> value) => GameModEntry(
    blockedReason: value['blockedReason'] as String?,
    kind: value['kind'] as String? ?? 'lua',
    origin: value['origin'] as String? ?? 'user',
    name: value['name'] as String,
    title: value['title'] as String,
    enabled: value['enabled'] == true,
    selectable: value['selectable'] == true,
    author: value['author'] as String?,
    category: value['category'] as String?,
    versionLabel: value['versionLabel'] as String?,
    description: value['description'] as String?,
  );
  final String? blockedReason;
  final String kind;
  final String origin;
  String get gamePath =>
      '${origin == "root" ? "" : "user/"}${isDynos ? "dynos/packs" : "mods"}/$name';
  bool get isDynos => kind == 'dynos';
  String get keyName => isDynos ? 'dynos:$name' : name;
  final String name;
  final String title;
  final bool enabled;
  final bool selectable;
  final String? author;
  final String? category;
  final String? versionLabel;
  final String? description;

  Map<String, Object?> toMap() => {
    'blockedReason': blockedReason,
    'kind': kind,
    'origin': origin,
    'name': name,
    'title': title,
    'enabled': enabled,
    'selectable': selectable,
    'author': author,
    'category': category,
    'versionLabel': versionLabel,
    'description': description,
  };

  GameModEntry withEnabled(bool value) => GameModEntry(
    blockedReason: blockedReason,
    kind: kind,
    origin: origin,
    name: name,
    title: title,
    enabled: value,
    selectable: selectable,
    author: author,
    category: category,
    versionLabel: versionLabel,
    description: description,
  );
}

class GameModSnapshot {
  const GameModSnapshot({
    required this.status,
    this.mods = const [],
    this.backupAvailable = false,
  });
  factory GameModSnapshot.fromMap(Map<dynamic, dynamic> value) =>
      GameModSnapshot(
        status: value['status'] as String,
        backupAvailable: value['backupAvailable'] == true,
        mods: (value['mods'] as List? ?? const [])
            .map((item) => GameModEntry.fromMap(item as Map))
            .toList(growable: false),
      );
  final String status;
  final bool backupAvailable;
  final List<GameModEntry> mods;

  Map<String, Object?> toMap() => {
    'status': status,
    'backupAvailable': backupAvailable,
    'mods': mods.map((mod) => mod.toMap()).toList(growable: false),
  };

  GameModSnapshot withActivation({
    required String name,
    required String kind,
    required bool enabled,
    bool? backupAvailable,
  }) => GameModSnapshot(
    status: status,
    backupAvailable: backupAvailable ?? this.backupAvailable,
    mods: mods
        .map(
          (mod) => mod.name == name && mod.kind == kind
              ? mod.withEnabled(enabled)
              : mod,
        )
        .toList(growable: false),
  );
}

class GameModActivation {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');
  static const _cacheKey = 'game_mod_activation_snapshot_v1';
  Future<GameModSnapshot?> call(
    String method, [
    Map<String, Object>? arguments,
  ]) async {
    final result = await _channel.invokeMapMethod<dynamic, dynamic>(
      method,
      arguments,
    );
    return result == null ? null : GameModSnapshot.fromMap(result);
  }

  Future<GameModSnapshot> read() async => (await call('getGameModActivation'))!;

  Future<GameModSnapshot?> readCached() async {
    if (!Hive.isBoxOpen(AppConstants.installationLibraryBoxKey)) return null;
    final value = Hive.box<dynamic>(
      AppConstants.installationLibraryBoxKey,
    ).get(_cacheKey);
    if (value is! Map) return null;
    try {
      return GameModSnapshot.fromMap(value);
    } catch (_) {
      await clearCached();
      return null;
    }
  }

  Future<void> writeCached(GameModSnapshot snapshot) async {
    if (!Hive.isBoxOpen(AppConstants.installationLibraryBoxKey)) return;
    await Hive.box<dynamic>(
      AppConstants.installationLibraryBoxKey,
    ).put(_cacheKey, snapshot.toMap());
  }

  Future<void> clearCached() async {
    if (!Hive.isBoxOpen(AppConstants.installationLibraryBoxKey)) return;
    await Hive.box<dynamic>(
      AppConstants.installationLibraryBoxKey,
    ).delete(_cacheKey);
  }
}
