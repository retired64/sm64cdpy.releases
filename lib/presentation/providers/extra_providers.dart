import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/vip_mod_datasource.dart';
import '../../data/datasource/dynos_datasource.dart';
import '../../data/datasource/touch_control_datasource.dart';
import '../../domain/entities/vip_mod_entity.dart';
import '../../domain/entities/dynos_entity.dart';
import '../../domain/entities/touch_control_entity.dart';
import 'mod_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datasource providers
// ─────────────────────────────────────────────────────────────────────────────

final vipDatasourceProvider = Provider<VipModDatasource>(
  (_) => VipModDatasource(),
);

final dynosDatasourceProvider = Provider<DynosDatasource>(
  (_) => DynosDatasource(),
);

final touchControlDatasourceProvider = Provider<TouchControlDatasource>(
  (_) => TouchControlDatasource(),
);

// ─────────────────────────────────────────────────────────────────────────────
// All items providers (cached async)
// ─────────────────────────────────────────────────────────────────────────────

final allVipModsProvider = FutureProvider<List<VipModEntity>>((ref) async {
  final datasource = ref.watch(vipDatasourceProvider);
  final models = await datasource.getAll();
  return models.map((model) => model.toEntity()).toList();
});

final allDynosProvider = FutureProvider<List<DynosEntity>>((ref) async {
  final datasource = ref.watch(dynosDatasourceProvider);
  final models = await datasource.getAll();
  return models.map((model) => model.toEntity()).toList();
});

final allTouchControlsProvider = FutureProvider<List<TouchControlEntity>>((
  ref,
) async {
  final datasource = ref.watch(touchControlDatasourceProvider);
  final models = await datasource.getAll();
  return models.map((model) => model.toEntity()).toList();
});

// ─────────────────────────────────────────────────────────────────────────────
// Favourites filtering (using existing favouritesProvider)
// ─────────────────────────────────────────────────────────────────────────────

/// Prefijos para IDs de favoritos (para evitar colisiones)
const _kVipPrefix = 'vip_';
const _kDynosPrefix = 'dynos_';
const _kTouchPrefix = 'tc_';

/// Filtra los favoritos del box global por prefijo y devuelve los IDs sin prefijo.
Set<String> _filterFavIdsByPrefix(Set<String> allFavIds, String prefix) {
  return allFavIds
      .where((id) => id.startsWith(prefix))
      .map((id) => id.substring(prefix.length))
      .toSet();
}

/// Provider que expone los IDs de VIP mods marcados como favoritos.
final vipFavouritesProvider = Provider<Set<String>>((ref) {
  final allFavs = ref.watch(favouritesProvider);
  return _filterFavIdsByPrefix(allFavs, _kVipPrefix);
});

/// Provider que expone los IDs de DynOS marcados como favoritos.
final dynosFavouritesProvider = Provider<Set<String>>((ref) {
  final allFavs = ref.watch(favouritesProvider);
  return _filterFavIdsByPrefix(allFavs, _kDynosPrefix);
});

/// Provider que expone los IDs de Touch Controls marcados como favoritos.
final touchFavouritesProvider = Provider<Set<String>>((ref) {
  final allFavs = ref.watch(favouritesProvider);
  return _filterFavIdsByPrefix(allFavs, _kTouchPrefix);
});

// ─────────────────────────────────────────────────────────────────────────────
// Favourite items providers (filtered lists)
// ─────────────────────────────────────────────────────────────────────────────

final favouriteVipModsProvider = Provider<AsyncValue<List<VipModEntity>>>((
  ref,
) {
  final favIds = ref.watch(vipFavouritesProvider);
  return ref
      .watch(allVipModsProvider)
      .whenData((mods) => mods.where((m) => favIds.contains(m.id)).toList());
});

final favouriteDynosProvider = Provider<AsyncValue<List<DynosEntity>>>((ref) {
  final favIds = ref.watch(dynosFavouritesProvider);
  return ref
      .watch(allDynosProvider)
      .whenData((mods) => mods.where((m) => favIds.contains(m.id)).toList());
});

final favouriteTouchControlsProvider =
    Provider<AsyncValue<List<TouchControlEntity>>>((ref) {
      final favIds = ref.watch(touchFavouritesProvider);
      return ref
          .watch(allTouchControlsProvider)
          .whenData(
            (mods) => mods.where((m) => favIds.contains(m.id)).toList(),
          );
    });

// ─────────────────────────────────────────────────────────────────────────────
// Helper functions for toggling favourites with prefixes
// ─────────────────────────────────────────────────────────────────────────────

/// Agrega/quita un VIP mod de favoritos (añade prefijo al ID almacenado).
Future<void> toggleVipFavourite(WidgetRef ref, String vipModId) async {
  final notifier = ref.read(favouritesProvider.notifier);
  await notifier.toggle('$_kVipPrefix$vipModId');
}

/// Agrega/quita un DynOS de favoritos (añade prefijo al ID almacenado).
Future<void> toggleDynosFavourite(WidgetRef ref, String dynosId) async {
  final notifier = ref.read(favouritesProvider.notifier);
  await notifier.toggle('$_kDynosPrefix$dynosId');
}

/// Agrega/quita un Touch Control de favoritos (añade prefijo al ID almacenado).
Future<void> toggleTouchFavourite(WidgetRef ref, String touchId) async {
  final notifier = ref.read(favouritesProvider.notifier);
  await notifier.toggle('$_kTouchPrefix$touchId');
}

/// Verifica si un VIP mod está en favoritos.
bool isVipFavourite(WidgetRef ref, String vipModId) {
  final notifier = ref.read(favouritesProvider.notifier);
  return notifier.isFav('$_kVipPrefix$vipModId');
}

/// Verifica si un DynOS está en favoritos.
bool isDynosFavourite(WidgetRef ref, String dynosId) {
  final notifier = ref.read(favouritesProvider.notifier);
  return notifier.isFav('$_kDynosPrefix$dynosId');
}

/// Verifica si un Touch Control está en favoritos.
bool isTouchFavourite(WidgetRef ref, String touchId) {
  final notifier = ref.read(favouritesProvider.notifier);
  return notifier.isFav('$_kTouchPrefix$touchId');
}
