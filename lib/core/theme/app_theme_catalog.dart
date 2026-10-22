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
    marioKart64Theme,
  ];

  // Definiciones internas conservadas para helpers visuales y compatibilidad.
  // No son opciones disponibles ni se restauran desde preferencias antiguas.
  static AppThemeDesign resolve(AppThemeId id) => switch (id) {
    AppThemeId.minishCap => minishCapTheme,
    AppThemeId.mario64 => mario64Theme,
    AppThemeId.sm64Intro => sm64IntroTheme,
    _ => designs.firstWhere((design) => design.id == id),
  };
}
