import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/player_profile.dart';
import 'package:sm64cdpy/presentation/widgets/player_3d_preview.dart';

void main() {
  testWidgets('scrolling offscreen preserves the player preview state', (
    tester,
  ) async {
    const profile = PlayerProfile(
      name: 'Mario',
      model: 0,
      palette: PlayerPalette.mario,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 240,
            child: ListView(
              children: [
                const SizedBox(
                  height: 220,
                  child: Player3DPreview(
                    profile: profile,
                    loadingLabel: 'Loading',
                    unavailableLabel: 'Unavailable',
                  ),
                ),
                const SizedBox(height: 1200),
              ],
            ),
          ),
        ),
      ),
    );
    final before = tester.state(find.byType(Player3DPreview));

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();

    final preview = find.byType(Player3DPreview, skipOffstage: false);
    expect(preview, findsOneWidget);
    expect(tester.state(preview), same(before));
  });
}
