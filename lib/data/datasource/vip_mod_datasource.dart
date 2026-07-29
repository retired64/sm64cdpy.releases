import '../../core/constants/app_constants.dart';
import '../models/vip_mod_model.dart';
import 'remote_json_datasource.dart';

class VipModDatasource {
  final RemoteJsonDatasource<VipModModel> _impl =
      RemoteJsonDatasource<VipModModel>(
    remoteUrl: AppConstants.vipModsRemoteUrl,
    assetPath: AppConstants.vipModsAssetPath,
    localFileName: 'vip.json',
    jsonKey: 'vip_mods',
    fromJson: (id, json) => VipModModel.fromJson(id, json),
    parseJson: mapJsonParser,
    getFetchInfo: defaultFetchInfo,
  );

  Future<List<VipModModel>> getAll() => _impl.getAll();
  Future<FetchResult> fetchRemote() => _impl.fetchRemote();
  Future<bool> hasLocalDb() => _impl.hasLocalDb();
  Future<void> deleteLocalDb() => _impl.deleteLocalDb();
  void invalidateCache() => _impl.invalidateCache();
}
