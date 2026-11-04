import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/presentation/widgets/player_3d_preview.dart';

void main() {
  testWidgets('slow contraction preserves surface size and uniform scaling', (
    tester,
  ) async {
    final surfaceKey = GlobalKey();
    const source = Size(361, 264);
    for (var step = 0; step <= 100; step++) {
      final progress = step / 100;
      final width = 361 - 201 * progress;
      final height = 264 - 148 * progress;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: Player3DSurface(
                size: source,
                child: ColoredBox(key: surfaceKey, color: Colors.red),
              ),
            ),
          ),
        ),
      );
      final box = surfaceKey.currentContext!.findRenderObject()! as RenderBox;
      expect(box.size, source);
      final transform = box.getTransformTo(null);
      expect(transform.storage[0], closeTo(transform.storage[5], 0.000001));
      expect(transform.storage[0], greaterThan(0));
      expect(transform.storage[0], lessThanOrEqualTo(1));
      expect(box.size.width * transform.storage[0], lessThanOrEqualTo(width + 0.001));
      expect(box.size.height * transform.storage[5], lessThanOrEqualTo(height + 0.001));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('window resize updates the intrinsic surface dimensions', (
    tester,
  ) async {
    final surfaceKey = GlobalKey();
    for (final size in [const Size(361, 264), const Size(680, 264)]) {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 140,
            child: Player3DSurface(
              size: size,
              child: ColoredBox(key: surfaceKey, color: Colors.red),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(surfaceKey)), size);
    }
  });
}
