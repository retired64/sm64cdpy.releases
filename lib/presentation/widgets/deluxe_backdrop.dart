import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../providers/deluxe_visual_provider.dart';

/// Dos mosaicos pequeños aislados del contenido. Ningún ticker activo por defecto.
class DeluxeBackdrop extends ConsumerStatefulWidget {
  const DeluxeBackdrop({super.key});
  @override
  ConsumerState<DeluxeBackdrop> createState() => _DeluxeBackdropState();
}

class _DeluxeBackdropState extends ConsumerState<DeluxeBackdrop>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion;
  bool _foreground = true;
  @override
  void initState() {
    super.initState();
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _motion = AnimationController(vsync: this, duration: const Duration(seconds: 60));
    WidgetsBinding.instance.addObserver(this);
  }
  void _update() {
    final allowed = _foreground && ref.read(deluxeMotionProvider) &&
        TickerMode.of(context) && !MediaQuery.disableAnimationsOf(context) &&
        !MediaQuery.accessibleNavigationOf(context);
    if (allowed && !_motion.isAnimating) _motion.repeat();
    if (!allowed && _motion.isAnimating) _motion.stop();
  }
  @override
  void didChangeDependencies() { super.didChangeDependencies(); _update(); }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _update();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    ref.listen(deluxeMotionProvider, (_, _) => _update());
    return IgnorePointer(
      child: RepaintBoundary(
        key: const ValueKey('manga-deluxe-backdrop'),
        child: LayoutBuilder(builder: (context, size) {
          Widget layer(String asset, double tile, double opacity, double t, {Color? tint}) => Positioned(
            left: -tile * t, top: -tile * t,
            width: size.maxWidth + ((_motion.isAnimating || t != 0) ? tile : 0),
            height: size.maxHeight + ((_motion.isAnimating || t != 0) ? tile : 0),
            child: RepaintBoundary(child: DecoratedBox(decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/themes/manga_deluxe/$asset.webp'),
                repeat: ImageRepeat.repeat,
                alignment: Alignment.topLeft,
                opacity: opacity,
                colorFilter: tint == null ? null : ColorFilter.mode(tint, BlendMode.srcIn),
                filterQuality: FilterQuality.low,
              ),
            ))),
          );
          return AnimatedBuilder(animation: _motion, builder: (context, _) => Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(child: ColoredBox(color: retro.background)),
              layer('pattern', 330, retro.isDark ? 0.07 : 0.09, _motion.value, tint: retro.accent),
              layer('hats', 256, retro.isDark ? 0.08 : 0.09, _motion.value),
            ],
          ));
        }),
      ),
    );
  }
}

/// Las páginas fuera de AppShell (detalle) comparten el mismo lienzo Deluxe.
class DeluxeScene extends StatelessWidget {
  const DeluxeScene({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (!RetroTheme.of(context).isDeluxe) return child;
    return Stack(fit: StackFit.expand, children: [
      const Positioned.fill(child: DeluxeBackdrop()),
      child,
    ]);
  }
}
