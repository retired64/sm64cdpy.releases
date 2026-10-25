/// Pure locale resolution for precomputed mod-description translations.
///
/// No Flutter, Riverpod, storage, network or asynchronous work is involved.
String? descriptionTranslationKey(String localeTag) {
  final normalized = localeTag.trim().replaceAll('-', '_').toLowerCase();
  if (normalized.isEmpty) return null;
  switch (normalized.split('_').first) {
    case 'es':
      return 'es';
    case 'pt':
      return 'pt_BR';
    case 'fr':
      return 'fr';
    case 'it':
      return 'it';
    default:
      return null;
  }
}

/// Returns the translated description when it is valid and differs from the
/// English original; otherwise returns null so callers show [description].
String? resolveDescriptionTranslation({
  required String description,
  required Map<String, String> translations,
  required String localeTag,
}) {
  final key = descriptionTranslationKey(localeTag);
  if (key == null) return null;
  final translation = translations[key];
  if (translation == null) return null;
  final normalizedTranslation = translation.trim();
  if (normalizedTranslation.isEmpty) return null;
  if (normalizedTranslation == description.trim()) return null;
  return translation;
}
