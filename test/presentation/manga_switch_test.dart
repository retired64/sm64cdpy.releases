import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/presentation/widgets/manga_switch.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('square switch: ink states, touch, semantics and keyboard dark=$dark', (tester) async {
      var value = false;
      await tester.pumpWidget(MaterialApp(
        theme: RetroTheme.materialTheme(dark),
        home: Scaffold(body: StatefulBuilder(builder: (context, update) {
          return MangaSwitch(value: value, onChanged: (next) => update(() => value = next));
        })),
      ));
      final control = find.byType(MangaSwitch);
      final rect = tester.getRect(control);
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      Semantics semantics() => tester.widget<Semantics>(find.descendant(
        of: control, matching: find.byType(Semantics),
      ).first);
      expect(semantics().properties.toggled, isFalse);
      final thumb = find.descendant(of: control, matching: find.byType(AnimatedAlign));
      expect(tester.widget<AnimatedAlign>(thumb).alignment, AlignmentDirectional.centerStart);
      final track = find.descendant(of: control, matching: find.byType(AnimatedContainer));
      final off = tester.widget<AnimatedContainer>(track).decoration! as BoxDecoration;
      expect(off.borderRadius, isNull);
      expect(off.shape, BoxShape.rectangle);
      await tester.tap(control);
      await tester.pumpAndSettle();
      expect(value, isTrue);
      expect(semantics().properties.toggled, isTrue);
      expect(tester.widget<AnimatedAlign>(thumb).alignment, AlignmentDirectional.centerEnd);
      final on = tester.widget<AnimatedContainer>(track).decoration! as BoxDecoration;
      expect(on.borderRadius, isNull);
      expect(on.color, isNot(off.color));
      final retro = RetroTheme.of(tester.element(control));
      final a = retro.ink.computeLuminance();
      final b = retro.background.computeLuminance();
      expect(((a > b ? a : b) + 0.05) / ((a < b ? a : b) + 0.05), greaterThan(4.5));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(value, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled square switch has no action dark=$dark', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: RetroTheme.materialTheme(dark),
        home: const Scaffold(body: MangaSwitch(value: true, onChanged: null)),
      ));
      final control = find.byType(MangaSwitch);
      final semantics = tester.widget<Semantics>(find.descendant(
        of: control, matching: find.byType(Semantics),
      ).first);
      expect(semantics.properties.enabled, isFalse);
      expect(semantics.properties.onTap, isNull);
      await tester.tap(control);
      await tester.pumpAndSettle();
      expect(tester.widget<MangaSwitch>(control).value, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduced motion removes the switch transition', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const Scaffold(body: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MangaSwitch(value: true, onChanged: null),
      )),
      theme: RetroTheme.materialTheme(false),
    ));
    expect(tester.widget<AnimatedAlign>(find.byType(AnimatedAlign)).duration, Duration.zero);
    expect(tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).duration, Duration.zero);
  });

  for (final design in AppThemeCatalog.designs) {
    testWidgets('switch rows keep native controls outside Manga: ${design.id}', (tester) async {
      var taps = 0;
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        theme: RetroTheme.materialTheme(false, design: design),
        home: Scaffold(body: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: ThemedSwitchListTile(
            title: const Text('Música ambiental'),
            subtitle: const Text('Volumen independiente de los efectos del menú'),
            value: false,
            onChanged: (_) => taps++,
          ),
        )),
      ));
      final manga = design.id.isManga;
      expect(find.byType(MangaSwitch), manga ? findsOneWidget : findsNothing);
      expect(find.byType(SwitchListTile), manga ? findsNothing : findsOneWidget);
      await tester.tap(find.text('Música ambiental'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
