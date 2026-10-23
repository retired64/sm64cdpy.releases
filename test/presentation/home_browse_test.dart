import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/app_theme_design.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/domain/entities/installation_library.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/deluxe_visual_provider.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';
import 'package:sm64cdpy/presentation/providers/installation_library_provider.dart';
import 'package:sm64cdpy/presentation/providers/mod_providers.dart';
import 'package:sm64cdpy/presentation/screens/home_screen.dart';
import 'package:sm64cdpy/presentation/widgets/home_typography.dart';

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
        await tester.pumpWidget(ProviderScope(
          overrides: [
            allModsProvider.overrideWith((ref) async => []),
            gameFolderProvider.overrideWith(_Folder.new),
            deluxeWelcomeHiddenProvider.overrideWith(_Welcome.new),
            installationLibraryProvider.overrideWith(_Library.new),
          ],
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
        await tester.pumpAndSettle();
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
