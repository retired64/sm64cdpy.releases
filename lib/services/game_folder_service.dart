import 'package:flutter/services.dart';

class GameFolderConnection {
  const GameFolderConnection({
    this.connected = false,
    this.dismissed = false,
    this.unified = false,
    this.mods = false,
    this.dynos = false,
    this.config = false,
    this.rom = false,
    this.status = 'unselected',
    this.connectionKey,
  });
  factory GameFolderConnection.fromMap(Map<dynamic, dynamic> value) =>
      GameFolderConnection(
        unified: value['unified'] == true,
        connected: value['connected'] == true,
        dismissed: value['dismissed'] == true,
        mods: value['mods'] == true,
        dynos: value['dynos'] == true,
        config: value['config'] == true,
        rom: value['rom'] == true,
        status: value['status'] as String? ?? 'unselected',
        connectionKey: value['rootUri'] as String?,
      );
  final bool connected, dismissed, unified, mods, dynos, config, rom;
  final String status;
  final String? connectionKey;
}

class GameFolderService {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');
  Future<GameFolderConnection?> call(String method) async {
    final result = await _channel.invokeMapMethod<dynamic, dynamic>(method);
    return result == null ? null : GameFolderConnection.fromMap(result);
  }
}
