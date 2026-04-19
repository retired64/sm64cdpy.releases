import '../../domain/entities/mod_entity.dart';
import '../../domain/repositories/mod_repository.dart';
import '../datasource/local_mod_datasource.dart';

class ModRepositoryImpl implements ModRepository {
  ModRepositoryImpl(this._datasource);

  final LocalModDatasource _datasource;

  @override
  Future<List<ModEntity>> getAll() async {
    final models = await _datasource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ModEntity>> search(String query) async {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return getAll();

    final all = await getAll();
    return all.where((m) {
      return m.title.toLowerCase().contains(q) ||
          m.author.toLowerCase().contains(q) ||
          m.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Future<List<String>> getTags() async {
    final all = await getAll();
    final tags = <String>{};
    for (final mod in all) {
      tags.addAll(mod.tags);
    }
    return tags.toList()..sort();
  }
}
