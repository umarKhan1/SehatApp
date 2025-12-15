import 'package:flutter/material.dart';

/// Global navigator key service for safe navigation from anywhere in the app.
/// This allows navigation from services, blocs, or background listeners.
class NavigatorService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get the current NavigatorState
  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Push a new route
  static Future<T?>? push<T>(Route<T> route) {
    return navigator?.push(route);
  }

  /// Pop the current route
  static void pop<T>([T? result]) {
    navigator?.pop(result);
  }

  /// Check if we can pop
  static bool canPop() {
    return navigator?.canPop() ?? false;
  }

  /// Push a named route
  static Future<T?>? pushNamed<T>(String routeName, {Object? arguments}) {
    return navigator?.pushNamed<T>(routeName, arguments: arguments);
  }
}


