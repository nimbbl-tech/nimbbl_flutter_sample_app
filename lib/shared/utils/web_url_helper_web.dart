// Web-specific implementation
import 'dart:html' as html;

/// Get the response parameter from the current browser URL
/// Returns null if not found or not on web
String? getResponseParamFromUrl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    return uri.queryParameters['response'];
  } catch (e) {
    return null;
  }
}


