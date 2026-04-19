import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// SM64CoopDX — Retro-gaming theme with light/dark modes (Material 3)
class AppTheme {
  AppTheme._();

  // ── Dark Theme Colors ─────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF13131A);
  static const Color darkSurfaceVariant = Color(0xFF1C1C27);
  static const Color darkSurfaceHigh = Color(0xFF252535);

  static const Color darkAccent = Color(0xFFE8344A); // SM64 red
  static const Color darkAccentSoft = Color(0xFF3D1520);
  static const Color darkGold = Color(0xFFFFCC00); // star gold
  static const Color darkGoldSoft = Color(0xFF3D3200);

  static const Color darkTextPrimary = Color(0xFFF0F0F8);
  static const Color darkTextSecondary = Color(0xFF8A8AAE);
  static const Color darkTextMuted = Color(0xFF55556A);

  static const Color darkDivider = Color(0xFF1F1F2E);
  static const Color darkShimmerBase = Color(0xFF1C1C27);
  static const Color darkShimmerHighlight = Color(0xFF2A2A3D);

  // ── Light Theme Colors ────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F5);
  static const Color lightSurfaceHigh = Color(0xFFE9ECEF);

  static const Color lightAccent = Color(
    0xFFD32F2F,
  ); // Slightly darker red for light mode
  static const Color lightAccentSoft = Color(0xFFFFEBEE);
  static const Color lightGold = Color(0xFFF57C00); // Amber for light mode
  static const Color lightGoldSoft = Color(0xFFFFF3E0);

  static const Color lightTextPrimary = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF495057);
  static const Color lightTextMuted = Color(0xFF6C757D);

  static const Color lightDivider = Color(0xFFDEE2E6);
  static const Color lightShimmerBase = Color(0xFFF1F3F5);
  static const Color lightShimmerHighlight = Color(0xFFE9ECEF);

  // ── Theme Getters ─────────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  // ── Helper to build theme based on brightness ────────────────────────
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Color selection based on brightness
    final background = isDark ? darkBackground : lightBackground;
    final surface = isDark ? darkSurface : lightSurface;
    final surfaceContainerHigh = isDark
        ? darkSurfaceVariant
        : lightSurfaceVariant;
    final surfaceContainerHighest = isDark ? darkSurfaceHigh : lightSurfaceHigh;
    final accent = isDark ? darkAccent : lightAccent;
    final accentSoft = isDark ? darkAccentSoft : lightAccentSoft;
    final gold = isDark ? darkGold : lightGold;
    final goldSoft = isDark ? darkGoldSoft : lightGoldSoft;
    final textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    final textSecondary = isDark ? darkTextSecondary : lightTextSecondary;
    final textMuted = isDark ? darkTextMuted : lightTextMuted;
    final divider = isDark ? darkDivider : lightDivider;

    // Base theme with Material 3
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    // ColorScheme
    final colorScheme = ColorScheme(
      brightness: brightness,
      // Primary colors
      primary: accent,
      onPrimary: Colors.white,
      primaryContainer: accentSoft,
      onPrimaryContainer: isDark ? Colors.white : darkAccent,
      // Secondary colors
      secondary: gold,
      onSecondary: isDark ? Colors.black : Colors.white,
      secondaryContainer: goldSoft,
      onSecondaryContainer: isDark ? Colors.black : darkGold,
      // Tertiary colors (optional)
      tertiary: isDark ? Color(0xFF00B4D8) : Color(0xFF0077B6),
      onTertiary: Colors.white,
      // Error colors
      error: Color(0xFFCF6679),
      onError: Colors.white,
      // Background colors
      background: background, // ignore: deprecated_member_use
      onBackground: textPrimary, // ignore: deprecated_member_use
      // Surface colors
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: textSecondary,
      // Outline colors
      outline: divider,
      outlineVariant: isDark ? Color(0xFF3A3A4D) : Color(0xFFCED4DA),
      // Other
      shadow: isDark
          ? Color.fromRGBO(0, 0, 0, 0.5)
          : Color.fromRGBO(158, 158, 158, 0.3),
      scrim: Color.fromRGBO(0, 0, 0, 0.5),
      inverseSurface: isDark ? lightSurface : darkSurface,
      onInverseSurface: isDark ? lightTextPrimary : darkTextPrimary,
      inversePrimary: isDark ? lightAccent : darkAccent,
      surfaceTint: accent,
    );

    // Base text theme with Google Fonts (Lato)
    final baseTextTheme = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final googleTextTheme = GoogleFonts.latoTextTheme(baseTextTheme);

    // Custom text theme with our colors
    final textTheme = googleTextTheme.copyWith(
      displayLarge: googleTextTheme.displayLarge?.copyWith(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      displayMedium: googleTextTheme.displayMedium?.copyWith(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: googleTextTheme.titleLarge?.copyWith(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: googleTextTheme.titleMedium?.copyWith(
        color: textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: googleTextTheme.titleSmall?.copyWith(
        color: textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: googleTextTheme.bodyLarge?.copyWith(
        color: textPrimary,
        fontSize: 15,
      ),
      bodyMedium: googleTextTheme.bodyMedium?.copyWith(
        color: textSecondary,
        fontSize: 13,
      ),
      bodySmall: googleTextTheme.bodySmall?.copyWith(
        color: textMuted,
        fontSize: 12,
      ),
      labelLarge: googleTextTheme.labelLarge?.copyWith(
        color: textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: googleTextTheme.labelMedium?.copyWith(
        color: textSecondary,
        fontSize: 12,
      ),
      labelSmall: googleTextTheme.labelSmall?.copyWith(
        color: textMuted,
        fontSize: 11,
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surface,
      dividerColor: divider,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),

      // Drawer
      drawerTheme: DrawerThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerHigh,
        labelStyle: TextStyle(
          color: textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // Input / Search
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: TextStyle(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: textSecondary,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }

  // ── Utility getters for direct color access ──────────────────────────
  static Color backgroundColor(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceContainerHighColor(bool isDark) =>
      isDark ? darkSurfaceVariant : lightSurfaceVariant;
  static Color surfaceContainerHighestColor(bool isDark) =>
      isDark ? darkSurfaceHigh : lightSurfaceHigh;
  static Color accentColor(bool isDark) => isDark ? darkAccent : lightAccent;
  static Color accentSoftColor(bool isDark) =>
      isDark ? darkAccentSoft : lightAccentSoft;
  static Color goldColor(bool isDark) => isDark ? darkGold : lightGold;
  static Color goldSoftColor(bool isDark) =>
      isDark ? darkGoldSoft : lightGoldSoft;
  static Color textPrimaryColor(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondaryColor(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMutedColor(bool isDark) =>
      isDark ? darkTextMuted : lightTextMuted;
  static Color dividerColor(bool isDark) => isDark ? darkDivider : lightDivider;
  static Color shimmerBaseColor(bool isDark) =>
      isDark ? darkShimmerBase : lightShimmerBase;
  static Color shimmerHighlightColor(bool isDark) =>
      isDark ? darkShimmerHighlight : lightShimmerHighlight;

  // ── Legacy getters (for backward compatibility during migration) ─────
  // These return dark theme colors to maintain existing behavior
  static Color get background => darkBackground;
  static Color get surface => darkSurface;
  static Color get surfaceContainerHigh => darkSurfaceVariant;
  static Color get surfaceContainerHighest => darkSurfaceHigh;
  static Color get accent => darkAccent;
  static Color get accentSoft => darkAccentSoft;
  static Color get gold => darkGold;
  static Color get goldSoft => darkGoldSoft;
  static Color get textPrimary => darkTextPrimary;
  static Color get textSecondary => darkTextSecondary;
  static Color get textMuted => darkTextMuted;
  static Color get divider => darkDivider;
  static Color get shimmerBase => darkShimmerBase;
  static Color get shimmerHighlight => darkShimmerHighlight;

  // Legacy theme getter (returns dark theme)
  static ThemeData get dark => darkTheme;
}
