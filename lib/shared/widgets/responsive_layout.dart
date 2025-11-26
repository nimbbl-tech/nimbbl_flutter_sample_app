import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../screens/order_create_screen.dart';
import '../../screens/web_order_create_screen.dart';

/// Responsive layout widget that switches between mobile and web UI
/// based on screen width
/// 
/// - Mobile UI: Screen width < 768px
/// - Web UI: Screen width >= 768px
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({Key? key}) : super(key: key);

  /// Breakpoint for switching between mobile and web UI
  static const double mobileBreakpoint = 768.0;

  @override
  Widget build(BuildContext context) {
    // On mobile platforms, always use mobile UI
    if (!kIsWeb) {
      return const OrderCreateScreen();
    }

    // On web, use responsive layout based on screen width
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        
        if (screenWidth < mobileBreakpoint) {
          // Mobile UI for small screens
          return const OrderCreateScreen();
        } else {
          // Web UI for large screens
          return const WebOrderCreateScreen();
        }
      },
    );
  }
}

