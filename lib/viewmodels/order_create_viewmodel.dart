import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/order_data.dart';
import '../services/payment_service.dart';
import '../services/settings_service.dart';
import '../shared/constants/app_strings.dart';
import '../shared/constants/order_create_data_values.dart';
import '../shared/utils/validation_utils.dart';

/// ViewModel for order creation screen
/// Handles all business logic and state management
/// Used by both mobile and web screens
class OrderCreateViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();
  final SettingsService _settingsService = SettingsService();

  // Text Controllers
  late TextEditingController amountController;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  // Order Data
  OrderData _orderData = OrderData(
    amount: AppConstants.defaultAmount,
    currency: AppConstants.defaultCurrency,
    orderLineItems: true,
    headerCustomisation: headerCustomTypeEnabledList.first.name,
    paymentCustomisation: AppConstants.defaultPaymentMode,
    subPaymentCustomisation: AppConstants.defaultSubPaymentMode,
    userDetails: false,
    firstName: '',
    mobileNumber: '',
    email: '',
    checkoutExperience: AppStrings.checkoutExperienceRedirect,
  );

  // UI State
  bool _isPaymentLoading = false;
  String? _paymentError;
  Map<String, dynamic>? _checkoutResult;
  String _selectedCurrency = AppConstants.defaultCurrency;
  bool _orderLineItems = true;
  bool _enableAddressCod = false;
  bool _userDetails = false;
  bool _renderDesktopUi = false;
  String _checkoutExperience = AppStrings.checkoutExperienceRedirect;

  // Validation state
  String? _numberError;
  String? _emailError;

  // Getters
  OrderData get orderData => _orderData;
  bool get isPaymentLoading => _isPaymentLoading;
  String? get paymentError => _paymentError;
  Map<String, dynamic>? get checkoutResult => _checkoutResult;
  String get selectedCurrency => _selectedCurrency;
  bool get orderLineItems => _orderLineItems;
  bool get enableAddressCod => _enableAddressCod;
  bool get userDetails => _userDetails;
  bool get renderDesktopUi => _renderDesktopUi;
  String get checkoutExperience => _checkoutExperience;
  String? get numberError => _numberError;
  String? get emailError => _emailError;

  /// Initialize the viewmodel
  Future<void> initialize({String? defaultAmount, String? defaultCheckoutExperience}) async {
    await _settingsService.loadSettings();
    await _paymentService.initialize(_settingsService.settingsData);

    if (defaultAmount != null) {
      _orderData = _orderData.copyWith(amount: defaultAmount);
      amountController = TextEditingController(text: defaultAmount);
    } else {
      amountController = TextEditingController(text: _orderData.amount);
    }

    if (defaultCheckoutExperience != null) {
      _checkoutExperience = defaultCheckoutExperience;
      _orderData = _orderData.copyWith(checkoutExperience: defaultCheckoutExperience);
    }

    _initializeOrderData();
    notifyListeners();
  }

  void _initializeOrderData() {
    final headerOptions = _orderData.orderLineItems ? headerCustomTypeEnabledList : headerCustomTypeDisabledList;
    final defaultHeaderCustomisation = headerOptions.isNotEmpty ? headerOptions.first.name : '';

    _orderData = _orderData.copyWith(
      headerCustomisation: defaultHeaderCustomisation,
    );
  }

  /// Update order field
  void updateOrderField({
    String? amount,
    String? currency,
    bool? orderLineItems,
    String? headerCustomisation,
    String? paymentCustomisation,
    String? subPaymentCustomisation,
    bool? userDetails,
    String? firstName,
    String? mobileNumber,
    String? email,
  }) {
    _orderData = _orderData.copyWith(
      amount: amount,
      currency: currency,
      orderLineItems: orderLineItems,
      headerCustomisation: headerCustomisation,
      paymentCustomisation: paymentCustomisation,
      subPaymentCustomisation: subPaymentCustomisation,
      userDetails: userDetails,
      firstName: firstName,
      mobileNumber: mobileNumber,
      email: email,
    );
    if (amount != null && amountController.text != amount) {
      amountController.text = amount;
    }
    notifyListeners();
  }

  /// Handle payment type change
  void handlePaymentTypeChange(String paymentType) {
    String defaultSubPayment = '';
    if (paymentType == 'netbanking') {
      defaultSubPayment = AppStrings.allBanks;
    } else if (paymentType == 'wallet') {
      defaultSubPayment = AppStrings.allWallets;
    } else if (paymentType == 'upi') {
      defaultSubPayment = AppStrings.collectIntent;
    }

    updateOrderField(
      paymentCustomisation: paymentType,
      subPaymentCustomisation: defaultSubPayment,
    );
  }

  /// Handle order line items change
  void handleOrderLineItemsChange(bool value) {
    _orderLineItems = value;
    _orderData = _orderData.copyWith(orderLineItems: value);

    // Update header customisation to a valid value when orderLineItems changes
    // - If orderLineItems is false → "your brand name"
    // - If orderLineItems is true and render_desktop_ui is false → "your brand name and brand logo"
    // - If orderLineItems is true and render_desktop_ui is true → "your brand name"
    if (!value) {
      _orderData = _orderData.copyWith(headerCustomisation: AppStrings.brandName);
    } else if (!_renderDesktopUi) {
      _orderData = _orderData.copyWith(headerCustomisation: AppStrings.brandNameAndLogo);
    } else {
      _orderData = _orderData.copyWith(headerCustomisation: AppStrings.brandName);
    }
    notifyListeners();
  }

  /// Handle currency change
  void handleCurrencyChange(String currency) {
    _selectedCurrency = currency;
    _orderData = _orderData.copyWith(currency: currency);

    // If currency is not INR, automatically set payment mode to 'card'
    if (currency != 'INR') {
      _orderData = _orderData.copyWith(
        paymentCustomisation: 'card',
        subPaymentCustomisation: '',
      );
    }
    notifyListeners();
  }

  /// Validate mobile number
  void validateMobileNumber(String value) {
    // Only allow numeric input and remove leading zeros
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    final cleanedValue = digitsOnly.replaceFirst(RegExp(r'^0+'), '');

    // Validate: exactly 10 digits
    String? error;
    if (cleanedValue.isNotEmpty) {
      if (cleanedValue.length != 10) {
        error = 'Invalid Number';
      } else {
        error = null;
      }
    }

    mobileController.value = TextEditingValue(
      text: cleanedValue,
      selection: TextSelection.collapsed(offset: cleanedValue.length),
    );
    _orderData = _orderData.copyWith(mobileNumber: cleanedValue);
    _numberError = error;
    notifyListeners();
  }

  /// Validate email
  void validateEmail(String value) {
    // Validate email format
    final emailRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    String? error;
    if (value.isNotEmpty) {
      if (!emailRegex.hasMatch(value)) {
        error = 'Invalid Email';
      } else {
        error = null;
      }
    } else {
      error = null;
    }

    _orderData = _orderData.copyWith(email: value);
    _emailError = error;
    notifyListeners();
  }

  /// Update first name
  void updateFirstName(String value) {
    _orderData = _orderData.copyWith(firstName: value);
    notifyListeners();
  }

  /// Toggle order line items
  void toggleOrderLineItems(bool value) {
    handleOrderLineItemsChange(value);
  }

  /// Toggle address COD
  void toggleAddressCod(bool value) {
    _enableAddressCod = value;
    _orderData = _orderData.copyWith(addressCodEnabled: value);

    // When Address & COD is enabled, set default headerCustomisation to 'MustBuy'
    if (value) {
      final isValidForAddressCod = _orderData.headerCustomisation == AppStrings.mustBuy ||
          _orderData.headerCustomisation == AppStrings.ballMart ||
          _orderData.headerCustomisation == AppStrings.tripKart;

      if (!isValidForAddressCod) {
        _orderData = _orderData.copyWith(headerCustomisation: AppStrings.mustBuy);
      }
    }
    notifyListeners();
  }

  /// Toggle user details
  void toggleUserDetails(bool value) {
    _userDetails = value;
    _orderData = _orderData.copyWith(userDetails: value);
    notifyListeners();
  }

  /// Toggle render desktop UI (view mode)
  void toggleRenderDesktopUi(bool value) {
    _renderDesktopUi = value;
    _orderData = _orderData.copyWith(renderDesktopUi: value);

    // Update header customisation based on renderDesktopUi
    if (_orderLineItems) {
      if (!value) {
        _orderData = _orderData.copyWith(headerCustomisation: AppStrings.brandNameAndLogo);
      } else {
        _orderData = _orderData.copyWith(headerCustomisation: AppStrings.brandName);
      }
    }
    notifyListeners();
  }

  /// Update checkout experience
  void updateCheckoutExperience(String value) {
    _checkoutExperience = value;
    _orderData = _orderData.copyWith(checkoutExperience: value);
    notifyListeners();
  }

  /// Update header customisation
  void updateHeaderCustomisation(String value) {
    _orderData = _orderData.copyWith(headerCustomisation: value);
    notifyListeners();
  }

  /// Update sub payment customisation
  void updateSubPaymentCustomisation(String value) {
    _orderData = _orderData.copyWith(subPaymentCustomisation: value);
    notifyListeners();
  }

  /// Process payment
  Future<Map<String, dynamic>?> processPayment() async {
    if (_isPaymentLoading) return null;

    _isPaymentLoading = true;
    _paymentError = null;
    notifyListeners();

    try {
      // Update order data with current values
      final updatedOrderData = _orderData.copyWith(
        amount: amountController.text,
        currency: _selectedCurrency,
        orderLineItems: _orderLineItems,
        userDetails: _userDetails,
        firstName: firstNameController.text,
        email: emailController.text,
        mobileNumber: mobileController.text,
        checkoutExperience: _checkoutExperience,
        renderDesktopUi: _renderDesktopUi,
        addressCodEnabled: _enableAddressCod,
      );

      // Validate order data
      final validation = ValidationUtils.validateOrderData(updatedOrderData);
      if (!validation['isValid']) {
        throw Exception(validation['errorMessage']);
      }

      final checkoutResult = await _paymentService.processPayment(
        updatedOrderData,
        _settingsService.settingsData,
      );

      // Check if this is an order creation failure
      if (checkoutResult.containsKey('success') && checkoutResult['success'] == false) {
        // This is an order creation failure - don't navigate to result screen
        _paymentError = checkoutResult['errorMessage'] ?? 'Failed to create order';
        _isPaymentLoading = false;
        notifyListeners();
        return null;
      }

      // Check if this is an intermediate status (checkout opening/starting) - don't navigate yet
      // These statuses indicate the checkout is opening, not that payment is complete
      final status = checkoutResult['status'] as String?;
      if (status != null) {
        final intermediateStatuses = [
          'checkout_started',
          'checkout_opened',
          'redirect', // For web redirect mode, this means redirecting, not completed
        ];
        
        if (intermediateStatuses.contains(status)) {
          // This is an intermediate status - checkout is opening, wait for actual result
          // For redirect mode on web, this is expected - don't navigate (redirect will handle it)
          // For mobile, the checkout webview is opening - wait for completion
          _isPaymentLoading = false;
          notifyListeners();
          return null; // Don't navigate yet, wait for actual payment result
        }
      }

      // Check if this is a final payment result
      // Final statuses are: 'success', 'failed', 'cancelled', 'error'
      // If status is null or not in intermediate list, it might be a final result
      // But we should also check if it has payment data (transaction, order, etc.)
      final hasPaymentData = checkoutResult.containsKey('transaction') || 
                            checkoutResult.containsKey('order') ||
                            checkoutResult.containsKey('payload');
      
      // Only return result if it's a final payment status or has payment data
      // This ensures we don't navigate on intermediate statuses
      if (status == null || hasPaymentData || 
          ['success', 'failed', 'cancelled', 'error'].contains(status)) {
        // This is an actual payment result
        _checkoutResult = checkoutResult;
        _isPaymentLoading = false;
        notifyListeners();
        return checkoutResult;
      }

      // Unknown status - don't navigate, just stop loading
      _isPaymentLoading = false;
      notifyListeners();
      return null;
    } catch (error) {
      _paymentError = 'An unexpected error occurred during payment';
      _isPaymentLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Clear checkout result
  void clearCheckoutResult() {
    _checkoutResult = null;
    notifyListeners();
  }

  /// Get header indicator color
  Color getHeaderIndicatorColor(String optionName) {
    switch (optionName) {
      case AppStrings.brandNameAndLogo:
        return const Color(0xFF022860); // Dark Blue
      case AppStrings.brandLogo:
        return const Color(0xFF3E6F96); // Light Blue
      case AppStrings.brandName:
        return const Color(0xFFFB381D); // Red/Orange
      case AppStrings.mustBuy:
        return const Color(0xFF022860); // Default to Dark Blue for merchant options
      case AppStrings.ballMart:
        return const Color(0xFF022860); // Default to Dark Blue for merchant options
      case AppStrings.tripKart:
        return const Color(0xFF022860); // Default to Dark Blue for merchant options
      default:
        return const Color(0xFF022860); // Default to Dark Blue
    }
  }

  /// Check if should show sub payment
  bool shouldShowSubPayment(String paymentType) {
    return paymentType == 'netbanking' || paymentType == 'wallet' || paymentType == 'upi';
  }

  /// Check if pay button should be enabled
  bool isPayButtonEnabled() {
    if (_isPaymentLoading) return false;
    if (_userDetails) {
      if (_numberError != null || _emailError != null ||
          mobileController.text.isEmpty || emailController.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    amountController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }
}

