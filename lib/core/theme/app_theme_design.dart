import 'package:flutter/material.dart';

/// Persisted IDs are independent from localized names and catalogue ordering.
enum AppThemeId {
  minimal('minimal'),
  retroManga('retro_manga'),
  minishCap('minish_cap'),
  marioKart64('mario_kart_64'),
  mario64('mario64'),
  sm64Intro('sm64_intro');

  const AppThemeId(this.storageKey);
  final String storageKey;

  static AppThemeId fromStorage(String? value) {
    for (final id in values) {
      if (id.storageKey == value) return id;
    }
    return retroManga;
  }
}

/// Code-native backdrop families. They intentionally describe a visual
/// treatment instead of a product/theme ID so shared widgets never need to
/// branch on `mario64`.
enum AppBackdropStyle {
  none,
  halftone,
  parchment,
  checkered,
  n64Sky,
  introMenu,
}

/// Surface language shared by cards, chips, buttons and settings panels.
enum AppSurfaceTreatment { minimal, flat, folio, racing, beveled }

/// Every surface has an explicit text role. Semantic and brand colors remain
/// separate from the selected interface accent.
@immutable
class AppThemePalette {
  const AppThemePalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.shadow,
    required this.ink,
    required this.inkDim,
    required this.accent,
    required this.onAccent,
    required this.accentText,
    this.secondaryAccent,
    this.surfaceHighlight,
    this.surfaceShade,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color shadow;
  final Color ink;
  final Color inkDim;
  final Color accent;
  final Color onAccent;
  final Color accentText;
  final Color? secondaryAccent;
  final Color? surfaceHighlight;
  final Color? surfaceShade;

  static AppThemePalette lerp(AppThemePalette a, AppThemePalette b, double t) =>
      AppThemePalette(
        background: Color.lerp(a.background, b.background, t)!,
        surface: Color.lerp(a.surface, b.surface, t)!,
        surfaceAlt: Color.lerp(a.surfaceAlt, b.surfaceAlt, t)!,
        border: Color.lerp(a.border, b.border, t)!,
        shadow: Color.lerp(a.shadow, b.shadow, t)!,
        ink: Color.lerp(a.ink, b.ink, t)!,
        inkDim: Color.lerp(a.inkDim, b.inkDim, t)!,
        accent: Color.lerp(a.accent, b.accent, t)!,
        onAccent: Color.lerp(a.onAccent, b.onAccent, t)!,
        accentText: Color.lerp(a.accentText, b.accentText, t)!,
        secondaryAccent: Color.lerp(
          a.secondaryAccent ?? a.accent,
          b.secondaryAccent ?? b.accent,
          t,
        ),
        surfaceHighlight: Color.lerp(
          a.surfaceHighlight ?? a.surface,
          b.surfaceHighlight ?? b.surface,
          t,
        ),
        surfaceShade: Color.lerp(
          a.surfaceShade ?? a.shadow,
          b.surfaceShade ?? b.shadow,
          t,
        ),
      );
}

/// Shared visual contract. Screens render roles, never branch on a theme ID.
@immutable
class AppThemeDesign {
  const AppThemeDesign({
    required this.id,
    required this.light,
    required this.dark,
    this.cornerRadius = 0,
    this.borderScale = 1,
    this.shadowBlur = 0,
    this.shadowOffsetScale = 1,
    this.chipSkew = 0.18,
    this.headingWeight = FontWeight.w900,
    this.headingTracking = -0.3,
    this.headingFontFamily,
    this.headingFontFamilyFallback = const [],
    this.bodyFontFamily,
    this.halftone = true,
    this.stripes = true,
    this.uppercaseLabels = true,
    this.softSettingsPanels = false,
    this.backdropStyle = AppBackdropStyle.halftone,
    this.surfaceTreatment = AppSurfaceTreatment.flat,
    this.playfulSelection = false,
    this.drawerRasterIcons = false,
    this.brandAsset,
  });

  final AppThemeId id;
  final AppThemePalette light;
  final AppThemePalette dark;
  final double cornerRadius;
  final double borderScale;
  final double shadowBlur;
  final double shadowOffsetScale;
  final double chipSkew;
  final FontWeight headingWeight;
  final double headingTracking;
  final String? headingFontFamily;
  final List<String> headingFontFamilyFallback;
  final String? bodyFontFamily;
  final bool halftone;
  final bool stripes;
  final bool uppercaseLabels;
  final bool softSettingsPanels;
  final AppBackdropStyle backdropStyle;
  final AppSurfaceTreatment surfaceTreatment;
  final bool playfulSelection;
  final bool drawerRasterIcons;
  final String? brandAsset;

  AppThemePalette palette(bool isDark) => isDark ? dark : light;
}
