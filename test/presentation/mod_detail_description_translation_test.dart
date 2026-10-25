import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/installation_action.dart';
import 'package:sm64cdpy/domain/entities/mod_entity.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/installation_action_provider.dart';
import 'package:sm64cdpy/presentation/providers/mod_providers.dart';
import 'package:sm64cdpy/presentation/screens/mod_detail_screen.dart';

const _toggleKey = ValueKey('mod-description-language-toggle');
const _aboutHeadingKey = ValueKey('mod-description-about-heading');

String _repeat(String text) => List<String>.filled(12, text).join(' ');

final _english = _repeat('Original English description of this adventure.');
final _spanish = _repeat('Descripción en español de esta aventura.');
final _french = _repeat('Description française de cette aventure.');

final _translatedMod = ModEntity(
  id: 'translated',
  url: 'https://example.test/mod',
  title: 'Translated Mod',
  version: '1.0',
  author: 'Test Author',
  description: _english,
  descriptionTranslations: <String, String>{
    'es': _spanish,
    'pt_BR': _repeat('Descrição em português desta aventura.'),
    'fr': _french,
    'it': _repeat('Descrizione italiana di questa avventura.'),
  },
  tags: const <String>['romhack'],
  isFeatured: false,
  descriptionImages: const <String>[],
  downloads: 0,
  views: 0,
  ratingCount: 0,
  reviewCount: 0,
  updateCount: 0,
  downloadUrls: const <String>[],
  updates: const [],
  extractedAt: '',
);

final _untranslatedMod = ModEntity(
  id: 'untranslated',
  url: 'https://example.test/plain',
  title: 'Plain Mod',
  version: '1.0',
  author: 'Plain Author',
  description: _english,
  tags: const <String>[],
  isFeatured: false,
  descriptionImages: const <String>[],
  downloads: 0,
  views: 0,
  ratingCount: 0,
  reviewCount: 0,
  updateCount: 0,
  downloadUrls: const <String>[],
  updates: const [],
  extractedAt: '',
);

Widget _app({
  required Locale locale,
  required ModEntity mod,
  double textScale = 1,
  ValueListenable<Locale>? localeListenable,
  AppThemeId themeId = AppThemeId.retroManga,
}) {
  final home = ModDetailScreen(modId: mod.id);
  final theme = RetroTheme(false, design: AppThemeCatalog.resolve(themeId));
  Widget material(Locale effectiveLocale) => MaterialApp(
    theme: theme.toMaterialTheme(),
    locale: effectiveLocale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  );
  return ProviderScope(
    overrides: [
      allModsProvider.overrideWith((ref) async => [mod]),
      installationActionProvider.overrideWith(
        (ref, identity) => InstallationActionState(
          primaryAction: InstallationPrimaryAction.download,
          identity: identity,
        ),
      ),
    ],
    child: localeListenable == null
        ? material(locale)
        : ValueListenableBuilder<Locale>(
            valueListenable: localeListenable,
            builder: (_, value, _) => material(value),
          ),
  );
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required Locale locale,
  ModEntity? mod,
  double textScale = 1,
  Size size = const Size(360, 900),
  ValueListenable<Locale>? localeListenable,
  AppThemeId themeId = AppThemeId.retroManga,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    _app(
      locale: locale,
      mod: mod ?? _translatedMod,
      textScale: textScale,
      localeListenable: localeListenable,
      themeId: themeId,
    ),
  );
  await tester.pumpAndSettle();
}

String? _toggleTooltip(WidgetTester tester) =>
    tester.widget<IconButton>(find.byKey(_toggleKey)).tooltip;

Future<void> _tapToggle(WidgetTester tester) async {
  final toggle = find.byKey(_toggleKey);
  expect(toggle, findsOneWidget);
  await tester.ensureVisible(toggle);
  await tester.pumpAndSettle();
  await tester.tap(toggle);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('English never shows the translation action', (tester) async {
    await _pumpDetail(tester, locale: const Locale('en'));

    expect(find.text(_english), findsWidgets);
    expect(find.text(_spanish), findsNothing);
    expect(find.byKey(_toggleKey), findsNothing);
    expect(find.text('View original'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Spanish starts translated and toggles the original', (
    tester,
  ) async {
    await _pumpDetail(tester, locale: const Locale('es'));

    final l10n = AppLocalizations.of(
      tester.element(find.byType(ModDetailScreen)),
    );
    expect(find.text(_spanish), findsWidgets);
    expect(find.text(_english), findsNothing);
    expect(find.text(l10n.detailDescriptionViewOriginal), findsNothing);
    expect(_toggleTooltip(tester), l10n.detailDescriptionViewOriginal);

    await _tapToggle(tester);
    expect(find.text(_english), findsWidgets);
    expect(find.text(_spanish), findsNothing);
    expect(find.text(l10n.detailDescriptionViewTranslation), findsNothing);
    expect(_toggleTooltip(tester), l10n.detailDescriptionViewTranslation);

    await _tapToggle(tester);
    expect(find.text(_spanish), findsWidgets);
    expect(find.text(_english), findsNothing);
    expect(_toggleTooltip(tester), l10n.detailDescriptionViewOriginal);
  });

  testWidgets('Portuguese locale resolves the pt_BR translation', (
    tester,
  ) async {
    await _pumpDetail(tester, locale: const Locale('pt', 'PT'));

    expect(find.textContaining('Descrição em português'), findsWidgets);
    expect(find.text(_english), findsNothing);
    expect(find.byKey(_toggleKey), findsOneWidget);
  });

  testWidgets('missing translations keep the original without an action', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      locale: const Locale('es'),
      mod: _untranslatedMod,
    );

    expect(find.text(_english), findsWidgets);
    expect(find.byKey(_toggleKey), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('toggling language preserves the description expansion state', (
    tester,
  ) async {
    await _pumpDetail(tester, locale: const Locale('es'));

    await tester.ensureVisible(find.text('Mostrar más'));
    await tester.tap(find.text('Mostrar más'));
    await tester.pumpAndSettle();
    expect(find.text('Mostrar menos'), findsOneWidget);

    await _tapToggle(tester);
    expect(find.text(_english), findsWidgets);
    expect(find.text('Mostrar menos'), findsOneWidget);
    expect(find.text('Mostrar más'), findsNothing);
  });

  testWidgets('title, author and tags are unchanged after toggling', (
    tester,
  ) async {
    await _pumpDetail(tester, locale: const Locale('es'));

    await _tapToggle(tester);

    expect(find.text('Translated Mod'), findsOneWidget);
    expect(find.text('Test Author'), findsOneWidget);
    expect(find.text('romhack'), findsOneWidget);
    expect(find.text(_english), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('changing locale resets the view to the new translation', (
    tester,
  ) async {
    final locale = ValueNotifier<Locale>(const Locale('es'));
    addTearDown(locale.dispose);
    await _pumpDetail(
      tester,
      locale: const Locale('es'),
      localeListenable: locale,
    );

    await _tapToggle(tester);
    expect(find.text(_english), findsWidgets);

    locale.value = const Locale('fr');
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(ModDetailScreen)),
    );
    expect(find.text(_french), findsWidgets);
    expect(find.text(_english), findsNothing);
    expect(_toggleTooltip(tester), l10n.detailDescriptionViewOriginal);
  });

  testWidgets('translation icon sits at the right of the About heading', (
    tester,
  ) async {
    await _pumpDetail(tester, locale: const Locale('es'));

    final l10n = AppLocalizations.of(
      tester.element(find.byType(ModDetailScreen)),
    );
    final heading = find.byKey(_aboutHeadingKey);
    final toggle = find.byKey(_toggleKey);
    expect(heading, findsOneWidget);
    expect(toggle, findsOneWidget);
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();

    final headingCenter = tester.getCenter(heading);
    final toggleCenter = tester.getCenter(toggle);
    expect(toggleCenter.dy, closeTo(headingCenter.dy, 1));
    expect(tester.getTopRight(toggle).dx, greaterThan(320));

    final description = find.text(_spanish).first;
    expect(
      tester.getBottomLeft(toggle).dy,
      lessThanOrEqualTo(tester.getTopLeft(description).dy),
    );

    final icon = tester.widget<Image>(
      find.descendant(of: toggle, matching: find.byType(Image)),
    );
    expect((icon.image as AssetImage).assetName, 'assets/icons/translate.webp');
    expect(find.text(l10n.detailDescriptionViewOriginal), findsNothing);
    expect(find.text(l10n.detailDescriptionViewTranslation), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Deluxe keeps the translate icon in the About header', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      locale: const Locale('es'),
      themeId: AppThemeId.mangaDeluxe,
    );

    expect(find.byKey(_aboutHeadingKey), findsOneWidget);
    expect(find.byKey(_toggleKey), findsOneWidget);
    final toggle = find.byKey(_toggleKey);
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    expect(tester.getSize(toggle).height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  testWidgets('action stays usable at narrow width with enlarged text', (
    tester,
  ) async {
    await _pumpDetail(
      tester,
      locale: const Locale('es'),
      size: const Size(320, 760),
      textScale: 2,
    );

    final toggle = find.byKey(_toggleKey);
    expect(toggle, findsOneWidget);
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();

    final size = tester.getSize(toggle);
    expect(size.height, greaterThanOrEqualTo(44));
    expect(size.width, lessThanOrEqualTo(320));
    expect(tester.getTopRight(toggle).dx, greaterThan(280));
    expect(tester.takeException(), isNull);
  });
}
