import 'package:go_router/go_router.dart';

import 'app_navigation_policy.dart';
import 'main_navigation_history.dart';

class AppNavigator {
  AppNavigator({MainNavigationHistory? history})
    : history = history ?? MainNavigationHistory();

  final MainNavigationHistory history;
  final List<Future<bool> Function()> _leaveGuards = [];

  void registerLeaveGuard(Future<bool> Function() guard) {
    if (!_leaveGuards.contains(guard)) _leaveGuards.add(guard);
  }

  void unregisterLeaveGuard(Future<bool> Function() guard) {
    _leaveGuards.remove(guard);
  }

  Future<bool> allowLeave() async {
    for (final guard in List<Future<bool> Function()>.of(_leaveGuards)) {
      if (!await guard()) return false;
    }
    return true;
  }

  void syncActive(Uri uri, {required bool isSecondary}) {
    if (isSecondary || !AppNavigationPolicy.isPrimaryLocation(uri)) return;
    history.sync(uri.toString());
  }

  void openPrimary(GoRouter router, String location) {
    history.record(location);
    router.go(location);
  }

  void openSecondary(GoRouter router, String location) {
    router.push(location, extra: const AppSecondaryDestination());
  }

  Future<bool> handleSystemBack(
    GoRouter router, {
    required bool isSecondary,
  }) async {
    if (router.canPop()) return false;
    if (!await allowLeave()) return true;

    final current = router.state.uri;
    if (!isSecondary) {
      syncActive(current, isSecondary: false);
    }
    final target = history.resolveBack(
      current.toString(),
      secondary: isSecondary,
      fallbackParent: AppNavigationPolicy.parentOf(current.path),
    );
    if (target == null) return false;
    history.commit(target);
    router.go(target.location);
    return true;
  }

  Future<void> goBack(GoRouter router) async {
    if (!await allowLeave()) return;

    if (router.canPop()) {
      router.pop();
      return;
    }

    final current = router.state.uri;
    final secondary = AppNavigationPolicy.isSecondaryLocation(current);
    if (!secondary) {
      syncActive(current, isSecondary: false);
    }
    final target = history.resolveBack(
      current.toString(),
      secondary: secondary,
      fallbackParent: AppNavigationPolicy.parentOf(current.path),
    );
    if (target == null) return;
    history.commit(target);
    router.go(target.location);
  }
}
