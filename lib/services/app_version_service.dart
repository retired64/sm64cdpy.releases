import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  AppVersionService._();

  static String _current = '';

  static String get current => _current;

  static Future<void> init() async {
    _current = (await PackageInfo.fromPlatform()).version;
  }
}
