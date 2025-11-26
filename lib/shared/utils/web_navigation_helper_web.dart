// Web-specific implementation
import 'dart:html' as html;

void navigateToRootWeb() {
  // Navigate to root URL with base path for GitHub Pages support
  // Extract base path from current location (e.g., /nimbbl_flutter_sample_app/)
  final origin = html.window.location.origin;
  final pathname = html.window.location.pathname;
  
  // Extract base path for GitHub Pages
  // For /nimbbl_flutter_sample_app/ -> /nimbbl_flutter_sample_app/
  // For /nimbbl_flutter_sample_app/some-page -> /nimbbl_flutter_sample_app/
  // For / -> /
  String basePath = '/';
  if (pathname.isNotEmpty && pathname != '/') {
    // Split pathname and get first non-empty segment (the repository name)
    final segments = pathname.split('/').where((s) => s.isNotEmpty).toList();
    if (segments.isNotEmpty) {
      // Reconstruct base path: /repository-name/
      basePath = '/${segments.first}/';
    }
  }
  
  // Navigate to root with base path (e.g., https://nimbbl-tech.github.io/nimbbl_flutter_sample_app/)
  html.window.location.href = origin + basePath;
}

