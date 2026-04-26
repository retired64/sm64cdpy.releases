import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../models/dynos_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DynosDatasource
//
// Estrategia de carga (por prioridad):
//   1. Cache en memoria  → mismo ciclo de vida de la app.
//   2. JSON descargado   → guardado en getApplicationDocumentsDirectory().
//                          Se actualiza cuando el usuario pulsa "Reload".
//   3. JSON bundled      → assets/db/dynos.json  (fallback).
//
// Flujo de "Reload database":
//   fetchRemote() → descarga de GitHub → persiste en disco → invalidateCache()
//   → el provider refresh hace que la UI recargue desde el nuevo JSON.
// ─────────────────────────────────────────────────────────────────────────────

class DynosDatasource {
  List<DynosModel>? _cache;

  // ── URLs y nombres de archivo ──────────────────────────────────────────────

  static const String _remoteUrl = AppConstants.dynosRemoteUrl;
  static const String _localFileName = 'dynos.json';

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_localFileName');
  }

  // ── Lectura ────────────────────────────────────────────────────────────────

  Future<List<DynosModel>> getAll() async {
    if (_cache != null) return _cache!;
    final raw = await _readRaw();
    _cache = _parse(raw);
    return _cache!;
  }

  /// Lee el JSON descargado si existe; si no, usa el bundled de assets.
  Future<String> _readRaw() async {
    try {
      final file = await _localFile();
      if (await file.exists()) {
        return await file.readAsString();
      }
    } catch (_) {}
    return rootBundle.loadString(AppConstants.dynosAssetPath);
  }

  // ── Descarga remota ────────────────────────────────────────────────────────

  /// Descarga el JSON desde GitHub y lo persiste localmente.
  /// Retorna [FetchResult] para que Settings muestre el mensaje correcto.
  Future<FetchResult> fetchRemote() async {
    try {
      final response = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        return FetchResult.error(
          'Server returned ${response.statusCode}. Try again later.',
        );
      }

      final body = response.body;

      // Validación mínima: JSON válido con clave "dynos"
      final decoded = json.decode(body) as Map<String, dynamic>;
      if (!decoded.containsKey('dynos')) {
        return const FetchResult.error('Invalid database format received.');
      }

      final modCount = (decoded['dynos'] as Map<String, dynamic>).length;
      final generatedAt = decoded['generated_at'] as String? ?? '';

      // Persistir en disco
      final file = await _localFile();
      await file.writeAsString(body, flush: true);

      // Limpiar cache para que el próximo getAll() lea desde el nuevo archivo
      invalidateCache();

      return FetchResult.success(modCount: modCount, generatedAt: generatedAt);
    } on SocketException {
      return const FetchResult.error(
        'No internet connection. Check your network and try again.',
      );
    } on HttpException {
      return const FetchResult.error('Could not reach the server.');
    } on FormatException {
      return const FetchResult.error(
        'The downloaded file has an unexpected format.',
      );
    } catch (e) {
      return FetchResult.error('Unexpected error: $e');
    }
  }

  // ── Utilidades ─────────────────────────────────────────────────────────────

  List<DynosModel> _parse(String raw) {
    final data = json.decode(raw) as Map<String, dynamic>;
    final modsMap = data['dynos'] as Map<String, dynamic>? ?? {};
    return modsMap.entries.map((e) {
      final map = e.value as Map<String, dynamic>;
      final id = map['id'] as String? ?? e.key;
      return DynosModel.fromJson(id, map);
    }).toList();
  }

  void invalidateCache() => _cache = null;

  /// Borra el JSON descargado y vuelve al bundled en el próximo getAll().
  Future<void> deleteLocalDb() async {
    try {
      final file = await _localFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}
    invalidateCache();
  }

  /// True si hay un JSON descargado en disco (distinto del bundled).
  Future<bool> hasLocalDb() async {
    try {
      final file = await _localFile();
      return file.existsSync();
    } catch (_) {
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FetchResult — resultado tipado de la descarga remota
// ─────────────────────────────────────────────────────────────────────────────
class FetchResult {
  const FetchResult._({
    required this.success,
    this.modCount,
    this.generatedAt,
    this.errorMessage,
  });

  const FetchResult.success({
    required int modCount,
    required String generatedAt,
  }) : this._(success: true, modCount: modCount, generatedAt: generatedAt);

  const FetchResult.error(String message)
    : this._(success: false, errorMessage: message);

  final bool success;
  final int? modCount; // cuántos mods tiene el JSON descargado
  final String? generatedAt; // timestamp del scraper
  final String? errorMessage;
}
