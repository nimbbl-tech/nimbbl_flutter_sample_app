// STUB FILE: Use this if you delete firebase_options.dart
// Copy this file to firebase_options.dart if Firebase is disabled
// This allows the app to compile without Firebase configuration

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Stub [FirebaseOptions] for use when Firebase is disabled
/// This file allows the app to compile without Firebase configuration
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // This will never be called if Firebase is disabled in AppConstants
    // But we need it for compilation
    throw UnsupportedError(
      'Firebase is not configured. '
      'Please set enableFirebaseCrashlytics or enableFirebaseAnalytics to false in AppConstants, '
      'or configure Firebase properly.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'stub',
    appId: 'stub',
    messagingSenderId: 'stub',
    projectId: 'stub',
    storageBucket: 'stub',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'stub',
    appId: 'stub',
    messagingSenderId: 'stub',
    projectId: 'stub',
    storageBucket: 'stub',
    iosBundleId: 'stub',
  );
}

