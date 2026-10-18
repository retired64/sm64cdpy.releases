import 'package:flutter/material.dart';

/// Stable IDs; semantic error, warning and brand colors are independent.
enum RetroAccent {
  cyan(0xFFA7DEE1),
  blue(0xFFAFCBFF),
  violet(0xFFD1B8FF),
  pink(0xFFFFB8D9),
  coral(0xFFFFB7A8),
  amber(0xFFFFD580),
  green(0xFFAFE0BA),
  lime(0xFFD3E69B);

  const RetroAccent(this.argb);
  final int argb;
  Color get color => Color(argb);

  static RetroAccent fromStorage(String? value) => values.firstWhere(
    (accent) => accent.name == value,
    orElse: () => cyan,
  );

  static final _textColors = <String, Color>{};

  Color textOn(List<Color> surfaces) => _textColors.putIfAbsent(
    '$name:${surfaces.map((color) => color.toARGB32()).join(",")}',
    () => _resolveText(surfaces),
  );

  Color _resolveText(List<Color> surfaces) {
    var candidate = color;
    for (var step = 0; step <= 100; step++) {
      candidate = Color.lerp(color, Colors.black, step / 100)!;
      if (surfaces.every((surface) => contrast(candidate, surface) >= 4.5)) {
        return candidate;
      }
    }
    return Colors.black;
  }

  static double contrast(Color a, Color b) {
    final x = a.computeLuminance();
    final y = b.computeLuminance();
    return ((x > y ? x : y) + .05) / ((x < y ? x : y) + .05);
  }
}
