import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/category_constants.dart';
import '../../data/datasource/local_mod_datasource.dart';
import '../../data/repositories/mod_repository_impl.dart';
import '../../domain/entities/mod_entity.dart';
import '../../domain/repositories/mod_repository.dart';

// ── State Providers (Notifier-based replacements for StateProvider) ──────────

class SortOrderNotifier extends Notifier<SortOrder> {
  @override
  SortOrder build() => SortOrder.none;

  void setSortOrder(SortOrder order) {
    state = order;
  }
}

class CurrentPageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int page) {
    state = page;
  }
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setSearchQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setCategory(String? category) {
    state = category;
  }

  void clear() {
    state = null;
  }
}

class SelectedTagNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTag(String? tag) {
    state = tag;
  }

  void clear() {
    state = null;
  }
}

class PopularCurrentPageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setPage(int page) {
    state = page;
  }
}

// ── Infrastructure ────────────────────────────────────────────────────────────

final localDatasourceProvider = Provider<LocalModDatasource>(
  (_) => LocalModDatasource(),
);

final modRepositoryProvider = Provider<ModRepository>((ref) {
  return ModRepositoryImpl(ref.watch(localDatasourceProvider));
});

// ── All mods (cached async) ──────────────────────────────────────────────────

final allModsProvider = FutureProvider<List<ModEntity>>((ref) async {
  return ref.watch(modRepositoryProvider).getAll();
});

// ── Sort options ──────────────────────────────────────────────────────────────

enum SortOrder { none, ratingDesc, downloadsDesc, newest }

final sortOrderProvider = NotifierProvider<SortOrderNotifier, SortOrder>(
  () => SortOrderNotifier(),
);

// ── Filtered + sorted mods for Home ──────────────────────────────────────────

final filteredModsProvider = Provider<AsyncValue<List<ModEntity>>>((ref) {
  final allAsync = ref.watch(allModsProvider);
  final sort = ref.watch(sortOrderProvider);
  final searchQ = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return allAsync.whenData((mods) {
    var result = mods.toList();

    // Filter by category
    if (selectedCategory != null) {
      result = result
          .where((mod) => modBelongsToCategory(mod, selectedCategory))
          .toList();
    }

    // Filter by search
    if (searchQ.isNotEmpty) {
      final q = searchQ.toLowerCase();
      result = result
          .where(
            (m) =>
                m.title.toLowerCase().contains(q) ||
                m.author.toLowerCase().contains(q) ||
                m.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }

    // Sort
    switch (sort) {
      case SortOrder.ratingDesc:
        result.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case SortOrder.downloadsDesc:
        result.sort((a, b) => b.downloads.compareTo(a.downloads));
      case SortOrder.newest:
        result.sort(
          (a, b) => (b.lastUpdate ?? '').compareTo(a.lastUpdate ?? ''),
        );
      case SortOrder.none:
        break;
    }

    return result;
  });
});

// ── Pagination ────────────────────────────────────────────────────────────────

final currentPageProvider = NotifierProvider<CurrentPageNotifier, int>(
  () => CurrentPageNotifier(),
);

final paginatedModsProvider = Provider<AsyncValue<List<ModEntity>>>((ref) {
  final filtered = ref.watch(filteredModsProvider);
  final page = ref.watch(currentPageProvider);
  return filtered.whenData((mods) {
    final start = page * AppConstants.pageSize;
    if (start >= mods.length) return [];
    final end = (start + AppConstants.pageSize).clamp(0, mods.length);
    return mods.sublist(start, end);
  });
});

final totalPagesProvider = Provider<int>((ref) {
  final filtered = ref.watch(filteredModsProvider);
  final pageSize = AppConstants.pageSize;
  return filtered.maybeWhen(
    data: (mods) => (mods.length / pageSize).ceil(),
    orElse: () => 0,
  );
});

// ── Search ────────────────────────────────────────────────────────────────────

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

// ── Category filter ────────────────────────────────────────────────────────────

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      () => SelectedCategoryNotifier(),
    );

/// Helper function to check if a mod belongs to a category
bool modBelongsToCategory(ModEntity mod, String category) {
  for (final tag in mod.tags) {
    final normalizedTag = CategoryConstants.normalizeTag(tag);
    final patterns = CategoryConstants.categoryPatterns[category] ?? [];
    for (final pattern in patterns) {
      if (normalizedTag.contains(pattern) || pattern.contains(normalizedTag)) {
        return true;
      }
    }
  }
  return false;
}

// ── Tags ──────────────────────────────────────────────────────────────────────

final allTagsProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(modRepositoryProvider).getTags();
});

final selectedTagProvider = NotifierProvider<SelectedTagNotifier, String?>(
  () => SelectedTagNotifier(),
);

final modsByTagProvider = Provider.family<AsyncValue<List<ModEntity>>, String>((
  ref,
  tag,
) {
  return ref
      .watch(allModsProvider)
      .whenData((mods) => mods.where((m) => m.tags.contains(tag)).toList());
});

// ── Favourites (Hive) ─────────────────────────────────────────────────────────

class FavouritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    Future.microtask(() => _init());
    return {};
  }

  late final Box<bool> _box;

  Future<void> _init() async {
    _box = await Hive.openBox<bool>(AppConstants.favoritesBoxKey);
    state = _box.keys.cast<String>().toSet();
  }

  Future<void> toggle(String modId) async {
    if (state.contains(modId)) {
      await _box.delete(modId);
      state = {...state}..remove(modId);
    } else {
      await _box.put(modId, true);
      state = {...state, modId};
    }
  }

  bool isFav(String modId) => state.contains(modId);

  // ── Export ────────────────────────────────────────────────────────────────
  /// Serializa los IDs favoritos a JSON y los comparte via share sheet nativo.
  /// Retorna null si todo OK, o un mensaje de error si algo falló.
  Future<String?> exportFavourites() async {
    try {
      if (state.isEmpty) return 'No favourites to export.';

      final payload = jsonEncode({
        'version': 1,
        'exported_at': DateTime.now().toUtc().toIso8601String(),
        'favourites': state.toList()..sort(),
      });

      // Escribe a un archivo temporal para poder compartirlo como adjunto
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/sm64coopdx_favourites.json');
      await file.writeAsString(payload, flush: true);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'SM64CoopDX Favourites',
        ),
      );

      return null; // éxito
    } catch (e) {
      return 'Export failed: $e';
    }
  }

  /// Deja al usuario elegir un JSON exportado previamente y fusiona los IDs
  /// con los favoritos actuales (no borra los existentes).
  /// Retorna un [FavImportResult] con contadores para mostrar en el snackbar.
  Future<FavImportResult> importFavourites(Set<String> knownIds) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return const FavImportResult(cancelled: true);
      }

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        return const FavImportResult(error: 'Could not read file.');
      }

      final raw = String.fromCharCodes(bytes);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      // Validación básica del formato
      if (decoded['version'] != 1 || decoded['favourites'] is! List) {
        return const FavImportResult(error: 'Invalid favourites file format.');
      }

      final ids = (decoded['favourites'] as List).cast<String>();

      int added = 0;
      int skippedUnknown = 0;
      int skippedDuplicate = 0;

      for (final id in ids) {
        if (!knownIds.contains(id)) {
          skippedUnknown++;
          continue;
        }
        if (state.contains(id)) {
          skippedDuplicate++;
          continue;
        }
        await _box.put(id, true);
        state = {...state, id};
        added++;
      }

      return FavImportResult(
        added: added,
        skippedUnknown: skippedUnknown,
        skippedDuplicate: skippedDuplicate,
      );
    } catch (e) {
      return FavImportResult(error: 'Import failed: $e');
    }
  }
}

final favouritesProvider = NotifierProvider<FavouritesNotifier, Set<String>>(
  () => FavouritesNotifier(),
);

final favouriteModsProvider = Provider<AsyncValue<List<ModEntity>>>((ref) {
  final favIds = ref.watch(favouritesProvider);
  return ref
      .watch(allModsProvider)
      .whenData((mods) => mods.where((m) => favIds.contains(m.id)).toList());
});

// ── Import result data class ──────────────────────────────────────────────────

class FavImportResult {
  const FavImportResult({
    this.cancelled = false,
    this.error,
    this.added = 0,
    this.skippedUnknown = 0,
    this.skippedDuplicate = 0,
  });

  final bool cancelled;
  final String? error;
  final int added;
  final int skippedUnknown;
  final int skippedDuplicate;

  bool get isSuccess => !cancelled && error == null;
}

// ── Popular mods ──────────────────────────────────────────────────────────────

final popularModsProvider = Provider<AsyncValue<List<ModEntity>>>((ref) {
  return ref.watch(allModsProvider).whenData((mods) {
    final sorted = [...mods]
      ..sort((a, b) => b.downloads.compareTo(a.downloads));
    return sorted;
  });
});

// ── Popular pagination ──────────────────────────────────────────────────────

final popularCurrentPageProvider =
    NotifierProvider<PopularCurrentPageNotifier, int>(
      () => PopularCurrentPageNotifier(),
    );

final popularPaginatedModsProvider = Provider<AsyncValue<List<ModEntity>>>((
  ref,
) {
  final popular = ref.watch(popularModsProvider);
  final page = ref.watch(popularCurrentPageProvider);
  return popular.whenData((mods) {
    final start = page * AppConstants.pageSize;
    if (start >= mods.length) return [];
    final end = (start + AppConstants.pageSize).clamp(0, mods.length);
    return mods.sublist(start, end);
  });
});

final popularTotalPagesProvider = Provider<int>((ref) {
  final popular = ref.watch(popularModsProvider);
  final pageSize = AppConstants.pageSize;
  return popular.maybeWhen(
    data: (mods) => (mods.length / pageSize).ceil(),
    orElse: () => 0,
  );
});
