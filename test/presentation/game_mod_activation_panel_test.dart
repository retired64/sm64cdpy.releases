import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/game_mod_activation_provider.dart';
import 'package:sm64cdpy/presentation/widgets/game_mod_activation_panel.dart';
import 'package:sm64cdpy/services/game_mod_activation.dart';

class _Gateway extends GameModActivation {
  GameModSnapshot current = const GameModSnapshot(
    status: 'ready',
    mods: [
      GameModEntry(
        name: 'alpha',
        title: 'Alpha adventure with a long descriptive name',
        enabled: false,
        selectable: true,
      ),
      GameModEntry(
        name: 'beta.lua',
        title: 'Beta',
        enabled: false,
        selectable: true,
        author: 'Fixture Author',
        category: 'romhack',
        versionLabel: '2.4',
        description: 'A description from the initial Lua header.',
      ),
    ],
  );
  int writes = 0;
  Map<String, Object>? lastWrite;
  Completer<void>? gate;
  @override
  Future<GameModSnapshot> read() async => current;
  @override
  Future<GameModSnapshot?> call(
    String method, [
    Map<String, Object>? arguments,
  ]) async {
    if (method != 'setGameModActivation') return current;
    writes++;
    if (gate != null) await gate!.future;
    final values = arguments!;
    lastWrite = values;
    current = GameModSnapshot(
      status: 'ready',
      mods: current.mods
          .map(
            (mod) => GameModEntry(
              kind: mod.kind,
              origin: mod.origin,
              name: mod.name,
              title: mod.title,
              selectable: mod.selectable,
              author: mod.author,
              category: mod.category,
              versionLabel: mod.versionLabel,
              description: mod.description,
              enabled:
                  mod.name == values['name'] &&
                      mod.kind == (values['kind'] ?? 'lua')
                  ? values['enabled'] == true
                  : mod.enabled,
            ),
          )
          .toList(),
    );
    return current;
  }
}

bool _fontsLoaded = false;

Future<void> _loadBundledFonts(WidgetTester tester) async {
  if (_fontsLoaded) return;
  await tester.runAsync(() async {
    final headings = FontLoader('TypefaceMario64')
      ..addFont(rootBundle.load('fonts/TypefaceMario64.otf'));
    await headings.load();
  });
  _fontsLoaded = true;
}

Future<void> _mount(
  WidgetTester tester,
  _Gateway gateway,
  AppThemeId design, {
  bool dark = false,
  double scale = 1,
}) async {
  await _loadBundledFonts(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [gameModGatewayProvider.overrideWithValue(gateway)],
      child: MaterialApp(
        theme: RetroTheme.materialTheme(
          dark,
          design: AppThemeCatalog.resolve(design),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: GameModActivationPanel(),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _toggle(WidgetTester tester, String name) async {
  final toggle = find.byKey(ValueKey('game-mod-switch-$name'));
  await tester.ensureVisible(toggle);
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

Future<void> _apply(WidgetTester tester) async {
  final apply = find.descendant(
    of: find.byType(Dialog),
    matching: find.byIcon(Icons.check_rounded),
  );
  await tester.ensureVisible(apply);
  await tester.tap(apply);
  await tester.pump();
}

void main() {
  testWidgets(
    'DynOS and Lua with the same folder name save independent switches',
    (tester) async {
      final gateway = _Gateway();
      gateway.current = const GameModSnapshot(
        status: 'ready',
        mods: [
          GameModEntry(
            name: 'Same',
            title: 'Same',
            enabled: false,
            selectable: true,
          ),
          GameModEntry(
            kind: 'dynos',
            origin: 'root',
            name: 'Same',
            title: 'Same',
            enabled: false,
            selectable: true,
          ),
        ],
      );
      await _mount(tester, gateway, AppThemeId.sm64Intro);
      expect(find.byKey(const ValueKey('game-mod-card-Same')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('game-mod-card-dynos:Same')),
        findsOneWidget,
      );
      expect(find.text('dynos/packs/Same'), findsOneWidget);
      await _toggle(tester, 'dynos:Same');
      await _apply(tester);
      await tester.pumpAndSettle();
      expect(gateway.lastWrite, {
        'name': 'Same',
        'kind': 'dynos',
        'enabled': true,
      });
      expect(gateway.current.mods.first.enabled, isFalse);
      expect(gateway.current.mods.last.enabled, isTrue);
      await _toggle(tester, 'Same');
      await tester.pumpAndSettle();
      expect(gateway.lastWrite, {
        'name': 'Same',
        'kind': 'lua',
        'enabled': true,
      });
      expect(gateway.current.mods.every((mod) => mod.enabled), isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final design in AppThemeId.values) {
    for (final dark in [false, true]) {
      testWidgets(
        '${design.name} $dark supports narrow screens, large text and local filtering',
        (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final gateway = _Gateway();
          await _mount(tester, gateway, design, dark: dark, scale: 1.6);
          expect(tester.takeException(), isNull);
          final search = find.byKey(const ValueKey('game-mods-search'));
          await tester.ensureVisible(search);
          await tester.enterText(search, 'beta');
          await tester.pumpAndSettle();
          expect(
            find.byKey(const ValueKey('game-mod-card-alpha')),
            findsNothing,
          );
          expect(
            find.byKey(const ValueKey('game-mod-card-beta.lua')),
            findsOneWidget,
          );
          final enabled = find.byKey(const ValueKey('game-mod-filter-enabled'));
          await tester.ensureVisible(enabled);
          await tester.tap(enabled);
          await tester.pumpAndSettle();
          expect(find.byType(Switch), findsNothing);
          expect(gateway.writes, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'merged metadata is searchable and full details never write configuration',
    (tester) async {
      final gateway = _Gateway();
      await _mount(tester, gateway, AppThemeId.mario64);
      final search = find.byKey(const ValueKey('game-mods-search'));
      await tester.ensureVisible(search);
      await tester.enterText(search, 'Fixture Author');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('game-mod-card-alpha')), findsNothing);
      expect(
        find.byKey(const ValueKey('game-mod-card-beta.lua')),
        findsOneWidget,
      );
      final details = find.text('Mod details');
      await tester.ensureVisible(details);
      await tester.tap(details);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(Dialog),
          matching: find.text('user/mods/beta.lua'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('A description from the initial Lua header.'),
        findsWidgets,
      );
      expect(gateway.writes, 0);
      final close = find.text('Close');
      await tester.ensureVisible(close);
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(gateway.writes, 0);
    },
  );

  testWidgets(
    'confirmation covers the visit, saves remain confirmed and resume asks again',
    (tester) async {
      final gateway = _Gateway();
      await _mount(tester, gateway, AppThemeId.mario64);
      await _toggle(tester, 'alpha');
      expect(find.byType(Dialog), findsOneWidget);
      gateway.gate = Completer<void>();
      await _apply(tester);
      await tester.pump(const Duration(milliseconds: 250));
      expect(gateway.writes, 1);
      expect(gateway.current.mods.first.enabled, isFalse);
      expect(find.byKey(const ValueKey('game-mod-switch-alpha')), findsNothing);
      gateway.gate!.complete();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Switch>(find.byKey(const ValueKey('game-mod-switch-alpha')))
            .value,
        isTrue,
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await _toggle(tester, 'beta.lua');
      expect(find.byType(Dialog), findsNothing);
      expect(gateway.writes, 2);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      // Android lifecycle passes through hidden/inactive when returning to the UI.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await _toggle(tester, 'alpha');
      expect(find.byType(Dialog), findsOneWidget);
      final cancel = find.descendant(
        of: find.byType(Dialog),
        matching: find.byIcon(Icons.close_rounded),
      );
      await tester.ensureVisible(cancel);
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(gateway.writes, 2);
      expect(gateway.current.mods.first.enabled, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
