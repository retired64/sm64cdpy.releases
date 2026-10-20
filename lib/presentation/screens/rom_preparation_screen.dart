import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';
import '../widgets/rom_preparation_panel.dart';

class RomPreparationScreen extends StatelessWidget {
  const RomPreparationScreen({super.key, this.fromGuide = false});
  final bool fromGuide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final retro = RetroTheme.of(context);
    return RetroFixedHeaderView(
      title: Text(l.romPrepareTitle, style: retro.heading(size: 22)),
      child: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            RomPreparationPanel(
              onContinueGuide: fromGuide
                  ? () => context.go('/how-to-play?step=2')
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
