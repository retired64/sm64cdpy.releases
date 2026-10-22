import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';

/// Viñeta estática: tinta, papel y sombra dura, sin capas de blur ni shaders.
class FeaturedModFrame extends StatelessWidget {
  const FeaturedModFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final retro = RetroTheme.of(context);
    if (!retro.showJapaneseDecorations) return child;
    return RepaintBoundary(
      child: Container(
        key: const ValueKey('manga-featured-frame'),
        margin: const EdgeInsets.only(right: 4, bottom: 4),
        padding: const EdgeInsets.all(4),
        decoration: retro.surfaceDecoration(border: 3, shadowDx: 4, shadowDy: 4),
        foregroundDecoration: BoxDecoration(
          borderRadius: retro.radius,
          border: Border.all(color: retro.border, width: retro.borderWidth(3)),
        ),
        child: child,
      ),
    );
  }
}
