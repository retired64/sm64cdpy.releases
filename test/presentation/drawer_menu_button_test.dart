import 'dart:math' as math;
import 'dart:ui' as ui show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/screens/disclaimer_screen.dart';
import 'package:sm64cdpy/presentation/widgets/app_shell.dart';

enum _Host { pinned, fixed, disclaimer }

Widget _body(_Host host) => switch (host) {
  _Host.pinned => const CustomScrollView(
    slivers: [RetroPinnedAppBar(title: Text('Title'))],
  ),
  _Host.fixed => const RetroFixedHeaderView(
    title: Text('Title'),
    child: SizedBox.expand(),
  ),
  _Host.disclaimer => const DisclaimerScreen(),
};

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

void main() {
  for (final design in AppThemeCatalog.designs) {
    for (final dark in [false, true]) {
      for (final language in ['en', 'es', 'pt']) {
        for (final host in _Host.values) {
          testWidgets('drawer ${design.id} dark=$dark $language ${host.name}', (
            tester,
          ) async {
            tester.view.physicalSize = const Size(320, 640);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final semantics = tester.ensureSemantics();
            try {
              final scaffold = GlobalKey<ScaffoldState>();
              await tester.pumpWidget(
                MaterialApp(
                  locale: Locale(language),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: RetroTheme.materialTheme(dark, design: design),
                  home: Scaffold(
                    key: scaffold,
                    drawer: const Drawer(child: Text('Drawer content')),
                    body: _body(host),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              final menu = find.byType(DrawerMenuButton);
              final button = find.descendant(
                of: menu,
                matching: find.byType(IconButton),
              );
              final context = tester.element(button);
              final tooltip = MaterialLocalizations.of(
                context,
              ).openAppDrawerTooltip;
              expect(find.byTooltip(tooltip), findsOneWidget);
              final rect = tester.getRect(button);
              expect(rect.width, greaterThanOrEqualTo(48));
              expect(rect.height, greaterThanOrEqualTo(48));
              expect(rect.left, greaterThanOrEqualTo(0));
              expect(rect.right, lessThanOrEqualTo(56));
              expect(rect.top, greaterThanOrEqualTo(0));
              expect(rect.bottom, lessThanOrEqualTo(56));
              final data = tester.getSemantics(button).getSemanticsData();
              expect(data.flagsCollection.isButton, isTrue);
              expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
              expect('${data.label} ${data.tooltip}', contains(tooltip));

              final retro = RetroTheme.of(context);
              final icon = tester.widget<MarioGameIcon>(
                find.descendant(of: menu, matching: find.byType(MarioGameIcon)),
              );
              final backgrounds = find.byKey(
                const ValueKey('drawer-menu-surface'),
              );
              // El modo minimalista no incorpora ningún panel decorativo.
              if (retro.usesMinimalSurfaces) {
                expect(backgrounds, findsNothing);
                expect(
                  _contrast(icon.color!, retro.background),
                  greaterThanOrEqualTo(3),
                );
              } else {
                final decoration =
                    tester.widget<DecoratedBox>(backgrounds).decoration
                        as BoxDecoration;
                expect(decoration.border, isNotNull);
                expect(
                  decoration.borderRadius,
                  retro.surfaceDecoration().borderRadius,
                );
                expect(
                  _contrast(icon.color!, decoration.color!),
                  greaterThanOrEqualTo(3),
                );
                // La inclinación y la sombra pintadas también caben en el botón.
                final transform = tester.widget<Transform>(
                  find
                      .descendant(of: menu, matching: find.byType(Transform))
                      .first,
                );
                expect(
                  transform.transform.entry(0, 1),
                  closeTo(-math.tan(retro.chipSkew), 0.0001),
                );
                final box = tester.renderObject<RenderBox>(backgrounds);
                final materialRect = MatrixUtils.transformRect(
                  box.getTransformTo(null),
                  Offset.zero & box.size,
                );
                var paintedRect = materialRect;
                for (final shadow in decoration.boxShadow ?? <BoxShadow>[]) {
                  paintedRect = paintedRect.expandToInclude(
                    materialRect
                        .shift(shadow.offset)
                        .inflate(shadow.spreadRadius),
                  );
                }
                expect(paintedRect.left, greaterThanOrEqualTo(rect.left));
                expect(paintedRect.right, lessThanOrEqualTo(rect.right));
                expect(paintedRect.top, greaterThanOrEqualTo(rect.top));
                expect(paintedRect.bottom, lessThanOrEqualTo(rect.bottom));
              }
              if (host == _Host.pinned) {
                final bar = tester.widget<SliverAppBar>(
                  find.byType(SliverAppBar),
                );
                expect(bar.leadingWidth, 56);
                expect(bar.toolbarHeight, 56);
              }
              // Probar cerca de la esquina, no solo encima del dibujo central.
              await tester.tapAt(rect.topLeft + const Offset(4, 4));
              await tester.pumpAndSettle();
              expect(scaffold.currentState!.isDrawerOpen, isTrue);
              expect(tester.takeException(), isNull);
            } finally {
              semantics.dispose();
            }
          });
        }
      }
      testWidgets('section colors ${design.id} dark=$dark stay readable', (
        tester,
      ) async {
        final retro = RetroTheme(dark, design: design);
        for (final color in [retro.amber, retro.blue, retro.accent]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: RetroTheme.materialTheme(dark, design: design),
              home: Scaffold(
                drawer: const Drawer(),
                body: SizedBox(
                  width: 56,
                  height: 56,
                  child: DrawerMenuButton(color: color),
                ),
              ),
            ),
          );
          final icon = tester.widget<MarioGameIcon>(find.byType(MarioGameIcon));
          final background = retro.usesMinimalSurfaces
              ? retro.background
              : retro.surfaceDecoration().color!;
          expect(_contrast(icon.color!, background), greaterThanOrEqualTo(3));
          if (_contrast(color, background) >= 3) {
            expect(icon.color, color);
          }
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('drawer preserves custom color icon and size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: RetroTheme.materialTheme(false),
        home: const Scaffold(
          drawer: Drawer(),
          body: DrawerMenuButton(
            color: Colors.red,
            icon: Icons.settings,
            size: 24,
          ),
        ),
      ),
    );
    final icon = tester.widget<MarioGameIcon>(find.byType(MarioGameIcon));
    expect(icon.color, Colors.red);
    expect(icon.icon, Icons.settings);
    expect(icon.size, 24);
  });
}
