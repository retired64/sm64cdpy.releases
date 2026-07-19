import 'package:flutter/material.dart';

/// Tokens de diseño del lenguaje visual "retro/arcade" compartido entre
/// screens (OMM Rebirth, Links & Resources, ...). Un solo lugar para la
/// paleta en vez de duplicar la clase `_Retro` en cada archivo.
///
/// Uso:
/// ```dart
/// final retro = RetroTheme.of(context);
/// Container(color: retro.panel, ...)
/// ```
class RetroTheme {
  RetroTheme(this.isDark);

  factory RetroTheme.of(BuildContext context) {
    return RetroTheme(Theme.of(context).brightness == Brightness.dark);
  }

  final bool isDark;

  Color get void_ =>
      isDark ? const Color(0xFF0B0710) : const Color(0xFFF5F0E8);
  Color get panel => isDark ? const Color(0xFF161020) : const Color(0xFFFFFFFF);
  Color get panelAlt =>
      isDark ? const Color(0xFF1D1628) : const Color(0xFFF0ECF8);
  Color get line => isDark ? const Color(0xFF000000) : const Color(0xFF2D2D3F);
  Color get red => const Color(0xFFE6402C);
  Color get redDark =>
      isDark ? const Color(0xFF8A1F14) : const Color(0xFFA01018);
  Color get gold => const Color(0xFFF4C430);
  Color get green => const Color(0xFF3FA564);
  Color get purple => const Color(0xFF8B6CF0);
  Color get ink => isDark ? const Color(0xFFE9E2F2) : const Color(0xFF1A1A2E);
  Color get inkDim =>
      isDark ? const Color(0xFF8D82A3) : const Color(0xFF5A5A7A);

  static const fontFamily = 'monospace';
  static const pixelRadius = BorderRadius.all(Radius.circular(3));

  List<BoxShadow> hardShadow({double dx = 4, double dy = 4}) => [
    BoxShadow(color: line, offset: Offset(dx, dy), blurRadius: 0),
  ];
}
