import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Platform-aware navigation utilities
/// 
/// Provides standard navigation methods that work consistently
/// across web and mobile platforms
class NavigationUtils {
  /// Navigate to a new screen
  /// 
  /// On web: Uses pushReplacement with fade transition for smooth navigation
  /// On mobile: Uses push (standard navigation stack)
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    Widget screen, {
    bool replace = false,
  }) {
    if (kIsWeb) {
      // On web, use pushReplacement with fade transition for smooth navigation
      // This prevents users from going back to the previous screen
      return Navigator.of(context).pushReplacement<T, void>(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade transition for smooth navigation on web
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        ),
      );
    } else {
      // On mobile, use standard push navigation
      if (replace) {
        return Navigator.of(context).pushReplacement<T, void>(
          MaterialPageRoute(builder: (_) => screen),
        );
      } else {
        return Navigator.of(context).push<T>(
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    }
  }

  /// Navigate back
  static void goBack<T extends Object?>(BuildContext context, [T? result]) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(result);
    }
  }

  /// Check if navigation is possible
  static bool canGoBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

