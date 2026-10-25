import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds when the enclosing route has finished its push transition.
///
/// Initial routes are considered settled immediately.
class RouteSettledBuilder extends StatefulWidget {
  const RouteSettledBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, bool settled) builder;

  @override
  State<RouteSettledBuilder> createState() => _RouteSettledBuilderState();
}

class _RouteSettledBuilderState extends State<RouteSettledBuilder> {
  Animation<double>? _animation;
  bool _settled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (identical(animation, _animation)) return;
    _animation?.removeStatusListener(_onStatusChanged);
    _animation = animation;
    _animation?.addStatusListener(_onStatusChanged);
    _settled = animation == null || animation.isCompleted;
  }

  void _onStatusChanged(AnimationStatus status) {
    final settled =
        status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed;
    if (settled == _settled || !mounted) return;
    setState(() => _settled = settled);
  }

  @override
  void dispose() {
    _animation?.removeStatusListener(_onStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _settled);
}

/// Waits for the current route's entrance animation before running work that
/// rebuilds the destination while frames are still being animated.
Future<void> waitForRouteSettled(BuildContext context) {
  final animation = ModalRoute.of(context)?.animation;
  if (animation == null || animation.isCompleted) return Future<void>.value();
  final completer = Completer<void>();
  void listener(AnimationStatus status) {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) {
      return;
    }
    animation.removeStatusListener(listener);
    if (!completer.isCompleted) completer.complete();
  }

  animation.addStatusListener(listener);
  return completer.future;
}
