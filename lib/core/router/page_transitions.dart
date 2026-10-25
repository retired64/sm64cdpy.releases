import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation profiles share the same motion language while reserving a little
/// more emphasis for destinations that represent a meaningful context change.
enum AppPageTransitionStyle { standard, modDetail, play }

const appPageTransitionDuration = Duration(milliseconds: 180);
const appPageReverseTransitionDuration = Duration(milliseconds: 150);
const modDetailTransitionDuration = Duration(milliseconds: 190);
const playTransitionDuration = Duration(milliseconds: 200);

typedef _TransitionSpec = ({
  Duration duration,
  Duration reverseDuration,
  Offset beginOffset,
});

_TransitionSpec _specFor(AppPageTransitionStyle style) => switch (style) {
  AppPageTransitionStyle.standard => (
    duration: appPageTransitionDuration,
    reverseDuration: appPageReverseTransitionDuration,
    beginOffset: const Offset(0, 0.035),
  ),
  AppPageTransitionStyle.modDetail => (
    duration: modDetailTransitionDuration,
    reverseDuration: const Duration(milliseconds: 150),
    beginOffset: const Offset(0, 0.02),
  ),
  AppPageTransitionStyle.play => (
    duration: playTransitionDuration,
    reverseDuration: const Duration(milliseconds: 160),
    beginOffset: const Offset(0, 0.05),
  ),
};

CustomTransitionPage<void> buildAppTransitionPage({
  required LocalKey key,
  required Widget child,
  AppPageTransitionStyle style = AppPageTransitionStyle.standard,
}) {
  final spec = _specFor(style);
  return CustomTransitionPage<void>(
    key: key,
    transitionDuration: spec.duration,
    reverseTransitionDuration: spec.reverseDuration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        buildLightweightPageTransition(context, animation, child, style: style),
  );
}

Widget buildLightweightPageTransition(
  BuildContext context,
  Animation<double> animation,
  Widget child, {
  AppPageTransitionStyle style = AppPageTransitionStyle.standard,
}) {
  if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return child;

  final spec = _specFor(style);
  final motion = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  final opacity = CurvedAnimation(
    parent: animation,
    curve: const Interval(0, 0.7, curve: Curves.easeOut),
    reverseCurve: Curves.easeIn,
  );
  final position = Tween<Offset>(
    begin: spec.beginOffset,
    end: Offset.zero,
  ).animate(motion);

  return FadeTransition(
    key: const ValueKey('app-page-fade'),
    opacity: opacity,
    child: SlideTransition(
      key: const ValueKey('app-page-slide'),
      position: position,
      transformHitTests: false,
      child: RepaintBoundary(child: child),
    ),
  );
}
