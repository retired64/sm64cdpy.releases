import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/utils/extensions.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'package:sm64cdpy/presentation/widgets/locale_selector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'new languages survive provider recreation; system clears the override',
    () async {
      final directory = await Directory.systemTemp.createTemp('locale-flow-');
      Hive.init(directory.path);
      SharedPreferences.setMockInitialValues({});
      await Hive.openBox<String>(AppConstants.settingsBoxKey);
      var container = ProviderContainer();
      try {
        for (final language in ['fr', 'it']) {
          await container
              .read(localeNotifierProvider.notifier)
              .setLocale(language);
          expect(container.read(localeNotifierProvider), language);
          expect(
            (await SharedPreferences.getInstance()).getString(
              AppConstants.appLocaleKey,
            ),
            language,
          );
          container.dispose();
          container = ProviderContainer();
          expect(container.read(localeNotifierProvider), language);
        }
        await container.read(localeNotifierProvider.notifier).setLocale(null);
        expect(container.read(localeNotifierProvider), isNull);
        expect(
          (await SharedPreferences.getInstance()).getString(
            AppConstants.appLocaleKey,
          ),
          'system',
        );
      } finally {
        container.dispose();
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'failed persistence leaves the published language and native mirror intact',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'locale-failure-',
      );
      Hive.init(directory.path);
      final box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
      await box.put('locale', 'fr');
      SharedPreferences.setMockInitialValues({AppConstants.appLocaleKey: 'fr'});
      final container = ProviderContainer();
      try {
        expect(container.read(localeNotifierProvider), 'fr');
        await box.close();
        await expectLater(
          container.read(localeNotifierProvider.notifier).setLocale('it'),
          throwsA(anything),
        );
        expect(container.read(localeNotifierProvider), 'fr');
        expect(
          (await SharedPreferences.getInstance()).getString(
            AppConstants.appLocaleKey,
          ),
          'fr',
        );
      } finally {
        container.dispose();
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );

  for (final language in ['fr', 'it']) {
    testWidgets(
      '$language selector and author label fit a narrow enlarged interface',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: Locale(language),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Builder(
                    builder: (context) => Column(
                      children: [
                        const LocaleSelector(),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).sharedAuthor('Release Soon'),
                        ),
                        Text(
                          AppLocalizations.of(
                            context,
                          ).detailDownloadedNotInstalled('mod.zip'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Release Soon'), findsOneWidget);
        expect(
          find.textContaining(
            language == 'fr' ? 'pas installé' : 'non installato',
          ),
          findsOneWidget,
        );
        await tester.tap(find.byIcon(Icons.translate_rounded));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('locale-fr')), findsOneWidget);
        expect(find.byKey(const ValueKey('locale-it')), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'regional formatting follows the supplied locale without global state',
    () async {
      await initializeDateFormatting();
      expect(4.5.starFor('it'), '4,5');
      expect(4.5.starFor('fr'), '4,5');
      expect(4.5.starFor('en'), '4.5');
      expect(formatDate('2026-10-24', locale: 'it'), contains('24 ott'));
      expect(formatDate('2026-10-24', locale: 'en'), contains('Oct 24'));
      expect(catalogTitle('N/A', 'Sans titre'), 'Sans titre');
    },
  );
}
