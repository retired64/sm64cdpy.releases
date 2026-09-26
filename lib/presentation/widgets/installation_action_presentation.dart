import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/installation_action.dart';
import '../../l10n/app_localizations.dart';
import '../../services/background_install_service.dart';
import '../providers/installation_library_provider.dart';

extension InstallationActionPresentation on InstallationPrimaryAction {
  String label(AppLocalizations l10n) => switch (this) {
    InstallationPrimaryAction.checking => l10n.installationChecking,
    InstallationPrimaryAction.download => l10n.sharedDownload,
    InstallationPrimaryAction.cancel => l10n.installationCancel,
    InstallationPrimaryAction.installed => l10n.installationInstalled,
    InstallationPrimaryAction.update => l10n.installationUpdate,
    InstallationPrimaryAction.reinstall => l10n.installationReinstall,
    InstallationPrimaryAction.verify => l10n.installationVerify,
    InstallationPrimaryAction.selectFolder => l10n.installationSelectFolder,
  };

  IconData get icon => switch (this) {
    InstallationPrimaryAction.checking => Icons.hourglass_top_rounded,
    InstallationPrimaryAction.download => Icons.download_rounded,
    InstallationPrimaryAction.cancel => Icons.close_rounded,
    InstallationPrimaryAction.installed => Icons.check_circle_rounded,
    InstallationPrimaryAction.update => Icons.system_update_alt_rounded,
    InstallationPrimaryAction.reinstall => Icons.refresh_rounded,
    InstallationPrimaryAction.verify => Icons.fact_check_outlined,
    InstallationPrimaryAction.selectFolder => Icons.folder_open_rounded,
  };
}

Future<void> runCanonicalInstallationAction({
  required BuildContext context,
  required WidgetRef ref,
  required InstallationActionState state,
  required Future<void> Function() onTransfer,
}) async {
  switch (state.primaryAction) {
    case InstallationPrimaryAction.cancel:
      await BackgroundInstallService.instance.cancelMod(
        state.identity.operationKey,
      );
    case InstallationPrimaryAction.verify:
      await ref
          .read(installationLibraryProvider.notifier)
          .verifyArtifact(state.identity.artifactKey);
    case InstallationPrimaryAction.selectFolder:
      if (context.mounted) context.go('/settings');
    case InstallationPrimaryAction.download:
    case InstallationPrimaryAction.update:
    case InstallationPrimaryAction.reinstall:
      await onTransfer();
    case InstallationPrimaryAction.checking:
    case InstallationPrimaryAction.installed:
      break;
  }
}
