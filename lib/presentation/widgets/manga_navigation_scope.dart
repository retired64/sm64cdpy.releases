import 'package:flutter/widgets.dart';

/// Indica que la navegación principal ya está disponible debajo del contenido.
class MangaNavigationScope extends InheritedWidget {
  const MangaNavigationScope({
    super.key,
    required this.enabled,
    this.reservedBottomInset = 0,
    required super.child,
  });

  final bool enabled;
  final double reservedBottomInset;

  static double insetOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MangaNavigationScope>()
          ?.reservedBottomInset ??
      0;

  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MangaNavigationScope>()
          ?.enabled ??
      false;

  @override
  bool updateShouldNotify(MangaNavigationScope oldWidget) =>
      enabled != oldWidget.enabled ||
      reservedBottomInset != oldWidget.reservedBottomInset;
}
