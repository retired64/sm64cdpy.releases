import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/mod_installer.dart';
import 'app_snackbar.dart';
import 'game_setup_widgets.dart';

/// Requests notifications at the moment a background operation is started.
/// Denial never blocks downloading or installation.
Future<bool> ensureNotificationPermission(
  BuildContext context,
  ModInstaller installer,
) async {
  if (await installer.hasNotificationPermission()) return true;
  if (!context.mounted) return false;

  final l10n = AppLocalizations.of(context);
  final proceed = await showGameSetupDialog(
    context,
    title: l10n.detailNotificationsNeeded,
    body: l10n.detailNotificationsBody,
    confirm: l10n.detailContinue,
    cancel: l10n.detailNotNow,
    icon: Icons.notifications_active_outlined,
  );
  if (!context.mounted) return false;
  if (proceed != true) {
    AppSnackbar.info(context, message: l10n.detailNotificationsSkipped);
    return false;
  }

  final granted = await installer.requestNotificationPermission();
  if (!context.mounted) return granted;
  if (!granted) {
    AppSnackbar.info(context, message: l10n.detailNotificationsDisabled);
  }
  return granted;
}
