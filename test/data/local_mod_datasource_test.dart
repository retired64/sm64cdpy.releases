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
  test('accepts the translated semantic catalogue contract', () {
    final mod = _mod('1', translations: <String, dynamic>{'es': 'Descripción'});
    mod['description_source_hash'] =
        'sha256:${List<String>.filled(64, 'a').join()}';
    mod['versions'] = <Map<String, dynamic>>[
      <String, dynamic>{
        'version_id': 'source:1',
        'resolved': true,
        'files': <Map<String, dynamic>>[
          <String, dynamic>{
            'file_id': 'github:v1:main.zip',
            'filename': 'main.zip',
            'download_url': 'https://example.test/main.zip',
            'display_name': 'Main package',
            'role': 'primary',
            'recommended': true,
            'requires_primary': false,
            'version_consistency': 'match',
          },
        ],
      },
    ];
    expect(
      () => validateModDatabaseForTesting(<String, dynamic>{
        'schema_version': 2,
        'catalog_status': 'complete',
        'catalog_id': 'sha256:${List<String>.filled(64, 'b').join()}',
        'translation_metadata': <String, dynamic>{
          'source_language': 'en',
          'target_locales': <String>['es'],
        },
        'mods': <Map<String, dynamic>>[mod],
      }),
      returnsNormally,
    );
  });

  test('rejects cross-version artifacts and ambiguous recommendations', () {
    Map<String, dynamic> catalogFor(List<Map<String, dynamic>> files) =>
        <String, dynamic>{
          'schema_version': 2,
          'catalog_status': 'complete',
          'catalog_id': 'sha256:${List<String>.filled(64, 'c').join()}',
          'mods': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': '1',
              'name': 'Unsafe',
              'versions': <Map<String, dynamic>>[
                <String, dynamic>{
                  'version_id': 'source:1',
                  'resolved': true,
                  'files': files,
                },
              ],
            },
          ],
        };
    Map<String, dynamic> file(String id, {bool recommended = true}) =>
        <String, dynamic>{
          'file_id': id,
          'filename': '$id.zip',
          'download_url': 'https://example.test/$id.zip',
          'display_name': id,
          'role': recommended ? 'primary' : 'optional',
          'recommended': recommended,
          'requires_primary': !recommended,
          'version_consistency': 'match',
        };

    final mismatch = file('wrong')..['version_consistency'] = 'mismatch';
    expect(
      () => validateModDatabaseForTesting(catalogFor([mismatch])),
      throwsFormatException,
    );
    expect(
      () =>
          validateModDatabaseForTesting(catalogFor([file('one'), file('two')])),
      throwsFormatException,
    );
  });

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
