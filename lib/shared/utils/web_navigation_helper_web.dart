// Web-specific implementation
import 'dart:html' as html;

void navigateToRootWeb() {
  // Navigate to root URL (matching React: location.href = window.location.origin)
  html.window.location.href = html.window.location.origin;
}

