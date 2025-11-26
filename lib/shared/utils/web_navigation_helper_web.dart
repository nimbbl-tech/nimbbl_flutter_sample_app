// Web-specific implementation
import 'dart:html' as html;

void navigateToRootWeb() {
  // Navigate to root URL with base path for GitHub Pages support
  // Extract base path from current location (e.g., /nimbbl_flutter_sample_app/)
  final origin = html.window.location.origin;
  final pathname = html.window.location.pathname;
  
  // Extract base path for GitHub Pages
  // Strategy: Check if we're on GitHub Pages (github.io domain) or detect base path from URL structure
  // For /nimbbl_flutter_sample_app/ -> /nimbbl_flutter_sample_app/
  // For /nimbbl_flutter_sample_app/Response -> /nimbbl_flutter_sample_app/
  // For /Response/ or /Response -> / (local testing, no base path)
  // For / -> /
  String basePath = '/';
  
  if (pathname != null && pathname.isNotEmpty && pathname != '/') {
    // Split pathname and get segments
    final segments = pathname.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      final firstSegment = segments.first.toLowerCase();
      
      // Check if we're on GitHub Pages (github.io domain)
      final isGitHubPages = origin.contains('github.io');
      
      // Known app routes (case-insensitive)
      final knownRoutes = ['response', 'home', 'index'];
      final isKnownRoute = knownRoutes.contains(firstSegment);
      
      if (isGitHubPages) {
        // On GitHub Pages: first segment is always the repository name (base path)
        // Even if it matches a route name, it's still the base path
        basePath = '/${segments.first}/';
      } else if (isKnownRoute && segments.length == 1) {
        // Local testing: if it's a known route at root level, navigate to root
        basePath = '/';
      } else if (segments.length > 1) {
        // Multiple segments: first one is likely base path (e.g., /repo-name/route)
        basePath = '/${segments.first}/';
      } else {
        // Single segment that's not a known route: could be base path or route
        // Default to treating as base path for safety
        basePath = '/${segments.first}/';
      }
    }
  }
  
  // Navigate to root with base path (e.g., https://nimbbl-tech.github.io/nimbbl_flutter_sample_app/)
  // or just root for local testing (e.g., http://192.168.0.30:8080/)
  html.window.location.href = origin + basePath;
}

