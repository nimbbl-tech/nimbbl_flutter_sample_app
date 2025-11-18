import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// Import firebase_options_stub.dart (stub file for when Firebase is disabled)
// This is required for compilation, but won't be used if Firebase is disabled in AppConstants
// The stub file will throw an error if accessed, but since Firebase is disabled, it will never be accessed
import '../../firebase_options_stub.dart';
import '../constants/app_constants.dart';

/// Service for managing Firebase initialization and configuration
/// Firebase is disabled by default and can be enabled via AppConstants
class FirebaseService {
  static FirebaseAnalytics? _analytics;
  static bool _isInitialized = false;

  /// Get Firebase Analytics instance (null if not enabled)
  static FirebaseAnalytics? get analytics => _analytics;

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Firebase services based on configuration
  /// Returns true if initialization was successful, false otherwise
  static Future<bool> initialize() async {
    // If Firebase is not enabled, skip initialization
    if (!AppConstants.enableFirebaseCrashlytics && !AppConstants.enableFirebaseAnalytics) {
      debugPrint('Firebase is disabled. Skipping initialization.');
      return false;
    }

    try {
      // Check if Firebase options are available
      FirebaseOptions? firebaseOptions;
      try {
        firebaseOptions = DefaultFirebaseOptions.currentPlatform;
      } catch (e) {
        debugPrint('Firebase options not available: $e');
        debugPrint('Please configure Firebase or disable it in AppConstants.');
        return false;
      }

      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: firebaseOptions,
      );

      // Initialize Crashlytics if enabled
      if (AppConstants.enableFirebaseCrashlytics) {
        // Store the original FlutterError.onError handler
        final originalOnError = FlutterError.onError;
        
        // Set up FlutterError.onError to report to Crashlytics
        FlutterError.onError = (errorDetails) {
          // Report to Crashlytics
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
          // Call original handler if it exists
          originalOnError?.call(errorDetails);
        };
        
        // Store the original PlatformDispatcher error handler
        final originalPlatformError = PlatformDispatcher.instance.onError;
        
        // Pass all uncaught asynchronous errors to Crashlytics
        PlatformDispatcher.instance.onError = (error, stack) {
          // Report to Crashlytics
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          // Call original handler if it exists
          if (originalPlatformError != null) {
            return originalPlatformError(error, stack);
          }
          return true;
        };

        // Set user identifier for better crash tracking (optional)
        // FirebaseCrashlytics.instance.setUserIdentifier('user_id_here');

        debugPrint('✅ Firebase Crashlytics initialized successfully.');
        debugPrint('📊 Crashlytics is ready to collect crash reports.');
        
        // Note: In debug mode, Crashlytics may not send reports immediately
        // Reports are typically sent when the app restarts or when sendUnsentReports() is called
        if (kDebugMode) {
          debugPrint('⚠️  Note: In debug mode, crash reports may be delayed.');
          debugPrint('💡 Use sendUnsentReports() to force send reports immediately.');
        }
      }

      // Initialize Analytics if enabled
      if (AppConstants.enableFirebaseAnalytics) {
        _analytics = FirebaseAnalytics.instance;
        debugPrint('Firebase Analytics initialized successfully.');
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
      debugPrint('App will continue to run without Firebase services.');
      return false;
    }
  }

  /// Log a non-fatal error to Crashlytics (if enabled)
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (AppConstants.enableFirebaseCrashlytics && _isInitialized) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          exception,
          stackTrace,
          reason: reason,
          fatal: fatal,
        );
        debugPrint('Error recorded to Crashlytics: $exception');
      } catch (e) {
        debugPrint('Failed to record error to Crashlytics: $e');
      }
    }
  }

  /// Force a test crash for testing Crashlytics
  /// This will crash the app and should appear in Firebase Crashlytics
  static void testCrash() {
    if (AppConstants.enableFirebaseCrashlytics && _isInitialized) {
      FirebaseCrashlytics.instance.crash();
    } else {
      throw Exception('Firebase Crashlytics is not enabled or initialized');
    }
  }

  /// Send pending crash reports immediately (useful for testing)
  static Future<void> sendUnsentReports() async {
    if (AppConstants.enableFirebaseCrashlytics && _isInitialized) {
      try {
        await FirebaseCrashlytics.instance.sendUnsentReports();
        debugPrint('Pending crash reports sent to Crashlytics');
      } catch (e) {
        debugPrint('Failed to send pending reports: $e');
      }
    }
  }

  /// Log a message to Crashlytics (if enabled)
  static Future<void> log(String message) async {
    if (AppConstants.enableFirebaseCrashlytics && _isInitialized) {
      try {
        await FirebaseCrashlytics.instance.log(message);
      } catch (e) {
        debugPrint('Failed to log to Crashlytics: $e');
      }
    }
  }

  /// Log an event to Analytics (if enabled)
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (AppConstants.enableFirebaseAnalytics && _isInitialized && _analytics != null) {
      try {
        await _analytics!.logEvent(
          name: name,
          parameters: parameters,
        );
      } catch (e) {
        debugPrint('Failed to log event to Analytics: $e');
      }
    }
  }
}

