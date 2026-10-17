import 'package:flutter/material.dart';

import '../app_theme_design.dart';

/// Low-cost design driven by whitespace and typography instead of containers.
const minimalTheme = AppThemeDesign(
  id: AppThemeId.minimal,
  light: AppThemePalette(
    background: Color(0xFFF7F7F8),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F1F3),
    border: Color(0xFFD8DADE),
    shadow: Colors.transparent,
    ink: Color(0xFF17181A),
    inkDim: Color(0xFF666A70),
    accent: Color(0xFF2F6FED),
    onAccent: Color(0xFFFFFFFF),
    accentText: Color(0xFF2459BF),
  ),
  dark: AppThemePalette(
    background: Color(0xFF111214),
    surface: Color(0xFF191B1E),
    surfaceAlt: Color(0xFF22252A),
    border: Color(0xFF34383E),
    shadow: Colors.transparent,
    ink: Color(0xFFF2F3F5),
    inkDim: Color(0xFFA5A9B0),
    accent: Color(0xFF70A0FF),
    onAccent: Color(0xFF0D1B33),
    accentText: Color(0xFF8DB3FF),
  ),
  cornerRadius: 6,
  borderScale: 0.5,
  shadowBlur: 0,
  shadowOffsetScale: 0,
  chipSkew: 0,
  headingWeight: FontWeight.w700,
  headingTracking: 0,
  halftone: false,
  stripes: false,
  uppercaseLabels: false,
  softSettingsPanels: false,
  backdropStyle: AppBackdropStyle.none,
  surfaceTreatment: AppSurfaceTreatment.minimal,
);
