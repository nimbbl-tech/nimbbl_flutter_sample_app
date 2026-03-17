/// API configuration constants - Matching Android sample app ApiConstants.kt exactly
class ApiConstants {
  // Production URL (Android: NIMBBL_TECH_URL)
  static const String nimbblTechUrl = 'https://api.nimbbl.tech/';

  // Pre-Production URL (Android: BASE_URL_PRE_PROD)
  static const String baseUrlPreProd = 'https://apipp.nimbbl.tech/';

  // QA1 URL - Default QA environment (Android: BASE_URL_QA1)
  static const String baseUrlQA1 = 'https://qa1api.qa.nimbbl.tech/';

  // Shop order endpoints (Android: SHOP_ORDER_URL_*)
  static const String shopOrderUrlQA1 = 'https://qa1sonicshopapi.qa.nimbbl.tech/create-shop';
  static const String shopOrderUrlProd = 'https://sonicshopapi.nimbbl.tech/create-shop';
  static const String shopOrderUrlPreProd = 'https://sonicshopapipp.nimbbl.tech/create-shop';

  // Legacy / convenience (matching Android app)
  static const String baseUrlProd = nimbblTechUrl;
  static const String baseUrlQA4 = 'https://qa4api.qa.nimbbl.tech/';

  // Default values
  static const String defaultEnvironment = nimbblTechUrl;
  static const String defaultQaUrl = baseUrlQA4;
}
