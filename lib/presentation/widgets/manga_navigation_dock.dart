import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../l10n/app_localizations.dart';
import 'manga_navigation_bar.dart';
import 'manga_navigation_scope.dart';

/// Navegación bajo demanda: el botón conserva su posición al abrir la tira.
class MangaNavigationDock extends StatefulWidget {
  const MangaNavigationDock({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  State<MangaNavigationDock> createState() => _MangaNavigationDockState();
}

class _MangaNavigationDockState extends State<MangaNavigationDock>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animation;
  late final CurvedAnimation _curve;
  late final Animation<Offset> _slide;
  bool _expanded = false;
  bool _hasOpened = false;
  double _lastKeyboard = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 130),
    );
    _curve = CurvedAnimation(
      parent: _animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(_curve);
  }

  void _setExpanded(bool value, {bool animate = true}) {
    if (!mounted || _expanded == value) return;
    setState(() {
      _expanded = value;
      _hasOpened |= value;
    });
    if (!animate || MediaQuery.disableAnimationsOf(context)) {
      _animation.value = value ? 1 : 0;
    } else if (value) {
      _animation.forward();
    } else {
      _animation.reverse();
    }
  }

  @override
  void didUpdateWidget(covariant MangaNavigationDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) _setExpanded(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    if (keyboard > 0 && _lastKeyboard == 0) {
      _setExpanded(false, animate: false);
    } else if (MediaQuery.disableAnimationsOf(context)) {
      _animation.value = _expanded ? 1 : 0;
    }
    _lastKeyboard = keyboard;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _setExpanded(false, animate: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _curve.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = keyboard > 0 ? 0.0 : MediaQuery.paddingOf(context).bottom;
    final scaled = MediaQuery.textScalerOf(context).scale(11);
    final labelHeight = scaled * (scaled > 14.3 ? 2.6 : 1.3);
    final panelHeight = (34 + labelHeight).clamp(48.0, double.infinity).toDouble();
    // El texto ampliado del botón también conserva su altura natural.
    final buttonHeight = 60 + MediaQuery.textScalerOf(context).scale(11) * 1.3;

    return BackButtonListener(
      onBackButtonPressed: () async {
        // Los diálogos y paneles modales tienen prioridad sobre este menú.
        if (!_expanded || ModalRoute.of(context)?.isCurrent == false) return false;
        _setExpanded(false);
        return true;
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final panelVisible = _expanded || !_animation.isDismissed;
          final inset = buttonHeight + 12 + safeBottom +
              (panelVisible ? panelHeight + 24 : 0);
          return MangaNavigationScope(
            enabled: true,
            reservedBottomInset: inset,
            child: Stack(
              fit: StackFit.expand,
              children: [
                child!,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: keyboard,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hasOpened)
                            Offstage(
                              offstage: !panelVisible,
                              child: TickerMode(
                                enabled: panelVisible,
                                child: ExcludeSemantics(
                                  excluding: !_expanded,
                                  child: IgnorePointer(
                                    ignoring: !_expanded,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: FadeTransition(
                                        opacity: _curve,
                                        child: SlideTransition(
                                          position: _slide,
                                          child: MangaNavigationBar(
                                            currentRoute: widget.currentRoute,
                                            bottomSafeArea: false,
                                            onDestinationSelected: () => _setExpanded(false),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Tooltip(
                              excludeFromSemantics: true,
                              message: _expanded ? l.mangaMenuClose : l.mangaMenuOpen,
                              child: Semantics(
                                button: true,
                                toggled: _expanded,
                                label: _expanded ? l.mangaMenuClose : l.mangaMenuOpen,
                                child: ExcludeSemantics(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      key: const ValueKey('manga-menu-toggle'),
                                      onTap: () {
                                        if (!_expanded) {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }
                                        _setExpanded(!_expanded);
                                      },
                                      borderRadius: BorderRadius.circular(32),
                                      child: SizedBox(
                                        width: 72,
                                        height: buttonHeight,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: retro.accent,
                                                border: Border.all(
                                                  color: retro.onColor(retro.accent),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: retro.shadowColor.withValues(alpha: 0.24),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 3,
                                                  ),
                                                ],
                                              ),
                                              child: SizedBox.square(
                                                dimension: 56,
                                                child: Icon(
                                                  _expanded ? Icons.close_rounded : Icons.more_horiz,
                                                  color: retro.onColor(retro.accent),
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              l.mangaMenuLabel,
                                              maxLines: 1,
                                              style: retro.body(size: 11, color: retro.ink, height: 1.3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
