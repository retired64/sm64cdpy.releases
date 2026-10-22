import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sm64cdpy/core/constants/app_constants.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/mod_entity.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/deluxe_visual_provider.dart';
import 'package:sm64cdpy/presentation/providers/theme_provider.dart';
import 'package:sm64cdpy/presentation/widgets/deluxe_backdrop.dart';
import 'package:sm64cdpy/presentation/widgets/deluxe_content.dart';
import 'package:sm64cdpy/services/deluxe_links.dart';

ModEntity _mod({String id = '3', String url = 'https://mods.sm64coopdx.com/mods/day-night-cycle-dx.3/'}) => ModEntity(
  id: id, url: url, title: 'Day Night Cycle DX', version: '', author: 'AgentX',
  description: '', tags: const [], isFeatured: true, descriptionImages: const [],
  downloads: 0, views: 0, ratingCount: 0, reviewCount: 0, updateCount: 0,
  downloadUrls: const [], updates: const [], extractedAt: '',
);

class _MovingBackdrop extends DeluxeMotionNotifier {
  @override
  bool build() => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final design = AppThemeCatalog.resolve(AppThemeId.mangaDeluxe);

  test('Deluxe is available and shares capabilities without Japanese decorations', () {
    expect(AppThemeId.fromStorage('manga_deluxe'), AppThemeId.mangaDeluxe);
    for (final dark in [false, true]) {
      final retro = RetroTheme(dark, design: design);
      expect(retro.isDeluxe, isTrue);
      expect(retro.isManga, isTrue);
      expect(retro.usesComicSurfaces, isTrue);
      expect(retro.supportsAdaptiveAccent, isTrue);
      expect(retro.showJapaneseDecorations, isFalse);
      expect(retro.radius, BorderRadius.zero);
    }
    expect(RetroTheme(false).isDeluxe, isFalse);
  });

  test('demo identity is stable and does not guess from display titles', () {
    expect(DeluxeLinks.hasDemo(_mod()), isTrue);
    expect(DeluxeLinks.hasDemo(_mod(id: '4')), isFalse);
    expect(DeluxeLinks.hasDemo(_mod(url: 'https://example.com/mods/day-night-cycle-dx.3/')), isFalse);
  });

  test('Deluxe restoration and motion do not alter other settings', () async {
    final directory = await Directory.systemTemp.createTemp('manga-deluxe-');
    Hive.init(directory.path);
    final box = await Hive.openBox<String>(AppConstants.settingsBoxKey);
    final container = ProviderContainer();
    try {
      expect(container.read(deluxeMotionProvider), isFalse);
      expect(await container.read(appearanceProvider.notifier).setTheme(AppThemeId.mangaDeluxe), isTrue);
      expect(await container.read(deluxeMotionProvider.notifier).select(true), isTrue);
      await box.put('auto_install_mods', 'false');
      final restored = ProviderContainer();
      try {
        expect(restored.read(themeDesignProvider).id, AppThemeId.mangaDeluxe);
        expect(restored.read(deluxeMotionProvider), isTrue);
      } finally { restored.dispose(); }
      expect(await container.read(deluxeMotionProvider.notifier).select(false), isTrue);
      expect(box.get('auto_install_mods'), 'false');
      await box.close();
      expect(await container.read(deluxeMotionProvider.notifier).select(true), isFalse);
      expect(container.read(deluxeMotionProvider), isFalse);
    } finally {
      container.dispose(); await Hive.close(); await directory.delete(recursive: true);
    }
  });

  testWidgets('background is static by default and honors reduced motion', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: MaterialApp(
      theme: RetroTheme.materialTheme(false, design: design),
      home: const Scaffold(body: SizedBox.expand(child: DeluxeBackdrop())),
    )));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('manga-deluxe-backdrop')), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    final moving = ProviderContainer(overrides: [
      deluxeMotionProvider.overrideWith(_MovingBackdrop.new),
    ]);
    addTearDown(moving.dispose);
    await tester.pumpWidget(const SizedBox.shrink());
    Widget scene(bool reduced) => UncontrolledProviderScope(container: moving, child: MaterialApp(
      theme: RetroTheme.materialTheme(true, design: design),
      home: Scaffold(body: MediaQuery(data: MediaQueryData(disableAnimations: reduced),
        child: const SizedBox.expand(child: DeluxeBackdrop()))),
    ));
    await tester.pumpWidget(scene(false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpWidget(scene(true));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'es', 'pt']) {
    for (final dark in [false, true]) {
      testWidgets('Deluxe editorial and help fit 320px $language dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(dark, design: design),
          home: Scaffold(body: MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
            child: SingleChildScrollView(child: Column(children: [
              const DeluxeWelcomePanel(), DeluxeFeaturedStory(mod: _mod()), const DeluxeHelpPanel(),
            ])))),
        ));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('deluxe-welcome')), findsOneWidget);
        expect(find.byKey(const ValueKey('deluxe-editorial')), findsOneWidget);
        expect(find.byKey(const ValueKey('deluxe-help')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  test('Deluxe assets are small bundled WebPs', () async {
    for (final name in ['hats', 'pattern', 'coopdx']) {
      final data = await rootBundle.load('assets/themes/manga_deluxe/$name.webp');
      expect(data.getUint32(0), 0x52494646);
      expect(data.lengthInBytes, lessThan(50000));
    }
  });
}
