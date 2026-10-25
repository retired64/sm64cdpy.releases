import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/entities/mod_entity.dart';

/// Identidad de recurso oficial, no coincidencia aproximada por título.
abstract final class DeluxeLinks {
  static const demoUrl = 'https://sm64coopdx.com/dnc.mp4';
  static const gameReleases = 'https://github.com/ManIsCat2/sm64coopdx/releases';
  static bool hasDemo(ModEntity mod) {
    final uri = Uri.tryParse(mod.url);
    return mod.id == '3' && uri != null && uri.host == 'mods.sm64coopdx.com' &&
        uri.path == '/mods/day-night-cycle-dx.3/';
  }
  static Future<bool> open(String url) async {
    try {
      return await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('DeluxeLinks: no se pudo abrir el recurso ($error)');
      return false;
    }
  }
}
