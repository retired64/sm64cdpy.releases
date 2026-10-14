import 'package:flutter/material.dart';

import '../app_theme_design.dart';

/// Original UI styling inspired by a colorful platform game; no game assets.
const mario64Theme = AppThemeDesign(
  id: AppThemeId.mario64,
  cornerRadius: 12,
  chipSkew: 0,
  headingTracking: 0,
  halftone: false,
  stripes: false,
  uppercaseLabels: false,
  softSettingsPanels: true,
  light: AppThemePalette(
    background: Color(0xFFEAF5FF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFD8EAFE),
    border: Color(0xFF234C79),
    shadow: Color(0xFF234C79),
    ink: Color(0xFF172D49),
    inkDim: Color(0xFF435B77),
    accent: Color(0xFFC62828),
    accentText: Color(0xFFC62828),
    onAccent: Color(0xFFFFFFFF),
  ),
  dark: AppThemePalette(
    background: Color(0xFF101E33),
    surface: Color(0xFF182B45),
    surfaceAlt: Color(0xFF223B59),
    border: Color(0xFF819FC4),
    shadow: Color(0xFF060D18),
    ink: Color(0xFFF4F8FF),
    inkDim: Color(0xFFB0C4DF),
    accent: Color(0xFFFFB6AE),
    accentText: Color(0xFFFFB6AE),
    onAccent: Color(0xFF3F1111),
  ),
);
