import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_design.dart';
import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/manga_menu_audio_provider.dart';
import '../providers/theme_provider.dart';
import 'app_snackbar.dart';

class MangaMenuSoundSetting extends ConsumerWidget {
  const MangaMenuSoundSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(themeDesignProvider).id != AppThemeId.retroManga) {
      return const SizedBox.shrink();
    }
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: retro.surfaceDecoration(),
        child: SwitchListTile(
          key: const ValueKey('manga-menu-sounds'),
          title: Text(l.mangaMenuSoundsTitle, style: retro.heading(size: 14)),
          subtitle: Text(l.mangaMenuSoundsDescription, style: retro.body(size: 12)),
          secondary: Icon(Icons.volume_up_outlined, color: retro.accentText),
          value: ref.watch(mangaMenuSoundsProvider),
          onChanged: (enabled) async {
            final saved = await ref.read(mangaMenuSoundsProvider.notifier).setEnabled(enabled);
            if (!context.mounted || saved) return;
            AppSnackbar.error(context, message: l.themeSaveFailed);
          },
        ),
      ),
    );
  }
}
