import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/presentation/widgets/player_3d_preview.dart';

void main() {
  group('resolvePlayer3DDragIntent', () {
    test('keeps small movements pending', () {
      expect(
        resolvePlayer3DDragIntent(const Offset(4, 4)),
        Player3DDragIntent.pending,
      );
    });

    test('rotates for horizontal and moderately diagonal drags', () {
      expect(
        resolvePlayer3DDragIntent(const Offset(12, 0)),
        Player3DDragIntent.rotate,
      );
      expect(
        resolvePlayer3DDragIntent(const Offset(9, 11)),
        Player3DDragIntent.rotate,
      );
    });

    test('leaves clearly vertical drags to the page', () {
      expect(
        resolvePlayer3DDragIntent(const Offset(2, 14)),
        Player3DDragIntent.scroll,
      );
    });
  });
}
