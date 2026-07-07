import 'package:flutter/services.dart';

/// Resultado de una instalación de mod.
class ModInstallResult {
  const ModInstallResult._({
    required this.success,
    this.targetDir,
    this.fileCount,
    this.errorMessage,
  });

  factory ModInstallResult.ok({required String targetDir, required int fileCount}) {
    return ModInstallResult._(success: true, targetDir: targetDir, fileCount: fileCount);
  }

  factory ModInstallResult.error(String message) {
    return ModInstallResult._(success: false, errorMessage: message);
  }

  final bool success;
  final String? targetDir;
  final int? fileCount;
  final String? errorMessage;
}

/// Servicio Dart que envuelve el MethodChannel hacia ModInstallerPlugin (Android nativo).
///
/// Responsabilidades:
/// - Abrir el picker SAF para que el usuario seleccione la carpeta de mods.
/// - Consultar si ya hay una carpeta seleccionada.
/// - Instalar un mod (ZIP) en la carpeta seleccionada.
/// - Limpiar la selección.
class ModInstaller {
  static const _channel = MethodChannel('mods.sm64cdpy/mod_installer');

  /// Abre el explorador de archivos del sistema para que el usuario
  /// seleccione la carpeta de mods. Retorna la URI si se seleccionó,
  /// null si el usuario canceló.
  Future<String?> openDirectoryPicker() async {
    try {
      final uri = await _channel.invokeMethod<String>('openDirectoryPicker');
      return uri;
    } on PlatformException catch (e) {
      throw ModInstallerException(e.message ?? 'Failed to open directory picker');
    }
  }

  /// Consulta si hay una carpeta de mods seleccionada y accesible.
  Future<bool> isDirectorySelected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDirectorySelected');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Obtiene la URI guardada (si existe y es accesible), o null.
  Future<String?> getSavedDirectoryUri() async {
    try {
      return await _channel.invokeMethod<String>('getSavedDirectoryUri');
    } on PlatformException {
      return null;
    }
  }

  /// Instala un mod: extrae el ZIP en [zipPath] dentro de la carpeta
  /// seleccionada, bajo un subdirectorio con nombre [modName].
  ///
  /// [zipPath] debe ser una ruta absoluta al archivo ZIP.
  /// [modName] es el nombre sanitizado del mod (se usará como nombre de carpeta).
  ///
  /// Esta operación se ejecuta en un hilo nativo (no bloquea UI).
  /// El ZIP se elimina del filesystem tras la extracción exitosa.
  Future<ModInstallResult> installMod({
    required String zipPath,
    required String modName,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('installMod', {
        'zipPath': zipPath,
        'modName': modName,
      });

      if (result == null) {
        return ModInstallResult.error('No result from native plugin');
      }

      final success = result['success'] as bool? ?? false;
      if (success) {
        return ModInstallResult.ok(
          targetDir: result['targetDir'] as String? ?? modName,
          fileCount: result['fileCount'] as int? ?? 0,
        );
      } else {
        return ModInstallResult.error(
          result['error'] as String? ?? 'Unknown installation error',
        );
      }
    } on PlatformException catch (e) {
      return ModInstallResult.error(e.message ?? 'Native plugin error');
    }
  }

  /// Revoca los permisos y limpia la selección de carpeta de mods.
  Future<void> clearDirectorySelection() async {
    try {
      await _channel.invokeMethod('clearDirectorySelection');
    } on PlatformException {
      // Silently ignore
    }
  }
}

/// Excepción lanzada por el ModInstaller.
class ModInstallerException implements Exception {
  const ModInstallerException(this.message);
  final String message;

  @override
  String toString() => 'ModInstallerException: $message';
}
