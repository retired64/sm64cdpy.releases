import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/mod_entity.dart';
import 'package:sm64cdpy/domain/entities/installation_action.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/mod_providers.dart';
import 'package:sm64cdpy/presentation/providers/installation_action_provider.dart';
import 'package:sm64cdpy/presentation/screens/mod_detail_screen.dart';

const mod = ModEntity(
  id: 'layout',
  url: 'https://example.com/mod',
  title: 'Super Mario 64: The Underworld — a very long mod title',
  version: '1.1.2',
  author: 'An author with a long name',
  description: 'A readable description of this adventure. ',
  tags: ['romhack'],
  isFeatured: false,
  descriptionImages: [],
  downloads: 21300,
  views: 62500,
  ratingCount: 1,
  reviewCount: 21,
  updateCount: 0,
  downloadUrls: [],
  updates: [],
  extractedAt: '',
);

void main() {
  for (final id in [
    AppThemeId.retroManga,
    AppThemeId.minishCap,
    AppThemeId.marioKart64,
    AppThemeId.mario64,
    AppThemeId.sm64Intro,
  ]) {
    testWidgets(
      '${id.storageKey} detail header stays below navigation at narrow width',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = const Size(360, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final theme = RetroTheme(false, design: AppThemeCatalog.resolve(id));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              allModsProvider.overrideWith((ref) async => [mod]),
              installationActionProvider.overrideWith(
                (ref, identity) => InstallationActionState(
                  primaryAction: InstallationPrimaryAction.download,
                  identity: identity,
                ),
              ),
            ],
            child: MaterialApp(
              theme: theme.toMaterialTheme(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.5)),
                child: child!,
              ),
              home: const ModDetailScreen(modId: 'layout'),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final header = find.byKey(const ValueKey('mod-detail-header'));
        final cover = find.byKey(const ValueKey('mod-detail-cover'));
        expect(header, findsOneWidget);
        expect(
          tester.getTopLeft(header).dy,
          greaterThanOrEqualTo(kToolbarHeight),
        );
        expect(tester.getSize(cover), const Size(112, 112));
        expect(find.text(mod.title), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
