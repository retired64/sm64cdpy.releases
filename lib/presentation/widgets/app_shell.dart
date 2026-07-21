import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../providers/extra_providers.dart';
import 'app_drawer.dart';

const _noHalftoneRoutes = {'/', '/favourites', '/changelog', '/disclaimer'};

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.currentRoute, required this.child});

  final String currentRoute;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      ref.read(currentRouteProvider.notifier).set(widget.currentRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final showHalftone = !_noHalftoneRoutes.contains(widget.currentRoute);

    return Scaffold(
      backgroundColor: retro.background,
      drawer: const AppDrawer(),
      body: showHalftone
          ? Stack(
              children: [
                Positioned.fill(
                  child: HalftoneBackground(
                    color: retro.ink.withValues(alpha: retro.isDark ? 0.05 : 0.08),
                  ),
                ),
                widget.child,
              ],
            )
          : widget.child,
    );
  }
}

class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({
    super.key,
    this.color,
    this.icon = Icons.menu_rounded,
    this.size = 22,
  });

  final Color? color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Builder(
      builder: (ctx) => IconButton(
        icon: Icon(icon, color: color ?? retro.ink, size: size),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }
}
