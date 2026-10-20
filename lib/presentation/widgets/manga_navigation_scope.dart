import 'package:flutter/widgets.dart';

/// Indica que la navegación principal ya está disponible debajo del contenido.
class MangaNavigationScope extends InheritedWidget {
  const MangaNavigationScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  final bool enabled;

  static bool of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MangaNavigationScope>()
          ?.enabled ??
      false;

  @override
  bool updateShouldNotify(MangaNavigationScope oldWidget) =>
      enabled != oldWidget.enabled;
}
