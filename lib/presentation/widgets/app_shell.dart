import 'dart:async';

import 'deluxe_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_navigation_policy.dart';
import '../../core/navigation/app_navigator.dart';
import '../../core/theme/retro_accent.dart';
import '../../core/theme/retro_theme.dart';
import '../../services/guided_setup_service.dart';
import '../providers/auto_install_provider.dart';
import '../providers/extra_providers.dart';
import '../providers/game_folder_provider.dart';
import '../providers/navigation_provider.dart';
import 'app_drawer.dart';
import 'app_navigation_scope.dart';
import 'guided_setup_flow.dart';
import 'manga_navigation_dock.dart';
import 'manga_navigation_scope.dart';
import 'player_leave_guard.dart';

const _noHalftoneRoutes = {'/', '/favourites', '/disclaimer'};

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.currentRoute,
    required this.child,
    this.currentUri,
    this.isSecondary,
  });

  final String currentRoute;
  final Widget child;
  final Uri? currentUri;
  final bool? isSecondary;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final ScrollController _drawerScrollController = ScrollController();
  final PageStorageBucket _pageStorage = PageStorageBucket();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final Future<bool> Function() _leaveGuard;
  late final AppNavigator _navigator;
  Listenable? _routerDelegate;
  bool _setupFlowScheduled = false;
  bool _setupFlowRunning = false;

  Uri get _uri => widget.currentUri ?? Uri.parse(widget.currentRoute);
  bool get _isSecondary =>
      widget.isSecondary ?? AppNavigationPolicy.isSecondaryLocation(_uri);

  Future<bool> _allowLeave() async {
    if (widget.currentRoute != '/player') return true;
    return confirmPlayerLeave(context, ref);
  }

  void _syncNavigation() {
    _navigator.syncActive(_uri, isSecondary: _isSecondary);
  }

  void _syncRouteProjection() {
    if (!mounted) return;
    ref
        .read(currentRouteProvider.notifier)
        .set(GoRouter.of(context).state.uri.path);
  }

  Future<bool> _handleBack() async {
    final scaffold = _scaffoldKey.currentState;
    if (scaffold != null && scaffold.isDrawerOpen) {
      scaffold.closeDrawer();
      return true;
    }
    return _navigator.handleSystemBack(
      GoRouter.of(context),
      isSecondary: _isSecondary,
    );
  }

  @override
  void initState() {
    super.initState();
    _navigator = ref.read(appNavigatorProvider);
    _leaveGuard = _allowLeave;
    _navigator.registerLeaveGuard(_leaveGuard);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncNavigation();
      ref.read(currentRouteProvider.notifier).set(widget.currentRoute);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routerDelegate != null) return;
    final delegate = GoRouter.of(context).routerDelegate;
    _routerDelegate = delegate;
    delegate.addListener(_syncRouteProjection);
  }

  void _scheduleSetupFlow(AutoInstallSettings autoInstall) {
    if (widget.currentRoute != '/' ||
        _setupFlowScheduled ||
        _setupFlowRunning ||
        autoInstall.isSaving) {
      return;
    }
    final folder = ref.read(gameFolderProvider);
    if (!folder.initialized || !GuidedSetupService.needsPrompt) return;

    _setupFlowScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _setupFlowScheduled = false;
      if (!mounted || _setupFlowRunning) return;
      _setupFlowRunning = true;
      try {
        final currentAutoInstall = ref.read(autoInstallProvider);
        final connection = ref.read(gameFolderProvider).connection;
        // Migration guard: established users keep their existing experience.
        if (!currentAutoInstall.needsDecision ||
            connection.connected ||
            connection.dismissed) {
          await GuidedSetupService.complete();
        } else if (mounted) {
          await showGuidedSetupFlow(context);
        }
      } finally {
        _setupFlowRunning = false;
      }
    });
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_syncRouteProjection);
    _navigator.unregisterLeaveGuard(_leaveGuard);
    _drawerScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentRoute != oldWidget.currentRoute ||
        widget.currentUri != oldWidget.currentUri ||
        widget.isSecondary != oldWidget.isSecondary) {
      _syncNavigation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final bottomNavigation = retro.isManga;
    final autoInstall = ref.watch(autoInstallProvider);
    ref.watch(gameFolderProvider);
    _scheduleSetupFlow(autoInstall);
    final showBackdrop =
        retro.isDeluxe ||
        retro.isIntro ||
        retro.showN64Backdrop ||
        retro.showParchmentBackdrop ||
        retro.showCheckeredBackdrop ||
        (retro.showHalftone &&
            !_noHalftoneRoutes.contains(widget.currentRoute));

    // El viewport debe llegar detrás de la navegación; la separación final
    // pertenece al contenido desplazable, no al tamaño de la pantalla.
    final scaffold = Scaffold(
      key: _scaffoldKey,
      extendBody: bottomNavigation,
      backgroundColor: retro.background,
      drawer: bottomNavigation
          ? null
          : AppDrawer(scrollController: _drawerScrollController),
      drawerEnableOpenDragGesture: !bottomNavigation,
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
      body: PageStorage(
        bucket: _pageStorage,
        child: KeyedSubtree(
          key: PageStorageKey(widget.currentRoute),
          child: showBackdrop
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: retro.isDeluxe
                          ? const DeluxeBackdrop()
                          : ThemeBackdrop(
                              menuSurface:
                                  widget.currentRoute == '/library' ||
                                  widget.currentRoute == '/settings',
                              allowHalftone: !_noHalftoneRoutes.contains(
                                widget.currentRoute,
                              ),
                            ),
                    ),
                    ThemePageFrame(child: widget.child),
                  ],
                )
              : widget.child,
        ),
      ),
    );
    return AppNavigationScope(
      navigator: _navigator,
      isSecondary: _isSecondary,
      child: BackButtonListener(
        onBackButtonPressed: _handleBack,
        child: bottomNavigation
            ? MangaNavigationDock(
                currentRoute: widget.currentRoute,
                child: scaffold,
              )
            : MangaNavigationScope(enabled: false, child: scaffold),
      ),
    );
  }
}

/// Espacio final desplazable: no recorta el viewport ni pinta una franja.
double mangaNavigationScrollInset(BuildContext context) {
  if (!MangaNavigationScope.of(context)) return 0;
  // El dock publica su altura real: botón cerrado o carrusel desplegado.
  return MangaNavigationScope.insetOf(context) + 24;
}

class MangaNavigationSliverInset extends StatelessWidget {
  const MangaNavigationSliverInset({super.key});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: SizedBox(height: mangaNavigationScrollInset(context)),
  );
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
    if (MangaNavigationScope.of(context)) return const SizedBox.shrink();
    return _NavigationSurfaceButton(
      icon: icon,
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      color: color,
      size: size,
      surfaceKey: const ValueKey('drawer-menu-surface'),
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.color, this.size = 22});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _NavigationSurfaceButton(
      icon: Icons.arrow_back_rounded,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      color: color,
      size: size,
      surfaceKey: const ValueKey('app-back-surface'),
      onPressed: () {
        final router = GoRouter.of(context);
        final navigator = AppNavigationScope.navigatorOf(context);
        unawaited(navigator.goBack(router));
      },
    );
  }
}

class _NavigationSurfaceButton extends StatelessWidget {
  const _NavigationSurfaceButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.surfaceKey,
    this.color,
    this.size = 22,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Key surfaceKey;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final decoration = retro.surfaceDecoration(
      shadowDx: retro.borderWidth(2),
      shadowDy: retro.borderWidth(2),
    );
    final background = retro.usesMinimalSurfaces
        ? retro.background
        : decoration.color ?? retro.background;
    final requestedColor = color ?? retro.ink;
    final foreground = RetroAccent.contrast(requestedColor, background) >= 3
        ? requestedColor
        : retro.onColor(background);
    final inset =
        retro.borderWidth(3) +
        retro.chipSkew.abs() * kMinInteractiveDimension / 2;

    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: kMinInteractiveDimension,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!retro.usesMinimalSurfaces)
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(inset),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.skewX(-retro.chipSkew),
                    child: DecoratedBox(
                      key: surfaceKey,
                      decoration: decoration,
                    ),
                  ),
                ),
              ),
            IconButton(
              tooltip: tooltip,
              constraints: const BoxConstraints.tightFor(
                width: kMinInteractiveDimension,
                height: kMinInteractiveDimension,
              ),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                minimumSize: const Size.square(kMinInteractiveDimension),
                maximumSize: const Size.square(kMinInteractiveDimension),
                visualDensity: VisualDensity.standard,
                tapTargetSize: MaterialTapTargetSize.padded,
                shape: RoundedRectangleBorder(borderRadius: retro.radius),
                foregroundColor: foreground,
                backgroundColor: Colors.transparent,
              ),
              icon: MarioGameIcon(icon, color: foreground, size: size),
              onPressed: onPressed,
            ),
          ],
        ),
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
    final bottomNavigation = MangaNavigationScope.of(context);
    final secondary = AppNavigationScope.maybeOf(context)?.isSecondary ?? false;
    final leading = secondary
        ? AppBackButton(color: leadingColor)
        : bottomNavigation
        ? null
        : DrawerMenuButton(color: leadingColor);

    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      toolbarHeight: 56,
      backgroundColor: retro.isDeluxe
          ? retro.background.withValues(alpha: 0.96)
          : retro.background,
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
      automaticallyImplyLeading: false,
      leadingWidth: leading == null ? null : 56,
      leading: leading,
      titleSpacing: leading == null ? 16 : 0,
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
    final secondary = AppNavigationScope.maybeOf(context)?.isSecondary ?? false;

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
                if (secondary)
                  AppBackButton(color: leadingColor)
                else if (MangaNavigationScope.of(context))
                  const SizedBox(width: 16)
                else
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
