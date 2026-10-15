import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/game_folder_provider.dart';
import 'package:sm64cdpy/presentation/widgets/game_folder_card.dart';
import 'package:sm64cdpy/presentation/widgets/game_setup_widgets.dart';
import 'package:sm64cdpy/services/game_folder_service.dart';

class FixedFolder extends GameFolderNotifier {
  FixedFolder(this.connected);
  final bool connected;
  @override
  GameFolderState build() => GameFolderState(initialized: true,
    connection: GameFolderConnection(connected: connected, unified: connected,
      mods: connected, dynos: connected, config: connected, rom: connected));
}

void main() {
  for (final design in AppThemeCatalog.designs) {
    for (final dark in [false, true]) {
      testWidgets('${design.id.name} $dark guides folder selection at large text', (tester) async {
        tester.view.physicalSize = const Size(360, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(ProviderScope(
          overrides: [gameFolderProvider.overrideWith(() => FixedFolder(false))],
          child: MaterialApp(
            theme: RetroTheme.materialTheme(dark, design: design),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!),
            home: const Scaffold(body: SingleChildScrollView(child: GameFolderCard(optional: true))),
          ),
        ));
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(GameFolderCard));
        final l10n = AppLocalizations.of(context);
        await tester.ensureVisible(find.text(l10n.gameFolderChoose));
        await tester.tap(find.text(l10n.gameFolderChoose));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.text('com.maniscat2.sm64coopdx/\nuser/'), findsOneWidget);
        expect(find.text(l10n.gameFolderGuide), findsOneWidget);
        final dialog = find.byType(Dialog);
        final cancel = find.descendant(of: dialog, matching: find.text(l10n.gameFolderLater));
        await tester.ensureVisible(cancel);
        await tester.tap(cancel);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('connected settings reveal status and actions through the shared selector', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [gameFolderProvider.overrideWith(() => FixedFolder(true))],
      child: MaterialApp(
        theme: RetroTheme.materialTheme(false),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SingleChildScrollView(child: GameFolderCard())),
      ),
    ));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(tester.element(find.byType(GameFolderCard)));
    expect(find.byType(GameSetupAction), findsNothing);
    await tester.tap(find.text(l10n.gameFolderTitle));
    await tester.pumpAndSettle();
    expect(find.text(l10n.gameFolderConfigReady), findsOneWidget);
    expect(find.text(l10n.gameFolderRomFound), findsOneWidget);
    expect(find.byType(GameSetupAction), findsNWidgets(2));
    await tester.tap(find.text(l10n.gameFolderTitle));
    await tester.pumpAndSettle();
    expect(find.byType(GameSetupAction), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
