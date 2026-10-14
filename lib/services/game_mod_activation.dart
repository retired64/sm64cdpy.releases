import 'package:flutter/services.dart';

class GameModEntry {
  const GameModEntry({required this.name, required this.title, required this.enabled, required this.selectable, this.author, this.category, this.versionLabel, this.description});
  factory GameModEntry.fromMap(Map<dynamic, dynamic> value) => GameModEntry(
    name: value['name'] as String,
    title: value['title'] as String,
    enabled: value['enabled'] == true,
    selectable: value['selectable'] == true,
    author: value['author'] as String?,
    category: value['category'] as String?,
    versionLabel: value['versionLabel'] as String?,
    description: value['description'] as String?,
  );
  final String name;
  final String title;
  final bool enabled;
  final bool selectable;
  final String? author;
  final String? category;
  final String? versionLabel;
  final String? description;
}

class GameModSnapshot {
  const GameModSnapshot({required this.status, this.mods = const [], this.backupAvailable = false});
  factory GameModSnapshot.fromMap(Map<dynamic, dynamic> value) => GameModSnapshot(
    status: value['status'] as String,
    backupAvailable: value['backupAvailable'] == true,
    mods: (value['mods'] as List? ?? const []).map((item) => GameModEntry.fromMap(item as Map)).toList(growable: false),
  );
  final String status;
  final bool backupAvailable;
  final List<GameModEntry> mods;
}

class GameModActivation {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');
  Future<GameModSnapshot?> call(String method, [Map<String, Object>? arguments]) async {
    final result = await _channel.invokeMapMethod<dynamic, dynamic>(method, arguments);
    return result == null ? null : GameModSnapshot.fromMap(result);
  }
  Future<GameModSnapshot> read() async => (await call('getGameModActivation'))!;
}
