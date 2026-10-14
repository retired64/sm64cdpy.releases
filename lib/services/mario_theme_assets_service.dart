import 'package:flutter/services.dart';
import '../domain/entities/mario_theme_assets.dart';

class MarioThemeAssetsService {
  static const _channel = MethodChannel('sm64cdpy/mario_assets');
  Future<MarioThemeAssets?> call(String method) async {
    final data = await _channel.invokeMapMethod<Object?, Object?>(method);
    return data == null ? null : MarioThemeAssets.fromMap(data);
  }

  Future<void> cancel() => _channel.invokeMethod<void>('cancel');
}
