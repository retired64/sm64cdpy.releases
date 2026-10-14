import 'package:flutter/material.dart';

import '../app_theme_design.dart';

const gamecubeTheme = AppThemeDesign(
  id: AppThemeId.gamecube,
  cornerRadius: 6,
  borderScale: 0.6,
  shadowBlur: 8,
  shadowOffsetScale: 0.5,
  chipSkew: 0,
  headingWeight: FontWeight.w700,
  headingTracking: 0.4,
  halftone: false,
  stripes: false,
  uppercaseLabels: false,
  light: AppThemePalette(
    background: Color(0xFFF0ECFA),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFE4DCF5),
    border: Color(0xFF766799),
    shadow: Color(0x33402B71),
    ink: Color(0xFF29213E),
    inkDim: Color(0xFF625475),
    accent: Color(0xFF59409C),
    accentText: Color(0xFF59409C),
    onAccent: Color(0xFFFFFFFF),
  ),
  dark: AppThemePalette(
    background: Color(0xFF171326),
    surface: Color(0xFF241D38),
    surfaceAlt: Color(0xFF33294B),
    border: Color(0xFF9B89BF),
    shadow: Color(0x66080314),
    ink: Color(0xFFF5F0FF),
    inkDim: Color(0xFFC0B2DA),
    accent: Color(0xFFC5ADFF),
    accentText: Color(0xFFC5ADFF),
    onAccent: Color(0xFF291747),
  ),
);
