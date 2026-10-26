import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_navigation_policy.dart';
import '../../core/navigation/app_navigator.dart';
import '../providers/navigation_provider.dart';

class AppNavigationScope extends InheritedWidget {
  const AppNavigationScope({
    super.key,
    required this.navigator,
    required this.isSecondary,
    required super.child,
  });

  final AppNavigator navigator;
  final bool isSecondary;

  static AppNavigationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppNavigationScope>();

  static AppNavigator navigatorOf(BuildContext context) =>
      maybeOf(context)?.navigator ??
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(appNavigatorProvider);

  @override
  bool updateShouldNotify(AppNavigationScope oldWidget) =>
      oldWidget.navigator != navigator || oldWidget.isSecondary != isSecondary;
}

void openPrimaryDestination(BuildContext context, String location) {
  AppNavigationScope.navigatorOf(
    context,
  ).openPrimary(GoRouter.of(context), location);
}

void openSecondaryDestination(BuildContext context, String location) {
  GoRouter.of(context).push(location, extra: const AppSecondaryDestination());
}

Future<T?> pushSecondaryDestination<T>(BuildContext context, String location) {
  return GoRouter.of(
    context,
  ).push<T>(location, extra: const AppSecondaryDestination());
}

void openLinkedDestination(BuildContext context, String location) {
  final router = GoRouter.of(context);
  final navigator = AppNavigationScope.navigatorOf(context);
  if (router.canPop() &&
      !AppNavigationPolicy.isPrimaryLocation(router.state.uri)) {
    navigator.openSecondary(router, location);
  } else {
    navigator.openPrimary(router, location);
  }
}
