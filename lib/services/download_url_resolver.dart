import 'dart:convert';

import 'package:http/http.dart' as http;

const _kValidExtensions = {'.zip', '.lua', '.rar', '.7z'};

// ── Resolución de URL (no solo filename) — ver resolveDownloadUrl() ────────
//
// Nombres de asset que GitHub genera automáticamente para el "source code"
// de una release (zip/tar.gz del repo completo). Nunca son el mod real, así
// que se excluyen aunque tengan extensión válida — mismo criterio que ya
// aplica el dumper Python hermano (coopdx64.py) para este mismo problema.
const _kSourceOnlyAssetNames = {
  'source code (zip)',
  'source code (tar.gz)',
  'source.zip',
  'source.tar.gz',
};

// Detecta páginas de GitHub Releases (no assets descargables directos):
//   https://github.com/owner/repo/releases
//   https://github.com/owner/repo/releases/latest
//   https://github.com/owner/repo/releases/tag/v4.0
// El grupo 3 captura el tag específico solo si viene después de "/tag/";
// queda null tanto para "/releases" a secas como para "/releases/latest"
// (ambos casos se resuelven contra el endpoint .../releases/latest de la API).
final _githubReleasesPageRe = RegExp(
  r'^https?://github\.com/([^/]+)/([^/]+)/releases(?:/(?:tag/([^/]+)|latest))?/?$',
);

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
  return '$safeName$suffix.zip';
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
/// Previene path traversal, elimina caracteres no imprimibles,
/// y limpia el nombre base con [sanitizeModTitle] preservando la extensión.
///
/// Ejemplo: "[CS] Triple Baka Pack.zip" → "cs-triple-baka-pack.zip"
String? _sanitizeRawFilename(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  String name = raw
      .replaceAll('\x00', '')
      .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '')
      .trim();
  if (name.isEmpty || name == '.' || name == '..') return null;
  if (name.contains('/') || name.contains('\\')) {
    final parts = name.replaceAll('\\', '/').split('/');
    name = parts.lastWhere((p) => p.isNotEmpty, orElse: () => '');
    if (name.isEmpty || name == '.' || name == '..') return null;
  }

  final dot = name.lastIndexOf('.');
  if (dot > 0) {
    final base = name.substring(0, dot);
    final ext = name.substring(dot);
    final clean = sanitizeModTitle(base);
    name = clean.isNotEmpty ? '$clean$ext' : 'mod$ext';
  } else {
    final clean = sanitizeModTitle(name);
    name = clean.isNotEmpty ? clean : 'mod';
  }

  return name.isNotEmpty ? name : null;
}

class DownloadUrlResolver {
  DownloadUrlResolver._();
  static final DownloadUrlResolver instance = DownloadUrlResolver._();

  final _filenameCache = <String, String>{};
  final _urlCache = <String, String>{};

  /// Resuelve una URL "de página" (no descargable directamente) a la URL
  /// real del asset binario que debe entregarse al downloader nativo.
  ///
  /// PROBLEMA QUE RESUELVE: algunas fuentes (ej. render96.json) apuntan a
  /// `https://github.com/{owner}/{repo}/releases/latest`, que GitHub NO
  /// redirige a un archivo — redirige a la página HTML del release
  /// (`.../releases/tag/vX`), que lista los assets pero no es ella misma
  /// descargable. Si esa URL se pasa tal cual a
  /// `BackgroundInstallService.startDownloadAndInstall()`, el
  /// `ModDownloadWorker` nativo sigue el redirect correctamente pero termina
  /// descargando el HTML de la página (unos pocos KB) y guardándolo con
  /// extensión `.zip`. `ModInstallWorker` falla al intentar extraerlo (no es
  /// un ZIP válido) — normalmente sin feedback claro para el usuario.
  ///
  /// Casos cubiertos, en cascada (mismo patrón de fallback que ya usa
  /// [resolveDownloadFilename]):
  ///   1. GitHub blob viewer (`github.com/owner/repo/blob/branch/path`) →
  ///      URL raw directa. Esta conversión YA existía en
  ///      [_tryGitHubBlobToRaw], pero antes solo se usaba para inferir el
  ///      *nombre* de archivo — la URL real que se descargaba seguía siendo
  ///      la del visor HTML de GitHub. Ahora también se usa para la URL real.
  ///   2. Página de GitHub Releases (`/releases`, `/releases/latest`,
  ///      `/releases/tag/{tag}`) → se resuelve contra la API pública de
  ///      GitHub (`api.github.com/repos/{owner}/{repo}/releases/latest` o
  ///      `.../releases/tags/{tag}`) y se toma el `browser_download_url`
  ///      del primer asset con extensión válida, excluyendo el "source
  ///      code" autogenerado.
  ///   3. Cualquier otra URL (ej. las de VIP mods, que ya son
  ///      `raw.githubusercontent.com` directas) → passthrough, sin tocarla.
  ///
  /// Si la resolución falla por cualquier motivo (red, timeout, rate limit
  /// de GitHub, JSON inesperado, sin assets compatibles), se retorna la URL
  /// original sin modificar — el downloader nativo sigue teniendo su propia
  /// lógica de reintentos/errores, así que un passthrough no empeora nada
  /// respecto al comportamiento actual; solo no lo mejora en ese caso puntual.
  Future<String> resolveDownloadUrl(String url) async {
    final cached = _urlCache[url];
    if (cached != null) return cached;

    // Caso 1: GitHub blob viewer → raw URL (sin red, resolución local)
    final rawUrl = _tryGitHubBlobToRaw(url);
    if (rawUrl != null) {
      _urlCache[url] = rawUrl;
      return rawUrl;
    }

    // Caso 2: página de GitHub Releases → resolver vía API
    final match = _githubReleasesPageRe.firstMatch(url);
    if (match == null) return url; // no es un patrón conocido → passthrough

    final owner = match.group(1)!;
    final repo = match.group(2)!;
    final tag = match.group(3); // null para "/releases" y "/releases/latest"

    try {
      final apiUrl = tag != null
          ? 'https://api.github.com/repos/$owner/$repo/releases/tags/$tag'
          : 'https://api.github.com/repos/$owner/$repo/releases/latest';

      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {'Accept': 'application/vnd.github+json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return url;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final assets = json['assets'] as List<dynamic>?;
      if (assets == null || assets.isEmpty) return url;

      // Primer asset con extensión válida que NO sea el source code
      // autogenerado por GitHub (mismo criterio que _kValidExtensions ya
      // usa en el resto del archivo, para no introducir un segundo criterio
      // de "qué es un mod descargable").
      for (final asset in assets) {
        final a = asset as Map<String, dynamic>;
        final name = a['name'] as String? ?? '';
        final browserUrl = a['browser_download_url'] as String? ?? '';
        if (browserUrl.isEmpty) continue;
        if (_validFileExtension(name).isEmpty) continue;
        if (_kSourceOnlyAssetNames.contains(name.toLowerCase())) continue;

        _urlCache[url] = browserUrl;
        return browserUrl;
      }

      return url; // ningún asset compatible → passthrough
    } catch (_) {
      return url; // red/timeout/JSON inesperado → passthrough
    }
  }

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
