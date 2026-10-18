import 'package:flutter/services.dart';

class GameSaveService {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');
  Future<Map<String, dynamic>> read() async => Map<String, dynamic>.from(
    (await _channel.invokeMapMethod<String, dynamic>('getGameSave'))!,
  );
  Future<Map<String, dynamic>> change(Map<String, dynamic> data) async =>
      Map<String, dynamic>.from((await _channel.invokeMapMethod<String, dynamic>('changeGameSave', data))!);
}
