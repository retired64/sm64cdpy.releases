import 'dart:async';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';

class GameSaveService {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');
  static const _cacheKey = 'game_save_display_snapshot_v1';
  static const _cacheSchema = 1;

  Future<Map<String, dynamic>> read() async => Map<String, dynamic>.from(
    (await _channel.invokeMapMethod<String, dynamic>('getGameSave'))!,
  );
  Future<Map<String, dynamic>> change(Map<String, dynamic> data) async =>
      Map<String, dynamic>.from(
        (await _channel.invokeMapMethod<String, dynamic>(
          'changeGameSave',
          data,
        ))!,
      );

  Map<String, dynamic>? readCached(String? connectionKey) {
    if (connectionKey == null ||
        !Hive.isBoxOpen(AppConstants.installationLibraryBoxKey)) {
      return null;
    }
    final value = Hive.box<dynamic>(
      AppConstants.installationLibraryBoxKey,
    ).get(_cacheKey);
    if (value is! Map ||
        value['schema'] != _cacheSchema ||
        value['owner'] != connectionKey ||
        value['snapshot'] is! Map) {
      return null;
    }
    try {
      final snapshot = Map<String, dynamic>.from(value['snapshot'] as Map);
      _validateSnapshot(snapshot);
      return snapshot;
    } catch (_) {
      unawaited(clearCached().catchError((Object _) {}));
      return null;
    }
  }

  Future<void> writeCached(
    String? connectionKey,
    Map<String, dynamic> snapshot,
  ) async {
    if (connectionKey == null ||
        !Hive.isBoxOpen(AppConstants.installationLibraryBoxKey)) {
      return;
    }
    _validateSnapshot(snapshot);
    await Hive.box<dynamic>(AppConstants.installationLibraryBoxKey).put(
      _cacheKey,
      <String, Object?>{
        'schema': _cacheSchema,
        'owner': connectionKey,
        // Display metadata only. The save bytes remain native/SAF authority.
        'snapshot': snapshot,
      },
    );
  }

  Future<void> clearCached() async {
    if (!Hive.isBoxOpen(AppConstants.installationLibraryBoxKey)) return;
    await Hive.box<dynamic>(
      AppConstants.installationLibraryBoxKey,
    ).delete(_cacheKey);
  }

  void _validateSnapshot(Map<String, dynamic> snapshot) {
    final revision = snapshot['revision'];
    final identity = snapshot['identity'];
    final slots = snapshot['slots'];
    final backups = snapshot['backups'];
    if (revision is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(revision) ||
        identity is! String ||
        identity.isEmpty ||
        slots is! List ||
        backups is! List ||
        snapshot['damaged'] is! bool) {
      throw const FormatException('Invalid game-save display snapshot');
    }
  }
}
