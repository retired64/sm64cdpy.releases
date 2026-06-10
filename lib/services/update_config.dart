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
    String abi,
  ) {
    final tagName = json['tag_name'] as String? ?? 'v0.0.0';
    final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

    final assets = json['assets'] as List<dynamic>? ?? [];
    final downloadUrl = _selectApkUrl(assets, abi);

    final selectedAsset = _findAsset(assets, abi);
    final size = selectedAsset?['size'] as int?;

    return UpdateConfig(
      latestVersion: version,
      updateUrl: downloadUrl,
      changelog: json['body'] as String?,
      apkSize: size,
      forceUpdate: false,
    );
  }

  static Map<String, dynamic>? _findAsset(List<dynamic> assets, String abi) {
    final abiKey = _abiToKey(abi);
    try {
      return assets.firstWhere(
        (a) =>
            (a['name'] as String).toLowerCase().contains(abiKey) &&
            (a['name'] as String).endsWith('.apk'),
      ) as Map<String, dynamic>?;
    } catch (_) {
      try {
        return assets.firstWhere(
          (a) => (a['name'] as String).endsWith('.apk'),
        ) as Map<String, dynamic>?;
      } catch (_) {
        return null;
      }
    }
  }

  static String _selectApkUrl(List<dynamic> assets, String abi) {
    final asset = _findAsset(assets, abi);
    return asset?['browser_download_url'] as String? ?? '';
  }

  static String _abiToKey(String abi) {
    return switch (abi) {
      'arm64-v8a' => 'arm64',
      'armeabi-v7a' => 'arm32',
      'x86_64' => 'x86_64',
      _ => 'arm64',
    };
  }
}
