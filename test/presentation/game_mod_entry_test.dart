import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/services/game_mod_activation.dart';

void main() {
  test('legacy snapshots remain readable and metadata never replaces game identity', () {
    final old = GameModEntry.fromMap({'name': 'actual.lua', 'title': 'Old title', 'enabled': false, 'selectable': true});
    expect(old.author, isNull);
    final merged = GameModEntry.fromMap({'name': 'actual.lua', 'title': 'Different display title',
      'author': 'Author', 'category': 'romhack', 'versionLabel': '2.4', 'description': 'Description',
      'enabled': true, 'selectable': true});
    expect(merged.name, 'actual.lua');
    expect(merged.title, 'Different display title');
    expect(merged.author, 'Author');
    expect(merged.enabled, isTrue);
  });
}
