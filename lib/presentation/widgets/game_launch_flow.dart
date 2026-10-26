import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/game_launcher_service.dart';
import 'app_navigation_scope.dart';
import 'app_snackbar.dart';
import 'game_setup_widgets.dart';

/// Every main-engine launch entry point offers the same getting-started path.
/// A failed launch of an installed game is not treated as a missing installation.
Future<void> launchGameWithGuide(BuildContext context) async {
  if (await GameLauncherService.launch() || !context.mounted) return;
  final installed = await GameLauncherService.isInstalled();
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  if (installed) {
    AppSnackbar.error(context, message: l10n.playGuideLaunchError);
    return;
  }
  final openGuide = await showGameSetupDialog(
    context,
    title: l10n.playGuideMissingTitle,
    body: l10n.playGuideMissingBody,
    confirm: l10n.playGuideRead,
    cancel: l10n.playGuideLater,
    icon: Icons.sports_esports_outlined,
  );
  if (context.mounted && openGuide == true) {
    openSecondaryDestination(context, '/how-to-play');
  }
}
