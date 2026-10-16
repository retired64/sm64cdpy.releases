import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return ((x > y ? x : y) + 0.05) / ((x < y ? x : y) + 0.05);
}

void main() {
  test('unknown/absent IDs use Retro Manga by default', () {
    expect(AppThemeId.fromStorage(null), AppThemeId.retroManga);
    expect(AppThemeId.fromStorage('removed-theme'), AppThemeId.retroManga);
    expect(
      AppThemeCatalog.designs.map((d) => d.id).toSet().length,
      AppThemeId.values.length,
    );
  });

  test('minimal option disables decorative rendering work', () {
    final design = AppThemeCatalog.resolve(AppThemeId.minimal);
    expect(design.backdropStyle, AppBackdropStyle.none);
    expect(design.halftone, isFalse);
    expect(design.stripes, isFalse);
    expect(design.chipSkew, 0);
    expect(design.shadowBlur, 0);
    expect(design.shadowOffsetScale, 0);
    expect(design.surfaceTreatment, AppSurfaceTreatment.minimal);
    expect(design.softSettingsPanels, isFalse);

    final retro = RetroTheme(false, design: design);
    final surface = retro.surfaceDecoration();
    expect(surface.color, Colors.transparent);
    expect(surface.border, isNull);
    expect(surface.boxShadow, isNull);

    final neutral = retro.gameDecoration(
      BoxDecoration(
        color: retro.surface,
        border: Border.all(color: retro.border),
        boxShadow: const [BoxShadow(blurRadius: 8)],
      ),
    );
    expect(neutral.color, Colors.transparent);
    expect(neutral.border, isNull);
    expect(neutral.boxShadow, isNull);
  });

  for (final design in AppThemeCatalog.designs) {
    for (final dark in [false, true]) {
      test(
        '${design.id.storageKey} $dark has readable surface and fill roles',
        () {
          final r = RetroTheme(dark, design: design);
          for (final surface in [r.background, r.surface, r.surfaceAlt]) {
            expect(contrast(r.ink, surface), greaterThanOrEqualTo(4.5));
            expect(contrast(r.inkDim, surface), greaterThanOrEqualTo(4.5));
            expect(contrast(r.accentText, surface), greaterThanOrEqualTo(4.5));
          }
          expect(contrast(r.accent, r.inkOnAccent), greaterThanOrEqualTo(4.5));
          final material = r.toMaterialTheme();
          expect(material.extension<RetroTheme>(), same(r));
          expect(material.colorScheme.primary, r.accent);
          expect(material.colorScheme.onPrimary, r.inkOnAccent);
          expect(material.scaffoldBackgroundColor, r.background);
          expect(
            r.systemUiStyle.statusBarIconBrightness,
            r.background.computeLuminance() > 0.179
                ? Brightness.dark
                : Brightness.light,
          );
          expect(
            r.systemUiStyle.systemNavigationBarIconBrightness,
            r.systemUiStyle.statusBarIconBrightness,
          );
        },
      );
    }
  }

  test(
    'contrast for custom filled categories does not depend on canvas color',
    () {
      for (final design in AppThemeCatalog.designs) {
        final r = RetroTheme(false, design: design);
        for (final color in [
          Colors.yellow,
          Colors.indigo,
          r.red,
          r.blue,
          r.amber,
          r.medalGold,
        ]) {
          expect(contrast(color, r.onColor(color)), greaterThanOrEqualTo(4.5));
        }
      }
    },
  );

  test('labels preserve authored case outside the manga design', () {
    expect(const RetroTheme(false).displayLabel('New release'), 'NEW RELEASE');
    final rounded = RetroTheme(
      false,
      design: AppThemeCatalog.resolve(AppThemeId.mario64),
    );
    expect(rounded.displayLabel('New release'), 'New release');
    expect(rounded.systemUiStyle.systemNavigationBarColor, rounded.background);
  });

  test('settings softness is confined to the selected design', () {
    expect(const RetroTheme(false).design.softSettingsPanels, isFalse);
    final mario = RetroTheme(
      false,
      design: AppThemeCatalog.resolve(AppThemeId.mario64),
    );
    expect(mario.design.softSettingsPanels, isTrue);
    expect(mario.design.shadowBlur, 0);
    expect(mario.design.backdropStyle, AppBackdropStyle.n64Sky);
    expect(mario.design.surfaceTreatment, AppSurfaceTreatment.beveled);
    expect(mario.design.playfulSelection, isTrue);
    expect(mario.showN64Backdrop, isTrue);
    expect(mario.usesBeveledSurfaces, isTrue);
    expect(mario.showHalftone, isFalse);
    expect(mario.copyWith().design.softSettingsPanels, isTrue);
  });

  test('retro manga retains its original decoration policy', () {
    const retro = RetroTheme(false);
    expect(retro.design.backdropStyle, AppBackdropStyle.halftone);
    expect(retro.design.surfaceTreatment, AppSurfaceTreatment.flat);
    expect(retro.design.playfulSelection, isFalse);
    expect(retro.showHalftone, isTrue);
    expect(retro.showN64Backdrop, isFalse);
  });

  test('overlay keeps its fixed palette regardless of catalogue selection', () {
    final overlay = RetroTheme.overlay();
    expect(overlay.design.id, AppThemeId.retroManga);
    expect(overlay.isDark, isTrue);
    expect(overlay.background, const Color(0xFF12141C));
    expect(overlay.surface, const Color(0xFF1A1D29));
    expect(overlay.toMaterialTheme().extension<RetroTheme>(), same(overlay));
  });

  test(
    'extension interpolation supports overrides and preserves endpoints',
    () {
      final a = RetroTheme.overlay();
      final b = RetroTheme(
        false,
        design: AppThemeCatalog.resolve(AppThemeId.mario64),
      );
      expect(a.lerp(b, 0), same(a));
      expect(a.lerp(b, 1), same(b));
      expect(
        a.lerp(b, 0.5).background,
        Color.lerp(a.background, b.background, 0.5),
      );
      expect(a.copyWith().background, a.background);
    },
  );

  testWidgets('changing design removes manga decorations through context', (
    tester,
  ) async {
    const halftoneKey = ValueKey('halftone-under-test');
    const stripesKey = ValueKey('stripes-under-test');
    final halftone = find.byKey(halftoneKey);
    final stripes = find.byKey(stripesKey);

    Future<void> render(AppThemeId id) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: RetroTheme.materialTheme(
            false,
            design: AppThemeCatalog.resolve(id),
          ),
          themeAnimationDuration: Duration.zero,
          home: const SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                HalftoneBackground(key: halftoneKey, color: Colors.black),
                DiagonalStripeBanner(
                  key: stripesKey,
                  baseColor: Colors.white,
                  stripeColor: Colors.black,
                ),
              ],
            ),
          ),
        ),
      );
      // AnimatedTheme/Navigator can schedule an extra frame even when the
      // theme transition duration is zero. Assert the settled selected design.
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    Future<void> expectManga() async {
      await render(AppThemeId.retroManga);
      expect(
        find.descendant(of: halftone, matching: find.byType(CustomPaint)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: stripes, matching: find.byType(CustomPaint)),
        findsOneWidget,
      );
    }

    await expectManga();
    for (final id in [AppThemeId.mario64]) {
      await render(id);
      // Restrict finders to our components: MaterialApp may also paint its
      // own surfaces, which are not manga decorations.
      expect(
        find.descendant(of: halftone, matching: find.byType(CustomPaint)),
        findsNothing,
      );
      expect(
        find.descendant(of: stripes, matching: find.byType(CustomPaint)),
        findsNothing,
      );
      final fill = find.descendant(
        of: stripes,
        matching: find.byType(ColoredBox),
      );
      expect(fill, findsOneWidget);
      expect(tester.widget<ColoredBox>(fill).color, Colors.white);
    }
    // Re-enabling decorations is part of switching designs too.
    await expectManga();
  });
}
