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
  );

  Future<List<ModModel>> getAll() => _impl.getAll();
  Future<FetchResult> fetchRemote() => _impl.fetchRemote();
  Future<bool> hasLocalDb() => _impl.hasLocalDb();
  Future<void> deleteLocalDb() => _impl.deleteLocalDb();
  void invalidateCache() => _impl.invalidateCache();
}
