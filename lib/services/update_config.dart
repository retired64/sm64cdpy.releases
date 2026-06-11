import 'package:collection/collection.dart';

/// Tipos de ABI soportados para la selección de APK.
enum AbiType {
  arm64('arm64', 'arm64-v8a'),
  arm32('arm32', 'armeabi-v7a'),
  x8664('x86_64', 'x86_64');

  const AbiType(this.key, this.androidAbi);
  final String key;
  final String androidAbi;

  static AbiType fromAndroidAbi(String abi) {
    return AbiType.values.firstWhere(
      (t) => t.androidAbi == abi,
      orElse: () => AbiType.arm64,
    );
  }

  static AbiType fromKey(String key) {
    return AbiType.values.firstWhere(
      (t) => t.key == key,
      orElse: () => AbiType.arm64,
    );
  }
}

/// Modelo que representa la configuración de actualización
/// obtenida desde la GitHub Releases API.
class UpdateConfig {
  final String latestVersion;
  final String updateUrl;
  final String? changelog;
  final int? apkSize;
  final bool forceUpdate;

  const UpdateConfig({
    required this.latestVersion,
    required this.updateUrl,
    this.changelog,
    this.apkSize,
    this.forceUpdate = false,
  });

  /// Parsea la respuesta de la GitHub API:
  /// GET https://api.github.com/repos/retired64/sm64cdpy.releases/releases/latest
  factory UpdateConfig.fromGithubRelease(
    Map<String, dynamic> json,
    AbiType abi,
  ) {
    final tagName = json['tag_name'] as String? ?? 'v0.0.0';
    final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

    final assets = json['assets'] as List<dynamic>? ?? [];
    final downloadUrl = _selectApkUrl(assets, abi);

    final selectedAsset = _findAsset(assets, abi);
    final size = selectedAsset?['size'] as int?;

    final body = json['body'] as String? ?? '';
    final forceUpdate = body.contains('[FORCE]');
    final cleanedChangelog = _stripMarkdown(body);

    return UpdateConfig(
      latestVersion: version,
      updateUrl: downloadUrl,
      changelog: cleanedChangelog,
      apkSize: size,
      forceUpdate: forceUpdate,
    );
  }

  static Map<String, dynamic>? _findAsset(List<dynamic> assets, AbiType abi) {
    final abiKey = abi.key;
    return assets
        .cast<Map<String, dynamic>>()
        .firstWhereOrNull(
          (a) =>
              (a['name'] as String).toLowerCase().contains(abiKey) &&
              (a['name'] as String).endsWith('.apk'),
        ) ??
        assets
            .cast<Map<String, dynamic>>()
            .firstWhereOrNull(
              (a) => (a['name'] as String).endsWith('.apk'),
            );
  }

  static String _selectApkUrl(List<dynamic> assets, AbiType abi) {
    final asset = _findAsset(assets, abi);
    return asset?['browser_download_url'] as String? ?? '';
  }

  /// Limpia el changelog eliminando sintaxis Markdown de GitHub
  /// para mostrarlo como texto plano en la app.
  static String _stripMarkdown(String body) {
    var text = body;

    text = text.replaceAll('[FORCE]', '');
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    text = text.replaceAll('`', '');

    text = text.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1');

    text = text.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*(.+?)\*'), r'$1');
    text = text.replaceAll(RegExp(r'__(.+?)__'), r'$1');
    text = text.replaceAll(RegExp(r'_(.+?)_'), r'$1');

    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '');

    text = text.replaceAll(RegExp(r'^---+\s*$', multiLine: true), '');

    text = text.replaceAll(RegExp(r'^>\s?', multiLine: true), '');

    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }
}
