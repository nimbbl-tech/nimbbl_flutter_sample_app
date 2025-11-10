import 'package:flutter/material.dart';
import '../../domain/models/order_data.dart';
import '../../domain/models/payment_result_data.dart';
import '../../../payment/domain/services/payment_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../../shared/widgets/order_create_data_values.dart';
import '../../../../core/constants/app_constants.dart';

/// Provider for managing order-related state
class OrderProvider extends ChangeNotifier {
  final PaymentService _paymentService;
  final SettingsProvider _settingsProvider;

  OrderProvider(this._paymentService, this._settingsProvider) {
    _initializeOrderData();
  }

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
  );

  // Payment State
  bool _isPaymentLoading = false;
  PaymentResultData? _paymentResult;
  String? _paymentError;
  Map<String, dynamic>? _checkoutResult;

  // Getters
  OrderData get orderData => _orderData;
  bool get isPaymentLoading => _isPaymentLoading;
  PaymentResultData? get paymentResult => _paymentResult;
  String? get paymentError => _paymentError;
  Map<String, dynamic>? get checkoutResult => _checkoutResult;

  /// Initialize order data with default values
  void _initializeOrderData() {
    final headerOptions = _orderData.orderLineItems ? headerCustomTypeEnabledList : headerCustomTypeDisabledList;
    final defaultHeaderCustomisation = headerOptions.isNotEmpty ? headerOptions.first.name : '';
    
    _orderData = _orderData.copyWith(
      headerCustomisation: defaultHeaderCustomisation,
    );
  }


  /// Update order data
  void updateOrderData(OrderData newOrderData) {
    _orderData = newOrderData;
    notifyListeners();
  }

  /// Update specific order field
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
    notifyListeners();
  }

  /// Handle payment type change
  void handlePaymentTypeChange(String paymentType) {
    String defaultSubPayment = '';
    if (paymentType == 'netbanking') {
      defaultSubPayment = 'all banks';
    } else if (paymentType == 'wallet') {
      defaultSubPayment = 'all wallets';
    } else if (paymentType == 'upi') {
      defaultSubPayment = 'collect + intent';
    }

    updateOrderField(
      paymentCustomisation: paymentType,
      subPaymentCustomisation: defaultSubPayment,
    );
  }

  /// Handle sub-payment type change
  void handleSubPaymentTypeChange(String subPaymentType) {
    updateOrderField(subPaymentCustomisation: subPaymentType);
  }

  /// Handle order line items toggle
  void handleOrderLineItemsChange(bool value) {
    // Reset header customisation to first option when order line items changes
    final newOptions = value ? headerCustomTypeEnabledList : headerCustomTypeDisabledList;
    final newHeaderCustomisation = newOptions.isNotEmpty ? newOptions.first.name : '';
    updateOrderField(
      orderLineItems: value,
      headerCustomisation: newHeaderCustomisation,
    );
  }

  /// Handle header customisation change
  void handleHeaderCustomisationChange(String value) {
    updateOrderField(headerCustomisation: value);
  }

  /// Handle user details toggle
  void handleUserDetailsToggle() {
    updateOrderField(userDetails: !_orderData.userDetails);
  }

  /// Handle amount change
  void handleAmountChange(String amount) {
    updateOrderField(amount: amount);
  }

  /// Handle currency change
  void handleCurrencyChange(String currency) {
    updateOrderField(currency: currency);
  }

  /// Handle first name change
  void handleFirstNameChange(String firstName) {
    updateOrderField(firstName: firstName);
  }

  /// Handle mobile number change
  void handleMobileNumberChange(String mobileNumber) {
    updateOrderField(mobileNumber: mobileNumber);
  }

  /// Handle email change
  void handleEmailChange(String email) {
    updateOrderField(email: email);
  }

  /// Process payment
  Future<void> processPayment() async {
    if (_isPaymentLoading) return;

    debugPrint('Starting payment process...');
    _isPaymentLoading = true;
    _paymentError = null;
    notifyListeners();

    try {
      debugPrint('Order data: ${_orderData.toString()}');
      debugPrint('Settings data: ${_settingsProvider.settingsData.toString()}');
      
      final checkoutResult = await _paymentService.processPayment(
        _orderData,
        _settingsProvider.settingsData,
      );

      debugPrint('Payment service result: $checkoutResult');

      // Only navigate to result screen if there was an actual payment attempt
      // Check if this is a PaymentService error (order creation failed) or actual payment result
      if (checkoutResult.containsKey('success') && checkoutResult['success'] == false) {
        // This is an order creation failure - don't navigate to result screen
        _paymentError = checkoutResult['errorMessage'] ?? 'Failed to create order';
        debugPrint('Order creation failed: $_paymentError');
        _isPaymentLoading = false;
        notifyListeners();
      } else {
        // This is an actual payment result - navigate to result screen
        _checkoutResult = checkoutResult;
        _isPaymentLoading = false;
        notifyListeners();
      }
    } catch (error) {
      _paymentError = 'An unexpected error occurred during payment';
      debugPrint('Payment Error: $error');
      _isPaymentLoading = false;
      notifyListeners();
    }
  }

  /// Handle payment result
  void handlePaymentResult(PaymentResultData result) {
    _paymentResult = result;
    _isPaymentLoading = false;
    notifyListeners();
  }


}
