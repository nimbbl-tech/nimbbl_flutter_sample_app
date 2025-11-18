import '../../models/order_data.dart';

/// Validation utilities for form inputs
class ValidationUtils {
  /// Validate order data for payment processing
  static Map<String, dynamic> validateOrderData(OrderData orderData) {
    // Check if amount is provided and valid
    if (orderData.amount.isEmpty) {
      return {
        'isValid': false,
        'errorMessage': 'Amount is required',
      };
    }

    // Check if amount is a valid number
    final amountValue = double.tryParse(orderData.amount);
    if (amountValue == null || amountValue <= 0) {
      return {
        'isValid': false,
        'errorMessage': 'Please enter a valid amount',
      };
    }

    // Check if currency is provided
    if (orderData.currency.isEmpty) {
      return {
        'isValid': false,
        'errorMessage': 'Currency is required',
      };
    }

    // If user details are enabled, validate required fields
    if (orderData.userDetails) {
      if (orderData.firstName.trim().isEmpty) {
        return {
          'isValid': false,
          'errorMessage': 'First name is required when user details are enabled',
        };
      }

      if (orderData.mobileNumber.trim().isEmpty) {
        return {
          'isValid': false,
          'errorMessage': 'Mobile number is required when user details are enabled',
        };
      }

      if (orderData.email.trim().isEmpty) {
        return {
          'isValid': false,
          'errorMessage': 'Email is required when user details are enabled',
        };
      }

      // Validate email format
      if (!_isValidEmail(orderData.email.trim())) {
        return {
          'isValid': false,
          'errorMessage': 'Please enter a valid email address',
        };
      }

      // Validate mobile number format (basic validation)
      if (!_isValidMobileNumber(orderData.mobileNumber.trim())) {
        return {
          'isValid': false,
          'errorMessage': 'Please enter a valid mobile number',
        };
      }
    }

    return {
      'isValid': true,
      'errorMessage': null,
    };
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate mobile number format (basic validation for Indian numbers)
  static bool _isValidMobileNumber(String mobileNumber) {
    // Remove any non-digit characters
    final digitsOnly = mobileNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Indian mobile number (10 digits starting with 6-9)
    if (digitsOnly.length == 10) {
      return RegExp(r'^[6-9]\d{9}$').hasMatch(digitsOnly);
    }
    
    // Check if it's a valid Indian mobile number with country code (12 digits starting with 91)
    if (digitsOnly.length == 12) {
      return RegExp(r'^91[6-9]\d{9}$').hasMatch(digitsOnly);
    }
    
    // Allow 9-digit numbers for testing (less strict validation)
    if (digitsOnly.length == 9) {
      return RegExp(r'^[6-9]\d{8}$').hasMatch(digitsOnly);
    }
    
    return false;
  }

}
