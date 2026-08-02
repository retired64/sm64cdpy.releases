import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/catalogue_screen.dart';
import '../../presentation/screens/changelog_screen.dart';
import '../../presentation/screens/disclaimer_screen.dart';
import '../../presentation/screens/dynos_screen.dart';
import '../../presentation/screens/favourites_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/links_resource_screen.dart';
import '../../presentation/screens/mod_detail_screen.dart';
import '../../presentation/screens/popular_screen.dart';
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
      builder: (context, state, child) => AppShell(
        currentRoute: state.uri.path,
        child: child,
      ),
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
          path: '/popular',
          pageBuilder: (_, s) => _page(const PopularScreen(), s),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, s) => _page(const SettingsScreen(), s),
        ),
        GoRoute(
          path: '/changelog',
          pageBuilder: (_, s) => _page(const ChangelogScreen(), s),
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
// Transición "página que aparece" — fade + micro-scale desde 0.97 → 1.0
// ─────────────────────────────────────────────────────────────────────────────
CustomTransitionPage<void> _page(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enterFade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final enterScale = Tween<double>(
        begin: 0.97,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      final exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        ),
      );

      return FadeTransition(
        opacity: exitFade,
        child: FadeTransition(
          opacity: enterFade,
          child: ScaleTransition(scale: enterScale, child: child),
        ),
      );
    },
  );
}
