import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'update_config.dart';

/// Servicio central de actualizaciones OTA.
/// Consulta la GitHub Releases API y compara versiones.
///
/// Endpoint: https://api.github.com/repos/retired64/sm64cdpy.releases/releases/latest
class UpdateService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/retired64/sm64cdpy.releases/releases/latest';

  static String _currentVersion = '';

  /// Debe llamarse en main() antes de runApp().
  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;
    debugPrint('[UpdateService] Versión instalada: $_currentVersion');
  }

  static String get currentVersion => _currentVersion;

  /// Consulta la GitHub Releases API y retorna la configuración
  /// de actualización si hay una versión más nueva disponible.
  ///
  /// Retorna null si:
  /// - No hay conexión a internet
  /// - Ya está en la última versión
  /// - Ocurre algún error
  static Future<UpdateConfig?> checkForUpdates() async {
    try {
      final abi = _getDeviceAbi();
      debugPrint('[UpdateService] ABI detectada: $abi');

      final response = await http
          .get(
            Uri.parse(_githubApiUrl),
            headers: {
              'Accept': 'application/vnd.github.v3+json',
              'User-Agent': 'sm64cdpy-flutter-app',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('[UpdateService] GitHub API error: ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;

      final config = UpdateConfig.fromGithubRelease(json, abi);
      debugPrint('[UpdateService] Versión remota: ${config.latestVersion}');
      debugPrint('[UpdateService] URL APK: ${config.updateUrl}');

      if (config.updateUrl.isEmpty) {
        debugPrint('[UpdateService] No se encontró APK para ABI: $abi');
        return null;
      }

      if (isVersionLower(_currentVersion, config.latestVersion)) {
        debugPrint('[UpdateService] Actualización disponible');
        return config;
      }

      debugPrint('[UpdateService] La app está actualizada');
      return null;
    } catch (e) {
      debugPrint('[UpdateService] Error al verificar actualizaciones: $e');
      return null;
    }
  }

  /// Detecta la ABI del dispositivo Android en runtime.
  /// Retorna 'arm64-v8a' como fallback seguro.
  static String _getDeviceAbi() {
    if (!Platform.isAndroid) return 'arm64-v8a';
    return 'arm64-v8a';
  }

  /// Compara dos versiones en formato X.Y.Z.
  /// Retorna true si [current] es menor que [target].
  static bool isVersionLower(String current, String target) {
    try {
      final v1 = current.split('.').map(int.parse).toList();
      final v2 = target.split('.').map(int.parse).toList();

      for (int i = 0; i < v1.length && i < v2.length; i++) {
        if (v1[i] < v2[i]) return true;
        if (v1[i] > v2[i]) return false;
      }
      return v1.length < v2.length;
    } catch (_) {
      return false;
    }
  }
}
