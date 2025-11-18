import 'package:flutter/foundation.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_sdk.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/types.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
// SDKConfig is in types.dart, imported above

import '../models/order_data.dart';
import '../models/settings_data.dart';
import '../shared/utils/validation_utils.dart';

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
      debugPrint('SDK initialization failed: $e');
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

      // Extract order parameters
      final currency = orderData.currency;
      final amount = orderData.amount.toString();
      final productId = _getProductIdForHeader(orderData.headerCustomisation);
      final orderLineItems = orderData.orderLineItems;
      final checkoutExperience = AppConstants.defaultCheckoutExperience;
      final paymentMode = _getPaymentModeCode(orderData.paymentCustomisation);
      final subPaymentMode = _getSubPaymentModeCode(orderData.subPaymentCustomisation);

      // Build user object (always include, empty if no user details)
      Map<String, dynamic> user = {};
      if (orderData.userDetails) {
        final trimmedName = orderData.firstName.trim();
        final trimmedNumber = orderData.mobileNumber.trim();
        final trimmedEmail = orderData.email.trim();

        if (trimmedName.isNotEmpty || trimmedNumber.isNotEmpty || trimmedEmail.isNotEmpty) {
          user = {
            'email': trimmedEmail,
            'name': trimmedName,
            'mobile_number': trimmedNumber
          };
        }
      }

      // Create order using Nimbbl SDK
      final orderParams = CreateOrderParams(
        currency: currency,
        amount: amount,
        productId: productId,
        orderLineItems: orderLineItems,
        checkoutExperience: checkoutExperience,
        paymentMode: paymentMode,
        subPaymentMode: subPaymentMode,
        user: user,
      );

      final orderResult = await _nimbblSDK.createShopOrder(orderParams);

      // Handle order creation result
      if (orderResult['success'] == false) {
        final error = orderResult['error'];
        String errorMessage = 'Failed to create order';
        
        if (error != null) {
          final errorString = error.toString();
          if (errorString.contains('PlatformException')) {
            final match = RegExp(r'PlatformException\([^,]+,\s*([^,]+)').firstMatch(errorString);
            if (match != null && match.group(1) != null) {
              String rawMessage = match.group(1)!.trim();
              if (rawMessage.contains('okhttp3.ResponseBody')) {
                errorMessage = 'Order creation failed';
              } else {
                errorMessage = rawMessage;
              }
            }
          } else {
            errorMessage = errorString;
          }
        }
        
        throw Exception(errorMessage);
      }

      // Extract order token from response
      final orderResponseData = orderResult['data'] as Map<String, dynamic>?;
      
      // Check if the response data itself indicates failure (nested error structure)
      if (orderResponseData != null && orderResponseData['success'] == false) {
        final error = orderResponseData['error'];
        String errorMessage = 'Order creation failed';
        
        if (error != null) {
          final errorString = error.toString();
          // Handle iOS error format: "The operation couldn't be completed. (Order error error 0.)"
          if (errorString.contains('Order error')) {
            errorMessage = 'Order creation failed: $errorString';
          } else {
            errorMessage = errorString;
          }
        }
        
        throw Exception(errorMessage);
      }
      
      // Try to extract token from different possible locations
      String? orderToken;
      if (orderResponseData != null) {
        // Try 'token' first (expected structure)
        orderToken = orderResponseData['token'] as String?;
        
        // If not found, try other possible keys
        if (orderToken == null || orderToken.isEmpty) {
          orderToken = orderResponseData['orderToken'] as String?;
        }
        if (orderToken == null || orderToken.isEmpty) {
          orderToken = orderResponseData['order_token'] as String?;
        }
      }
      
      // If still not found, check if the response itself is the token
      if ((orderToken == null || orderToken.isEmpty) && orderResult['data'] is String) {
        orderToken = orderResult['data'] as String?;
      }
      
      if (orderToken == null || orderToken.isEmpty) {
        throw Exception('Order token is missing from order creation response');
      }
      
      // Create checkout options
      final checkoutOptions = CheckoutOptions(
        orderToken: orderToken,
        paymentModeCode: paymentMode,
        bankCode: _getBankCode(orderData.subPaymentCustomisation),
        walletCode: _getWalletCode(orderData.subPaymentCustomisation),
        paymentFlow: _getPaymentFlow(orderData.subPaymentCustomisation, paymentMode),
      );

      // Process payment using checkout method
      final checkoutResult = await _nimbblSDK.checkout(checkoutOptions);

      // Return the checkout result directly
      return checkoutResult;

    } catch (e) {
      debugPrint('Payment processing failed: $e');
      rethrow;
    }
  }

  /// Get product ID based on header customization
  String _getProductIdForHeader(String headerCustomisation) {
    switch (headerCustomisation) {
      case 'your brand name and brand logo':
        return '11';
      case 'your brand logo':
        return '12';
      case 'your brand name':
        return '13';
      default:
        return '11';
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

  /// Get sub payment mode code
  String _getSubPaymentModeCode(String subPaymentCustomisation) {
    return subPaymentCustomisation;
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