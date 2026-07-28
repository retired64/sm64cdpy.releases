import 'package:http/http.dart' as http;

const _kValidExtensions = {'.zip', '.lua', '.rar', '.7z'};

String _validFileExtension(String name) {
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) return '';
  final ext = name.substring(dot).toLowerCase();
  return _kValidExtensions.contains(ext) ? ext : '';
}

String sanitizeModTitle(String title) {
  return title
      .toLowerCase()
      .replaceAll(RegExp(r"[^\w\s\-]"), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-|-$'), '')
      .trim();
}

String _inferFileName(String url, String modTitle, {int? index}) {
  final uri = Uri.tryParse(url);

  if (uri != null) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final lastSegment = segments.isNotEmpty ? segments.last : '';
    if (lastSegment.isNotEmpty &&
        lastSegment != 'download' &&
        _validFileExtension(lastSegment).isNotEmpty) {
      return lastSegment;
    }

    if (lastSegment.isNotEmpty &&
        lastSegment != 'download' &&
        _validFileExtension(lastSegment).isEmpty &&
        lastSegment.length > 2 &&
        !RegExp(r'^\d+$').hasMatch(lastSegment)) {
      return '$lastSegment.zip';
    }

    final fileParam = uri.queryParameters['file'] ?? '';
    if (_validFileExtension(fileParam).isNotEmpty) {
      return fileParam;
    }
  }

  final base = sanitizeModTitle(modTitle);
  final safeName = base.isNotEmpty ? base : 'mod';
  final suffix = index != null && index > 1 ? '-$index' : '';
  return '$safeName$suffix';
}

/// Detecta URLs de GitHub blob viewer y las convierte a raw para descarga
/// directa. Si la URL no es un blob de GitHub, retorna null.
String? _tryGitHubBlobToRaw(String url) {
  final match = RegExp(
    r'^https?://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)$',
  ).firstMatch(url);
  if (match == null) return null;

  final owner = match.group(1)!;
  final repo = match.group(2)!;
  final branch = match.group(3)!;
  final path = match.group(4)!;
  return 'https://raw.githubusercontent.com/$owner/$repo/$branch/$path';
}

/// Extrae el nombre de archivo de un header Content-Disposition.
/// Soporta RFC 5987 (filename*=UTF-8''...) y formato simple
/// (filename="...").
String? _parseContentDisposition(String header) {
  // RFC 5987: filename*=UTF-8''encoded-name
  final rfc5987Match = RegExp(
    r"filename\*=(?:UTF-8''|utf-8'')([^;]+)",
    caseSensitive: false,
  ).firstMatch(header);
  if (rfc5987Match != null) {
    return Uri.decodeComponent(rfc5987Match.group(1)!);
  }

  // Simple: filename="name.zip" or filename=name.zip
  final simpleMatch = RegExp(
    r'filename\s*=\s*"?([^";\r\n]+)"?',
    caseSensitive: false,
  ).firstMatch(header);
  if (simpleMatch != null) {
    return simpleMatch.group(1)!.trim();
  }

  return null;
}

/// Sanitiza un nombre de archivo obtenido del servidor.
/// Previene path traversal y elimina caracteres no imprimibles.
String? _sanitizeRawFilename(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final name = raw
      .replaceAll('\x00', '')
      .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '')
      .trim();
  if (name.isEmpty || name == '.' || name == '..') return null;
  if (name.contains('/') || name.contains('\\')) {
    final parts = name.replaceAll('\\', '/').split('/');
    final last = parts.lastWhere((p) => p.isNotEmpty, orElse: () => '');
    if (last.isEmpty || last == '.' || last == '..') return null;
    return last;
  }
  return name;
}

class DownloadUrlResolver {
  DownloadUrlResolver._();
  static final DownloadUrlResolver instance = DownloadUrlResolver._();

  final _filenameCache = <String, String>{};

  /// Resuelve el nombre de archivo para una URL de descarga.
  ///
  /// Estrategia en capas:
  ///   1. Cache de sesión (URL → filename)
  ///   2. GitHub blob viewer → raw URL + extraer filename del path
  ///   3. HEAD request → Content-Disposition (RFC 5987 + simple)
  ///   4. Fallback: inferir del URL + modTitle
  Future<String> resolveDownloadFilename(
    String url,
    String modTitle, {
    int? index,
  }) async {
    final cached = _filenameCache[url];
    if (cached != null) return cached;

    // GitHub blob → raw transform
    final rawUrl = _tryGitHubBlobToRaw(url);
    if (rawUrl != null) {
      final rawFilename = rawUrl.split('/').last.split('?').first;
      final sanitized = _sanitizeRawFilename(rawFilename);
      if (sanitized != null && sanitized.isNotEmpty) {
        _filenameCache[url] = sanitized;
        return sanitized;
      }
    }

    // HEAD request → Content-Disposition
    try {
      final headResp = await http
          .head(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      final disposition = headResp.headers['content-disposition'];
      if (disposition != null) {
        final parsed = _parseContentDisposition(disposition);
        final sanitized = _sanitizeRawFilename(parsed);
        if (sanitized != null && sanitized.isNotEmpty) {
          _filenameCache[url] = sanitized;
          return sanitized;
        }
      }
    } catch (_) {
      // Timeout, network error → fall through to inference
    }

    // Fallback: infer from URL + modTitle
    final inferred = _inferFileName(url, modTitle, index: index);
    _filenameCache[url] = inferred;
    return inferred;
  }
}
