import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/auto_install_provider.dart';
import '../providers/extra_providers.dart';
import '../providers/game_folder_provider.dart';
import 'app_drawer.dart';
import 'game_folder_card.dart';
import 'game_setup_widgets.dart';

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
  bool _setupFlowScheduled = false;
  bool _setupFlowRunning = false;

  void _scheduleSetupFlow(AutoInstallSettings autoInstall) {
    if (widget.currentRoute != '/' ||
        _setupFlowScheduled ||
        _setupFlowRunning ||
        autoInstall.isSaving) {
      return;
    }
    final folder = ref.read(gameFolderProvider);
    final folderPending =
        !folder.initialized ||
        (!folder.connection.connected && !folder.connection.dismissed);
    if (!autoInstall.needsDecision && !folderPending) return;

    _setupFlowScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _setupFlowScheduled = false;
      if (!mounted || _setupFlowRunning) return;
      _setupFlowRunning = true;
      try {
        if (ref.read(autoInstallProvider).needsDecision) {
          final l10n = AppLocalizations.of(context);
          final enable = await showGameSetupDialog(
            context,
            title: l10n.autoInstallPromptTitle,
            body: l10n.autoInstallPromptBody,
            confirm: l10n.autoInstallPromptEnable,
            cancel: l10n.autoInstallPromptDownloadOnly,
            icon: Icons.auto_mode_rounded,
            barrierDismissible: false,
          );
          if (!mounted || enable == null) return;
          final saved = await ref
              .read(autoInstallProvider.notifier)
              .setEnabled(enable);
          if (!mounted || !saved) return;
        }

        await ref.read(gameFolderProvider.notifier).initialize();
        if (!mounted) return;
        final connection = ref.read(gameFolderProvider).connection;
        if (!connection.connected && !connection.dismissed) {
          await connectGameFolder(
            context,
            ref,
            dismissOnCancel: true,
            barrierDismissible: false,
          );
        }
      } finally {
        _setupFlowRunning = false;
      }
    });
  }

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
    final autoInstall = ref.watch(autoInstallProvider);
    ref.watch(gameFolderProvider);
    _scheduleSetupFlow(autoInstall);
    final showBackdrop =
        retro.isIntro ||
        retro.showN64Backdrop ||
        retro.showParchmentBackdrop ||
        retro.showCheckeredBackdrop ||
        (retro.showHalftone &&
            !_noHalftoneRoutes.contains(widget.currentRoute));

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
      body: showBackdrop
          ? Stack(
              children: [
                Positioned.fill(
                  child: ThemeBackdrop(
                    menuSurface:
                        widget.currentRoute == '/library' ||
                        widget.currentRoute == '/settings',
                    allowHalftone: !_noHalftoneRoutes.contains(
                      widget.currentRoute,
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
        icon: MarioGameIcon(icon, color: color ?? retro.ink, size: size),
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
      systemOverlayStyle: retro.systemUiStyle,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: showBottomBorder
          ? Border(
              bottom: BorderSide(
                color: retro.border,
                width: retro.borderWidth(2),
              ),
            )
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
            decoration: retro.gameDecoration(
              BoxDecoration(
                color: retro.background,
                border: Border(
                  bottom: BorderSide(
                    color: retro.border,
                    width: retro.borderWidth(2),
                  ),
                ),
              ),
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
