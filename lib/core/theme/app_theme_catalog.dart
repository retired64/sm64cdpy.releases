import 'app_theme_design.dart';
import 'themes/minimal_theme.dart';
import 'themes/mario64_theme.dart';
import 'themes/mario_kart_64_theme.dart';
import 'themes/minish_cap_theme.dart';
import 'themes/sm64_intro_theme.dart';
import 'themes/retro_manga_theme.dart';

/// The same immutable definitions drive the selector previews and the app.
abstract final class AppThemeCatalog {
  static const designs = <AppThemeDesign>[
    minimalTheme,
    retroMangaTheme,
    minishCapTheme,
    marioKart64Theme,
    mario64Theme,
    sm64IntroTheme,
  ];

  static AppThemeDesign resolve(AppThemeId id) =>
      designs.firstWhere((design) => design.id == id);
}
