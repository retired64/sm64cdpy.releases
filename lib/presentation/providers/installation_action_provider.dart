import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/install_identity.dart';
import '../../domain/entities/installation_action.dart';
import 'installation_library_provider.dart';
import 'mod_providers.dart';

final installationActionProvider = Provider.family
    .autoDispose<InstallationActionState, InstallIdentity>((ref, identity) {
      final operations = ref.watch(bgInstallStateProvider);
      final libraryValue = ref.watch(installationLibraryProvider);
      return InstallationActionSelector.select(
        identity: identity,
        operation: operations[identity.operationKey],
        library: libraryValue.value?.snapshot,
        libraryLoading: libraryValue.isLoading,
      );
    });
