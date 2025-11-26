// Web-specific implementation
import 'dart:html' as html;

/// Clean up the URL to show a cleaner format
/// Converts ?//Response&response=... to /Response?response=...
void cleanupResponseUrl() {
  try {
    final uri = Uri.parse(html.window.location.href);
    final queryString = uri.query;
    
    // Check if URL is in SPA format (starts with / or //)
    if (queryString.isNotEmpty && queryString.startsWith('/')) {
      // Extract the response parameter
      final responseParam = getResponseParamFromUrl();
      
      if (responseParam != null) {
        // Determine base path (for GitHub Pages)
        final pathname = html.window.location.pathname;
        String basePath = '/';
        if (pathname != null && pathname.isNotEmpty && pathname != '/') {
          final segments = pathname.split('/').where((s) => s.isNotEmpty).toList();
          if (segments.isNotEmpty) {
            basePath = '/${segments.first}/';
          }
        }
        
        // Construct clean URL: /basePath/Response?response=...
        final cleanPath = '${basePath}Response?response=${Uri.encodeComponent(responseParam)}';
        
        // Update URL without reloading page
        html.window.history.replaceState(null, '', cleanPath);
      }
    }
  } catch (e) {
    // Silently handle errors
  }
}

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


