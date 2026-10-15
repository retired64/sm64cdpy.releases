import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../domain/entities/mario_theme_assets.dart';

class MarioThemeAssetsService {
  bool _fontsLoaded = false;
  static const _channel = MethodChannel('sm64cdpy/mario_assets');
  Future<MarioThemeAssets?> call(String method) async {
    final data = await _channel.invokeMapMethod<Object?, Object?>(method);
    if (data == null) return null;
    final assets = MarioThemeAssets.fromMap(data);
    if (assets.complete && !_fontsLoaded) {
      for (final entry in const {
        'font_menu': 'MarioRomMenuV2',
        'font_dialog': 'MarioRomDialogV2',
        'font_hud': 'MarioRomHudV2',
      }.entries) {
        final bytes = await File(assets.files[entry.key]!).readAsBytes();
        final loader = FontLoader(entry.value);
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
        await loader.load();
      }
      // Each accepted ROM has identical bytes/hash. Versioned font families are loaded once per main engine.
      _fontsLoaded = true;
    }
    return assets;
  }

  Future<void> cancel() => _channel.invokeMethod<void>('cancel');

  Future<String?> renderPlayer(List<int> colors) => _channel.invokeMethod<String>(
    'renderPlayer',
    {'colors': colors.map((value) => value & 0xFFFFFF).toList()},
  );
}
