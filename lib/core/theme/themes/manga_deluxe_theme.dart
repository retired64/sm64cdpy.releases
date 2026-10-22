import 'package:flutter/material.dart';

import '../app_theme_design.dart';

const mangaDeluxeTheme = AppThemeDesign(
  id: AppThemeId.mangaDeluxe,
  light: AppThemePalette(
    background: Color(0xFFF7F1E3),
    surface: Color(0xFFFFFCF5),
    surfaceAlt: Color(0xFFF0E5D2),
    border: Color(0xFF2C2438),
    shadow: Color(0xFF2C2438),
    ink: Color(0xFF251F30),
    inkDim: Color(0xFF655F70),
    accent: Color(0xFFA7DEE1),
    accentText: Color(0xFF24666B),
    onAccent: Color(0xFF251F30),
  ),
  dark: AppThemePalette(
    background: Color(0xFF100F19),
    surface: Color(0xFF1C1929),
    surfaceAlt: Color(0xFF282437),
    border: Color(0xFF92879F),
    shadow: Color(0xFF050407),
    ink: Color(0xFFFFF4E2),
    inkDim: Color(0xFFB4A9C3),
    accent: Color(0xFFA7DEE1),
    accentText: Color(0xFFA7DEE1),
    onAccent: Color(0xFF251F30),
  ),
  drawerRasterIcons: true,
  brandAsset: 'assets/themes/manga_deluxe/hats.webp',
);
