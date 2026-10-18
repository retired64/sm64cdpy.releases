import '../../presentation/screens/game_save_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/catalogue_screen.dart';
import '../../presentation/screens/disclaimer_screen.dart';
import '../../presentation/screens/dynos_screen.dart';
import '../../presentation/screens/favourites_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/links_resource_screen.dart';
import '../../presentation/screens/library_screen.dart';
import '../../presentation/screens/mod_detail_screen.dart';
import '../../presentation/screens/popular_screen.dart';
import '../../presentation/screens/player_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/touch_controls_screen.dart';
import '../../presentation/screens/vip_mods_screen.dart';
import '../../presentation/screens/omm_rebirth_screen.dart';
import '../../presentation/screens/render96_screen.dart';
import '../../presentation/widgets/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) =>
          AppShell(currentRoute: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/', pageBuilder: (_, s) => _page(const HomeScreen(), s)),
        GoRoute(
          path: '/catalogue',
          pageBuilder: (_, s) => _page(const CatalogueScreen(), s),
        ),
        GoRoute(
          path: '/favourites',
          pageBuilder: (_, s) => _page(const FavouritesScreen(), s),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (_, s) => _page(const LibraryScreen(), s),
        ),
        GoRoute(
          path: '/game-tool/save-file',
          pageBuilder: (_, s) => _page(const GameSaveScreen(), s),
        ),
        GoRoute(
          path: '/player',
          pageBuilder: (_, s) => _page(const PlayerScreen(), s),
        ),
        GoRoute(
          path: '/popular',
          pageBuilder: (_, s) => _page(const PopularScreen(), s),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, s) => _page(const SettingsScreen(), s),
        ),
        GoRoute(
          path: '/links-resource',
          pageBuilder: (_, s) => _page(const LinksResourceScreen(), s),
        ),
        GoRoute(
          path: '/disclaimer',
          pageBuilder: (_, s) => _page(const DisclaimerScreen(), s),
        ),
        GoRoute(
          path: '/vip',
          pageBuilder: (_, s) => _page(const VipModsScreen(), s),
        ),
        GoRoute(
          path: '/dynos',
          pageBuilder: (_, s) => _page(const DynosScreen(), s),
        ),
        GoRoute(
          path: '/touch-controls',
          pageBuilder: (_, s) => _page(const TouchControlsScreen(), s),
        ),
        GoRoute(
          path: '/omm-rebirth',
          pageBuilder: (_, s) => _page(const OmmRebirthScreen(), s),
        ),
        GoRoute(
          path: '/render96',
          pageBuilder: (_, s) => _page(const Render96Screen(), s),
        ),
      ],
    ),
    GoRoute(
      path: '/mod/:id',
      pageBuilder: (_, s) {
        final id = Uri.decodeComponent(s.pathParameters['id']!);
        return _page(ModDetailScreen(modId: id), s);
      },
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Root and detail routes render immediately; motion stays inside interactions
// where it communicates state instead of delaying navigation.
// ─────────────────────────────────────────────────────────────────────────────
NoTransitionPage<void> _page(Widget child, GoRouterState state) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
