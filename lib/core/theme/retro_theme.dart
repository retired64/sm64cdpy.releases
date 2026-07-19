import 'package:flutter/material.dart';

/// Tokens de diseño del lenguaje visual "manga panel" compartido entre
/// screens (OMM Rebirth, Links & Resources, ...). Basado en las referencias
/// de diseño del usuario: fondo navy oscuro, tinta crema, acento teal,
/// bordes claros con sombra dura desplazada, chips inclinados tipo viñeta
/// de cómic y trama halftone de fondo.
///
/// Uso:
/// ```dart
/// final retro = RetroTheme.of(context);
/// Container(color: retro.surface, ...)
/// ```
class RetroTheme {
  RetroTheme(this.isDark);

  factory RetroTheme.of(BuildContext context) {
    return RetroTheme(Theme.of(context).brightness == Brightness.dark);
  }

  final bool isDark;

  // El modo oscuro es la identidad "real" de la referencia (navy + crema).
  // El modo claro reinterpreta la misma paleta sobre papel cálido para no
  // perder el carácter cuando el sistema pide light mode.
  Color get background =>
      isDark ? const Color(0xFF262A38) : const Color(0xFFF5F2E9);
  Color get surface => isDark ? const Color(0xFF2B2F3E) : const Color(0xFFFFFFFF);
  Color get surfaceAlt =>
      isDark ? const Color(0xFF333849) : const Color(0xFFEDE8DA);
  Color get border => isDark ? const Color(0xFFF2EFE4) : const Color(0xFF262A38);
  Color get shadowColor =>
      isDark ? const Color(0xFF14161F) : const Color(0xFF262A38);
  Color get ink => isDark ? const Color(0xFFF2EFE4) : const Color(0xFF20232E);
  Color get inkDim =>
      isDark ? const Color(0xFF9096A3) : const Color(0xFF696E7C);

  // Acento principal (teal) — selección, links, estado activo.
  Color get accent => const Color(0xFFA7DEE1);
  // Paleta secundaria tomada del selector de acentos de la referencia.
  Color get red => const Color(0xFFE0483A);
  Color get blue => const Color(0xFF3E63E0);
  Color get amber => const Color(0xFFF2A91E);

  /// Sombra dura sin blur, desplazada — la firma visual del sistema.
  List<BoxShadow> hardShadow({double dx = 4, double dy = 4}) => [
    BoxShadow(color: shadowColor, offset: Offset(dx, dy), blurRadius: 0),
  ];

  /// Esquinas cuadradas — la referencia no usa radios visibles.
  static const radius = BorderRadius.zero;

  /// Estilo para títulos / labels: bold condensado en mayúsculas.
  /// Nota: se aproxima con peso w900 + letterSpacing negativo sobre la
  /// fuente del sistema. Para el match 1:1 con la referencia hace falta
  /// bundlear una fuente display condensada (p. ej. "Anton" o "Archivo
  /// Black") vía `google_fonts` — decilo si quieres que lo agregue.
  TextStyle heading({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w900,
    double letterSpacing = -0.3,
    double height = 1.05,
  }) => TextStyle(
    color: color ?? ink,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );

  /// Estilo para cuerpo de texto: sans normal, nada de monospace.
  TextStyle body({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double height = 1.35,
  }) => TextStyle(
    color: color ?? inkDim,
    fontSize: size,
    fontWeight: weight,
    height: height,
  );
}

// ── Halftone background ────────────────────────────────────────────────────
// Trama de puntos tipo screentone de cómic, fija detrás del contenido
// (no se redibuja con el scroll — cubre solo el viewport visible).

class HalftoneBackground extends StatelessWidget {
  const HalftoneBackground({
    super.key,
    required this.color,
    this.spacing = 15,
    this.dotRadius = 1.1,
  });

  final Color color;
  final double spacing;
  final double dotRadius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _HalftonePainter(
            color: color,
            spacing: spacing,
            dotRadius: dotRadius,
          ),
        ),
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  _HalftonePainter({
    required this.color,
    required this.spacing,
    required this.dotRadius,
  });

  final Color color;
  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // Antes: un canvas.drawCircle() por punto (miles de draw calls
    // individuales, cada uno con antialiasing). En gama baja eso se nota,
    // sobre todo en la primera pintada al entrar a la pantalla.
    //
    // Ahora: todos los puntos se juntan en un solo canvas.drawPoints()
    // — UNA sola llamada de dibujo para toda la trama — usando
    // strokeCap.round para que cada punto siga siendo un círculo.
    // Antialiasing apagado porque a este tamaño no se nota, pero sí pesa
    // por punto cuando son miles.
    final points = <Offset>[];
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        points.add(Offset(x, y));
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = dotRadius * 2
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = false;

    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant _HalftonePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}

// ── Section kicker ───────────────────────────────────────────────────────────
// El patrón "/ TÍTULO 日本語 ----------" usado como header de sección.

class SectionKicker extends StatelessWidget {
  const SectionKicker({
    super.key,
    required this.retro,
    required this.label,
    this.japanese,
  });

  final RetroTheme retro;
  final String label;
  final String? japanese;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(-0.5),
          child: Container(width: 5, height: 18, color: retro.accent),
        ),
        const SizedBox(width: 10),
        Text(label, style: retro.heading(size: 17)),
        if (japanese != null) ...[
          const SizedBox(width: 8),
          Text(japanese!, style: retro.body(size: 13, color: retro.inkDim)),
        ],
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 1.5, color: retro.inkDim.withValues(alpha: 0.35)),
        ),
      ],
    );
  }
}

// ── Skewed chip ──────────────────────────────────────────────────────────────
// El chip/paño inclinado tipo "viñeta de velocidad" usado en filtros y
// badges. El contenido interno se des-inclina para que el texto quede
// derecho mientras el fondo queda en paralelogramo.

class SkewChip extends StatelessWidget {
  const SkewChip({
    super.key,
    required this.retro,
    required this.label,
    this.selected = false,
    this.icon,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  final RetroTheme retro;
  final String label;
  final bool selected;
  final IconData? icon;
  final IconData? trailing;
  final VoidCallback? onTap;
  final bool dense;

  static const _skew = 0.18;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? retro.accent : retro.surface;
    final fg = selected ? retro.background : retro.ink;

    final chip = Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(-_skew),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 14,
          vertical: dense ? 6 : 9,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: retro.border, width: 2),
          boxShadow: retro.hardShadow(dx: 3, dy: 3),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(_skew),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: dense ? 13 : 15, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: retro.heading(size: dense ? 11 : 12.5, color: fg),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                Icon(trailing, size: 16, color: fg),
              ],
            ],
          ),
        ),
      ),
    );

    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}
