import 'package:flutter/services.dart';

/// Canal sin cola de reproducción: un fallo de audio nunca bloquea la interfaz.
class MangaMenuAudio {
  static const _channel = MethodChannel('sm64cdpy/manga_menu_audio');

  Future<void> prepare() => _invoke('prepare');
  Future<void> stop() => _invoke('stop');
  Future<void> play(String sound) => _invoke('play', {'sound': sound});

  Future<void> _invoke(String method, [Map<String, Object>? arguments]) async {
    try {
      await _channel.invokeMethod<void>(method, arguments);
    } on PlatformException {
      // Efecto opcional: conservar navegación y animación aunque falle Android.
    } on MissingPluginException {
      // Pruebas de widgets y engines sin este plugin permanecen silenciosos.
    }
  }
}
