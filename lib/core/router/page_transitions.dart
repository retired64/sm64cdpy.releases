import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Short enough to keep navigation responsive on low-end devices while still
/// making a route change perceptible.
const appPageTransitionDuration = Duration(milliseconds: 190);
const appPageReverseTransitionDuration = Duration(milliseconds: 150);

CustomTransitionPage<void> buildAppTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: appPageTransitionDuration,
    reverseTransitionDuration: appPageReverseTransitionDuration,
    child: child,
    transitionsBuilder: buildLightweightPageTransition,
  );
}

Widget buildLightweightPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;

  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final position = Tween<Offset>(
    begin: const Offset(0.018, 0),
    end: Offset.zero,
  ).animate(curvedAnimation);

  return FadeTransition(
    key: const ValueKey('app-page-fade'),
    opacity: curvedAnimation,
    child: SlideTransition(
      key: const ValueKey('app-page-slide'),
      position: position,
      transformHitTests: false,
      child: RepaintBoundary(child: child),
    ),
  );
}
