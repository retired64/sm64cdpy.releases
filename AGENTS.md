# AGENTS.md

## Project
Flutter Android app — SM64CoopDX mods browser. Targets **Android only** (API 24+). Portrait-locked.

- Flutter 3.41.6 (stable), Dart ^3.11.0, JDK 17
- App ID: `mods.sm64cdpy`

## Commands
```bash
flutter pub get                    # install deps
flutter analyze                    # lint + typecheck (uses flutter_lints)
flutter build apk --release --target-platform android-arm64   # arm64 APK
flutter build apk --release --split-per-abi                    # split per ABI
flutter clean && flutter pub get   # fix stale artifacts after pull
```

## Architecture
Clean-layer dirs under `lib/`:
- `core/` — constants, go_router routes, theme (Material 3, Google Fonts Lato), extensions
- `data/` — datasources (reads bundled JSON, fetches remote JSON from GitHub), models (manual JSON parsing + `toEntity()`), repository impl
- `domain/` — pure entity classes, repository interfaces
- `presentation/` — Riverpod providers (manually-written Notifiers), screens (one per go_router route), widgets

**No code generation.** Despite `riverpod_annotation` in deps, there are zero `.g.dart` files. All providers are hand-written `Notifier`/`Provider` subclasses.

## Data flow
1. JSON bundled at `assets/db/database_sm64coopdx.json`
2. On app launch: read from disk (if previously downloaded) → fallback to bundled asset → cache in memory
3. User taps "Reload database" → HTTP GET from GitHub raw → write to app dir → invalidate cache

Three additional bundled JSONs exist for special sections: `vip.json`, `dynos.json`, `touch_controls.json`, `omm.json` — each has its own datasource class.

## State management (Riverpod)
- `FavouritesNotifier` persists favorite IDs via Hive box (`'favorites'`), supports JSON export/import
- `ThemeNotifier` persists theme choice via Hive box (`'settings'`)
- `allModsProvider` is a `FutureProvider` — screens that need mods watch `filteredModsProvider` or `paginatedModsProvider` instead
- Pagination uses `AppConstants.pageSize` (6 mods per page)
- Category filtering maps to `CategoryConstants.categoryPatterns` — tag-based pattern matching

## Key constraints
- **JDK 17 only** — JDK 21+ breaks Gradle
- **Release builds need `android/key.properties`** with signing credentials (gitignored)
- **No test suite exists** — the `test/` directory is absent
- App is portrait-only — locked via `SystemChrome.setPreferredOrientations` in `main.dart`
- The `pubspec.lock` is committed — do not delete it
- Entity/model mapping is manual (`ModModel.fromJson()` + `ModModel.toEntity()`), no freezed/json_serializable
- `GoRouter` in `core/router/app_router.dart` defines all routes with a custom fade+scale page transition
