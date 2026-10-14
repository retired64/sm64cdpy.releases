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
  testWidgets('bundled menu changes the full design and follows system brightness', (tester) async {
    late Directory directory;
    late ProviderContainer container;
    await tester.runAsync(() async {
      directory = await Directory.systemTemp.createTemp('theme-menu-test-');
      Hive.init(directory.path);
      await Hive.openBox<String>(AppConstants.settingsBoxKey);
      container = ProviderContainer();
    });
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    try {
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const _Harness(),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Interface theme'));
      await tester.pumpAndSettle();

      final gamecube = find.byKey(const ValueKey('theme-gamecube'));
      await tester.ensureVisible(gamecube);
      await tester.runAsync(() async {
        await tester.tap(gamecube);
        // Await the actual Hive write instead of a timing-based UI assertion.
        await Hive.box<String>(AppConstants.settingsBoxKey).flush();
      });
      await tester.pumpAndSettle();
      expect(container.read(themeDesignProvider).id, AppThemeId.gamecube);
      var theme = Theme.of(tester.element(find.byKey(const ValueKey('theme-probe'))));
      expect(theme.extension<RetroTheme>()!.design.id, AppThemeId.gamecube);
      expect(theme.extension<RetroTheme>()!.radius, BorderRadius.circular(6));
      expect(theme.colorScheme.primary, const Color(0xFF59409C));

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      theme = Theme.of(tester.element(find.byKey(const ValueKey('theme-probe'))));
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, const Color(0xFFC5ADFF));
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
  });
}
