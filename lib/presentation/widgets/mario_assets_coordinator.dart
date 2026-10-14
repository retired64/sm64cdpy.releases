import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/mario_theme_assets_provider.dart';
import 'app_snackbar.dart';

/// One terminal message, including when the user navigates away from Settings.
class MarioAssetsCoordinator extends ConsumerWidget {
  const MarioAssetsCoordinator({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(marioThemeAssetsProvider, (previous, next) {
      if (previous?.busy != true || next.busy || !context.mounted) return;
      final l10n = AppLocalizations.of(context);
      if (next.error != null) {
        AppSnackbar.error(context, message: next.error == 'unsupported' ? l10n.marioRomUnsupported : l10n.marioRomFailed);
      } else if (next.imported > (previous?.imported ?? 0)) {
        AppSnackbar.success(context, message: l10n.marioRomSuccess);
      }
    });
    return child;
  }
}
