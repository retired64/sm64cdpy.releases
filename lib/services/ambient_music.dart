import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AmbientMusic {
  static const _channel = MethodChannel('sm64cdpy/ambient_music');

  Future<void> configure({required bool enabled, required double volume}) async {
    try {
      await _channel.invokeMethod<void>('configure', {
        'enabled': enabled,
        'volume': volume.isFinite ? volume.clamp(0.0, 1.0).toDouble() : 0.18,
      });
    } on PlatformException catch (error) {
      debugPrint('AmbientMusic: ${error.code}');
    } on MissingPluginException {
      // Permitir pruebas y engines que no registran música ambiental.
    }
  }
}
