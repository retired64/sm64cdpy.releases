import 'package:flutter/material.dart';

import '../../core/theme/retro_theme.dart';
import '../../core/theme/themes/mario64_theme.dart';

/// Rótulo multicolor dibujado con texto real, sin nuevos assets o animaciones.
class MarioMulticolorLabel extends StatelessWidget {
  const MarioMulticolorLabel({
    super.key,
    required this.label,
    this.fontSize = 11,
    this.keyPrefix = 'manga-menu-caption',
  });

  final String label;
  final double fontSize;
  final String keyPrefix;

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
      fontSize: fontSize,
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
      height: MediaQuery.textScalerOf(context).scale(fontSize) * 1.3 + 2,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (retro.isDark)
                contour(Colors.white, 2.8, ValueKey('$keyPrefix-rim')),
              contour(Colors.black, 1.5, ValueKey('$keyPrefix-outline')),
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
                key: ValueKey('$keyPrefix-fill'),
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
