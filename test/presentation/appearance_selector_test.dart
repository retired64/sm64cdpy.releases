import 'mario_rom_fixture.dart';
import 'package:sm64cdpy/presentation/providers/mario_theme_assets_provider.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'package:sm64cdpy/presentation/widgets/appearance_selector.dart';

class _Harness extends ConsumerWidget {
  const _Harness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final design = ref.watch(themeDesignProvider);
    return MaterialApp(
      theme: RetroTheme.materialTheme(false, design: design),
      darkTheme: RetroTheme.materialTheme(true, design: design),
      themeMode: ref.watch(themeModeProvider),
      themeAnimationDuration: Duration.zero,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(key: ValueKey('theme-probe'), height: 1),
              AppearanceSelector(),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'bundled menu changes the full design and follows system brightness',
    (tester) async {
      late Directory directory;
      late ProviderContainer container;
      await tester.runAsync(() async {
        directory = await Directory.systemTemp.createTemp('theme-menu-test-');
        Hive.init(directory.path);
        await Hive.openBox<String>(AppConstants.settingsBoxKey);
        container = ProviderContainer(
          overrides: [
            marioThemeAssetsServiceProvider.overrideWithValue(
              ReadyMarioRomService(),
            ),
          ],
        );
        await container.read(marioThemeAssetsProvider.notifier).initialize();
      });
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const _Harness(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Interface theme'));
        await tester.pumpAndSettle();

        final mario = find.byKey(const ValueKey('theme-mario64'));
        await tester.ensureVisible(mario);
        await tester.runAsync(() async {
          await tester.tap(mario);
          // Await the actual Hive write instead of a timing-based UI assertion.
          await Hive.box<String>(AppConstants.settingsBoxKey).flush();
        });
        await tester.pumpAndSettle();
        expect(container.read(themeDesignProvider).id, AppThemeId.mario64);
        var theme = Theme.of(
          tester.element(find.byKey(const ValueKey('theme-probe'))),
        );
        expect(theme.extension<RetroTheme>()!.design.id, AppThemeId.mario64);
        expect(theme.extension<RetroTheme>()!.radius, BorderRadius.circular(0));
        expect(theme.extension<RetroTheme>()!.showN64Backdrop, isTrue);
        expect(theme.extension<RetroTheme>()!.usesBeveledSurfaces, isTrue);
        expect(theme.colorScheme.primary, const Color(0xFFA82010));

        tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
        await tester.pumpAndSettle();
        theme = Theme.of(
          tester.element(find.byKey(const ValueKey('theme-probe'))),
        );
        expect(theme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, const Color(0xFFFFC928));
        expect(find.byKey(const ValueKey('theme-odyssey')), findsNothing);
        expect(find.byKey(const ValueKey('theme-gamecube')), findsNothing);
        final modeHeader = find.text(
          AppLocalizations.of(
            tester.element(find.byKey(const ValueKey('theme-probe'))),
          ).settingsThemeMode,
        );
        expect(find.byKey(const ValueKey('theme-mode-light')), findsNothing);
        await tester.ensureVisible(modeHeader);
        await tester.tap(modeHeader);
        await tester.pumpAndSettle();
        for (final mode in ThemeMode.values) {
          expect(
            find.byKey(ValueKey('theme-mode-${mode.name}')),
            findsOneWidget,
          );
        }
        final light = find.byKey(const ValueKey('theme-mode-light'));
        await tester.ensureVisible(light);
        await tester.runAsync(() async {
          await tester.tap(light);
          await Hive.box<String>(AppConstants.settingsBoxKey).flush();
        });
        await tester.pumpAndSettle();
        expect(container.read(themeModeProvider), ThemeMode.light);
        expect(container.read(themeDesignProvider).id, AppThemeId.mario64);
        theme = Theme.of(
          tester.element(find.byKey(const ValueKey('theme-probe'))),
        );
        expect(theme.brightness, Brightness.light);
        await tester.ensureVisible(modeHeader);
        await tester.tap(modeHeader);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('theme-mode-light')), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        tester.platformDispatcher.clearPlatformBrightnessTestValue();
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.runAsync(() async {
          await Hive.close();
          await directory.delete(recursive: true);
        });
      }
    },
  );
}
