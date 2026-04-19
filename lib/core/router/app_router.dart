import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/catalogue_screen.dart';
import '../../presentation/screens/changelog_screen.dart';
import '../../presentation/screens/favourites_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/mod_detail_screen.dart';
import '../../presentation/screens/popular_screen.dart';
import '../../presentation/screens/disclaimer_screen.dart';
import '../../presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
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
      path: '/disclaimer',
      pageBuilder: (_, s) => _page(const DisclaimerScreen(), s),
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
//
// Por qué esto elimina el "saltito":
//  · No hay ningún Offset / slide: la nueva pantalla no se mueve, sólo
//    aparece. El cerebro no percibe un "salto" porque no hay desplazamiento
//    espacial.
//  · El micro-scale (0.97 → 1.0) da la sensación de que la pantalla
//    "emerge" suavemente, como voltear una hoja hacia el frente.
//  · 300 ms con easeOutCubic es suficientemente corto para sentirse rápido
//    en gama alta, y suficientemente largo para que gama baja no vea un
//    corte abrupto.
//  · secondaryAnimation con fade-out (1.0 → 0.0) sobre la pantalla saliente
//    hace la salida igual de suave.
// ─────────────────────────────────────────────────────────────────────────────
CustomTransitionPage<void> _page(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Entrada: fade + scale 0.97 → 1.0
      final enterFade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final enterScale = Tween<double>(
        begin: 0.97,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      // Salida de la pantalla anterior: fade-out suave
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
