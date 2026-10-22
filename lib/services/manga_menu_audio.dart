import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Canal sin cola de reproducción: un fallo de audio nunca bloquea la interfaz.
class MangaMenuAudio {
  static const _channel = MethodChannel('sm64cdpy/manga_menu_audio');

  Future<void> prepare() => _invoke('prepare');
  Future<void> stop() => _invoke('stop');
  Future<void> play(String sound, {double volume = 0.65}) =>
      _invoke('play', {
        'sound': sound,
        'volume': volume.isFinite ? volume.clamp(0.0, 1.0).toDouble() : 0.65,
      });

  Future<void> _invoke(String method, [Map<String, Object>? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException catch (error) {
      debugPrint('MangaMenuAudio: $method failed (${error.code})');
      // Efecto opcional: conservar navegación y animación aunque falle Android.
    } on MissingPluginException {
      debugPrint('MangaMenuAudio: canal nativo no disponible ($method)');
      // Pruebas de widgets y engines sin este plugin permanecen silenciosos.
    }
  }
}
