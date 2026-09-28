import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../providers/extra_providers.dart';
import 'app_drawer.dart';

const _noHalftoneRoutes = {'/', '/favourites', '/disclaimer'};

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.currentRoute, required this.child});

  final String currentRoute;
  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final ScrollController _drawerScrollController = ScrollController();

  @override
  void dispose() {
    _drawerScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute) {
      Future.microtask(() {
        ref.read(currentRouteProvider.notifier).set(widget.currentRoute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final showHalftone = !_noHalftoneRoutes.contains(widget.currentRoute);

    return Scaffold(
      backgroundColor: retro.background,
      drawer: AppDrawer(scrollController: _drawerScrollController),
      drawerEnableOpenDragGesture: true,
      drawerEdgeDragWidth: 32,
      drawerScrimColor: Colors.black.withValues(alpha: 0.62),
      onDrawerChanged: (isOpened) {
        if (!isOpened) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_drawerScrollController.hasClients) {
            _drawerScrollController.jumpTo(0);
          }
        });
      },
      body: showHalftone
          ? Stack(
              children: [
                Positioned.fill(
                  child: HalftoneBackground(
                    color: retro.ink.withValues(
                      alpha: retro.isDark ? 0.035 : 0.08,
                    ),
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
        tooltip: MaterialLocalizations.of(ctx).openAppDrawerTooltip,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Icon(icon, color: color ?? retro.ink, size: size),
        onPressed: () => Scaffold.of(ctx).openDrawer(),
      ),
    );
  }
}

/// Canonical top bar for every root destination hosted by [AppShell].
///
/// It stays pinned so the navigation drawer remains reachable regardless of
/// scroll direction or momentum. Screen-specific content belongs in [title],
/// [actions] and [bottom], not in a second scrolling/navigation policy.
class RetroPinnedAppBar extends StatelessWidget {
  const RetroPinnedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leadingColor,
    this.showBottomBorder = true,
  });

  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? leadingColor;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      toolbarHeight: 56,
      backgroundColor: retro.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: showBottomBorder
          ? Border(bottom: BorderSide(color: retro.border, width: 2))
          : null,
      leadingWidth: 56,
      leading: DrawerMenuButton(color: leadingColor),
      titleSpacing: 0,
      title: title,
      actions: actions,
      bottom: bottom,
    );
  }
}

/// Fixed counterpart used while a root destination is loading or failed.
/// Keeps the drawer reachable even when the screen cannot build its data list.
class RetroFixedHeaderView extends StatelessWidget {
  const RetroFixedHeaderView({
    super.key,
    required this.title,
    required this.child,
    this.leadingColor,
  });

  final Widget title;
  final Widget child;
  final Color? leadingColor;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: retro.background,
              border: Border(bottom: BorderSide(color: retro.border, width: 2)),
            ),
            child: Row(
              children: [
                DrawerMenuButton(color: leadingColor),
                Expanded(child: title),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
