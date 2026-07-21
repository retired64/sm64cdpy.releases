# TO-DO-DRAWER.md

## Objetivo
Consolidar el drawer (menú lateral) en un `Scaffold` único y persistente usando `ShellRoute` de GoRouter, eliminando código duplicado en 11 pantallas y mejorando el rendimiento en dispositivos de gama baja.

---

## Fase 0 — Infraestructura base

- [x] **T0.1** — Crear `currentRouteProvider` en `lib/presentation/providers/extra_providers.dart`
- [x] **T0.2** — Modificar `AppDrawer` en `lib/presentation/widgets/app_drawer.dart` para leer `currentRoute` del provider (eliminar parámetro del constructor)
- [x] **T0.3** — Crear `lib/presentation/widgets/app_shell.dart` (`AppShell` + `DrawerMenuButton`)

---

## Fase 1 — GoRouter + ShellRoute

- [x] **T1.1** — Modificar `lib/core/router/app_router.dart` — ShellRoute wrapper

---

## Fase 2 — Pantallas con CustomScrollView + SliverAppBar

- [x] **T2.1** — Refactor `home_screen.dart`
- [x] **T2.2** — Refactor `catalogue_screen.dart`
- [x] **T2.3** — Refactor `popular_screen.dart`
- [x] **T2.4** — Refactor `settings_screen.dart`
- [x] **T2.5** — Refactor `links_resource_screen.dart`
- [x] **T2.6** — Refactor `vip_mods_screen.dart`
- [x] **T2.7** — Refactor `dynos_screen.dart`
- [x] **T2.8** — Refactor `touch_controls_screen.dart`
- [x] **T2.9** — Refactor `omm_rebirth_screen.dart`

---

## Fase 3 — Pantallas con AppBar nativo (requieren conversión)

- [x] **T3.1** — Refactor `changelog_screen.dart` (AppBar → SliverAppBar + SliverList)
- [x] **T3.2** — Refactor `disclaimer_screen.dart` (AppBar → custom header bar en Stack)
- [x] **T3.3** — Refactor `favourites_screen.dart` (TabBar → SliverAppBar + SliverFillRemaining + TabBarView, tabs con shrinkWrap: true)

---

## Fase 4 — Verificación

- [x] **T4.1** — `flutter analyze` — 0 errores en `lib/`
- [x] **T4.2** — 3 rutas sin halftone: `/`, `/favourites`, `/changelog`, `/disclaimer`
- [x] **T4.3** — `/mod/:id` (ModDetailScreen) fuera del ShellRoute — sin drawer
- [x] **T4.4** — `RefreshIndicator` en CatalogueScreen preservado
- [x] **T4.5** — `FavouritesScreen` — tabs con SliverFillRemaining + TabBarView

---

## Resumen de código eliminado

| Patrón duplicado | Antes | Después |
|---|---|---|
| `Scaffold(backgroundColor: ..., drawer: AppDrawer(...))` | 11 pantallas | 0 (manejado por AppShell) |
| `Builder + IconButton + Scaffold.of(ctx).openDrawer()` | 9 pantallas | 0 (DrawerMenuButton reusable) |
| `Stack + Positioned.fill + HalftoneBackground(...)` | 8 pantallas | 0 (manejado por AppShell) |
| `currentRoute` hardcodeado en cada pantalla | 11 strings | 0 (provider global) |

