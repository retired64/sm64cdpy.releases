import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../core/theme/themes/mario64_theme.dart';

/// Tipografía local a Home; no modifica el diseño guardado ni otras rutas.
class HomeTypography extends StatelessWidget {
  const HomeTypography({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!RetroTheme.of(context).isManga) return child;
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

/// Letras Mario monocromas, con contorno negro uniforme y semántica única.
class HomeMarioLabel extends StatelessWidget {
  const HomeMarioLabel({
    super.key,
    required this.label,
    this.size = 18,
    this.singleLine = false,
  });
  final String label;
  final double size;
  final bool singleLine;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isManga) return Text(label, style: retro.heading(size: size));
    final style = TextStyle(
      fontFamily: mario64Theme.headingFontFamily,
      fontFamilyFallback: mario64Theme.headingFontFamilyFallback,
      fontSize: size,
      fontWeight: FontWeight.w400,
      height: 1.3,
    );
    final lettering = Stack(
      children: [
        Text(
          label,
          maxLines: singleLine ? 1 : null,
          softWrap: !singleLine,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeJoin = StrokeJoin.round
              ..strokeWidth = 2
              ..color = Colors.black,
          ),
        ),
        Text(
          label,
          maxLines: singleLine ? 1 : null,
          softWrap: !singleLine,
          style: style.copyWith(color: Colors.white),
        ),
      ],
    );
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: singleLine
            ? SizedBox(
                height: MediaQuery.textScalerOf(context).scale(size) * 1.3 + 4,
                child: FittedBox(fit: BoxFit.scaleDown, child: lettering),
              )
            : lettering,
      ),
    );
  }
}

class HomeLaunchIcon extends StatelessWidget {
  const HomeLaunchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isManga) {
      return MarioGameIcon(
        Icons.play_arrow_rounded,
        size: 22,
        color: retro.inkOnAccent,
      );
    }
    return Image.asset(
      'assets/themes/manga/navigation/home-start-game.webp',
      width: 32,
      height: 32,
      cacheWidth: 128,
      cacheHeight: 128,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) =>
          Icon(Icons.play_arrow_rounded, color: retro.inkOnAccent),
    );
  }
}

/// Arte de categoría con decodificación acotada; nunca consulta la red.
class HomeBrowseIcon extends StatelessWidget {
  const HomeBrowseIcon({
    super.key,
    required this.asset,
    required this.fallback,
  });
  final String asset;
  final IconData fallback;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/themes/manga/navigation/home-$asset.webp',
    width: 56,
    height: 56,
    cacheWidth: 128,
    cacheHeight: 128,
    excludeFromSemantics: true,
    errorBuilder: (_, _, _) =>
        Icon(fallback, color: RetroTheme.of(context).accentText),
  );
}
