import '../../core/constants/app_constants.dart';
import '../models/mod_model.dart';
import 'remote_json_datasource.dart';

class LocalModDatasource {
  final RemoteJsonDatasource<ModModel> _impl = RemoteJsonDatasource<ModModel>(
    remoteUrl:
        'https://raw.githubusercontent.com/retired64/sm64cdpy.releases/main/db/database_sm64coopdx.json',
    assetPath: AppConstants.dbAssetPath,
    localFileName: 'database_sm64coopdx.json',
    jsonKey: 'mods',
    fromJson: (id, json) => ModModel.fromJson(id, json),
    parseJson: listOrMapJsonParser,
    getFetchInfo: flexibleFetchInfo,
    minimumRelativeItemCount: 0.75,
    validateJson: _validateModDatabase,
  );

  Future<List<ModModel>> getAll() => _impl.getAll();
  Future<FetchResult> fetchRemote() => _impl.fetchRemote();
  Future<bool> hasLocalDb() => _impl.hasLocalDb();
  Future<void> deleteLocalDb() => _impl.deleteLocalDb();
  void invalidateCache() => _impl.invalidateCache();
}

void _validateModDatabase(Map<String, dynamic> decoded) {
  final schemaVersion = (decoded['schema_version'] as num?)?.toInt() ?? 1;
  if (schemaVersion >= 2 && decoded['catalog_status'] != 'complete') {
    throw const FormatException('Catalog generation is incomplete');
  }
  if (schemaVersion >= 2 &&
      !RegExp(
        r'^sha256:[0-9a-f]{64}$',
      ).hasMatch(decoded['catalog_id']?.toString() ?? '')) {
    throw const FormatException('Invalid catalog identity');
  }
  final mods = decoded['mods'];
  if (mods is! List && mods is! Map<String, dynamic>) {
    throw const FormatException('mods must be a list or object');
  }
  final values = mods is List ? mods : mods.values.toList(growable: false);
  final ids = <String>{};
  for (final value in values) {
    if (value is! Map) throw const FormatException('Invalid mod entry');
    final id = (value['id'] ?? value['slug'] ?? '').toString().trim();
    final name = (value['name'] ?? value['title'] ?? '').toString().trim();
    if (id.isEmpty || name.isEmpty || !ids.add(id)) {
      throw const FormatException('Missing or duplicate mod identity');
    }
    final versions = value['versions'];
    if (versions != null && versions is! List) {
      throw const FormatException('versions must be a list');
    }
    final versionIds = <String>{};
    for (final version in versions as List? ?? const <dynamic>[]) {
      if (version is! Map) throw const FormatException('Invalid version');
      if (schemaVersion >= 2 &&
          !versionIds.add(version['version_id']?.toString().trim() ?? '')) {
        throw const FormatException('Missing or duplicate version identity');
      }
      final files = version['files'];
      if (files != null && files is! List) {
        throw const FormatException('files must be a list');
      }
      if (version['resolved'] == true && (files is! List || files.isEmpty)) {
        throw const FormatException('Resolved version has no files');
      }
      final fileIds = <String>{};
      for (final file in files as List? ?? const <dynamic>[]) {
        if (file is! Map ||
            (file['download_url']?.toString().trim().isEmpty ?? true)) {
          throw const FormatException('Invalid downloadable file');
        }
        if (schemaVersion >= 2 &&
            !fileIds.add(file['file_id']?.toString().trim() ?? '')) {
          throw const FormatException('Missing or duplicate file identity');
        }
      }
    }
  }
}
