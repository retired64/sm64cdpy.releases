import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/platform_environment.dart';
import '../../domain/contracts/platform_capabilities.dart';

final platformCapabilitiesProvider = Provider<PlatformCapabilities>(
  (_) => PlatformEnvironment.capabilities,
);
