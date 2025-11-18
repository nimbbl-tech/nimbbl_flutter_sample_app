/// Core application constants - Matching Android app exactly
class AppConstants {
  // API Configuration
  static const String defaultEnvironment = 'Prod';
  static const String defaultExperience = 'Webview';
  
  // Payment Configuration
  static const String defaultAmount = '4';
  static const String defaultCurrency = 'INR';
  static const String defaultCheckoutExperience = 'redirect';
  static const String defaultPaymentMode = 'all payments modes';
  static const String defaultSubPaymentMode = '';
  
  // Environment Values - Matching Android app exactly
  static const String environmentQA = 'QA';
  static const String environmentPreProd = 'Pre-Prod';
  static const String environmentProd = 'Prod';
  
  // Experience Values - Matching Android app exactly
  static const String experienceNative = 'Native';
  static const String experienceWebView = 'Webview';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double buttonHeight = 56.0;
  static const double inputFieldHeight = 40.0;
  
  // Storage Keys - Matching Android app exactly
  static const String appPreference = 'app_configs_prefs';
  static const String sampleAppModeKey = 'sample_app_mode';
  static const String shopBaseUrlKey = 'shop_base_url';
  static const String qaEnvironmentUrlKey = 'qa_environment_url';
  
  // Firebase Configuration
  static const bool enableFirebaseCrashlytics = false; // Set to true to enable Firebase Crashlytics
  static const bool enableFirebaseAnalytics = false; // Set to true to enable Firebase Analytics
}
