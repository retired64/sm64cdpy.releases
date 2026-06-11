import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'update_config.dart';

/// Servicio central de actualizaciones OTA.
/// Consulta la GitHub Releases API y compara versiones.
///
/// Endpoint: https://api.github.com/repos/retired64/sm64cdpy.releases/releases/latest
class UpdateService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/retired64/sm64cdpy.releases/releases/latest';

  static const _cacheKeyBody = 'ota_cached_body';
  static const _cacheKeyTimestamp = 'ota_last_check_ms';
  static const _cacheMaxAge = Duration(hours: 6);

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
      final abi = await _getDeviceAbi();
      debugPrint('[UpdateService] ABI detectada: ${abi.androidAbi}');

      // Intentar cache primero
      final cached = await _readCache(abi);
      if (cached != null) return cached;

      final response = await http
          .get(
            Uri.parse(_githubApiUrl),
            headers: {
              'Accept': 'application/vnd.github.v3+json',
              'User-Agent': 'sm64cdpy-flutter-app',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 403) {
        debugPrint(
          '[UpdateService] GitHub API rate limit alcanzado (403). '
          'Reintentar más tarde.',
        );
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('[UpdateService] GitHub API error: ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;

      await _writeCache(json);

      final config = UpdateConfig.fromGithubRelease(json, abi);
      debugPrint('[UpdateService] Versión remota: ${config.latestVersion}');
      debugPrint('[UpdateService] URL APK: ${config.updateUrl}');

      if (config.updateUrl.isEmpty) {
        debugPrint(
          '[UpdateService] No se encontró APK para ABI: ${abi.androidAbi}',
        );
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

  /// Detecta la ABI del dispositivo Android en runtime usando device_info_plus.
  /// Retorna arm64-v8a como fallback en caso de error.
  static Future<AbiType> _getDeviceAbi() async {
    if (!Platform.isAndroid) return AbiType.arm64;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      final abis = info.supportedAbis;
      debugPrint('[UpdateService] ABIs soportadas: $abis');
      for (final abi in abis) {
        final match = AbiType.values.firstWhereOrNull(
        (t) => abi == t.androidAbi,
      );
        if (match != null) return match;
      }
      return AbiType.arm64;
    } catch (e) {
      debugPrint('[UpdateService] Error detectando ABI: $e');
      return AbiType.arm64;
    }
  }

  /// Compara dos versiones en formato X.Y.Z, ignorando sufijos (pre-release,
  /// build metadata). Retorna true si [current] es menor que [target].
  static bool isVersionLower(String current, String target) {
    try {
      final v1 = _parseVersion(current);
      final v2 = _parseVersion(target);

      for (int i = 0; i < v1.length && i < v2.length; i++) {
        if (v1[i] < v2[i]) return true;
        if (v1[i] > v2[i]) return false;
      }
      return v1.length < v2.length;
    } catch (e) {
      debugPrint(
        '[UpdateService] Error comparando versiones "$current" vs "$target": $e',
      );
      return false;
    }
  }

  /// Extrae los componentes numéricos X.Y.Z de una versión, descartando
  /// sufijos como -beta, -rc1, +5, etc.
  static List<int> _parseVersion(String version) {
    final clean = version
        .split('-')
        .first
        .split('+')
        .first;
    return clean.split('.').map(int.parse).toList();
  }

  static Future<UpdateConfig?> _readCache(AbiType abi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_cacheKeyTimestamp) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - lastCheck;

      if (age > _cacheMaxAge.inMilliseconds) return null;

      final body = prefs.getString(_cacheKeyBody);
      if (body == null) return null;

      final json = jsonDecode(body) as Map<String, dynamic>;
      final config = UpdateConfig.fromGithubRelease(json, abi);

      if (config.updateUrl.isEmpty) return null;
      if (isVersionLower(_currentVersion, config.latestVersion)) {
        debugPrint('[UpdateService] Actualización desde caché');
        return config;
      }
      return null;
    } catch (e) {
      debugPrint('[UpdateService] Error leyendo caché: $e');
      return null;
    }
  }

  static Future<void> _writeCache(Map<String, dynamic> json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final body = jsonEncode(json);
      await prefs.setString(_cacheKeyBody, body);
      await prefs.setInt(
        _cacheKeyTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('[UpdateService] Error escribiendo caché: $e');
    }
  }
}

