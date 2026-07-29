import '../../core/constants/app_constants.dart';
import '../models/omm_rebirth_model.dart';
import 'remote_json_datasource.dart';

class OmmRebirthDatasource {
  final RemoteJsonDatasource<OmmRebirthModel> _impl =
      RemoteJsonDatasource<OmmRebirthModel>(
    remoteUrl: AppConstants.ommRebirthRemoteUrl,
    assetPath: AppConstants.ommRebirthAssetPath,
    localFileName: 'omm.json',
    jsonKey: 'omm_mods',
    fromJson: (id, json) => OmmRebirthModel.fromJson(id, json),
    parseJson: mapJsonParser,
    getFetchInfo: defaultFetchInfo,
  );

  Future<List<OmmRebirthModel>> getAll() => _impl.getAll();
  Future<FetchResult> fetchRemote() => _impl.fetchRemote();
  Future<bool> hasLocalDb() => _impl.hasLocalDb();
  Future<void> deleteLocalDb() => _impl.deleteLocalDb();
  void invalidateCache() => _impl.invalidateCache();
}
