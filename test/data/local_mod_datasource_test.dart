import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/data/datasource/local_mod_datasource.dart';

Map<String, dynamic> _catalog(List<Map<String, dynamic>> mods) =>
    <String, dynamic>{'schema_version': 1, 'mods': mods};

Map<String, dynamic> _mod(String id, {dynamic translations}) {
  final mod = <String, dynamic>{
    'id': id,
    'name': 'Mod $id',
    'description': 'English description',
    'versions': <Map<String, dynamic>>[],
  };
  if (translations != null) {
    mod['description_translations'] = translations;
  }
  return mod;
}

void main() {
  test('accepts catalogues without description translations', () {
    expect(
      () => validateModDatabaseForTesting(_catalog([_mod('1')])),
      returnsNormally,
    );
  });

  test('accepts catalogues with partial or complete translations', () {
    expect(
      () => validateModDatabaseForTesting(
        _catalog([
          _mod(
            '1',
            translations: <String, dynamic>{
              'es': 'Descripción',
              'pt_BR': 'Descrição',
              'fr': 'Description',
              'it': 'Descrizione',
            },
          ),
          _mod('2'),
          _mod('3', translations: <String, dynamic>{'es': 'Solo español'}),
        ]),
      ),
      returnsNormally,
    );
  });

  test('rejects a non-object description_translations value', () {
    for (final invalid in <dynamic>[
      <String>['es'],
      'es',
      42,
      true,
    ]) {
      expect(
        () => validateModDatabaseForTesting(
          _catalog([_mod('1', translations: invalid)]),
        ),
        throwsA(isA<FormatException>()),
        reason: 'Expected $invalid to be rejected',
      );
    }
  });
}
