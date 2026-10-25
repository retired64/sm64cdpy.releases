import 'package:flutter_test/flutter_test.dart';
import 'package:sm64cdpy/core/utils/mod_description_translation.dart';

const _translations = <String, String>{
  'es': 'Descripción en español',
  'pt_BR': 'Descrição em português',
  'fr': 'Description française',
  'it': 'Descrizione italiana',
};

String? _resolve(String localeTag, {Map<String, String>? translations}) =>
    resolveDescriptionTranslation(
      description: 'Original English',
      translations: translations ?? _translations,
      localeTag: localeTag,
    );

void main() {
  test('maps Spanish variants to es', () {
    for (final tag in ['es', 'es_419', 'es-ES', 'es-MX', 'es_AR']) {
      expect(_resolve(tag), 'Descripción en español', reason: tag);
    }
  });

  test('maps Portuguese variants to pt_BR', () {
    for (final tag in ['pt', 'pt_BR', 'pt-PT', 'pt-BR']) {
      expect(_resolve(tag), 'Descrição em português', reason: tag);
    }
  });

  test('maps French and Italian regional variants', () {
    for (final tag in ['fr', 'fr_CA', 'fr-FR']) {
      expect(_resolve(tag), 'Description française', reason: tag);
    }
    for (final tag in ['it', 'it_CH', 'it_IT']) {
      expect(_resolve(tag), 'Descrizione italiana', reason: tag);
    }
  });

  test('English and unknown locales always use the original', () {
    for (final tag in ['en', 'en_US', 'en-GB', 'de', 'ja', '']) {
      expect(_resolve(tag), isNull, reason: tag);
    }
  });

  test('missing, empty or identical translations fall back to English', () {
    expect(_resolve('es', translations: const {}), isNull);
    expect(_resolve('es', translations: const {'es': ''}), isNull);
    expect(_resolve('es', translations: const {'es': '   '}), isNull);
    expect(
      _resolve('es', translations: const {'es': 'Original English'}),
      isNull,
    );
    expect(
      _resolve('es', translations: const {'es': '  Original English  '}),
      isNull,
    );
  });

  test('returns the translation text unchanged when it is valid', () {
    expect(
      _resolve('es', translations: const {'es': ' Español '}),
      ' Español ',
    );
  });
}
