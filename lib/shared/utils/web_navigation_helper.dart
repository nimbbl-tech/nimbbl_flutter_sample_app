// Conditional import for web navigation
import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_navigation_helper_stub.dart'
    if (dart.library.html) 'web_navigation_helper_web.dart';

/// Helper for web navigation
/// Uses conditional imports to access dart:html only on web
void navigateToRoot() {
  if (kIsWeb) {
    navigateToRootWeb();
  }
}

