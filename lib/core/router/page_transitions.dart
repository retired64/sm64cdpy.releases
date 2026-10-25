import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation profiles share the same motion language while reserving a little
/// more emphasis for destinations that represent a meaningful context change.
enum AppPageTransitionStyle { standard, modDetail, play }

const appPageTransitionDuration = Duration(milliseconds: 250);
const appPageReverseTransitionDuration = Duration(milliseconds: 180);
const modDetailTransitionDuration = Duration(milliseconds: 270);
const playTransitionDuration = Duration(milliseconds: 320);

typedef _TransitionSpec = ({
  Duration duration,
  Duration reverseDuration,
  Offset beginOffset,
  double beginScale,
});

_TransitionSpec _specFor(AppPageTransitionStyle style) => switch (style) {
  AppPageTransitionStyle.standard => (
    duration: appPageTransitionDuration,
    reverseDuration: appPageReverseTransitionDuration,
    beginOffset: const Offset(0, 0.075),
    beginScale: 0.985,
  ),
  AppPageTransitionStyle.modDetail => (
    duration: modDetailTransitionDuration,
    reverseDuration: const Duration(milliseconds: 190),
    beginOffset: const Offset(0, 0.025),
    beginScale: 0.97,
  ),
  AppPageTransitionStyle.play => (
    duration: playTransitionDuration,
    reverseDuration: const Duration(milliseconds: 220),
    beginOffset: const Offset(0, 0.11),
    beginScale: 0.96,
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
        buildLightweightPageTransition(
          context,
          animation,
          secondaryAnimation,
          child,
          style: style,
        ),
  );
}

Widget buildLightweightPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
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
  final scale = Tween<double>(begin: spec.beginScale, end: 1).animate(motion);
  final outgoingScale = Tween<double>(begin: 1, end: 0.992).animate(
    CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOutCubic),
  );
  final outgoingOpacity = Tween<double>(
    begin: 1,
    end: 0.94,
  ).animate(CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut));

  return FadeTransition(
    key: const ValueKey('app-page-fade'),
    opacity: opacity,
    child: SlideTransition(
      key: const ValueKey('app-page-slide'),
      position: position,
      transformHitTests: false,
      child: ScaleTransition(
        key: const ValueKey('app-page-scale'),
        scale: scale,
        child: FadeTransition(
          opacity: outgoingOpacity,
          child: ScaleTransition(
            scale: outgoingScale,
            child: RepaintBoundary(child: child),
          ),
        ),
      ),
    ),
  );
}
