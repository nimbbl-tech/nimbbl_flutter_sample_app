/// Order Creation Service
/// 
/// This service handles order creation for the example app.
/// 
/// ⚠️ **IMPORTANT**: In production, order creation should be done server-to-server (S2S)
/// by your backend. This client-side implementation is for example/demo purposes only.
/// 
/// For production:
/// 1. Your backend should create orders via S2S API call
/// 2. Backend returns order token to Flutter app
/// 3. Flutter app uses token for checkout
/// 
/// @version 1.0.0
/// @author Nimbbl Tech

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';
import '../models/order_data.dart';
import '../models/settings_data.dart';
import '../shared/constants/app_strings.dart';

/// Service for creating orders via Nimbbl API
/// 
/// **Note**: This is for example app only. Production apps should use S2S order creation.
class OrderCreationService {
  static final OrderCreationService _instance = OrderCreationService._internal();
  factory OrderCreationService() => _instance;
  OrderCreationService._internal();

  /// Create order via Nimbbl create-shop API (matching Android OrderCreateActivity).
  /// 
  /// This method makes a direct HTTP call to Nimbbl create-shop API.
  /// In production, this should be done by your backend (S2S).
  /// 
  /// Returns order token on success, throws exception on failure.
  Future<String> createOrder(
    OrderData orderData,
    SettingsData settingsData,
  ) async {
    // Resolve shop base URL then shop order URL (matching Android resolveShopBaseUrl + resolveShopOrderUrl)
    final shopBaseUrl = resolveShopBaseUrl(settingsData.baseUrl);
    final createOrderUrl = _resolveShopOrderUrl(shopBaseUrl);

    // Build request body matching Android createShopOrderRequest (OrderCreateActivity.kt)
    final productId = _getProductIdForHeader(
      orderData.headerCustomisation,
      orderData.orderLineItems,
      orderData.renderDesktopUi ?? false,
      orderData.addressCodEnabled ?? false,
    );
    final amountInt = int.tryParse(orderData.amount) ?? 0;
    final bodyData = <String, dynamic>{
      'currency': orderData.currency,
      'amount': orderData.amount,
      'product_id': productId,
      'total_amount': amountInt,
      'amount_before_tax': amountInt,
      'tax': 0,
      'additional_charges': 0,
      'grand_total_amount': amountInt,
      'order_line_items': true,
      'checkout_experience': orderData.checkoutExperience ?? 'redirect',
      'payment_mode': _getPaymentModeCode(orderData.paymentCustomisation).isNotEmpty
          ? _getPaymentModeCode(orderData.paymentCustomisation)
          : 'All',
    };
    
    // Add access credentials if provided
    if (settingsData.useAccessCredentials &&
        settingsData.accessKey != null &&
        settingsData.accessKey!.trim().isNotEmpty &&
        settingsData.accessSecret != null &&
        settingsData.accessSecret!.trim().isNotEmpty) {
      bodyData['product_id'] = 0;
      bodyData['merchant'] = {
        'access_key': settingsData.accessKey!.trim(),
        'access_secret': settingsData.accessSecret!.trim(),
      };
    }

    final subPaymentMode = _getSubPaymentModeCode(orderData.subPaymentCustomisation);
    if (subPaymentMode.isNotEmpty) {
      bodyData['sub_payment_mode'] = subPaymentMode;
    }

    // User details (Android: user { email, name, mobile_number })
    if (orderData.userDetails) {
      final trimmedName = orderData.firstName.trim();
      final trimmedNumber = orderData.mobileNumber.trim();
      final trimmedEmail = orderData.email.trim();

      if (trimmedName.isNotEmpty || trimmedNumber.isNotEmpty || trimmedEmail.isNotEmpty) {
        bodyData['user'] = {
          'email': trimmedEmail,
          'name': trimmedName,
          'mobile_number': trimmedNumber,
        };
      }
    }

    // Order line item array (Android: order_line_item)
    bodyData['order_line_item'] = [
      {
        'title': 'Product',
        'description': 'Product description',
        'quantity': 1.toDouble(),
        'rate': amountInt.toDouble(),
        'total_amount': amountInt.toDouble(),
        'amount_before_tax': amountInt.toDouble(),
        'tax': 0,
        'image_url': '',
        'sku_id': productId,
        'uom': 'unit',
      },
    ];

    try {
      // Create Dio instance
      final dio = Dio();
      
      // Make HTTP POST request
      final response = await dio.post(
        createOrderUrl,
        data: bodyData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      ).timeout(const Duration(seconds: 30));

      // Check response status
      if (response.statusCode == 200) {
        // Parse response data
        Map<String, dynamic> responseData;
        if (response.data is String) {
          responseData = jsonDecode(response.data) as Map<String, dynamic>;
        } else {
          responseData = response.data as Map<String, dynamic>;
        }

        // Check for errors in response
        if (responseData['success'] == false) {
          final error = responseData['error'] ?? responseData['message'] ?? 'Unknown error';
          throw Exception('Order creation failed: $error');
        }

        // Extract order token from response
        final orderToken = responseData['token'] as String?;
        
        if (orderToken == null || orderToken.isEmpty) {
          throw Exception('Order token is missing from order creation response');
        }
        
        return orderToken;
      } else {
        throw Exception('Order creation failed: HTTP ${response.statusCode}');
      }
    } on DioException catch (error) {
      if (error.response != null) {
        try {
          Map<String, dynamic> errorData;
          if (error.response!.data is String) {
            errorData = jsonDecode(error.response!.data) as Map<String, dynamic>;
          } else {
            errorData = error.response!.data as Map<String, dynamic>;
          }
          
          final errorMessage = errorData['error'] ?? 
                              errorData['message'] ?? 
                              'Failed to create order';
          throw Exception(errorMessage);
        } catch (e) {
          throw Exception('Order creation failed: ${error.response?.statusCode} - ${error.response?.data}');
        }
      } else {
        throw Exception('Order creation failed: ${error.message ?? 'Network error'}');
      }
    } catch (error) {
      if (error is Exception) {
        rethrow;
      } else {
        throw Exception('Unexpected error: $error');
      }
    }
  }

  /// Format URL (matching Android AppUtilExtensions.formatUrl)
  static String _formatUrl(String url) {
    String formatted = url.trim();
    formatted = formatted.replaceAll('//', '/');
    formatted = formatted.replaceAll('https:/', 'https://');
    formatted = formatted.replaceAll('http:/', 'http://');
    if (!formatted.endsWith('/')) formatted += '/';
    return formatted;
  }

  /// Check if URL is IP-based (matching Android OrderCreateActivity.isIpBasedUrl)
  static bool _isIpBasedUrl(String value) {
    try {
      final normalized = value.startsWith('http://') || value.startsWith('https://')
          ? value
          : 'https://$value';
      final uri = Uri.parse(normalized);
      final host = uri.host;
      final ipV4 = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
      return ipV4.hasMatch(host);
    } catch (_) {
      return false;
    }
  }

  /// Resolve shop base URL (matching Android resolveShopBaseUrl). Exposed for SDK env URL.
  static String resolveShopBaseUrl(String? configuredBaseUrl) {
    final trimmed = (configuredBaseUrl ?? '').trim();
    final baseUrl = trimmed.isEmpty
        ? ApiConstants.nimbblTechUrl
        : _isIpBasedUrl(trimmed)
            ? ApiConstants.baseUrlQA1
            : trimmed;
    final formatted = _formatUrl(baseUrl);
    return formatted.isEmpty ? ApiConstants.nimbblTechUrl : formatted;
  }

  /// Resolve shop order URL from API base URL (matching Android resolveShopOrderUrl)
  String _resolveShopOrderUrl(String apiBaseUrl) {
    try {
      final normalized = _formatUrl(apiBaseUrl);
      final withoutTrailingSlash = normalized.endsWith('/')
          ? normalized.substring(0, normalized.length - 1)
          : normalized;
      if (withoutTrailingSlash.isEmpty) return ApiConstants.shopOrderUrlQA1;
      final uri = Uri.parse(withoutTrailingSlash);
      final host = uri.host;
      if (host.isEmpty) return ApiConstants.shopOrderUrlQA1;
      final shopHost = host.replaceFirst(RegExp('api'), 'sonicshopapi');
      final scheme = uri.scheme;
      return '$scheme://$shopHost/create-shop';
    } catch (_) {
      return ApiConstants.shopOrderUrlQA1;
    }
  }

  /// Get product ID based on header customization
  /// 
  /// For Web (matching React implementation from nimbbl_sonic_shop):
  /// - PRODUCT_LIST[0] = value: '1', label: 'your brand name and brand logo'
  /// - PRODUCT_LIST[1] = value: '2', label: 'your brand logo'
  /// - PRODUCT_LIST[2] = value: '3', label: 'your brand name' (when orderLineItems is false)
  /// - PRODUCT_LIST[3] = value: '4', label: 'your brand name' (when render_desktop_ui is true)
  /// - PRODUCT_LIST[5] = value: '5', label: 'MustBuy' (when addressCodEnabled is true, default)
  /// - PRODUCT_LIST[6] = value: '6', label: 'BallMart' (when addressCodEnabled is true)
  /// - PRODUCT_LIST[7] = value: '7', label: 'TripKart' (when addressCodEnabled is true)
  /// 
  /// For Mobile:
  /// - 'your brand name and brand logo' → '11'
  /// - 'your brand logo' → '12'
  /// - 'your brand name' → '13'
  /// 
  /// Logic from React useEffect (for web):
  /// - If addressCodEnabled is true → PRODUCT_LIST[5] → '5' (default MustBuy), or '6'/'7' based on selection
  /// - If orderLineItems is false → PRODUCT_LIST[2] → '3'
  /// - If render_desktop_ui is true → PRODUCT_LIST[3] → '4'
  /// - If render_desktop_ui is false → PRODUCT_LIST[0] → '1' or PRODUCT_LIST[1] → '2'
  String _getProductIdForHeader(
    String headerCustomisation,
    bool orderLineItems,
    bool renderDesktopUi,
    bool addressCodEnabled,
  ) {
    // Check if running on web
    if (kIsWeb) {
      // Address & COD mode: product IDs 5, 6, 7
      // Should show: MustBuy, BallMart, TripKart (PRODUCT_LIST[5], PRODUCT_LIST[6], PRODUCT_LIST[7])
      if (addressCodEnabled) {
        switch (headerCustomisation) {
          case AppStrings.mustBuy:
            return '5'; // PRODUCT_LIST[5] - default when Address & COD is enabled
          case AppStrings.ballMart:
            return '6'; // PRODUCT_LIST[6]
          case AppStrings.tripKart:
            return '7'; // PRODUCT_LIST[7]
          default:
            return '5'; // Default to PRODUCT_LIST[5] (MustBuy) when Address & COD is enabled
        }
      }

      // Web product IDs: 1, 2, 3, 4
      // If orderLineItems is false, always return '3' (PRODUCT_LIST[2])
      if (!orderLineItems) {
        return '3';
      }

      // If render_desktop_ui is true, return '4' (PRODUCT_LIST[3])
      if (renderDesktopUi) {
        return '4';
      }

      // Default case: render_desktop_ui is false
      // Map headerCustomisation to product_id
      switch (headerCustomisation) {
        case AppStrings.brandNameAndLogo:
          return '1'; // PRODUCT_LIST[0]
        case AppStrings.brandLogo:
          return '2'; // PRODUCT_LIST[1]
        case AppStrings.brandName:
          // This shouldn't happen when orderLineItems is true and render_desktop_ui is false
          // But if it does, default to '1'
          return '1';
        default:
          return '1'; // Default to PRODUCT_LIST[0]
      }
    } else {
      // Mobile: Address & COD mode uses same product IDs as web (5, 6, 7)
      // Should show: MustBuy, BallMart, TripKart (PRODUCT_LIST[5], PRODUCT_LIST[6], PRODUCT_LIST[7])
      if (addressCodEnabled) {
        switch (headerCustomisation) {
          case AppStrings.mustBuy:
            return '5'; // PRODUCT_LIST[5] - default when Address & COD is enabled
          case AppStrings.ballMart:
            return '6'; // PRODUCT_LIST[6]
          case AppStrings.tripKart:
            return '7'; // PRODUCT_LIST[7]
          default:
            return '5'; // Default to PRODUCT_LIST[5] (MustBuy) when Address & COD is enabled
        }
      }
      
      // Mobile product IDs: 11, 12, 13 for standard headers
      switch (headerCustomisation) {
        case AppStrings.brandNameAndLogo:
          return '1';
        case AppStrings.brandLogo:
          return '2';
        case AppStrings.brandName:
          return '3';
        default:
          return '1'; // Default to 'your brand name and brand logo'
      }
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
}
