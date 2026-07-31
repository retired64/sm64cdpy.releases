import 'dart:ui' as ui;

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
  RetroTheme(
    this.isDark, {
    Color? backgroundOverride,
    Color? surfaceOverride,
    Color? surfaceAltOverride,
    Color? borderOverride,
    Color? shadowColorOverride,
  }) : _backgroundOverride = backgroundOverride,
       _surfaceOverride = surfaceOverride,
       _surfaceAltOverride = surfaceAltOverride,
       _borderOverride = borderOverride,
       _shadowColorOverride = shadowColorOverride;

  factory RetroTheme.of(BuildContext context) {
    return RetroTheme(Theme.of(context).brightness == Brightness.dark);
  }

  /// Variante fija para el overlay flotante (corre en un segundo engine de
  /// Flutter vía `overlayMain()`, sin acceso al `Theme` de la app principal).
  /// Siempre oscura por diseño: un overlay sobre gameplay en vivo necesita
  /// contraste alto y no debe competir visualmente con el juego, sin
  /// importar la preferencia claro/oscuro del usuario en la app. Navy más
  /// profundo que el `isDark` normal + el mismo acento teal real del
  /// sistema (antes el overlay usaba 0xFF00D9C0 hardcodeado, divergente de
  /// `accent` — corregido acá porque ya no hace falta overridearlo).
  factory RetroTheme.overlay() => RetroTheme(
    true,
    backgroundOverride: const Color(0xFF12141C),
    surfaceOverride: const Color(0xFF1A1D29),
    surfaceAltOverride: const Color(0xFF232738),
    shadowColorOverride: const Color(0xFF090A10),
  );

  final bool isDark;
  final Color? _backgroundOverride;
  final Color? _surfaceOverride;
  final Color? _surfaceAltOverride;
  final Color? _borderOverride;
  final Color? _shadowColorOverride;

  // El modo oscuro es la identidad "real" de la referencia (navy + crema).
  // El modo claro reinterpreta la misma paleta sobre papel cálido para no
  // perder el carácter cuando el sistema pide light mode.
  Color get background =>
      _backgroundOverride ??
      (isDark ? const Color(0xFF262A38) : const Color(0xFFF5F2E9));
  Color get surface =>
      _surfaceOverride ??
      (isDark ? const Color(0xFF2B2F3E) : const Color(0xFFFFFFFF));
  Color get surfaceAlt =>
      _surfaceAltOverride ??
      (isDark ? const Color(0xFF333849) : const Color(0xFFEDE8DA));
  Color get border =>
      _borderOverride ??
      (isDark ? const Color(0xFFF2EFE4) : const Color(0xFF262A38));
  Color get shadowColor =>
      _shadowColorOverride ??
      (isDark ? const Color(0xFF14161F) : const Color(0xFF262A38));
  Color get ink => isDark ? const Color(0xFFF2EFE4) : const Color(0xFF20232E);
  Color get inkDim =>
      isDark ? const Color(0xFF9096A3) : const Color(0xFF696E7C);

  // Acento principal (teal) — selección, links, estado activo.
  Color get accent => const Color(0xFFA7DEE1);
  // Paleta secundaria tomada del selector de acentos de la referencia.
  Color get red => const Color(0xFFE0483A);
  Color get blue => const Color(0xFF3E63E0);
  Color get amber => const Color(0xFFF2A91E);
  // Texto sobre superficies doradas (botones/badges VIP): tinta oscura fija,
  // independiente del modo claro/oscuro, porque el dorado siempre es claro
  // y necesita contraste oscuro encima.
  Color get onAmber => const Color(0xFF20232E);

  // Texto/íconos sobre superficies de acento claro (teal) rellenas — misma
  // lógica que onAmber: tinta oscura fija para contraste garantizado.
  Color get inkOnAccent => const Color(0xFF20232E);

  // Colores de medalla (podio / ranking) — paleta clásica olímpica.
  Color get medalGold => const Color(0xFFFFD700);
  Color get medalSilver => const Color(0xFFC0C0C0);
  Color get medalBronze => const Color(0xFFCD7F32);

  // Colores semánticos para tipos de cambio en changelog.
  Color get changelogAdded => const Color(0xFF22C55E);
  Color get changelogImproved => const Color(0xFF3B82F6);
  Color get changelogFixed => const Color(0xFFF59E0B);
  Color get changelogRemoved => const Color(0xFFEF4444);
  Color get changelogChanged => const Color(0xFF8B5CF6);

  // Discord brand color (blurple).
  Color get discordBrand => const Color(0xFF5865F2);

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

  /// ThemeData mínimo para MaterialApp — solo lo indispensable para que
  /// los widgets nativos (Scaffold, Drawer, BottomNav, SnackBar, etc.)
  /// tengan un baseline coherente. El estilo visual real lo provee
  /// RetroTheme directamente.
  static ThemeData materialTheme(bool isDark) {
    final r = RetroTheme(isDark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: r.accent,
        onPrimary: r.inkOnAccent,
        secondary: r.amber,
        onSecondary: r.onAmber,
        surface: r.surface,
        onSurface: r.ink,
        error: r.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: r.background,
    );
  }
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

    canvas.drawPoints(ui.PointMode.points, points, paint);
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
    this.accentColor,
  });

  final RetroTheme retro;
  final String label;
  final bool selected;
  final IconData? icon;
  final IconData? trailing;
  final VoidCallback? onTap;
  final bool dense;
  // Override opcional del color de acento (por defecto retro.accent).
  // Usado, por ejemplo, por VIP Mods para chips dorados en vez de teal.
  final Color? accentColor;

  static const _skew = 0.18;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? retro.accent;
    final bg = selected ? accent : retro.surface;
    // Cuando se rellena con un accentColor custom (p.ej. botones "GO TO" por
    // categoría: amarillo/rojo/azul marino), el contraste correcto depende
    // de qué tan clara u oscura sea ESA tarjeta de color puntual, no del
    // tema global — un azul marino oscuro necesita texto blanco, no la
    // tinta oscura por defecto que usaríamos sobre el teal claro.
    final fg = selected
        ? (ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
              ? Colors.white
              : retro.background)
        : retro.ink;

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

// ── Diagonal stripe banner ────────────────────────────────────────────────────
// Fondo de franjas diagonales tipo "cabecera de repo" — usado como backdrop
// decorativo detrás de un hero header (ver referencia: banner a rayas detrás
// del avatar en una tarjeta de release). Una sola llamada canvas.drawPath()
// para todas las franjas — igual de barato que el halftone.

class DiagonalStripeBanner extends StatelessWidget {
  const DiagonalStripeBanner({
    super.key,
    required this.baseColor,
    required this.stripeColor,
    this.stripeWidth = 22,
    this.gap = 22,
    this.angle = -0.5,
  });

  final Color baseColor;
  final Color stripeColor;
  final double stripeWidth;
  final double gap;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _DiagonalStripePainter(
            baseColor: baseColor,
            stripeColor: stripeColor,
            stripeWidth: stripeWidth,
            gap: gap,
            angle: angle,
          ),
        ),
      ),
    );
  }
}

class _DiagonalStripePainter extends CustomPainter {
  _DiagonalStripePainter({
    required this.baseColor,
    required this.stripeColor,
    required this.stripeWidth,
    required this.gap,
    required this.angle,
  });

  final Color baseColor;
  final Color stripeColor;
  final double stripeWidth;
  final double gap;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    // Todas las franjas se acumulan en un solo Path (un solo draw call)
    // sobre un área extendida en diagonal, para no dejar huecos en las
    // esquinas una vez rotado.
    final diag = size.width + size.height;
    final period = stripeWidth + gap;
    final path = Path();
    for (double x = -diag; x < diag; x += period) {
      path.addRect(Rect.fromLTWH(x, -diag, stripeWidth, diag * 2));
    }

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawPath(path, Paint()..color = stripeColor..isAntiAlias = false);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripePainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
      oldDelegate.stripeColor != stripeColor ||
      oldDelegate.stripeWidth != stripeWidth ||
      oldDelegate.gap != gap ||
      oldDelegate.angle != angle;
}

// ── Retro tag ─────────────────────────────────────────────────────────────────
// Etiqueta cuadrada con borde, sin interacción — para badges tipo
// "NEW RELEASE", números de versión, o estado ("Instalado"). Variante
// `filled` para el caso resaltado (fondo sólido) y outline para el resto.

class RetroTag extends StatelessWidget {
  const RetroTag({
    super.key,
    required this.retro,
    required this.label,
    this.icon,
    this.color,
    this.filled = false,
    this.dense = true,
  });

  final RetroTheme retro;
  final String label;
  final IconData? icon;
  final Color? color;
  final bool filled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = color ?? retro.accent;
    final bg = filled ? c : Colors.transparent;
    final fg = filled ? retro.background : c;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 11,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(color: bg, border: Border.all(color: c, width: 1.5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: dense ? 10 : 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Retro meta ────────────────────────────────────────────────────────────────
// Fila "ícono + texto" para metadata secundaria (autor, versión, fecha,
// contador...). Antes vivía duplicada como widget privado en cada screen
// (DynOS, VIP Mods); ahora es pública y compartida.

class RetroMeta extends StatelessWidget {
  const RetroMeta({
    super.key,
    required this.retro,
    required this.icon,
    required this.label,
    this.color,
  });

  final RetroTheme retro;
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color ?? retro.accent),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: retro.inkDim,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Retro badge dot ───────────────────────────────────────────────────────────
// Círculo pequeño con ícono, para insignias tipo "verificado" o "destacado"
// que se superponen en la esquina de una miniatura — inspirado en el check
// azul junto al nombre de usuario en una tarjeta de release de GitHub.

class RetroBadgeDot extends StatelessWidget {
  const RetroBadgeDot({
    super.key,
    required this.retro,
    required this.icon,
    this.color,
    this.size = 20,
  });

  final RetroTheme retro;
  final IconData icon;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? retro.accent;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: retro.background, width: 2),
      ),
      child: Icon(icon, size: size * 0.58, color: retro.background),
    );
  }
}
