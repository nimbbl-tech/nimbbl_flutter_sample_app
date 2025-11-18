import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/order_data.dart';
import '../services/payment_service.dart';
import '../services/settings_service.dart';
import '../shared/constants/app_strings.dart';
import '../shared/constants/order_create_data_values.dart';
import 'order_success_screen.dart';
import 'settings_screen.dart';

/// Main order creation screen
class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen({super.key});

  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  final PaymentService _paymentService = PaymentService();
  final SettingsService _settingsService = SettingsService();
  late TextEditingController _amountController;

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
  String? _paymentError;
  Map<String, dynamic>? _checkoutResult;

  @override
  void initState() {
    super.initState();
    _initializeOrderData();
    _amountController = TextEditingController(text: _orderData.amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _initializeOrderData() {
    final headerOptions = _orderData.orderLineItems ? headerCustomTypeEnabledList : headerCustomTypeDisabledList;
    final defaultHeaderCustomisation = headerOptions.isNotEmpty ? headerOptions.first.name : '';
    
    setState(() {
      _orderData = _orderData.copyWith(
        headerCustomisation: defaultHeaderCustomisation,
      );
    });
  }

  void _handleCheckoutResult() {
    if (_checkoutResult != null) {
      final checkoutResult = _checkoutResult;
      // Clear the checkout result immediately to prevent duplicate navigation
      setState(() {
        _checkoutResult = null;
      });
      
      // Navigate to success screen (handles both success and failure cases)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            paymentData: checkoutResult!,
          ),
        ),
      ).then((_) {
        // Reset state when returning from success screen
        // This allows for new payments to be processed
      });
    }
  }

  void _updateOrderField({
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
    setState(() {
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
      if (amount != null && _amountController.text != amount) {
        _amountController.text = amount;
      }
    });
  }

  void _handlePaymentTypeChange(String paymentType) {
    String defaultSubPayment = '';
    if (paymentType == 'netbanking') {
      defaultSubPayment = 'all banks';
    } else if (paymentType == 'wallet') {
      defaultSubPayment = 'all wallets';
    } else if (paymentType == 'upi') {
      defaultSubPayment = 'collect + intent';
    }

    _updateOrderField(
      paymentCustomisation: paymentType,
      subPaymentCustomisation: defaultSubPayment,
    );
  }

  void _handleOrderLineItemsChange(bool value) {
    final newOptions = value ? headerCustomTypeEnabledList : headerCustomTypeDisabledList;
    final newHeaderCustomisation = newOptions.isNotEmpty ? newOptions.first.name : '';
    _updateOrderField(
      orderLineItems: value,
      headerCustomisation: newHeaderCustomisation,
    );
  }

  Future<void> _processPayment() async {
    if (_isPaymentLoading) return;

    debugPrint('Starting payment process...');
    setState(() {
      _isPaymentLoading = true;
      _paymentError = null;
    });

    try {
      debugPrint('Order data: ${_orderData.toString()}');
      debugPrint('Settings data: ${_settingsService.settingsData.toString()}');
      
      final checkoutResult = await _paymentService.processPayment(
        _orderData,
        _settingsService.settingsData,
      );

      debugPrint('Payment service result: $checkoutResult');

      // Only navigate to result screen if there was an actual payment attempt
      if (checkoutResult.containsKey('success') && checkoutResult['success'] == false) {
        // This is an order creation failure - don't navigate to result screen
        setState(() {
          _paymentError = checkoutResult['errorMessage'] ?? 'Failed to create order';
          _isPaymentLoading = false;
        });
        debugPrint('Order creation failed: $_paymentError');
      } else {
        // This is an actual payment result - navigate to result screen
        setState(() {
          _checkoutResult = checkoutResult;
          _isPaymentLoading = false;
        });
        _handleCheckoutResult();
      }
    } catch (error) {
      setState(() {
        _paymentError = 'An unexpected error occurred during payment';
        _isPaymentLoading = false;
      });
      debugPrint('Payment Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Card
                    _buildProductCard(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Product Details (Title, Currency, Amount in one row)
                    _buildProductDetails(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Transaction Info Section
                    _buildTransactionInfoSection(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Order Line Items Section
                    _buildOrderLineItemsSection(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Header Customisation Section
                    _buildHeaderCustomisationSection(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Payment Customisation Section
                    _buildPaymentCustomisationSection(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Sub Payment Customisation Section
                    if (_shouldShowSubPayment(_orderData.paymentCustomisation))
                      _buildSubPaymentCustomisationSection(),
                    if (_shouldShowSubPayment(_orderData.paymentCustomisation))
                      const SizedBox(height: AppConstants.defaultPadding),
                    
                    // User Details Section
                    _buildUserDetailsSection(),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // User Detail Input Fields
                    if (_orderData.userDetails)
                      _buildUserDetailInputFields(),
                    if (_orderData.userDetails)
                      const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Pay Button
                    _buildPayButton(context),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // Bottom spacer
                    const SizedBox(height: AppConstants.largePadding),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // Header Widget
  Widget _buildHeader() {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 0,
      ),
      child: Row(
        children: [
          // App Logo
          Image.asset(
            'assets/images/headerLogo.png',
            height: 32,
            width: 32,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          
          // App Title
          const Expanded(
            child: Text(
              'by nimbbl.',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 12,
              ),
            ),
          ),
          
          // Settings Button
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            ),
            icon: const Icon(
              Icons.settings,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Footer Widget
  Widget _buildFooter() {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding + 4, 
        AppConstants.defaultPadding, 
        AppConstants.defaultPadding + 4, 
        AppConstants.defaultPadding
      ),
      child: Row(
        children: [
          Text(
            '© ${DateTime.now().year} nimbbl by bigital technologies pvt ltd',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  // Form Widgets
  Widget _buildProductCard() {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(top: 16,),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/PaperPlane.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Product Title
        const Text(
          'paper plane.',
          style: AppTheme.headingSmall,
        ),
        
        // Currency and Amount Container
        Row(
          children: [
            // Currency Dropdown
            Container(
              width: 55,
              height: 32,
              margin: const EdgeInsets.only(right: 5),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppTheme.inputBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _orderData.currency,
                  isExpanded: false,
                  style: AppTheme.inputText.copyWith(fontSize: 12),
                  underline: const SizedBox.shrink(),
                  icon: const Icon(Icons.arrow_drop_down, size: 16),
                  items: currencyOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _updateOrderField(currency: newValue);
                    }
                  },
                ),
              ),
            ),
            
            // Amount Field
            Container(
              width: 50,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.inputBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: DottedBorder(
                color: AppTheme.borderColor,
                strokeWidth: 1,
                dashPattern: const [5, 5],
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                child: Center(
                  child: TextFormField(
                    controller: _amountController,
                    onChanged: (value) => _updateOrderField(amount: value),
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: AppTheme.inputText.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.all(0),
                      isDense: true,
                      hintText: AppStrings.enterAmount,
                      hintStyle: AppTheme.hintText,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionInfoSection() {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'i',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'this is a real transaction, any amount deducted will refunded within 7 working days',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderLineItemsSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.orderLineItems,
            style: AppTheme.labelMedium,
          ),
        ),
        Switch(
          value: _orderData.orderLineItems,
          onChanged: _handleOrderLineItemsChange,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildHeaderCustomisationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.headerCustomisation,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _orderData.headerCustomisation,
              isExpanded: true,
              style: AppTheme.inputText,
              items: _getHeaderCustomisationOptions(_orderData.orderLineItems)
                  .asMap()
                  .entries
                  .map((entry) {
                final item = entry.value;
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 16,
                        color: _getHeaderIndicatorColor(item.name),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateOrderField(headerCustomisation: newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCustomisationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.paymentCustomisation,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _orderData.paymentCustomisation,
              isExpanded: true,
              style: AppTheme.inputText,
              items: paymentTypeList.map((IconWithName item) {
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Row(
                    children: [
                      Icon(item.icon, size: 16),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _handlePaymentTypeChange(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubPaymentCustomisationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.subPaymentCustomisation,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _orderData.subPaymentCustomisation,
              isExpanded: true,
              style: AppTheme.inputText,
              items: _getSubPaymentItems(_orderData.paymentCustomisation)
                  .map((ImageWithName item) {
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Row(
                    children: [
                      Image.asset(
                        item.image,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Expanded(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _updateOrderField(subPaymentCustomisation: newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsSection() {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.userDetails,
            style: AppTheme.labelMedium,
          ),
        ),
        GestureDetector(
          onTap: () => _updateOrderField(userDetails: !_orderData.userDetails),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(3),
              color: _orderData.userDetails ? Colors.black : Colors.white,
            ),
            child: _orderData.userDetails
                ? const Center(
                    child: Text(
                      '✓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailInputFields() {
    return Column(
      children: [
        // First Name Field
        _buildUserDetailField(
          label: AppStrings.firstName,
          value: _orderData.firstName,
          onChanged: (value) => _updateOrderField(firstName: value),
          hintText: AppStrings.enterFirstName,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Mobile Number Field
        _buildUserDetailField(
          label: AppStrings.mobileNumber,
          value: _orderData.mobileNumber,
          onChanged: (value) => _updateOrderField(mobileNumber: value),
          hintText: AppStrings.enterMobileNumber,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Email Field
        _buildUserDetailField(
          label: AppStrings.email,
          value: _orderData.email,
          onChanged: (value) => _updateOrderField(email: value),
          hintText: AppStrings.enterEmail,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildUserDetailField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextFormField(
            initialValue: value,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: keyboardType,
            style: AppTheme.inputText,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              isDense: true,
              hintText: hintText,
              hintStyle: AppTheme.hintText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isPaymentLoading ? null : () async {
          await _processPayment();
          // Show error toast if payment failed
          if (_paymentError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _paymentError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Colors.grey.shade800,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPaymentLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                ),
              )
            : const Text(
                AppStrings.payNow,
                style: AppTheme.buttonText,
              ),
      ),
    );
  }

  // Helper methods
  List<IconWithName> _getHeaderCustomisationOptions(bool orderLineItems) {
    return orderLineItems ? headerCustomTypeEnabledList : headerCustomTypeDisabledList;
  }

  List<ImageWithName> _getSubPaymentItems(String paymentType) {
    switch (paymentType) {
      case 'netbanking':
        return netBankingSubPaymentTypeList;
      case 'wallet':
        return walletSubPaymentTypeList;
      case 'upi':
        return upiSubPaymentTypeList;
      default:
        return [];
    }
  }

  bool _shouldShowSubPayment(String paymentType) {
    return paymentType == 'netbanking' || paymentType == 'wallet' || paymentType == 'upi';
  }

  Color _getHeaderIndicatorColor(String optionName) {
    switch (optionName) {
      case 'your brand name and brand logo':
        return const Color(0xFF022860); // Dark Blue
      case 'your brand logo':
        return const Color(0xFF3E6F96); // Light Blue
      case 'your brand name':
        return const Color(0xFFFB381D); // Red
      default:
        return const Color(0xFF022860); // Default to Dark Blue
    }
  }
}
