import 'package:flutter/services.dart';

/// Resultado de una instalación de mod.
class ModInstallResult {
  const ModInstallResult._({
    required this.success,
    this.targetDir,
    this.fileCount,
    this.errorMessage,
  });

  factory ModInstallResult.ok({
    required String targetDir,
    required int fileCount,
  }) {
    return ModInstallResult._(
      success: true,
      targetDir: targetDir,
      fileCount: fileCount,
    );
  }

  factory ModInstallResult.error(String message) {
    return ModInstallResult._(success: false, errorMessage: message);
  }

  final bool success;
  final String? targetDir;
  final int? fileCount;
  final String? errorMessage;
}

/// Resultado combinado de la cadena download + install.
class ModChainResult {
  const ModChainResult({
    required this.downloadWorkId,
    required this.installWorkId,
  });

  final String downloadWorkId;
  final String installWorkId;
}

/// Instantánea de un trabajo nativo usada para reconstruir el estado de
/// Flutter después de que el proceso o alguno de sus engines se reinicie.
class NativeWorkSnapshot {
  const NativeWorkSnapshot({
    required this.workId,
    required this.state,
    this.progress,
    this.current,
    this.total,
    this.fileCount,
    this.targetDir,
    this.error,
  });

  factory NativeWorkSnapshot.fromMap(Map<dynamic, dynamic> map) {
    return NativeWorkSnapshot(
      workId: map['workId'] as String,
      state: map['state'] as String? ?? 'UNKNOWN',
      progress: map['progress'] as int?,
      current: map['current'] as int?,
      total: map['total'] as int?,
      fileCount: map['fileCount'] as int?,
      targetDir: map['targetDir'] as String?,
      error: map['error'] as String?,
    );
  }

  final String workId;
  final String state;
  final int? progress;
  final int? current;
  final int? total;
  final int? fileCount;
  final String? targetDir;
  final String? error;
}

/// Servicio Dart que envuelve el MethodChannel hacia ModInstallerPlugin (Android nativo).
///
/// Responsabilidades:
/// - Abrir el picker SAF para que el usuario seleccione la carpeta de mods.
/// - Consultar si ya hay una carpeta seleccionada.
/// - Instalar un mod (ZIP) en la carpeta seleccionada.
/// - Descargar e instalar en cadena via WorkManager (downloadAndInstallMod).
/// - Cancelar operaciones en curso.
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
      throw ModInstallerException(
        e.message ?? 'Failed to open directory picker',
      );
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

  /// Descarga e instala en cadena via WorkManager.
  ///
  /// Encadena ModDownloadWorker → ModInstallWorker.
  /// Retorna inmediatamente con los workIds.
  /// El progreso se recibe via EventChannel (BackgroundInstallService).
  ///
  /// [installDestination] indica qué carpeta SAF usar como destino:
  /// 'mods' (KEY_TREE_URI) o 'dynos' (KEY_DYNOS_TREE_URI).
  Future<ModChainResult?> downloadAndInstallMod({
    required String url,
    required String modName,
    required String fileName,
    String? displayTitle,
    String? notificationTitle,
    String installDestination = 'mods',
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('downloadAndInstallMod', {
        'url': url,
        'modName': modName,
        'fileName': fileName,
        'displayTitle': displayTitle ?? modName,
        'notificationTitle': notificationTitle ?? displayTitle ?? modName,
        'installDestination': installDestination,
      });
      if (result == null) return null;
      return ModChainResult(
        downloadWorkId: result['downloadWorkId'] as String,
        installWorkId: result['installWorkId'] as String,
      );
    } on PlatformException catch (e) {
      throw ModInstallerException(
        e.message ?? 'Failed to start download + install',
      );
    }
  }

  /// Cancela todas las operaciones WorkManager asociadas a un mod.
  Future<bool> cancelModOperation({required String modName}) async {
    try {
      final result = await _channel.invokeMethod<bool>('cancelModOperation', {
        'modName': modName,
      });
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Reconecta observers nativos y devuelve el estado actual de los Workers
  /// que Flutter había persistido antes de cerrar el proceso.
  Future<Map<String, NativeWorkSnapshot>> reconcileBackgroundOperations(
    List<Map<String, String>> operations,
  ) async {
    if (operations.isEmpty) return const {};
    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'reconcileBackgroundOperations',
        {'operations': operations},
      );
      final result = <String, NativeWorkSnapshot>{};
      for (final entry in raw ?? const <dynamic>[]) {
        if (entry is! Map) continue;
        final snapshot = NativeWorkSnapshot.fromMap(entry);
        result[snapshot.workId] = snapshot;
      }
      return result;
    } on PlatformException catch (e) {
      throw ModInstallerException(
        e.message ?? 'Failed to reconcile background operations',
      );
    }
  }

  /// Copia un archivo local al directorio SAF de mods seleccionado.
  /// Elimina el archivo fuente tras la copia exitosa.
  /// Tira [ModInstallerException] si la copia falla.
  Future<void> copyFileToModsFolder({
    required String sourcePath,
    required String targetName,
  }) async {
    final result = await _channel.invokeMethod<bool>('copyFileToModsFolder', {
      'sourcePath': sourcePath,
      'targetName': targetName,
    });
    if (result != true) {
      throw const ModInstallerException('Failed to copy file to mods folder');
    }
  }

  /// Returns true if POST_NOTIFICATIONS is granted (always true on Android < 13).
  Future<bool> hasNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'hasNotificationPermission',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Returns true if a rationale dialog should be shown before requesting.
  Future<bool> shouldShowNotificationRationale() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'shouldShowNotificationRationale',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Shows system permission dialog for POST_NOTIFICATIONS.
  /// Returns true if granted, false if denied.
  Future<bool> requestNotificationPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'requestNotificationPermission',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Abre el explorador de archivos del sistema para que el usuario
  /// seleccione la carpeta de dynos. Retorna la URI si se seleccionó,
  /// null si el usuario canceló.
  Future<String?> openDynosPicker() async {
    try {
      final uri = await _channel.invokeMethod<String>('openDynosPicker');
      return uri;
    } on PlatformException catch (e) {
      throw ModInstallerException(
        e.message ?? 'Failed to open dynos directory picker',
      );
    }
  }

  /// Consulta si hay una carpeta de dynos seleccionada y accesible.
  Future<bool> isDynosDirectorySelected() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isDynosDirectorySelected',
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Obtiene la URI de dynos guardada (si existe y es accesible), o null.
  Future<String?> getSavedDynosUri() async {
    try {
      return await _channel.invokeMethod<String>('getSavedDynosUri');
    } on PlatformException {
      return null;
    }
  }

  /// Copia un archivo local al directorio SAF de dynos seleccionado.
  /// Elimina el archivo fuente tras la copia exitosa.
  Future<void> copyFileToDynosFolder({
    required String sourcePath,
    required String targetName,
  }) async {
    final result = await _channel.invokeMethod<bool>('copyFileToDynosFolder', {
      'sourcePath': sourcePath,
      'targetName': targetName,
    });
    if (result != true) {
      throw const ModInstallerException('Failed to copy file to DynOS folder');
    }
  }

  /// Instala un mod en la carpeta DynOS: extrae el ZIP en [zipPath] dentro
  /// de la carpeta DynOS seleccionada, bajo un subdirectorio con nombre
  /// [modName].
  ///
  /// [zipPath] debe ser una ruta absoluta al archivo ZIP.
  /// [modName] es el nombre sanitizado del mod (se usará como nombre de carpeta).
  ///
  /// Esta operación se ejecuta en un hilo nativo (no bloquea UI).
  /// El ZIP se elimina del filesystem tras la extracción exitosa.
  Future<ModInstallResult> installModToDynosFolder({
    required String zipPath,
    required String modName,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>(
        'installModToDynosFolder',
        {'zipPath': zipPath, 'modName': modName},
      );

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

  /// Revoca los permisos y limpia la selección de carpeta de dynos.
  Future<void> clearDynosSelection() async {
    try {
      await _channel.invokeMethod('clearDynosSelection');
    } on PlatformException {
      // Silently ignore
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

  /// Instalación en segundo plano via WorkManager (NO BLOQUEA la UI).
  ///
  /// Encola un OneTimeWorkRequest y retorna inmediatamente el workId.
  /// El progreso se recibe via EventChannel (BackgroundInstallService).
  Future<String?> installModBackground({
    required String zipPath,
    required String modName,
  }) async {
    try {
      final workId = await _channel.invokeMethod<String>(
        'installModBackground',
        {'zipPath': zipPath, 'modName': modName},
      );
      return workId;
    } on PlatformException catch (e) {
      throw ModInstallerException(
        e.message ?? 'Failed to start background install',
      );
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
