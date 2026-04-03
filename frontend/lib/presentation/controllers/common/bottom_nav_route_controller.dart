import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';

class BottomNavRouteController {
  const BottomNavRouteController._();

  static String? routeForIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutes.postsFeed;
      case 1:
        return AppRoutes.explore;
      case 2:
        return AppRoutes.messages;
      case 3:
        return AppRoutes.profile;
      default:
        return null;
    }
  }

  static Future<void> handleTabSelection({
    required BuildContext context,
    required int currentIndex,
    required int nextIndex,
    required ValueChanged<int> onIndexChanged,
    required VoidCallback onUnsupportedDestination,
  }) async {
    if (nextIndex == currentIndex) return;

    final targetRoute = routeForIndex(nextIndex);
    if (targetRoute == null) {
      onUnsupportedDestination();
      return;
    }

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == targetRoute) {
      onIndexChanged(nextIndex);
      return;
    }

    onIndexChanged(nextIndex);
    await Navigator.of(context).pushReplacementNamed(targetRoute);
  }
}
