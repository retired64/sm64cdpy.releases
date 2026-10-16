import 'package:flutter/material.dart';

import '../app_theme_design.dart';

const retroMangaTheme = AppThemeDesign(
  id: AppThemeId.retroManga,
  light: AppThemePalette(
    background: Color(0xFFF5F2E9),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDE8DA),
    border: Color(0xFF262A38),
    shadow: Color(0xFF262A38),
    ink: Color(0xFF20232E),
    inkDim: Color(0xFF626775),
    accent: Color(0xFFA7DEE1),
    accentText: Color(0xFF24666B),
    onAccent: Color(0xFF20232E),
  ),
  dark: AppThemePalette(
    background: Color(0xFF0D1117),
    surface: Color(0xFF161B22),
    surfaceAlt: Color(0xFF21262D),
    border: Color(0xFF6E7681),
    shadow: Color(0xFF010409),
    ink: Color(0xFFF2EFE4),
    inkDim: Color(0xFF9096A3),
    accent: Color(0xFFA7DEE1),
    accentText: Color(0xFFA7DEE1),
    onAccent: Color(0xFF20232E),
  ),
  drawerRasterIcons: true,
);
