import 'package:flutter/material.dart';

import '../app_theme_design.dart';

const odysseyTheme = AppThemeDesign(
  id: AppThemeId.odyssey,
  cornerRadius: 18,
  borderScale: 0.5,
  shadowBlur: 12,
  shadowOffsetScale: 0.5,
  chipSkew: 0,
  headingWeight: FontWeight.w800,
  headingTracking: 0,
  halftone: false,
  stripes: false,
  uppercaseLabels: false,
  light: AppThemePalette(
    background: Color(0xFFF7F5F3),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEE6E3),
    border: Color(0xFF89716B),
    shadow: Color(0x332F1915),
    ink: Color(0xFF30211E),
    inkDim: Color(0xFF705C57),
    accent: Color(0xFFB91C35),
    accentText: Color(0xFFB91C35),
    onAccent: Color(0xFFFFFFFF),
  ),
  dark: AppThemePalette(
    background: Color(0xFF1B1517),
    surface: Color(0xFF2B2226),
    surfaceAlt: Color(0xFF3B2E33),
    border: Color(0xFFAA8F98),
    shadow: Color(0x66000000),
    ink: Color(0xFFFFF4F6),
    inkDim: Color(0xFFD3B5BE),
    accent: Color(0xFFFFA8BA),
    accentText: Color(0xFFFFA8BA),
    onAccent: Color(0xFF461220),
  ),
);
