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

class _DismissibleWelcome extends DeluxeWelcomeHiddenNotifier {
  @override
  bool build() => false;
  @override
  Future<bool> dismiss() async {
    state = true;
    return true;
  }
}

class _HiddenWelcome extends DeluxeWelcomeHiddenNotifier {
  @override
  bool build() => true;
}

class _MovingBackdrop extends DeluxeMotionNotifier {
  @override
  bool build() => true;
}

class _SwitchableMotion extends DeluxeMotionNotifier {
  @override
  bool build() => false;
  @override
  Future<bool> select(bool value) async {
    state = value;
    return true;
  }
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
      expect(await container.read(deluxeWelcomeHiddenProvider.notifier).dismiss(), isTrue);
      await box.put('auto_install_mods', 'false');
      final restored = ProviderContainer();
      try {
        expect(restored.read(themeDesignProvider).id, AppThemeId.mangaDeluxe);
        expect(restored.read(deluxeMotionProvider), isTrue);
        expect(restored.read(deluxeWelcomeHiddenProvider), isTrue);
      } finally { restored.dispose(); }
      expect(await container.read(deluxeMotionProvider.notifier).select(false), isTrue);
      expect(box.get('auto_install_mods'), 'false');
      expect(container.read(deluxeWelcomeHiddenProvider), isTrue);
      await box.close();
      expect(await container.read(deluxeMotionProvider.notifier).select(true), isFalse);
      expect(container.read(deluxeMotionProvider), isFalse);
      final unavailable = ProviderContainer();
      try {
        expect(await unavailable.read(deluxeWelcomeHiddenProvider.notifier).dismiss(), isFalse);
        expect(unavailable.read(deluxeWelcomeHiddenProvider), isFalse);
      } finally { unavailable.dispose(); }
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
    AnimationController controller() => tester.widget<AnimatedBuilder>(
      find.descendant(
        of: find.byKey(const ValueKey('manga-deluxe-backdrop')),
        matching: find.byType(AnimatedBuilder),
      ),
    ).animation as AnimationController;
    addTearDown(() => tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    expect(find.byKey(const ValueKey('manga-deluxe-backdrop')), findsOneWidget);
    expect(controller().isAnimating, isFalse);
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
    expect(controller().isAnimating, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(controller().isAnimating, isFalse);
    final pausedValue = controller().value;
    await tester.pump(const Duration(milliseconds: 200));
    expect(controller().value, pausedValue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller().isAnimating, isTrue);
    await tester.pumpWidget(scene(true));
    await tester.pumpAndSettle();
    expect(controller().isAnimating, isFalse);
    final reducedValue = controller().value;
    await tester.pump(const Duration(milliseconds: 200));
    expect(controller().value, reducedValue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('motion switch moves pixels, stops and resumes without remounting', (tester) async {
    final container = ProviderContainer(overrides: [
      deluxeMotionProvider.overrideWith(_SwitchableMotion.new),
    ]);
    addTearDown(container.dispose);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: RetroTheme.materialTheme(true, design: design),
        home: const Scaffold(body: SizedBox.expand(child: DeluxeBackdrop())),
      ),
    ));
    await tester.pumpAndSettle();
    double offset() => tester.widget<Transform>(
      find.byKey(const ValueKey('deluxe-motion-hats')),
    ).transform.storage[12];
    expect(offset(), 0);
    final notifier = container.read(deluxeMotionProvider.notifier);
    await notifier.select(true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // Más de 5 dp por segundo: perceptible incluso en los huecos de Home.
    expect(offset(), lessThan(-5));
    await notifier.select(false);
    await tester.pump();
    final stopped = offset();
    await tester.pump(const Duration(seconds: 1));
    expect(offset(), stopped);
    await notifier.select(true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(offset(), lessThan(stopped - 5));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'es', 'pt']) {
    for (final dark in [false, true]) {
      testWidgets('Deluxe welcome and help fit 320px $language dark=$dark', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(ProviderScope(child: MaterialApp(
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: RetroTheme.materialTheme(dark, design: design),
          home: Scaffold(body: MediaQuery(data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
            child: SingleChildScrollView(child: Column(children: [
              const DeluxeWelcomePanel(), const DeluxeHelpPanel(),
            ])))),
        )));
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('deluxe-welcome')), findsOneWidget);
        expect(find.byKey(const ValueKey('deluxe-help')), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Skip immediately removes the introduction after confirmation', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [deluxeWelcomeHiddenProvider.overrideWith(_DismissibleWelcome.new)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: RetroTheme.materialTheme(false, design: design),
        home: const Scaffold(body: SingleChildScrollView(child: DeluxeWelcomePanel())),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('deluxe-skip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('deluxe-welcome')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismissed welcome leaves no card or spacing', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [deluxeWelcomeHiddenProvider.overrideWith(_HiddenWelcome.new)],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: RetroTheme.materialTheme(false, design: design),
        home: const Scaffold(body: DeluxeWelcomePanel()),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('deluxe-welcome')), findsNothing);
    expect(tester.getSize(find.byType(DeluxeWelcomePanel)), Size.zero);
  });

  test('only Deluxe neutral paper lets the backdrop through', () {
    for (final dark in [false, true]) {
      final retro = RetroTheme(dark, design: design);
      expect(retro.surfaceDecoration().color!.a, closeTo(0.88, 0.01));
      expect(RetroTheme(dark).surfaceDecoration().color!.a, 1);
      expect(retro.surfaceDecoration(color: retro.accent).color, retro.accent);
    }
  });

  test('Deluxe assets are small bundled WebPs', () async {
    for (final name in ['hats', 'pattern', 'coopdx']) {
      final data = await rootBundle.load('assets/themes/manga_deluxe/$name.webp');
      expect(data.getUint32(0), 0x52494646);
      expect(data.lengthInBytes, lessThan(50000));
    }
  });
}
