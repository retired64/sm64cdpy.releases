import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/mod_entity.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/mod_providers.dart';
import 'package:sm64cdpy/presentation/screens/home_screen.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('real Home leaves loading after catalogue failure dark=$dark', (tester) async {
      final catalogue = Completer<List<ModEntity>>();
      await tester.pumpWidget(ProviderScope(
        overrides: [allModsProvider.overrideWith((ref) => catalogue.future)],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(
            dark, design: AppThemeCatalog.resolve(AppThemeId.mangaDeluxe),
          ),
          home: const Scaffold(body: HomeScreen()),
        ),
      ));
      expect(find.byType(Shimmer), findsWidgets);
      catalogue.completeError(StateError('catalog-offline'));
      await tester.pumpAndSettle();
      final l = AppLocalizations.of(tester.element(find.byType(HomeScreen)));
      expect(find.text(l.homeFailedToLoad), findsOneWidget);
      expect(find.byType(Shimmer), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
