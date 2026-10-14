import 'package:flutter/material.dart';

/// Persisted IDs are independent from localized names and catalogue ordering.
enum AppThemeId {
  retroManga('retro_manga'),
  mario64('mario64');

  const AppThemeId(this.storageKey);
  final String storageKey;

  static AppThemeId fromStorage(String? value) {
    for (final id in values) {
      if (id.storageKey == value) return id;
    }
    return retroManga;
  }
}

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

  static AppThemePalette lerp(
    AppThemePalette a,
    AppThemePalette b,
    double t,
  ) => AppThemePalette(
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
    this.bodyFontFamily,
    this.halftone = true,
    this.stripes = true,
    this.uppercaseLabels = true,
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
  final String? bodyFontFamily;
  final bool halftone;
  final bool stripes;
  final bool uppercaseLabels;

  AppThemePalette palette(bool isDark) => isDark ? dark : light;
}
