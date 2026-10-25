import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import 'mario_multicolor_label.dart';

/// Tipografia de lectura del tema Deluxe, limitada al subarbol de la pantalla.
class MangaDeluxeTypography extends StatelessWidget {
  const MangaDeluxeTypography({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!RetroTheme.of(context).isDeluxe) return child;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'FamiljenGrotesk'),
        primaryTextTheme: theme.primaryTextTheme.apply(
          fontFamily: 'FamiljenGrotesk',
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: 'FamiljenGrotesk'),
        child: child,
      ),
    );
  }
}

/// Encabezado Mario legible. El texto sigue siendo real y conserva semantica.
class MangaDeluxeScreenTitle extends StatelessWidget {
  const MangaDeluxeScreenTitle({
    super.key,
    required this.label,
    this.size = 20,
  });

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isDeluxe) return Text(label, style: retro.heading(size: size));
    return Semantics(
      header: true,
      label: label,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: MarioMulticolorLabel(
            label: label,
            fontSize: size,
            keyPrefix: 'deluxe-screen-$label',
          ),
        ),
      ),
    );
  }
}

class MangaDeluxeAssetIcon extends StatelessWidget {
  const MangaDeluxeAssetIcon({
    super.key,
    required this.asset,
    required this.fallback,
    this.size = 64,
  });

  final String asset;
  final IconData fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isDeluxe) {
      return Icon(fallback, size: size * .62, color: retro.accentText);
    }
    return RepaintBoundary(
      child: Image.asset(
        'assets/themes/manga_deluxe/$asset.webp',
        width: size,
        height: size,
        cacheWidth: 160,
        cacheHeight: 160,
        filterQuality: FilterQuality.low,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) =>
            Icon(fallback, size: size * .62, color: retro.accentText),
      ),
    );
  }
}

/// Hero compacto compartido: una sola superficie y una sola imagen decodificada.
class MangaDeluxeHeroPanel extends StatelessWidget {
  const MangaDeluxeHeroPanel({
    super.key,
    required this.asset,
    required this.fallback,
    required this.title,
    required this.body,
  });

  final String asset;
  final IconData fallback;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: retro.surfaceDecoration(shadowDx: 3, shadowDy: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MangaDeluxeAssetIcon(asset: asset, fallback: fallback),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MangaDeluxeScreenTitle(label: title, size: 18),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: retro
                      .body(size: 14, color: retro.inkDim, height: 1.45)
                      .copyWith(
                        fontFamily: retro.isDeluxe ? 'FamiljenGrotesk' : null,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MangaDeluxeAction extends StatelessWidget {
  const MangaDeluxeAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isDeluxe) {
      return primary
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            );
    }
    final foreground = primary ? retro.inkOnAccent : retro.ink;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: retro.surfaceDecoration(
          color: primary ? retro.accent : retro.surfaceAlt,
          shadowDx: 2,
          shadowDy: 2,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: retro.radius,
          child: Opacity(
            opacity: onPressed == null ? .5 : 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(icon, color: foreground, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: retro
                            .body(
                              size: 16,
                              color: foreground,
                              weight: FontWeight.w700,
                            )
                            .copyWith(fontFamily: 'FamiljenGrotesk'),
                      ),
                    ),
                    if (primary)
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: foreground,
                        size: 20,
                      ),
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

/// Homenaje discreto al `.dx` de la web. Se usa una sola vez por pantalla.
class MangaDeluxeRainbowText extends StatefulWidget {
  const MangaDeluxeRainbowText({
    super.key,
    required this.label,
    required this.style,
    this.enabled = true,
  });

  final String label;
  final TextStyle style;
  final bool enabled;

  @override
  State<MangaDeluxeRainbowText> createState() => _MangaDeluxeRainbowTextState();
}

class _MangaDeluxeRainbowTextState extends State<MangaDeluxeRainbowText>
    with SingleTickerProviderStateMixin {
  bool _animate = false;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  void _syncAnimation() {
    final media = MediaQuery.of(context);
    final animate =
        widget.enabled &&
        RetroTheme.of(context).isDeluxe &&
        TickerMode.valuesOf(context).enabled &&
        !media.disableAnimations &&
        !media.accessibleNavigation;
    _animate = animate;
    if (animate && _controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
    if (!animate && _controller.isAnimating) _controller.stop();
  }

  @override
  void didUpdateWidget(covariant MangaDeluxeRainbowText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) _controller.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncAnimation();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!_animate || !widget.enabled || !retro.isDeluxe) {
      return Text(widget.label, style: widget.style);
    }
    return Semantics(
      label: widget.label,
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, _) => Text(
              widget.label,
              style: widget.style.copyWith(
                color: HSVColor.fromAHSV(
                  1,
                  _controller.value * 360,
                  retro.isDark ? .42 : .58,
                  retro.isDark ? 1 : .72,
                ).toColor(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
