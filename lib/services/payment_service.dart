import 'package:flutter/foundation.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_sdk.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/types.dart';

import '../core/constants/api_constants.dart';
// SDKConfig is in types.dart, imported above

import '../models/order_data.dart';
import '../models/settings_data.dart';
import '../shared/utils/validation_utils.dart';
import 'order_creation_service.dart';

/// Simplified Payment Service - Merchant-friendly integration
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  late NimbblCheckoutSDK _nimbblSDK;
  bool _isInitialized = false;
  String? _lastInitializedBaseUrl; // Track the last baseUrl used for initialization

  /// Initialize the SDK instance
  void _initializeSDKInstance() {
    _nimbblSDK = NimbblCheckoutSDK.instance;
  }

  /// Initialize SDK with configuration
  Future<void> initialize([SettingsData? settingsData]) async {
    _initializeSDKInstance();

    try {
      // Build configuration with API base URL if provided
      final apiBaseUrl = settingsData != null ? _getApiBaseUrl(settingsData) : null;
      final config = SDKConfig(apiBaseUrl: apiBaseUrl);
      
      // Actually initialize the SDK
      await _nimbblSDK.initialize(config);
      
      _isInitialized = true;
      _lastInitializedBaseUrl = apiBaseUrl; // Store the baseUrl used for initialization
    } catch (e) {
      rethrow;
    }
  }

  /// Get API base URL based on environment - Matching Android app approach
  String _getApiBaseUrl(SettingsData? settingsData) {
    if (settingsData == null) return ApiConstants.defaultEnvironment;
    
    // Use the single baseUrl field like Android app
    return settingsData.baseUrl;
  }

  /// Process payment - Simplified merchant integration
  Future<Map<String, dynamic>> processPayment(
    OrderData orderData,
    SettingsData settingsData,
  ) async {
    try {
      // Get the current baseUrl from settings
      final currentBaseUrl = _getApiBaseUrl(settingsData);
      
      // Re-initialize SDK if not initialized or if baseUrl has changed
      if (!_isInitialized || _lastInitializedBaseUrl != currentBaseUrl) {
        await initialize(settingsData);
      }

      // Validate order data
      final validation = ValidationUtils.validateOrderData(orderData);
      if (!validation['isValid']) {
        throw Exception(validation['errorMessage']);
      }

      // Create order using OrderCreationService for all platforms
      // Note: In production, this should be done server-to-server (S2S) by your backend
      final orderCreationService = OrderCreationService();
      final orderToken = await orderCreationService.createOrder(orderData, settingsData);

      // Extract payment mode for checkout options
      final paymentMode = _getPaymentModeCode(orderData.paymentCustomisation);

      
      // Create checkout options
      final checkoutOptions = CheckoutOptions(
        orderToken: orderToken,
        paymentModeCode: paymentMode,
        bankCode: _getBankCode(orderData.subPaymentCustomisation),
        walletCode: _getWalletCode(orderData.subPaymentCustomisation),
        paymentFlow: _getPaymentFlow(orderData.subPaymentCustomisation, paymentMode),
        checkoutExperience: orderData.checkoutExperience, // Pass checkout experience
      );

      // Process payment using checkout method
      final checkoutResult = await _nimbblSDK.checkout(checkoutOptions);

      // Return the checkout result directly
      return checkoutResult;

    } catch (e) {
      rethrow;
    }
  }

  /// Get payment mode code
  String _getPaymentModeCode(String paymentCustomisation) {
    switch (paymentCustomisation) {
      case 'netbanking':
        return 'Netbanking';
      case 'wallet':
        return 'Wallet';
      case 'card':
        return 'card';
      case 'upi':
        return 'UPI';
      default:
        return '';
    }
  }

  /// Get bank code
  String _getBankCode(String subPaymentCustomisation) {
    switch (subPaymentCustomisation.toLowerCase()) {
      case 'hdfc bank':
        return 'hdfc';
      case 'sbi bank':
        return 'sbi';
      case 'kotak bank':
        return 'kotak';
      default:
        return '';
    }
  }

  /// Get wallet code
  String _getWalletCode(String subPaymentCustomisation) {
    switch (subPaymentCustomisation.toLowerCase()) {
      case 'phonepe':
        return 'phonepe';
      case 'paytm':
        return 'paytm';
      case 'freecharge':
        return 'freecharge';
      case 'jiomoney':
        return 'jiomoney';
      default:
        return '';
    }
  }

  /// Get payment flow
  String _getPaymentFlow(String subPaymentCustomisation, String paymentMode) {
    if (paymentMode == 'UPI' && subPaymentCustomisation.isNotEmpty) {
      return 'intent';
    }
    return 'redirect';
  }
}