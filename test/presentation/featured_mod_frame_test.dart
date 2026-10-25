import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/theme/app_theme_catalog.dart';
import 'package:sm64cdpy/core/theme/retro_theme.dart';
import 'package:sm64cdpy/presentation/widgets/featured_mod_frame.dart';

void main() {
  for (final design in AppThemeCatalog.designs) {
    for (final dark in [false, true]) {
      testWidgets('featured ink frame is isolated: ${design.id} dark=$dark', (tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: RetroTheme.materialTheme(dark, design: design),
          home: const Scaffold(body: SizedBox(
            width: 280, height: 220,
            child: FeaturedModFrame(child: ColoredBox(color: Colors.red)),
          )),
        ));
        final frame = find.byKey(const ValueKey('manga-featured-frame'));
        expect(frame, design.id.isManga ? findsOneWidget : findsNothing);
        if (design.id.isManga) {
          final box = tester.widget<Container>(frame);
          final decoration = box.decoration! as BoxDecoration;
          expect((decoration.border! as Border).top.width, greaterThan(0));
          expect(decoration.boxShadow, isNotEmpty);
          expect(decoration.boxShadow!.first.blurRadius, 0);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
