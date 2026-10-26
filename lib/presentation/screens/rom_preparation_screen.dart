import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/app_shell.dart';
import '../widgets/manga_deluxe_screen_visuals.dart';
import '../widgets/manga_navigation_scope.dart';
import '../widgets/rom_preparation_panel.dart';

class RomPreparationScreen extends StatelessWidget {
  const RomPreparationScreen({super.key, this.fromGuide = false});
  final bool fromGuide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return RetroFixedHeaderView(
      title: MangaDeluxeScreenTitle(label: l.romPrepareTitle, size: 22),
      child: MangaDeluxeTypography(
        child: SafeArea(
          top: false,
          bottom: !MangaNavigationScope.of(context),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              28 + mangaNavigationScrollInset(context),
            ),
            children: [
              RomPreparationPanel(
                onContinueGuide: fromGuide ? () => context.pop(true) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
