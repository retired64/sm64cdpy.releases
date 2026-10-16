import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/domain/entities/player_profile.dart';

void main() {
  test(
    'copyWith changes the selected game model without losing the profile',
    () {
      const original = PlayerProfile(
        name: 'Mario',
        model: 0,
        palette: PlayerPalette.mario,
      );

      final changed = original.copyWith(model: 3);

      expect(changed.name, original.name);
      expect(changed.palette, original.palette);
      expect(changed.model, 3);
      expect(changed, isNot(original));
    },
  );
}
