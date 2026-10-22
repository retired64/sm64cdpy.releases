import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/retro_theme.dart';
import '../../core/theme/themes/mario64_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/manga_menu_audio.dart';
import '../providers/manga_menu_audio_provider.dart';
import 'manga_navigation_bar.dart';
import 'manga_navigation_scope.dart';

/// Tira anclada abajo; el botón se eleva por encima al desplegarla.
class MangaNavigationDock extends ConsumerStatefulWidget {
  const MangaNavigationDock({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  final String currentRoute;
  final Widget child;

  @override
  ConsumerState<MangaNavigationDock> createState() => _MangaNavigationDockState();
}

class _MangaNavigationDockState extends ConsumerState<MangaNavigationDock>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final MangaMenuAudio _audio;
  late final AnimationController _animation;
  late final CurvedAnimation _curve;
  late final Animation<Offset> _slide;
  bool _expanded = false;
  bool _hasOpened = false;
  double _lastKeyboard = 0;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(mangaMenuAudioProvider);
    unawaited(_audio.prepare());
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
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_curve);
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
    if (state != AppLifecycleState.resumed) {
      unawaited(_audio.stop());
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _setExpanded(false, animate: false);
    }
  }

  @override
  void dispose() {
    unawaited(_audio.stop());
    WidgetsBinding.instance.removeObserver(this);
    _curve.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = keyboard > 0
        ? 0.0
        : MediaQuery.paddingOf(context).bottom;
    final scaled = MediaQuery.textScalerOf(context).scale(11);
    final labelHeight = scaled * (scaled > 14.3 ? 2.6 : 1.3);
    final panelHeight = (34 + labelHeight)
        .clamp(48.0, double.infinity)
        .toDouble();
    // El texto ampliado del botón también conserva su altura natural.
    final buttonHeight = 60 + MediaQuery.textScalerOf(context).scale(11) * 1.3;

    return BackButtonListener(
      onBackButtonPressed: () async {
        // Los diálogos y paneles modales tienen prioridad sobre este menú.
        if (!_expanded || ModalRoute.of(context)?.isCurrent == false)
          return false;
        _setExpanded(false);
        return true;
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final panelVisible = _expanded || !_animation.isDismissed;
          final inset =
              buttonHeight +
              12 +
              safeBottom +
              (panelVisible ? panelHeight + 28 : 0);
          return MangaNavigationScope(
            enabled: true,
            reservedBottomInset: inset,
            child: Stack(
              fit: StackFit.expand,
              children: [
                child!,
                if (_hasOpened)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: keyboard,
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Offstage(
                          offstage: !panelVisible,
                          child: TickerMode(
                            enabled: panelVisible,
                            child: ExcludeSemantics(
                              excluding: !_expanded,
                              child: IgnorePointer(
                                ignoring: !_expanded,
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
                    ),
                  ),
                Positioned(
                  key: const ValueKey('manga-menu-lift'),
                  right: 0,
                  // Mover la posición real mantiene la X también pulsable;
                  // una transformación fuera de su padre solo movería el dibujo.
                  bottom: keyboard + (panelHeight + 28) * _curve.value,
                  child: SafeArea(
                    top: false,
                    left: false,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12, bottom: 12),
                      child: _MangaMenuToggle(
                        progress: _curve.value,
                        expanded: _expanded,
                        height: buttonHeight,
                        onTap: () {
                          if (!_expanded) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                          unawaited(ref.read(mangaMenuSoundsProvider.notifier).play('press'));
                          _setExpanded(!_expanded);
                        },
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

/// Dos imágenes pequeñas comparten la misma transición; no hay animación ociosa.
class _MangaMenuToggle extends StatelessWidget {
  const _MangaMenuToggle({
    required this.progress,
    required this.expanded,
    required this.height,
    required this.onTap,
  });

  final double progress, height;
  final bool expanded;
  final VoidCallback onTap;

  Widget _badge(String name, IconData fallback, Color color) => Image.asset(
    'assets/themes/manga/navigation/$name.webp',
    key: ValueKey('manga-menu-$name'),
    width: 56,
    height: 56,
    cacheWidth: 192,
    cacheHeight: 192,
    filterQuality: FilterQuality.medium,
    excludeFromSemantics: true,
    errorBuilder: (context, error, stackTrace) => Icon(
      fallback,
      size: 30,
      color: color,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final l = AppLocalizations.of(context);
    final action = expanded ? l.mangaMenuClose : l.mangaMenuOpen;
    return Tooltip(
      excludeFromSemantics: true,
      message: action,
      child: Semantics(
        button: true,
        toggled: expanded,
        label: action,
        child: ExcludeSemantics(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('manga-menu-toggle'),
              onTap: onTap,
              borderRadius: BorderRadius.circular(32),
              child: SizedBox(
                width: 72,
                height: height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      // El cierre ocupa la mitad visual, conservando el área táctil.
                      scale: (1 - 0.5 * progress) *
                          (1 - 0.24 * progress * (1 - progress)),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: retro.accent.withValues(alpha: 0.24),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: RepaintBoundary(
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: 1 - progress,
                                child: _badge('menu-button', Icons.more_horiz, retro.ink),
                              ),
                              Opacity(
                                opacity: progress,
                                child: _badge('close-button', Icons.close_rounded, retro.ink),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!expanded) ...[
                      const SizedBox(height: 2),
                      Opacity(
                        opacity: 1 - progress,
                        child: _MarioMenuCaption(label: l.mangaMenuLabel),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rótulo multicolor dibujado con texto real, sin nuevos assets o animaciones.
class _MarioMenuCaption extends StatelessWidget {
  const _MarioMenuCaption({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    final text = label.toUpperCase();
    const colors = [
      Color(0xFF4BA7FF),
      Color(0xFFFF6354),
      Color(0xFFFFD83D),
      Color(0xFF6BDF72),
    ];
    final style = TextStyle(
      fontFamily: mario64Theme.headingFontFamily,
      fontFamilyFallback: mario64Theme.headingFontFamilyFallback,
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.3,
    );
    Text contour(Color color, double width, Key key) => Text(
      text,
      key: key,
      maxLines: 1,
      softWrap: false,
      style: style.copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width
          ..color = color,
      ),
    );
    final letters = text.runes.toList(growable: false);
    return SizedBox(
      height: MediaQuery.textScalerOf(context).scale(11) * 1.3 + 2,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (retro.isDark)
                contour(Colors.white, 2.8, const ValueKey('manga-menu-caption-rim')),
              contour(Colors.black, 1.5, const ValueKey('manga-menu-caption-outline')),
              Text.rich(
                TextSpan(
                  children: [
                    for (var i = 0; i < letters.length; i++)
                      TextSpan(
                        text: String.fromCharCode(letters[i]),
                        style: TextStyle(color: colors[i % colors.length]),
                      ),
                  ],
                ),
                key: const ValueKey('manga-menu-caption-fill'),
                maxLines: 1,
                softWrap: false,
                style: style,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
