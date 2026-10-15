import 'dart:ui' as ui;
import 'dart:io';

import '../../domain/entities/mario_theme_assets.dart';

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
    this.marioAssets = const MarioThemeAssets(),
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
  final MarioThemeAssets marioAssets;
  bool get isIntro => design.id == AppThemeId.sm64Intro;
  bool get isMario => design.id == AppThemeId.mario64 || isIntro;
  String? marioAsset(String id) => isMario ? marioAssets.files[id] : null;
  String? get headingFamily => isMario && marioAssets.complete
      ? 'MarioRomHudV2'
      : design.headingFontFamily;
  String? get bodyFamily => isMario && marioAssets.complete
      ? 'MarioRomDialogV2'
      : design.bodyFontFamily;
  String? get menuFamily =>
      isMario && marioAssets.complete ? 'MarioRomMenuV2' : headingFamily;

  /// All main-engine panels use the same full-opacity material. Photo gradients,
  /// circular badges and semantic colored fills keep their own foreground contract.
  BoxDecoration gameDecoration(BoxDecoration value) {
    if (!isMario ||
        value.shape != BoxShape.rectangle ||
        value.image != null ||
        value.gradient != null ||
        value.color == null ||
        value.color!.a < 0.85)
      return value;
    final color = value.color!;
    if (color != surface &&
        color != surfaceAlt &&
        color != background &&
        color != Colors.white &&
        color != Colors.black)
      return value;
    if (isIntro) return value;
    final id = marioAssets.complete
        ? (isDark ? 'panel_dark' : 'panel_light')
        : (isDark ? 'stone_dark' : 'stone');
    final path = marioAsset(id);
    return value.copyWith(
      borderRadius: value.borderRadius ?? radius,
      image: path == null
          ? null
          : DecorationImage(
              image: FileImage(File(path)),
              repeat: ImageRepeat.repeat,
              filterQuality: FilterQuality.none,
              opacity: 1,
              colorFilter: marioAssets.complete
                  ? null
                  : ColorFilter.mode(
                      surface.withValues(alpha: 0.62),
                      BlendMode.srcATop,
                    ),
              onError: (error, stack) {},
            ),
    );
  }

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
  Color get secondaryAccent => _palette.secondaryAccent ?? amber;
  Color get surfaceHighlight =>
      _palette.surfaceHighlight ??
      Color.lerp(surface, Colors.white, isDark ? 0.12 : 0.45)!;
  Color get surfaceShade =>
      _palette.surfaceShade ?? Color.lerp(surface, shadowColor, 0.7)!;
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
    final darkContrast =
        (luminance + 0.05) / (darkInk.computeLuminance() + 0.05);
    return whiteContrast >= darkContrast ? Colors.white : darkInk;
  }

  BorderRadius get radius => BorderRadius.circular(design.cornerRadius);
  double borderWidth(double retroWidth) => retroWidth * design.borderScale;
  double get chipSkew => design.chipSkew;
  bool get showHalftone =>
      design.halftone && design.backdropStyle == AppBackdropStyle.halftone;
  bool get showStripes => design.stripes;
  bool get showN64Backdrop => design.backdropStyle == AppBackdropStyle.n64Sky;
  bool get usesBeveledSurfaces =>
      design.surfaceTreatment == AppSurfaceTreatment.beveled;

  List<BoxShadow> hardShadow({double dx = 4, double dy = 4}) => [
    if (usesBeveledSurfaces)
      BoxShadow(
        color: surfaceHighlight.withValues(alpha: isDark ? 0.2 : 0.7),
        offset: Offset(-dx * 0.35, -dy * 0.35),
        blurRadius: design.shadowBlur,
      ),
    BoxShadow(
      color: shadowColor.withValues(alpha: usesBeveledSurfaces ? 0.72 : 1),
      offset: Offset(
        dx * design.shadowOffsetScale,
        dy * design.shadowOffsetScale,
      ),
      blurRadius: design.shadowBlur,
    ),
  ];

  BoxDecoration surfaceDecoration({
    Color? color,
    Color? borderColor,
    double border = 2,
    double shadowDx = 4,
    double shadowDy = 4,
  }) => gameDecoration(
    BoxDecoration(
      color: color ?? surface,
      borderRadius: radius,
      border: Border(
        top: BorderSide(
          color: usesBeveledSurfaces
              ? surfaceHighlight
              : borderColor ?? this.border,
          width: borderWidth(border),
        ),
        left: BorderSide(
          color: usesBeveledSurfaces
              ? surfaceHighlight
              : borderColor ?? this.border,
          width: borderWidth(border),
        ),
        bottom: BorderSide(
          color:
              borderColor ?? (usesBeveledSurfaces ? surfaceShade : this.border),
          width: borderWidth(border),
        ),
        right: BorderSide(
          color:
              borderColor ?? (usesBeveledSurfaces ? surfaceShade : this.border),
          width: borderWidth(border),
        ),
      ),
      boxShadow: hardShadow(dx: shadowDx, dy: shadowDy),
    ),
  );

  TextStyle heading({
    required double size,
    Color? color,
    FontWeight? weight,
    double? letterSpacing,
    double height = 1.05,
  }) => TextStyle(
    color: color ?? ink,
    fontFamily: headingFamily,
    fontFamilyFallback: design.headingFontFamilyFallback,
    fontSize: size,
    fontWeight: weight ?? design.headingWeight,
    letterSpacing: letterSpacing ?? design.headingTracking,
    height: height,
    shadows: isMario
        ? [
            Shadow(
              color: shadowColor.withValues(alpha: 0.24),
              offset: const Offset(0, 1),
            ),
          ]
        : null,
  );

  TextStyle body({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w500,
    double height = 1.35,
  }) => TextStyle(
    color: color ?? inkDim,
    fontFamily: bodyFamily,
    fontFamilyFallback: const ['Roboto'],
    fontSize: isMario && marioAssets.complete
        ? size.clamp(16.0, double.infinity)
        : size,
    fontWeight: isMario && marioAssets.complete ? FontWeight.w400 : weight,
    letterSpacing: isMario ? 0 : null,
    height: height,
  );

  Brightness get systemIconBrightness => background.computeLuminance() > 0.179
      ? Brightness.dark
      : Brightness.light;

  SystemUiOverlayStyle get systemUiStyle => SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: systemIconBrightness,
    systemNavigationBarColor: background,
    systemNavigationBarIconBrightness: systemIconBrightness,
  );

  ThemeData toMaterialTheme() {
    final shape = RoundedRectangleBorder(borderRadius: radius);
    var theme = ThemeData(
      useMaterial3: true,
      extensions: <ThemeExtension<dynamic>>[this],
      fontFamily: bodyFamily,
      fontFamilyFallback: design.headingFontFamilyFallback,
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
        shape: isMario
            ? RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: border, width: 3),
              )
            : shape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border, width: borderWidth(3)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: shape,
          elevation: 0,
          side: usesBeveledSurfaces
              ? BorderSide(color: surfaceHighlight, width: borderWidth(1.5))
              : null,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          elevation: 0,
          side: usesBeveledSurfaces
              ? BorderSide(
                  color: inkOnAccent.withValues(alpha: 0.65),
                  width: borderWidth(1.5),
                )
              : null,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentText),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          foregroundColor: accentText,
        ),
      ),
    );
    if (isMario) {
      ButtonStyle originalControl(ButtonStyle? base, {bool filled = false}) =>
          (base ?? const ButtonStyle()).copyWith(
            backgroundColor: isIntro && filled
                ? WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.disabled)
                        ? surfaceAlt
                        : const Color(0xFF24479B),
                  )
                : null,
            foregroundColor: isIntro && filled
                ? WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.disabled)
                        ? inkDim
                        : Colors.white,
                  )
                : null,
            textStyle: WidgetStatePropertyAll(
              (theme.textTheme.labelLarge ??
                      const TextStyle(inherit: false, fontSize: 14))
                  .copyWith(
                    inherit: false,
                    fontSize: isMario && marioAssets.complete ? 16 : 14,
                    height: 1.4,
                    letterSpacing: 0.1,
                    textBaseline: TextBaseline.alphabetic,
                    leadingDistribution: TextLeadingDistribution.even,
                    fontFamily: isMario && marioAssets.complete
                        ? bodyFamily
                        : menuFamily,
                    fontFamilyFallback: const ['Roboto'],
                    fontWeight: FontWeight.w400,
                  ),
            ),
            minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
            backgroundBuilder: (context, states, child) {
              final texture = marioAsset(isDark ? 'stone_dark' : 'stone');
              return Stack(
                fit: StackFit.passthrough,
                children: [
                  if (texture != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipPath(
                          clipper: const MarioControlFrameClipper(),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(texture)),
                                repeat: ImageRepeat.repeat,
                                filterQuality: FilterQuality.none,
                                colorFilter: isIntro
                                    ? ColorFilter.mode(
                                        const Color(
                                          0xFF244BC0,
                                        ).withValues(alpha: 0.7),
                                        BlendMode.srcATop,
                                      )
                                    : null,
                                opacity: states.contains(WidgetState.disabled)
                                    ? 0.5
                                    : 1,
                                onError: (error, stack) {},
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  child ?? const SizedBox.shrink(),
                ],
              );
            },
          );
      theme = theme.copyWith(
        filledButtonTheme: FilledButtonThemeData(
          style: originalControl(theme.filledButtonTheme.style, filled: true),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: originalControl(theme.elevatedButtonTheme.style, filled: true),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: originalControl(theme.outlinedButtonTheme.style),
        ),
        textButtonTheme: TextButtonThemeData(
          style: originalControl(theme.textButtonTheme.style),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceAlt,
          enabledBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: border, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: accent, width: 3),
          ),
        ),
      );
    }
    if (headingFamily == null) return theme;
    TextStyle? title(TextStyle? base) => base?.copyWith(
      fontFamily: headingFamily,
      fontFamilyFallback: design.headingFontFamilyFallback,
      fontWeight: design.headingWeight,
      letterSpacing: design.headingTracking,
    );
    TextTheme typography(TextTheme base) => base.copyWith(
      displayLarge: title(base.displayLarge),
      displayMedium: title(base.displayMedium),
      displaySmall: title(base.displaySmall),
      headlineLarge: title(base.headlineLarge),
      headlineMedium: title(base.headlineMedium),
      headlineSmall: title(base.headlineSmall),
      titleLarge: title(base.titleLarge),
      titleMedium: title(base.titleMedium),
      titleSmall: title(base.titleSmall),
    );
    return theme.copyWith(
      textTheme: typography(theme.textTheme),
      primaryTextTheme: typography(theme.primaryTextTheme),
    );
  }

  static ThemeData materialTheme(
    bool isDark, {
    AppThemeDesign design = retroMangaTheme,
    MarioThemeAssets marioAssets = const MarioThemeAssets(),
  }) => RetroTheme(
    isDark,
    design: design,
    marioAssets: marioAssets,
  ).toMaterialTheme();

  @override
  RetroTheme copyWith({
    bool? isDark,
    AppThemeDesign? design,
    MarioThemeAssets? marioAssets,
    Color? backgroundOverride,
    Color? surfaceOverride,
    Color? surfaceAltOverride,
    Color? borderOverride,
    Color? shadowColorOverride,
  }) => RetroTheme(
    isDark ?? this.isDark,
    design: design ?? this.design,
    marioAssets: marioAssets ?? this.marioAssets,
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
      marioAssets: selected.marioAssets,
      design: AppThemeDesign(
        id: selected.design.id,
        light: palette,
        dark: palette,
        cornerRadius: ui.lerpDouble(
          design.cornerRadius,
          other.design.cornerRadius,
          t,
        )!,
        borderScale: ui.lerpDouble(
          design.borderScale,
          other.design.borderScale,
          t,
        )!,
        shadowBlur: ui.lerpDouble(
          design.shadowBlur,
          other.design.shadowBlur,
          t,
        )!,
        shadowOffsetScale: ui.lerpDouble(
          design.shadowOffsetScale,
          other.design.shadowOffsetScale,
          t,
        )!,
        chipSkew: ui.lerpDouble(chipSkew, other.chipSkew, t)!,
        headingWeight: FontWeight.lerp(
          design.headingWeight,
          other.design.headingWeight,
          t,
        )!,
        headingTracking: ui.lerpDouble(
          design.headingTracking,
          other.design.headingTracking,
          t,
        )!,
        headingFontFamily: selected.design.headingFontFamily,
        headingFontFamilyFallback: selected.design.headingFontFamilyFallback,
        bodyFontFamily: selected.design.bodyFontFamily,
        halftone: selected.showHalftone,
        stripes: selected.showStripes,
        uppercaseLabels: selected.design.uppercaseLabels,
        softSettingsPanels: selected.design.softSettingsPanels,
        backdropStyle: selected.design.backdropStyle,
        surfaceTreatment: selected.design.surfaceTreatment,
        playfulSelection: selected.design.playfulSelection,
      ),
      backgroundOverride: Color.lerp(background, other.background, t),
      surfaceOverride: Color.lerp(surface, other.surface, t),
      surfaceAltOverride: Color.lerp(surfaceAlt, other.surfaceAlt, t),
      borderOverride: Color.lerp(border, other.border, t),
      shadowColorOverride: Color.lerp(shadowColor, other.shadowColor, t),
    );
  }
}

/// Shared scenic canvas used by [AppShell]. The painter is intentionally
/// abstract: sky, clouds, distant polygonal hills and stars evoke the N64 era
/// without bundling or reconstructing proprietary game artwork.
class ThemeBackdrop extends StatelessWidget {
  const ThemeBackdrop({
    super.key,
    this.allowHalftone = true,
    this.menuSurface = false,
  });

  final bool allowHalftone;
  final bool menuSurface;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (retro.isIntro) {
      return IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: retro.isDark
                  ? const [
                      Color(0xFF172F6A),
                      Color(0xFF080F25),
                      Color(0xFF203F79),
                    ]
                  : const [
                      Color(0xFFDA9900),
                      Color(0xFFFFD329),
                      Color(0xFFE6A700),
                    ],
            ),
          ),
        ),
      );
    }
    if (retro.isMario && retro.marioAssets.complete) {
      final sky = retro.marioAsset(retro.isDark ? 'sky_night' : 'sky_day')!;
      return IgnorePointer(
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(sky),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, error, stack) =>
                    ColoredBox(color: retro.background),
              ),
              if (menuSurface)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: retro.background.withValues(
                      alpha: retro.isDark ? 0.45 : 0.22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }
    if (retro.isMario) {
      return IgnorePointer(
        child: DecoratedBox(
          decoration: retro.surfaceDecoration(shadowDx: 0, shadowDy: 0),
        ),
      );
    }
    if (retro.showN64Backdrop) {
      return IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _N64SkyPainter(retro: retro),
          ),
        ),
      );
    }
    if (allowHalftone && retro.showHalftone) {
      return HalftoneBackground(
        color: retro.ink.withValues(alpha: retro.isDark ? 0.035 : 0.08),
      );
    }
    return const SizedBox.shrink();
  }
}

class _N64SkyPainter extends CustomPainter {
  const _N64SkyPainter({required this.retro});

  final RetroTheme retro;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final top = retro.isDark
        ? const Color(0xFF10172E)
        : const Color(0xFF67BDF2);
    final bottom = retro.isDark
        ? const Color(0xFF2A315B)
        : const Color(0xFFDDF6FF);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(bounds),
    );

    if (retro.isDark) {
      final starPaint = Paint()
        ..color = const Color(0xFFFFE79A).withValues(alpha: 0.5);
      final stars = <Offset>[];
      for (var y = 22.0; y < size.height * 0.72; y += 58) {
        final row = (y / 58).round();
        for (var x = 18.0 + (row.isEven ? 0 : 31); x < size.width; x += 79) {
          stars.add(Offset(x, y));
        }
      }
      canvas.drawPoints(
        ui.PointMode.points,
        stars,
        starPaint..strokeWidth = 2.2,
      );
    } else {
      final cloud = Paint()..color = Colors.white.withValues(alpha: 0.34);
      for (final center in [
        Offset(size.width * 0.16, size.height * 0.13),
        Offset(size.width * 0.78, size.height * 0.3),
        Offset(size.width * 0.34, size.height * 0.57),
      ]) {
        canvas.drawOval(
          Rect.fromCenter(center: center, width: 82, height: 24),
          cloud,
        );
        canvas.drawCircle(center.translate(-20, -7), 17, cloud);
        canvas.drawCircle(center.translate(10, -10), 22, cloud);
      }
    }

    final horizon = size.height * 0.78;
    final farHill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, horizon + 18)
      ..quadraticBezierTo(
        size.width * 0.22,
        horizon - 42,
        size.width * 0.48,
        horizon + 10,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        horizon - 55,
        size.width,
        horizon + 5,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      farHill,
      Paint()
        ..color =
            (retro.isDark ? const Color(0xFF253B4F) : const Color(0xFF63B96C))
                .withValues(alpha: 0.2),
    );
  }

  @override
  bool shouldRepaint(covariant _N64SkyPainter oldDelegate) =>
      oldDelegate.retro.isDark != retro.isDark ||
      oldDelegate.retro.design != retro.design;
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
        if (retro.design.playfulSelection)
          MarioMenuGlyph(
            retro: retro,
            asset: 'star',
            fallback: Icons.star_rounded,
            size: 20,
            color: retro.secondaryAccent,
          )
        else
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.skewX(retro.chipSkew == 0 ? 0 : -0.5),
            child: Container(width: 5, height: 18, color: retro.accent),
          ),
        const SizedBox(width: 10),
        if (retro.isMario)
          Expanded(
            child: Text(
              label,
              style: retro
                  .heading(size: 13.5)
                  .copyWith(
                    fontFamily: retro.menuFamily,
                    height: 1.3,
                    letterSpacing: 0,
                  ),
            ),
          )
        else
          Flexible(
            child: MarioGameTitle(text: label, retro: retro, size: 17),
          ),
        if (japanese != null) ...[
          const SizedBox(width: 8),
          Text(japanese!, style: retro.body(size: 13, color: retro.inkDim)),
        ],
        if (!retro.isMario) ...[
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1.5,
              color: retro.inkDim.withValues(alpha: 0.35),
            ),
          ),
        ],
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
    final fg = selected ? retro.onColor(accent) : retro.ink;

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
    canvas.drawPath(
      path,
      Paint()
        ..color = stripeColor
        ..isAntiAlias = false,
    );
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
      decoration: BoxDecoration(
        borderRadius: retro.radius,
        color: bg,
        border: Border.all(color: c, width: retro.borderWidth(1.5)),
      ),
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
              fontSize: retro.isMario ? 16 : (dense ? 10 : 11.5),
              fontWeight: retro.isMario ? FontWeight.w400 : FontWeight.w800,
              letterSpacing: retro.isMario ? 0 : 0.4,
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
        border: Border.all(
          color: retro.background,
          width: retro.borderWidth(2),
        ),
      ),
      child: Icon(icon, size: size * 0.58, color: retro.onColor(c)),
    );
  }
}

/// Original texture when locally imported; themed vector fallback otherwise.
/// Decorative images never replace an action's accessible label.
class MarioMenuGlyph extends StatelessWidget {
  const MarioMenuGlyph({
    super.key,
    required this.retro,
    required this.asset,
    required this.fallback,
    this.size = 24,
    this.color,
  });
  final RetroTheme retro;
  final String asset;
  final IconData fallback;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final path = retro.marioAsset(asset);
    final icon = Icon(
      fallback,
      size: size,
      color: color ?? retro.secondaryAccent,
    );
    if (path == null) return icon;
    return ExcludeSemantics(
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, error, stack) => icon,
      ),
    );
  }
}

/// Compact HUD numerals; the complete value is announced once, not digit by digit.
class MarioHudNumber extends StatelessWidget {
  const MarioHudNumber({
    super.key,
    required this.value,
    required this.retro,
    this.size = 16,
  });
  final int value;
  final RetroTheme retro;
  final double size;
  @override
  Widget build(BuildContext context) {
    final text = value.toString();
    if (!retro.isMario ||
        !retro.marioAssets.available ||
        value < 0 ||
        text.length > 6) {
      return Text(text, style: retro.heading(size: size));
    }
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final digit in text.split(''))
              Image.file(
                File(retro.marioAsset('digit_$digit')!),
                width: size,
                height: size,
                filterQuality: FilterQuality.none,
                errorBuilder: (_, error, stack) =>
                    Text(digit, style: retro.heading(size: size)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Only the frame uses raw stone, so filled controls keep their semantic contrast.
class MarioControlFrameClipper extends CustomClipper<Path> {
  const MarioControlFrameClipper();
  @override
  Path getClip(Size size) => Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(Offset.zero & size)
    ..addRect((Offset.zero & size).deflate(4));
  @override
  bool shouldReclip(covariant MarioControlFrameClipper oldClipper) => false;
}

/// Original colored HUD glyphs for prominent menu headings. Missing HUD letters
/// use the ROM's complete file-select alphabet; unsupported accents use font fallback.
class MarioGameTitle extends StatelessWidget {
  const MarioGameTitle({
    super.key,
    required this.text,
    required this.retro,
    required this.size,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.color,
  });
  final String text;
  final RetroTheme retro;
  final double size;
  final int? maxLines;
  final TextOverflow overflow;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final style = retro.heading(size: size, color: color);
    if (!retro.isMario || !retro.marioAssets.complete)
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    final pixels = MediaQuery.textScalerOf(context).scale(size);
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              for (final character in text.split('')) ...[
                if (character == ' ')
                  WidgetSpan(child: SizedBox(width: pixels * 0.4))
                else if (retro.marioAsset(
                          'hud_glyph_${character.toUpperCase()}',
                        ) !=
                        null ||
                    retro.marioAsset('digit_$character') != null ||
                    retro.marioAsset('menu_glyph_${character.toUpperCase()}') !=
                        null)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Image.file(
                      File(
                        retro.marioAsset(
                              'hud_glyph_${character.toUpperCase()}',
                            ) ??
                            retro.marioAsset('digit_$character') ??
                            retro.marioAsset(
                              'menu_glyph_${character.toUpperCase()}',
                            )!,
                      ),
                      width: pixels * 0.88,
                      height: pixels,
                      filterQuality: FilterQuality.none,
                      color:
                          retro.marioAsset(
                                    'hud_glyph_${character.toUpperCase()}',
                                  ) ==
                                  null &&
                              retro.marioAsset('digit_$character') == null
                          ? color ?? retro.ink
                          : null,
                      errorBuilder: (_, error, stack) =>
                          Text(character, style: style),
                    ),
                  )
                else
                  TextSpan(text: character),
              ],
            ],
          ),
          style: style,
          maxLines: maxLines,
          overflow: overflow,
        ),
      ),
    );
  }
}

/// Shared icon vocabulary; unavailable game symbols retain their action's familiar icon.
class MarioGameIcon extends StatelessWidget {
  static final Map<IconData, String> _sprites =
      Map.unmodifiable(<IconData, String>{
        Icons.star_rounded: 'star',
        Icons.star: 'star',
        Icons.favorite: 'star',
        Icons.favorite_rounded: 'star',
        Icons.extension: 'mario_save',
        Icons.extension_rounded: 'mario_save',
        Icons.menu_rounded: 'menu_file',
        Icons.folder_rounded: 'menu_file',
        Icons.folder_open: 'menu_file',
        Icons.download_rounded: 'menu_copy',
        Icons.download: 'menu_copy',
        Icons.settings: 'menu_sound',
        Icons.settings_rounded: 'menu_sound',
        Icons.palette_outlined: 'mario_new',
        Icons.apps_rounded: 'menu_file',
        Icons.folder_zip_rounded: 'menu_copy',
        Icons.person: 'mario_head',
        Icons.color_lens_rounded: 'menu_score',
        Icons.touch_app_rounded: 'hand_pressed',
        Icons.trending_up_rounded: 'menu_score',
        Icons.workspace_premium_rounded: 'star',
        Icons.play_arrow_rounded: 'mario_save',
        Icons.sports_esports_rounded: 'mario_save',
        Icons.expand_more: 'arrow_down',
        Icons.expand_less: 'arrow_up',
        Icons.keyboard_arrow_down: 'arrow_down',
        Icons.keyboard_arrow_up: 'arrow_up',
      });

  const MarioGameIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.fill,
    this.weight,
    this.grade,
    this.opticalSize,
    this.shadows,
    this.applyTextScaling,
  });
  final IconData? icon;
  final double? size, fill, weight, grade, opticalSize;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final List<Shadow>? shadows;
  final bool? applyTextScaling;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final asset = _sprites[icon];
    final path = asset == null ? null : retro.marioAsset(asset);
    if (path == null)
      return Icon(
        icon,
        size: size,
        color: color,
        semanticLabel: semanticLabel,
        textDirection: textDirection,
        fill: fill,
        weight: weight,
        grade: grade,
        opticalSize: opticalSize,
        shadows: shadows,
        applyTextScaling: applyTextScaling,
      );
    final dimension = size ?? IconTheme.of(context).size ?? 24;
    final image = Image.file(
      File(path),
      width: dimension,
      height: dimension,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, error, stack) =>
          Icon(icon, size: dimension, color: color),
    );
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: image),
    );
  }
}

/// Confirmed on/off selection rendered as an original menu tile, without owning state.
class MarioGameToggle extends StatelessWidget {
  const MarioGameToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Semantics(
      toggled: value,
      enabled: onChanged != null,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Opacity(
            opacity: onChanged == null ? 0.5 : 1,
            child: Container(
              width: retro.isIntro ? 64 : 56,
              height: retro.isIntro ? 48 : 44,
              alignment: Alignment.center,
              decoration: retro.surfaceDecoration(
                color: retro.isIntro
                    ? (value
                          ? const Color(0xFF087B1A)
                          : const Color(0xFF41473B))
                    : null,
                borderColor: value ? retro.accent : retro.border,
                shadowDx: 2,
                shadowDy: 2,
              ),
              child: ColorFiltered(
                colorFilter: retro.isIntro && !value
                    ? const ColorFilter.matrix([
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ])
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: MarioMenuGlyph(
                  retro: retro,
                  asset: retro.isIntro
                      ? (value ? 'mario_save' : 'mario_new')
                      : (value ? 'star' : 'hand'),
                  fallback: value ? Icons.check : Icons.pan_tool_alt_rounded,
                  size: retro.isIntro ? 40 : 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
