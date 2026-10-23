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
        primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: 'FamiljenGrotesk'),
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
  const HomeMarioLabel({super.key, required this.label, this.size = 18});
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isManga) return Text(label, style: retro.heading(size: size));
    final style = TextStyle(
      fontFamily: mario64Theme.headingFontFamily,
      fontFamilyFallback: mario64Theme.headingFontFamilyFallback,
      fontSize: size, fontWeight: FontWeight.w400, height: 1.3,
    );
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: Stack(children: [
        Text(label, style: style.copyWith(foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 2
          ..color = Colors.black)),
        Text(label, style: style.copyWith(color: Colors.white)),
      ])),
    );
  }
}

class HomeLaunchIcon extends StatelessWidget {
  const HomeLaunchIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.isManga) return MarioGameIcon(
      Icons.play_arrow_rounded, size: 22, color: retro.inkOnAccent,
    );
    return Image.asset(
      'assets/themes/manga/navigation/play.webp',
      width: 36, height: 36, cacheWidth: 128, cacheHeight: 128,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => Icon(Icons.play_arrow_rounded, color: retro.inkOnAccent),
    );
  }
}
