import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/widgets/order_create_data_values.dart';
import '../providers/order_provider.dart';

/// Form widget for order creation
class OrderFormWidget extends StatelessWidget {
  const OrderFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Card
              _buildProductCard(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Product Details (Title, Currency, Amount in one row)
              _buildProductDetails(orderProvider),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Transaction Info Section
              _buildTransactionInfoSection(),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Order Line Items Section
              _buildOrderLineItemsSection(orderProvider),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Header Customisation Section
              _buildHeaderCustomisationSection(orderProvider),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Payment Customisation Section
              _buildPaymentCustomisationSection(orderProvider),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // Sub Payment Customisation Section
              if (_shouldShowSubPayment(orderProvider.orderData.paymentCustomisation))
                _buildSubPaymentCustomisationSection(orderProvider),
              if (_shouldShowSubPayment(orderProvider.orderData.paymentCustomisation))
                const SizedBox(height: AppConstants.defaultPadding),
              
              // User Details Section
              _buildUserDetailsSection(orderProvider),
              const SizedBox(height: AppConstants.defaultPadding),
              
              // User Detail Input Fields
              if (orderProvider.orderData.userDetails)
                _buildUserDetailInputFields(orderProvider),
              if (orderProvider.orderData.userDetails)
                const SizedBox(height: AppConstants.defaultPadding),
              
              // Pay Button
              _buildPayButton(context, orderProvider),
              const SizedBox(height: AppConstants.largePadding),
              
              // Bottom spacer (matching React Native structure)
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

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

  Widget _buildProductDetails(OrderProvider orderProvider) {
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
                  value: orderProvider.orderData.currency,
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
                      orderProvider.handleCurrencyChange(newValue);
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
                    controller: TextEditingController(text: orderProvider.orderData.amount),
                    onChanged: orderProvider.handleAmountChange,
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

  Widget _buildOrderLineItemsSection(OrderProvider orderProvider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.orderLineItems,
            style: AppTheme.labelMedium,
          ),
        ),
        Switch(
          value: orderProvider.orderData.orderLineItems,
          onChanged: orderProvider.handleOrderLineItemsChange,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildHeaderCustomisationSection(OrderProvider orderProvider) {
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
              value: orderProvider.orderData.headerCustomisation,
              isExpanded: true,
              style: AppTheme.inputText,
              items: _getHeaderCustomisationOptions(orderProvider.orderData.orderLineItems)
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
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
                  orderProvider.handleHeaderCustomisationChange(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCustomisationSection(OrderProvider orderProvider) {
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
              value: orderProvider.orderData.paymentCustomisation,
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
                  orderProvider.handlePaymentTypeChange(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubPaymentCustomisationSection(OrderProvider orderProvider) {
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
              value: orderProvider.orderData.subPaymentCustomisation,
              isExpanded: true,
              style: AppTheme.inputText,
              items: _getSubPaymentItems(orderProvider.orderData.paymentCustomisation)
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
                  orderProvider.handleSubPaymentTypeChange(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetailsSection(OrderProvider orderProvider) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.userDetails,
            style: AppTheme.labelMedium,
          ),
        ),
        GestureDetector(
          onTap: () => orderProvider.handleUserDetailsToggle(),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(3),
              color: orderProvider.orderData.userDetails ? Colors.black : Colors.white,
            ),
            child: orderProvider.orderData.userDetails
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

  Widget _buildUserDetailInputFields(OrderProvider orderProvider) {
    return Column(
      children: [
        // First Name Field
        _buildUserDetailField(
          label: AppStrings.firstName,
          value: orderProvider.orderData.firstName,
          onChanged: orderProvider.handleFirstNameChange,
          hintText: AppStrings.enterFirstName,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Mobile Number Field
        _buildUserDetailField(
          label: AppStrings.mobileNumber,
          value: orderProvider.orderData.mobileNumber,
          onChanged: orderProvider.handleMobileNumberChange,
          hintText: AppStrings.enterMobileNumber,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Email Field
        _buildUserDetailField(
          label: AppStrings.email,
          value: orderProvider.orderData.email,
          onChanged: orderProvider.handleEmailChange,
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

  Widget _buildPayButton(BuildContext context, OrderProvider orderProvider) {
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
        onPressed: orderProvider.isPaymentLoading ? null : () async {
          await orderProvider.processPayment();
          // Show error toast if payment failed
          if (orderProvider.paymentError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  orderProvider.paymentError!,
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
        child: orderProvider.isPaymentLoading
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

  /// Get header indicator color based on the option name (matching Android sample app logic)
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
