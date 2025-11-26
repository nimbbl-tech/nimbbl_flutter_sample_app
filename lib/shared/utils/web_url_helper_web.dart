// Web-specific implementation
import 'dart:html' as html;

/// Get the response parameter from the current browser URL
/// Returns null if not found or not on web
/// Handles both direct query params and GitHub Pages SPA format (?//Response&response=...)
String? getResponseParamFromUrl() {
  try {
    final fullUrl = html.window.location.href;
    final uri = Uri.parse(fullUrl);
    
    // First try direct query parameter (standard format)
    if (uri.queryParameters.containsKey('response')) {
      return uri.queryParameters['response'];
    }
    
    // Handle GitHub Pages SPA routing format: ?//Response&response=... or ?/Response&response=...
    // The 404.html script converts /Response?response=... to ?/Response&response=... (or ?//Response&response=...)
    // We need to parse the raw query string manually
    final queryString = uri.query;
    if (queryString.isNotEmpty) {
      // Check if it's in SPA format (starts with / or //)
      if (queryString.startsWith('/')) {
        // Parse manually: /Response&response=... or //Response&response=...
        // Split by & but handle ~and~ encoding
        final parts = queryString.split('&');
        for (final part in parts) {
          if (part.contains('=')) {
            final keyValue = part.split('=');
            if (keyValue.length == 2) {
              final key = keyValue[0].trim();
              // Skip the route part (/Response or //Response) - it doesn't have =
              // Look for response parameter
              if (key == 'response') {
                // Decode the value (replace ~and~ back to &, then URL decode)
                var value = keyValue[1].replaceAll('~and~', '&');
                return Uri.decodeComponent(value);
              }
            }
          }
        }
      } else {
        // Try parsing the raw query string for response parameter
        // Sometimes the format might be different
        final parts = queryString.split('&');
        for (final part in parts) {
          if (part.startsWith('response=')) {
            var value = part.substring('response='.length);
            value = value.replaceAll('~and~', '&');
            return Uri.decodeComponent(value);
          }
        }
      }
    }
    
    return null;
  } catch (e) {
    return null;
  }
}


