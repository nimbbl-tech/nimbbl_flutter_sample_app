/// API configuration constants - Matching Android app exactly
class ApiConstants {
  // Base URLs (matching Android sample app exactly)
  static const String baseUrlProd = 'https://api.nimbbl.tech/';
  static const String baseUrlPreProd = 'https://apipp.nimbbl.tech/';
  static const String baseUrlQA1 = 'https://qa1api.nimbbl.tech/';
  static const String baseUrlQA4 = 'https://qa4api.nimbbl.tech/';
  
  // Default values (matching Android app exactly)
  static const String defaultEnvironment = baseUrlProd;
  static const String defaultQaUrl = baseUrlQA4;
}
