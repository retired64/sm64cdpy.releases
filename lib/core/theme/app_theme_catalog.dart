import 'app_theme_design.dart';
import 'themes/mario64_theme.dart';
import 'themes/retro_manga_theme.dart';

/// The same immutable definitions drive the selector previews and the app.
abstract final class AppThemeCatalog {
  static const designs = <AppThemeDesign>[retroMangaTheme, mario64Theme];

  static AppThemeDesign resolve(AppThemeId id) =>
      designs.firstWhere((design) => design.id == id);
}
