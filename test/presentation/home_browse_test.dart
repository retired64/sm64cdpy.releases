import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/installation_library.dart';
import 'package:sm64cdpy/domain/entities/mod_entity.dart';
import 'package:sm64cdpy/services/manga_menu_audio.dart';
import 'package:sm64cdpy/presentation/providers/manga_menu_audio_provider.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/deluxe_visual_provider.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';
import 'package:sm64cdpy/presentation/providers/installation_library_provider.dart';
import 'package:sm64cdpy/presentation/providers/mod_providers.dart';
import 'package:sm64cdpy/presentation/screens/home_screen.dart';
import 'package:sm64cdpy/presentation/widgets/home_typography.dart';

class _Audio extends MangaMenuAudio {
  final played = <String>[];
  @override
  Future<void> play(String sound, {double volume = 0.65}) async { played.add(sound); }
}
class _Favourites extends FavouritesNotifier {
  @override
  Set<String> build() => {};
}
ModEntity _featured(String id) => ModEntity(
  id: id, url: 'https://example.com/$id', title: id, version: '1', author: 'Author',
  description: '', tags: const [], isFeatured: true, descriptionImages: const [],
  downloads: 0, views: 0, ratingCount: 0, reviewCount: 0, updateCount: 0,
  downloadUrls: const [], updates: const [], extractedAt: '',
);

class _Folder extends GameFolderNotifier {
  @override
  GameFolderState build() => const GameFolderState();
}
class _Welcome extends DeluxeWelcomeHiddenNotifier {
  @override
  bool build() => true;
}
class _Library extends InstallationLibraryNotifier {
  @override
  Future<InstallationLibraryState> build() async => const InstallationLibraryState(
    status: InstallationLibraryLoadStatus.ready,
    snapshot: InstallationLibrarySnapshot(receipts: [], history: [], issues: []),
  );
}

void main() {
  for (final id in [AppThemeId.retroManga, AppThemeId.mangaDeluxe]) {
    for (final language in ['en', 'es', 'pt']) {
      testWidgets('Home browse focus and compact launch $id $language', (tester) async {
        tester.view.physicalSize = const Size(320, 760);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const launcher = MethodChannel('sm64cdpy/launcher');
        final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        messenger.setMockMethodCallHandler(launcher, (call) async {
          if (call.method == 'isInstalled') return true;
          throw PlatformException(code: 'unexpected-method', message: call.method);
        });
        addTearDown(() => messenger.setMockMethodCallHandler(launcher, null));
        final audio = _Audio();
        final container = ProviderContainer(overrides: [
            mangaMenuAudioProvider.overrideWithValue(audio),
            favouritesProvider.overrideWith(_Favourites.new),
            featuredModsProvider.overrideWith((ref) => AsyncData([_featured('First'), _featured('Second')])),
            allModsProvider.overrideWith((ref) async => []),
            gameFolderProvider.overrideWith(_Folder.new),
            deluxeWelcomeHiddenProvider.overrideWith(_Welcome.new),
            installationLibraryProvider.overrideWith(_Library.new),
          ]);
        addTearDown(container.dispose);
        // Esta prueba mide UI ya cargada, no esperas del catálogo o de Android.
        await tester.runAsync(() async {
          await container.read(allModsProvider.future);
          await container.read(installationLibraryProvider.future);
        });
        expect(container.read(allModsProvider).hasValue, isTrue);
        await tester.pumpWidget(UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: Locale(language),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: RetroTheme.materialTheme(true, design: AppThemeCatalog.resolve(id)),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.6),
                disableAnimations: language == 'pt',
              ),
              child: child!,
            ),
            home: const Scaffold(body: HomeScreen()),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(audio.played, isEmpty);
        final strings = AppLocalizations.of(tester.element(find.byType(HomeScreen)));
        final badges = tester.widgetList<RetroTag>(find.byType(RetroTag))
            .where((tag) => tag.label == strings.badgeFeatured);
        expect(badges, isNotEmpty);
        expect(badges.every((tag) => tag.flexibleLabel), isTrue);
        final featured = find.byKey(const ValueKey('home-featured-pages'));
        await tester.scrollUntilVisible(featured, 140,
          scrollable: find.byType(Scrollable).first);
        await tester.drag(featured, const Offset(-190, 0));
        await tester.pumpAndSettle();
        expect(audio.played, ['home_slide']);
        final pages = find.byKey(const ValueKey('home-browse-pages'));
        await tester.scrollUntilVisible(pages, 140,
          scrollable: find.byType(Scrollable).first);
        await tester.pumpAndSettle();
        AnimatedContainer card(String path) => tester.widget<AnimatedContainer>(
          find.byKey(ValueKey('home-browse-card-$path')));
        expect(card('/catalogue').margin, const EdgeInsets.symmetric(horizontal: 6));
        expect(card('/catalogue').duration, language == 'pt'
          ? Duration.zero : const Duration(milliseconds: 250));
        await tester.drag(pages, const Offset(-190, 0));
        await tester.pumpAndSettle();
        expect(card('/favourites').margin, const EdgeInsets.symmetric(horizontal: 6));
        expect(card('/catalogue').margin,
          const EdgeInsets.symmetric(horizontal: 6, vertical: 8));
        expect(find.byType(HomeBrowseIcon), findsWidgets);
        expect(audio.played, ['home_slide', 'home_slide']);
        final launch = find.byType(HomeLaunchIcon);
        await tester.scrollUntilVisible(launch, 140,
          scrollable: find.byType(Scrollable).first);
        await tester.pumpAndSettle();
        final l = AppLocalizations.of(tester.element(find.byType(HomeScreen)));
        final label = tester.widget<HomeMarioLabel>(find.byWidgetPredicate(
          (widget) => widget is HomeMarioLabel && widget.label == l.homeLaunchGame));
        expect(label.singleLine, isTrue);
        expect(label.size, 14);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
