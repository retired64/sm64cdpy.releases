import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_navigator.dart';

final appNavigatorProvider = Provider<AppNavigator>((ref) => AppNavigator());
