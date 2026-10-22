import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'package:sm64cdpy/presentation/widgets/appearance_selector.dart';
import 'package:sm64cdpy/presentation/widgets/locale_selector.dart';
import 'package:sm64cdpy/presentation/widgets/settings_expansion_group.dart';

class _LocaleHarness extends ConsumerWidget {
  const _LocaleHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final design = ref.watch(themeDesignProvider);
    final tag = ref.watch(localeNotifierProvider);
    return MaterialApp(
      theme: RetroTheme.materialTheme(false, design: design),
      themeAnimationDuration: Duration.zero,
      locale: tag == null
          ? const Locale('en')
          : LocaleNotifier.localeFromTag(tag),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              AppearanceSelector(),
              SizedBox(height: 12),
              LocaleSelector(),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'language shares selectors, keeps animation and saves before collapsing',
    (tester) async {
      late Directory directory;
      late ProviderContainer container;
      SharedPreferences.setMockInitialValues({});
      await tester.runAsync(() async {
        directory = await Directory.systemTemp.createTemp(
          'locale-selector-test-',
        );
        Hive.init(directory.path);
        final box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
        await box.putAll({
          'theme_id': 'mario_kart_64',
          'theme_mode': 'light',
          'locale': 'en_US',
        });
        container = ProviderContainer();
      });
      try {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const _LocaleHarness(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SettingsExpansionGroup), findsNWidgets(3));
        expect(
          find.byKey(const PageStorageKey('mario-rom-assets')),
          findsNothing,
        );
        final group = find.byKey(const PageStorageKey('locale-selector'));
        final arrow = find.descendant(
          of: group,
          matching: find.byType(AnimatedRotation),
        );
        final size = find.descendant(
          of: group,
          matching: find.byType(AnimatedSize),
        );
        expect(
          tester.widget<AnimatedRotation>(arrow).duration,
          const Duration(milliseconds: 200),
        );
        expect(
          tester.widget<AnimatedSize>(size).duration,
          const Duration(milliseconds: 220),
        );
        expect(find.byKey(const ValueKey('locale-es_419')), findsNothing);
        final header = find.descendant(
          of: group,
          matching: find.byIcon(Icons.translate_rounded),
        );
        await tester.ensureVisible(header);
        await tester.tap(header);
        await tester.pump(const Duration(milliseconds: 110));
        expect(tester.widget<AnimatedRotation>(arrow).turns, 0.5);
        await tester.pumpAndSettle();
        final spanish = find.byKey(const ValueKey('locale-es_419'));
        await tester.ensureVisible(spanish);
        await tester.runAsync(() async {
          await tester.tap(spanish);
          await Hive.box<String>(AppConstants.settingsBoxKey).flush();
          final prefs = await SharedPreferences.getInstance();
          expect(prefs.getString(AppConstants.appLocaleKey), 'es_419');
        });
        await tester.pumpAndSettle();
        expect(container.read(localeNotifierProvider), 'es_419');
        expect(
          Hive.box<String>(AppConstants.settingsBoxKey).get('locale'),
          'es_419',
        );
        expect(find.byKey(const ValueKey('locale-es_419')), findsNothing);
        expect(tester.widget<AnimatedRotation>(arrow).turns, 0);
        await tester.ensureVisible(header);
        await tester.tap(header);
        await tester.pumpAndSettle();
        final system = find.byKey(const ValueKey('locale-system'));
        await tester.ensureVisible(system);
        await tester.runAsync(() async {
          await tester.tap(system);
          await Hive.box<String>(AppConstants.settingsBoxKey).flush();
        });
        await tester.pumpAndSettle();
        expect(container.read(localeNotifierProvider), isNull);
        expect(
          Hive.box<String>(AppConstants.settingsBoxKey).get('locale'),
          'system',
        );
        expect(tester.takeException(), isNull);
      } finally {
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
