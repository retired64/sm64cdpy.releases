import '../entities/mod_entity.dart';

/// Contract that any datasource must fulfil.
abstract interface class ModRepository {
  /// Load all mods (from local JSON or future API).
  Future<List<ModEntity>> getAll();

  /// Search across title, author and tags.
  Future<List<ModEntity>> search(String query);

  /// All unique tags from the catalogue.
  Future<List<String>> getTags();
}
