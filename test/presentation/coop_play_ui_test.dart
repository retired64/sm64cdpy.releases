import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/coop_session.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/coop_session_provider.dart';
import 'package:sm64cdpy/presentation/screens/coop_session_screen.dart';
import 'package:sm64cdpy/presentation/widgets/coop_play_visuals.dart';

class _Session extends CoopSessionNotifier {
  _Session(this.initial, this.allowed);
  final CoopSessionState initial;
  final bool allowed;
  @override
  CoopSessionState build() => initial;
  @override
  Future<List<String>> recentCodes() async => [];
  @override
  Future<CoopBatteryOptimizationState> batteryOptimizationStatus() async =>
      CoopBatteryOptimizationState(supported: true, ignored: allowed);
}

Widget _app(AppThemeId theme, String language, bool dark,
    CoopSessionState state, {bool allowed = true}) => ProviderScope(
  overrides: [coopSessionProvider.overrideWith(() => _Session(state, allowed))],
  child: MaterialApp(
    locale: Locale(language),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: RetroTheme.materialTheme(dark, design: AppThemeCatalog.resolve(theme)),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.5)),
      child: child!,
    ),
    home: const Scaffold(body: CoopSessionScreen()),
  ),
);

void main() {
  for (final theme in [AppThemeId.retroManga, AppThemeId.mangaDeluxe]) {
    for (final dark in [false, true]) {
      for (final language in ['en', 'es', 'pt']) {
        testWidgets('compact Play $theme $language dark=$dark', (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(_app(theme, language, dark,
            const CoopSessionState(initialized: true, gameInstalled: true)));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('coop-game-missing')), findsNothing);
          expect(find.byKey(const ValueKey('coop-battery-help')), findsNothing);
          expect(find.byType(CoopPlayIcon), findsWidgets);
          final action = find.byType(CoopPlayAction).last;
          await tester.ensureVisible(action);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final field = find.byType(TextField);
          await tester.ensureVisible(field);
          await tester.tap(field);
          await tester.enterText(field, 'abcd-1234');
          expect(tester.widget<TextField>(field).controller!.text, 'abcd-1234');
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('Play action preserves callback and disabled state', (tester) async {
    var calls = 0;
    Widget scene(bool enabled) => MaterialApp(
      theme: RetroTheme.materialTheme(false,
        design: AppThemeCatalog.resolve(AppThemeId.mangaDeluxe)),
      home: Scaffold(body: CoopPlayAction(
        label: 'Create room', icon: Icons.add_link_rounded,
        primary: true, onPressed: enabled ? () => calls++ : null,
      )),
    );
    await tester.pumpWidget(scene(true));
    expect(tester.widget<Text>(find.text('Create room')).style?.fontFamily, 'SupremeSpike');
    await tester.tap(find.text('Create room'));
    expect(calls, 1);
    await tester.pumpWidget(scene(false));
    await tester.tap(find.text('Create room'));
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('unresolved game and battery requirements remain visible', (tester) async {
    await tester.pumpWidget(_app(AppThemeId.mangaDeluxe, 'en', false,
      const CoopSessionState(initialized: true, gameInstalled: false), allowed: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('coop-game-missing')), findsOneWidget);
    expect(find.byKey(const ValueKey('coop-battery-help')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final phase in CoopSessionPhase.values.where((phase) => phase.active)) {
    testWidgets('Play preserves active state actions for $phase', (tester) async {
      await tester.pumpWidget(_app(AppThemeId.mangaDeluxe, 'en', true,
        CoopSessionState(initialized: true, gameInstalled: true,
          phase: phase, mode: CoopSessionMode.host, code: 'ABCD-1234')));
      await tester.pumpAndSettle();
      final stop = find.byWidgetPredicate((widget) =>
        widget is CoopPlayAction && widget.icon == Icons.stop_circle_outlined);
      await tester.ensureVisible(stop);
      await tester.pumpAndSettle();
      expect(tester.widget<CoopPlayAction>(stop).onPressed == null,
        phase == CoopSessionPhase.stopping);
      expect(find.byType(TextField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
