import '../../core/constants/app_constants.dart';
import '../models/dynos_model.dart';
import 'remote_json_datasource.dart';

class DynosDatasource {
  final RemoteJsonDatasource<DynosModel> _impl =
      RemoteJsonDatasource<DynosModel>(
    remoteUrl: AppConstants.dynosRemoteUrl,
    assetPath: AppConstants.dynosAssetPath,
    localFileName: 'dynos.json',
    jsonKey: 'dynos',
    fromJson: (id, json) => DynosModel.fromJson(id, json),
    parseJson: mapJsonParser,
    getFetchInfo: defaultFetchInfo,
  );

  Future<List<DynosModel>> getAll() => _impl.getAll();
  Future<FetchResult> fetchRemote() => _impl.fetchRemote();
  Future<bool> hasLocalDb() => _impl.hasLocalDb();
  Future<void> deleteLocalDb() => _impl.deleteLocalDb();
  void invalidateCache() => _impl.invalidateCache();
}
