import 'deluxe_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_accent.dart';
import '../../core/theme/retro_theme.dart';
import '../../services/guided_setup_service.dart';
import '../providers/auto_install_provider.dart';
import '../providers/extra_providers.dart';
import '../providers/game_folder_provider.dart';
import 'app_drawer.dart';
import 'manga_navigation_dock.dart';
import 'manga_navigation_scope.dart';
import 'guided_setup_flow.dart';

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
  final PageStorageBucket _pageStorage = PageStorageBucket();
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
    return bottomNavigation
        ? MangaNavigationDock(
            currentRoute: widget.currentRoute,
            child: scaffold,
          )
        : MangaNavigationScope(enabled: false, child: scaffold);
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
    final retro = RetroTheme.of(context);
    final decoration = retro.surfaceDecoration(
      shadowDx: retro.borderWidth(2),
      shadowDy: retro.borderWidth(2),
    );
    // La madera y los paneles comparten los materiales del resto de la app.
    final background = retro.usesMinimalSurfaces
        ? retro.background
        : decoration.color ?? retro.background;
    final requestedColor = color ?? retro.ink;
    // Los colores de sección se conservan solo si siguen siendo legibles.
    final foreground = RetroAccent.contrast(requestedColor, background) >= 3
        ? requestedColor
        : retro.onColor(background);
    // Reserva espacio para el borde, la sombra y la inclinación sin transformar
    // el área táctil ni invadir el título o el límite superior de la barra.
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
                      key: const ValueKey('drawer-menu-surface'),
                      decoration: decoration,
                    ),
                  ),
                ),
              ),
            // Solo se inclina el material: el icono y su semántica quedan rectos.
            IconButton(
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
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
              onPressed: () => Scaffold.of(context).openDrawer(),
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
      automaticallyImplyLeading: !bottomNavigation,
      leadingWidth: bottomNavigation ? null : 56,
      leading: bottomNavigation ? null : DrawerMenuButton(color: leadingColor),
      titleSpacing: bottomNavigation ? 16 : 0,
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
                if (MangaNavigationScope.of(context))
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
