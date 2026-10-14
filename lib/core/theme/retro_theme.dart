import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme_design.dart';
import 'themes/retro_manga_theme.dart';

/// Compatibility facade and ThemeExtension for every interface design.
/// The main engine obtains it from ThemeData; the overlay explicitly creates
/// its own fixed dark instance and does not read the main engine's preferences.
class RetroTheme extends ThemeExtension<RetroTheme> {
  const RetroTheme(
    this.isDark, {
    this.design = retroMangaTheme,
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
    final theme = Theme.of(context);
    return theme.extension<RetroTheme>() ??
        RetroTheme(theme.brightness == Brightness.dark);
  }

  factory RetroTheme.overlay() => const RetroTheme(
    true,
    backgroundOverride: Color(0xFF12141C),
    surfaceOverride: Color(0xFF1A1D29),
    surfaceAltOverride: Color(0xFF232738),
    shadowColorOverride: Color(0xFF090A10),
  );

  final bool isDark;
  final AppThemeDesign design;
  final Color? _backgroundOverride;
  final Color? _surfaceOverride;
  final Color? _surfaceAltOverride;
  final Color? _borderOverride;
  final Color? _shadowColorOverride;

  AppThemePalette get _palette => design.palette(isDark);
  Color get background => _backgroundOverride ?? _palette.background;
  Color get surface => _surfaceOverride ?? _palette.surface;
  Color get surfaceAlt => _surfaceAltOverride ?? _palette.surfaceAlt;
  Color get border => _borderOverride ?? _palette.border;
  Color get shadowColor => _shadowColorOverride ?? _palette.shadow;
  Color get ink => _palette.ink;
  Color get inkDim => _palette.inkDim;
  Color get accent => _palette.accent;
  Color get inkOnAccent => _palette.onAccent;
  Color get accentText => _palette.accentText;
  String displayLabel(String value) =>
      design.uppercaseLabels ? value.toUpperCase() : value;

  // Stable semantic/brand roles are intentionally independent of theme IDs.
  Color get red => const Color(0xFFE0483A);
  Color get blue => const Color(0xFF3E63E0);
  Color get amber => const Color(0xFFF2A91E);
  Color get onAmber => const Color(0xFF20232E);
  Color get medalGold => const Color(0xFFFFD700);
  Color get medalSilver => const Color(0xFFC0C0C0);
  Color get medalBronze => const Color(0xFFCD7F32);
  Color get changelogAdded => const Color(0xFF22C55E);
  Color get changelogImproved => const Color(0xFF3B82F6);
  Color get changelogFixed => const Color(0xFFF59E0B);
  Color get changelogRemoved => const Color(0xFFEF4444);
  Color get changelogChanged => const Color(0xFF8B5CF6);
  Color get discordBrand => const Color(0xFF5865F2);

  /// Use the explicit foreground for the main accent, otherwise the higher
  /// contrast of dark ink and white (including category/VIP/custom fills).
  Color onColor(Color color) {
    if (color == accent) return inkOnAccent;
    const darkInk = Colors.black;
    final luminance = color.computeLuminance();
    final whiteContrast = 1.05 / (luminance + 0.05);
    final darkContrast = (luminance + 0.05) /
        (darkInk.computeLuminance() + 0.05);
    return whiteContrast >= darkContrast ? Colors.white : darkInk;
  }

  BorderRadius get radius => BorderRadius.circular(design.cornerRadius);
  double borderWidth(double retroWidth) => retroWidth * design.borderScale;
  double get chipSkew => design.chipSkew;
  bool get showHalftone => design.halftone;
  bool get showStripes => design.stripes;

  List<BoxShadow> hardShadow({double dx = 4, double dy = 4}) => [
    BoxShadow(
      color: shadowColor,
      offset: Offset(
        dx * design.shadowOffsetScale,
        dy * design.shadowOffsetScale,
      ),
      blurRadius: design.shadowBlur,
    ),
  ];

  TextStyle heading({
    required double size,
    Color? color,
    FontWeight? weight,
    double? letterSpacing,
    double height = 1.05,
  }) => TextStyle(
    color: color ?? ink,
    fontFamily: design.headingFontFamily,
    fontSize: size,
    fontWeight: weight ?? design.headingWeight,
    letterSpacing: letterSpacing ?? design.headingTracking,
    height: height,
  );

  TextStyle body({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double height = 1.35,
  }) => TextStyle(
    color: color ?? inkDim,
    fontFamily: design.bodyFontFamily,
    fontSize: size,
    fontWeight: weight,
    height: height,
  );

  SystemUiOverlayStyle get systemUiStyle => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    systemNavigationBarColor: background,
    systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  );

  ThemeData toMaterialTheme() {
    final shape = RoundedRectangleBorder(borderRadius: radius);
    return ThemeData(
      useMaterial3: true,
      extensions: <ThemeExtension<dynamic>>[this],
      fontFamily: design.bodyFontFamily,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: accent,
        onPrimary: inkOnAccent,
        secondary: amber,
        onSecondary: onAmber,
        surface: surface,
        onSurface: ink,
        error: red,
        onError: onColor(red),
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        systemOverlayStyle: systemUiStyle,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: borderWidth(3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: shape),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: shape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: shape, foregroundColor: accentText),
      ),
    );
  }

  static ThemeData materialTheme(
    bool isDark, {
    AppThemeDesign design = retroMangaTheme,
  }) => RetroTheme(isDark, design: design).toMaterialTheme();

  @override
  RetroTheme copyWith({
    bool? isDark,
    AppThemeDesign? design,
    Color? backgroundOverride,
    Color? surfaceOverride,
    Color? surfaceAltOverride,
    Color? borderOverride,
    Color? shadowColorOverride,
  }) => RetroTheme(
    isDark ?? this.isDark,
    design: design ?? this.design,
    backgroundOverride: backgroundOverride ?? _backgroundOverride,
    surfaceOverride: surfaceOverride ?? _surfaceOverride,
    surfaceAltOverride: surfaceAltOverride ?? _surfaceAltOverride,
    borderOverride: borderOverride ?? _borderOverride,
    shadowColorOverride: shadowColorOverride ?? _shadowColorOverride,
  );

  @override
  RetroTheme lerp(covariant RetroTheme? other, double t) {
    if (other == null) return this;
    if (t <= 0) return this;
    if (t >= 1) return other;
    final selected = t < 0.5 ? this : other;
    final palette = AppThemePalette.lerp(_palette, other._palette, t);
    return RetroTheme(
      selected.isDark,
      design: AppThemeDesign(
        id: selected.design.id,
        light: palette,
        dark: palette,
        cornerRadius: ui.lerpDouble(design.cornerRadius, other.design.cornerRadius, t)!,
        borderScale: ui.lerpDouble(design.borderScale, other.design.borderScale, t)!,
        shadowBlur: ui.lerpDouble(design.shadowBlur, other.design.shadowBlur, t)!,
        shadowOffsetScale: ui.lerpDouble(design.shadowOffsetScale, other.design.shadowOffsetScale, t)!,
        chipSkew: ui.lerpDouble(chipSkew, other.chipSkew, t)!,
        headingWeight: FontWeight.lerp(design.headingWeight, other.design.headingWeight, t)!,
        headingTracking: ui.lerpDouble(design.headingTracking, other.design.headingTracking, t)!,
        headingFontFamily: selected.design.headingFontFamily,
        bodyFontFamily: selected.design.bodyFontFamily,
        halftone: selected.showHalftone,
        stripes: selected.showStripes,
        uppercaseLabels: selected.design.uppercaseLabels,
        softSettingsPanels: selected.design.softSettingsPanels,
      ),
      backgroundOverride: Color.lerp(background, other.background, t),
      surfaceOverride: Color.lerp(surface, other.surface, t),
      surfaceAltOverride: Color.lerp(surfaceAlt, other.surfaceAlt, t),
      borderOverride: Color.lerp(border, other.border, t),
      shadowColorOverride: Color.lerp(shadowColor, other.shadowColor, t),
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
    if (!RetroTheme.of(context).showHalftone) return const SizedBox.shrink();
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
          transform: Matrix4.skewX(retro.chipSkew == 0 ? 0 : -0.5),
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
        ? retro.onColor(accent)
        : retro.ink;

    final chip = Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(-retro.chipSkew),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 10 : 14,
          vertical: dense ? 6 : 9,
        ),
        decoration: BoxDecoration(
          borderRadius: retro.radius,
          color: bg,
          border: Border.all(color: retro.border, width: retro.borderWidth(2)),
          boxShadow: retro.hardShadow(dx: 3, dy: 3),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.skewX(retro.chipSkew),
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
    if (!RetroTheme.of(context).showStripes) {
      return ColoredBox(color: baseColor);
    }
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
    final fg = filled ? retro.onColor(c) : c;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 11,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(borderRadius: retro.radius, color: bg, border: Border.all(color: c, width: retro.borderWidth(1.5))),
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
        Icon(icon, size: 13, color: color ?? retro.accentText),
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
        border: Border.all(color: retro.background, width: retro.borderWidth(2)),
      ),
      child: Icon(icon, size: size * 0.58, color: retro.onColor(c)),
    );
  }
}
