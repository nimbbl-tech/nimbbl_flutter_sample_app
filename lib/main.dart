import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/order_success_screen.dart';
import 'shared/widgets/responsive_layout.dart';
import 'services/settings_service.dart';

// Conditional import for web URL access
import 'shared/utils/web_url_helper.dart' if (dart.library.html) 'shared/utils/web_url_helper_web.dart' show getResponseParamFromUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase conditionally (disabled by default)
  await FirebaseService.initialize();

  // Initialize services
  final settingsService = SettingsService();
  await settingsService.loadSettings();

  // Set orientation only for mobile platforms
  if (!kIsWeb) {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nimbbl Flutter SDK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
        useMaterial3: true,
      ),
      // Use onGenerateRoute to handle all routes, including /Response with query parameters
      onGenerateRoute: (settings) {
        // Handle /Response route for redirect mode
        // Check both exact match and path starts with /Response (case-insensitive)
        final routeName = (settings.name ?? '').toLowerCase();
        if (routeName == '/response' || routeName.startsWith('/response')) {
          return MaterialPageRoute(
            builder: (context) => _ResponsePage(),
            settings: settings,
          );
        }
        
        // Also check if we're on web and the actual URL path is /Response
        if (kIsWeb) {
          try {
            final uri = Uri.base;
            final path = uri.path.toLowerCase();
            if (path == '/response' || path.startsWith('/response')) {
              return MaterialPageRoute(
                builder: (context) => _ResponsePage(),
                settings: settings,
              );
            }
          } catch (e) {
            // Silently handle URL path check errors
          }
        }
        
        // Default route (home)
        return MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(),
          settings: settings,
        );
      },
      // Set initial route
      initialRoute: '/',
    );
  }
}

/// Response page handler for redirect mode
/// Matches React Response.tsx implementation
/// Decodes base64 response from URL and displays payment result
class _ResponsePage extends StatefulWidget {
  @override
  State<_ResponsePage> createState() => _ResponsePageState();
}

class _ResponsePageState extends State<_ResponsePage> {
  Map<String, dynamic>? decodedResponse;
  bool _isDecoding = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check URL again when dependencies change (route parameters might be available now)
    if (kIsWeb && decodedResponse == null && !_isDecoding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _decodeResponseFromURL();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Decode immediately
    _decodeResponseFromURL();
    
    // Also set up a listener for URL changes (in case redirect happens after page load)
    if (kIsWeb) {
      // Use multiple retries to ensure we catch the response parameter
      // Sometimes the URL hasn't fully updated when initState is called
      for (int i = 0; i < 5; i++) {
        Future.delayed(Duration(milliseconds: 100 * (i + 1)), () {
          if (mounted && decodedResponse == null && !_isDecoding) {
            _decodeResponseFromURL();
          }
        });
      }
    }
  }

  void _decodeResponseFromURL() {
    if (!kIsWeb || _isDecoding) {
      // Not on web or already decoding
      return;
    }

    _isDecoding = true;

    try {
      // Get URL query parameters using dart:html for more reliable URL access
      // This ensures we get the actual browser URL, not just Flutter's route
      final responseParam = getResponseParamFromUrl();

      if (responseParam != null && responseParam.isNotEmpty) {
        try {
          // Decode base64 (matching React: atob(base64String))
          final decodedString = utf8.decode(base64Decode(responseParam));
          
          // Parse JSON (matching React: JSON.parse(decodedResponse))
          final parsedResponse = jsonDecode(decodedString) as Map<String, dynamic>;
          
          if (mounted) {
            setState(() {
              decodedResponse = parsedResponse;
              _isDecoding = false;
            });

            // Auto-redirect after 5 seconds (matching React: setTimeout redirect)
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                // Navigate to home (matching React: window.open('/', '_self'))
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
                  (route) => false,
                );
              }
            });
          }
        } catch (decodeError) {
          _isDecoding = false;
        }
      } else {
        _isDecoding = false;
        
        // If no response parameter, retry after a short delay
        // This handles the case where the redirect happens but URL hasn't updated yet
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && decodedResponse == null) {
            final retryUri = Uri.base;
            final retryResponseParam = retryUri.queryParameters['response'];
            if (retryResponseParam != null && retryResponseParam.isNotEmpty) {
              _isDecoding = false; // Reset flag before retry
              _decodeResponseFromURL(); // Retry decoding
            }
          }
        });
      }
    } catch (e, stackTrace) {
      _isDecoding = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If we have decoded response, show success screen
    if (decodedResponse != null) {
      return PopScope(
        // Prevent back navigation - redirect to home instead
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop && kIsWeb) {
            // Navigate to home instead of going back
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
              (route) => false,
            );
          }
        },
        child: OrderSuccessScreen(paymentData: decodedResponse),
      );
    }

    // Show loading state while decoding or waiting for response
    return PopScope(
      // Prevent back navigation - redirect to home instead
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop && kIsWeb) {
          // Navigate to home instead of going back
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ResponsiveLayout()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFECF0FD), // Matching React: bg-[#ECF0FD]
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Waiting for payment response...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If this page doesn\'t update, check the browser console for errors.',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



