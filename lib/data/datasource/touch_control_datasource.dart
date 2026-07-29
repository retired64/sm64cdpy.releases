import '../../core/constants/app_constants.dart';
import '../models/touch_control_model.dart';
import 'remote_json_datasource.dart';

class TouchControlDatasource {
  final RemoteJsonDatasource<TouchControlModel> _impl =
      RemoteJsonDatasource<TouchControlModel>(
    remoteUrl: AppConstants.touchControlsRemoteUrl,
    assetPath: AppConstants.touchControlsAssetPath,
    localFileName: 'touch_controls.json',
    jsonKey: 'touch_controls',
    fromJson: (id, json) => TouchControlModel.fromJson(id, json),
    parseJson: mapJsonParser,
    getFetchInfo: defaultFetchInfo,
  );

  Future<List<TouchControlModel>> getAll() => _impl.getAll();
  Future<FetchResult> fetchRemote() => _impl.fetchRemote();
  Future<bool> hasLocalDb() => _impl.hasLocalDb();
  Future<void> deleteLocalDb() => _impl.deleteLocalDb();
  void invalidateCache() => _impl.invalidateCache();
}
