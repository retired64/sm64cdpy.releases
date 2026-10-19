import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/l10n/app_localizations.dart';
import 'package:sm64cdpy/presentation/providers/game_save_provider.dart';
import 'package:sm64cdpy/presentation/screens/game_save_screen.dart';

class _Files extends GameSaveNotifier {
  @override
  GameSaveState build() => GameSaveState(
    data: {
      'identity': 'save',
      'revision': 'original',
      'backups': [],
      'slots': [
        for (var i = 0; i < 4; i++)
          {
            'slot': i,
            'bank': 0,
            'total': i == 0 ? 120 : 0,
            'empty': false,
            'valid': true,
            'flags': i == 0 ? 31 << 24 : 0,
            'stars': List.generate(
              25,
              (c) => i == 0
                  ? (c < 15
                        ? 127
                        : c == 18
                        ? 3
                        : c < 24
                        ? 1
                        : 0)
                  : 0,
            ),
            'coins': List.filled(15, i == 0 ? 100 : 0),
            'cannons': List.filled(15, i == 0),
          },
      ],
    },
  );
}

void main() {
  for (final design in AppThemeCatalog.designs) {
    testWidgets(
      '${design.id}: tapping B opens its own draft, not A or the 120-star preset',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [gameSaveProvider.overrideWith(_Files.new)],
            child: MaterialApp(
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(extensions: [RetroTheme(false, design: design)]),
              home: const Scaffold(body: GameSaveScreen()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('★ 120 / 120'), findsOneWidget);
        await tester.ensureVisible(find.text('B'));
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        expect(find.text('Save File B · Normal'), findsOneWidget);
        expect(find.text('Preview · saved only after Apply'), findsOneWidget);
        expect(find.text('Complete progress: 120 stars'), findsNothing);
        expect(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('★ 0 / 120'),
          ),
          findsOneWidget,
        );
        await tester.tap(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.byTooltip('Slot actions'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Complete progress: 120 stars'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('★ 120 / 120'),
          ),
          findsOneWidget,
        );
        // Opening and cancelling an editor never changes confirmed slot data.
        await tester.tap(find.byTooltip('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Preview · saved only after Apply'), findsNothing);
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('★ 0 / 120'),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
