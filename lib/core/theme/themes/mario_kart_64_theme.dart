import 'package:flutter/material.dart';

import '../app_theme_design.dart';

/// Mario Kart 64 manual and map-select language rendered with flat native
/// surfaces. Checkers are painted by Flutter, so no repeating bitmap or blur
/// is needed while scrolling.
const marioKart64Theme = AppThemeDesign(
  id: AppThemeId.marioKart64,
  cornerRadius: 0,
  borderScale: 0.75,
  shadowBlur: 0,
  shadowOffsetScale: 0.75,
  chipSkew: 0,
  headingWeight: FontWeight.w400,
  headingTracking: -0.7,
  headingFontFamily: 'Mk64Racing',
  headingFontFamilyFallback: ['Roboto'],
  halftone: false,
  stripes: false,
  uppercaseLabels: false,
  softSettingsPanels: true,
  backdropStyle: AppBackdropStyle.checkered,
  surfaceTreatment: AppSurfaceTreatment.racing,
  playfulSelection: true,
  brandAsset: 'assets/themes/mk64/mk64.webp',
  light: AppThemePalette(
    background: Color(0xFFFBFAF4),
    surface: Color(0xFFFFFFF3),
    surfaceAlt: Color(0xFFE8E9F2),
    border: Color(0xFF36337A),
    shadow: Color(0xFF161937),
    ink: Color(0xFF24243D),
    inkDim: Color(0xFF5B5D6D),
    accent: Color(0xFFD42140),
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFFAD1933),
    secondaryAccent: Color(0xFFFFE470),
    surfaceHighlight: Color(0xFFFFFFFF),
    surfaceShade: Color(0xFFB5B8CA),
  ),
  dark: AppThemePalette(
    background: Color(0xFF111321),
    surface: Color(0xFF1B1C37),
    surfaceAlt: Color(0xFF292D53),
    border: Color(0xFF7F82B7),
    shadow: Color(0xFF090A18),
    ink: Color(0xFFF7F5EA),
    inkDim: Color(0xFFC6C8D9),
    accent: Color(0xFFFF6078),
    onAccent: Color(0xFF251019),
    accentText: Color(0xFFFF9AAA),
    secondaryAccent: Color(0xFFFFE470),
    surfaceHighlight: Color(0xFF45486E),
    surfaceShade: Color(0xFF0B0D20),
  ),
);
