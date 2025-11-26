import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../shared/constants/app_strings.dart';
import '../shared/constants/order_create_data_values.dart';
import '../shared/utils/navigation_utils.dart';
import '../viewmodels/order_create_viewmodel.dart';

import '../shared/widgets/currency_amount_input.dart';
import '../shared/widgets/header_customisation_dropdown.dart';
import '../shared/widgets/payment_customisation_dropdown.dart';
import '../shared/widgets/sub_payment_customisation_dropdown.dart';
import '../shared/widgets/toggle_option.dart';
import '../shared/widgets/info_message.dart';
import '../shared/widgets/user_detail_field.dart';
import 'order_success_screen.dart';
import 'settings_screen.dart';

/// Main order creation screen
class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen({Key? key}) : super(key: key);

  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  late OrderCreateViewModel _viewModel;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _viewModel = OrderCreateViewModel();
    _initializeViewModel();
  }

  Future<void> _initializeViewModel() async {
    await _viewModel.initialize(
      defaultCheckoutExperience: AppStrings.checkoutExperienceRedirect, // Mobile SDK always uses redirect
    );
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleCheckoutResult() async {
    final checkoutResult = _viewModel.checkoutResult;
    if (checkoutResult != null) {
      // Clear the checkout result immediately to prevent duplicate navigation
      _viewModel.clearCheckoutResult();
      
      // Navigate to success screen using platform-aware navigation
      await NavigationUtils.navigateTo(
        context,
        OrderSuccessScreen(paymentData: checkoutResult),
      );
    }
  }

  Future<void> _processPayment() async {
    final checkoutResult = await _viewModel.processPayment();
    if (checkoutResult != null && mounted) {
      await _handleCheckoutResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white, // White background to match web and React app
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
                        InfoMessage(
                          message: AppStrings.infoRealTransaction,
                          maxLines: 2,
                          padding: const EdgeInsets.symmetric(vertical: 4), // Less spacing for mobile
                        ),
                        const SizedBox(height: 4), // Less spacing between messages for mobile
                        InfoMessage(
                          message: AppStrings.infoEmiAmount,
                          maxLines: 2,
                          padding: const EdgeInsets.symmetric(vertical: 4), // Less spacing for mobile
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Order Line Items Section
                        _buildOrderLineItemsSection(),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // View Mode Selector - Hidden for mobile (not applicable for mobile SDK)
                        // Note: View mode is only relevant for web UI
                        
                        // Enable Address & COD Section (matching web UI)
                        _buildAddressCodSection(),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Header Customisation Section
                        _buildHeaderCustomisationSection(),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Payment Customisation Section
                        _buildPaymentCustomisationSection(),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Sub Payment Customisation Section
                        if (_viewModel.shouldShowSubPayment(_viewModel.orderData.paymentCustomisation))
                          _buildSubPaymentCustomisationSection(),
                        if (_viewModel.shouldShowSubPayment(_viewModel.orderData.paymentCustomisation))
                          const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Checkout Experience Section - Hidden for mobile (always redirect)
                        // Note: Mobile SDK always uses redirect mode, so this section is not shown
                        
                        // User Details Section
                        _buildUserDetailsSection(),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // User Detail Input Fields
                        if (_viewModel.userDetails)
                          _buildUserDetailInputFields(),
                        if (_viewModel.userDetails)
                          const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Pay Button
                        _buildPayButton(context),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // Error Message
                        if (_viewModel.paymentError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
                            child: Text(
                              _viewModel.paymentError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        
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
      },
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
          // App Logo - Using SonicLogo to match React
          // Matching React: <img src={SonicLogo} alt='' className='' />
          // React uses natural size, no explicit height/width
          Image.asset(
            'assets/images/SonicLogo.png',
            // No explicit height/width to match React's natural size behavior
            // Image will use its natural aspect ratio (134x49)
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          
          // App Title
          // Matching React: <span className='font-black text-white text-nowrap'>by nimbbl.</span>
          // React: font-black (w900), text-white, text-nowrap, text-sm (12px on mobile)
          const Expanded(
            child: Text(
              AppStrings.byNimbbl,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 12, // Matching React: text-sm (12px on mobile)
                fontWeight: FontWeight.w900, // Matching React: font-black (heaviest weight)
                color: Colors.white, // Matching React: text-white
              ),
              maxLines: 1, // Matching React: text-nowrap
              overflow: TextOverflow.ellipsis,
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
    // Matching React: <img src={PaperPlane} className='mb-6 h-max rounded-lg' width='100%' />
    // h-max = natural height (no fixed height), rounded-lg = 12px, width='100%' = full width
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 24), // mb-6 = 24px bottom margin
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // rounded-lg (12px) - matching React
        child: Image.asset(
          'assets/images/PaperPlane.png',
          width: double.infinity, // width='100%' - matching React
          // h-max means height: max-content (natural height, not stretched)
          // No height specified to allow natural aspect ratio
          fit: BoxFit.contain, // Maintain aspect ratio like React's h-max
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Product Title
        // Matching React: text-[20px] lg:text-4xl md:text-4xl tracking-tighter text-nowrap font-[Gordita-bold]
        Text(
          AppStrings.paperPlane, // Using paperPlane (with capital P) to match React
          style: const TextStyle(
            fontFamily: 'Gordita',
            fontSize: 20, // Matching React: text-[20px] (20px on mobile)
            fontWeight: FontWeight.w700, // Matching React: font-[Gordita-bold]
            color: Colors.black,
            letterSpacing: -0.05, // Matching React: tracking-tighter (tighter letter spacing)
          ),
          maxLines: 1, // Matching React: text-nowrap
          overflow: TextOverflow.ellipsis,
        ),
        
        // Currency and Amount Input - using shared widget
        CurrencyAmountInput(
          currency: _viewModel.selectedCurrency,
          amount: _viewModel.amountController.text,
          amountController: _viewModel.amountController,
          onCurrencyChanged: (value) {
            _viewModel.handleCurrencyChange(value);
          },
          onAmountChanged: (value) {
            _viewModel.updateOrderField(amount: value);
          },
        ),
      ],
    );
  }

  Widget _buildOrderLineItemsSection() {
    return ToggleOption(
      label: AppStrings.orderLineItems,
      value: _viewModel.orderLineItems,
      disabled: _viewModel.enableAddressCod, // Matching web UI: disabled when Address & COD is enabled
      onChanged: (value) {
        _viewModel.handleOrderLineItemsChange(value);
      },
    );
  }

  Widget _buildAddressCodSection() {
    return ToggleOption(
      label: AppStrings.enableAddressCod,
      value: _viewModel.enableAddressCod,
      onChanged: (value) {
        _viewModel.toggleAddressCod(value);
      },
    );
  }


  Widget _buildHeaderCustomisationSection() {
    // If addressCodEnabled, show merchant dropdown (MustBuy, BallMart, TripKart)
    if (_viewModel.enableAddressCod) {
      final options = headerCustomTypeAddressCodList;
      final currentValue = _viewModel.orderData.headerCustomisation;
      final isValid = options.any((option) => option.name == currentValue);
      final validValue = isValid ? currentValue : AppStrings.mustBuy;
      
      if (!isValid && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _viewModel.updateHeaderCustomisation(AppStrings.mustBuy);
          }
        });
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.headerCustomisation,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.8),
              letterSpacing: -0.05,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: AppConstants.inputFieldHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: AppTheme.inputBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x1A000000), width: 1),
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
                value: validValue,
                isExpanded: true,
                style: const TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  letterSpacing: -0.05,
                ),
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option.name,
                    child: Row(
                      children: [
                        Icon(
                          option.icon,
                          size: 18,
                          color: _viewModel.getHeaderIndicatorColor(option.name),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option.name,
                            style: const TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              letterSpacing: -0.05,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _viewModel.updateHeaderCustomisation(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      );
    }

    // If orderLineItems is false, show disabled state with "your brand name" (matching web UI)
    if (!_viewModel.orderLineItems) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.headerCustomisation,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.8),
              letterSpacing: -0.05,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(maxHeight: 38),
            decoration: BoxDecoration(
              color: AppTheme.inputBackgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 0.4,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 18,
                  color: _viewModel.getHeaderIndicatorColor(AppStrings.brandName),
                ),
                const SizedBox(width: 16),
                Text(
                  AppStrings.brandName,
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // If render_desktop_ui is true and orderLineItems is true, show disabled state (matching web UI)
    if (_viewModel.renderDesktopUi && _viewModel.orderLineItems) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.headerCustomisation,
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.8),
              letterSpacing: -0.05,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(maxHeight: 38),
            decoration: BoxDecoration(
              color: AppTheme.inputBackgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 0.4,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 18,
                  color: const Color(0xFFFB381D), // Pink/Red color for desktop UI
                ),
                const SizedBox(width: 16),
                Text(
                  AppStrings.brandName,
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Default: orderLineItems is true and render_desktop_ui is false
    return HeaderCustomisationDropdown(
      value: _viewModel.orderData.headerCustomisation,
      orderLineItems: _viewModel.orderData.orderLineItems,
      onChanged: (value) {
        _viewModel.updateHeaderCustomisation(value);
      },
    );
  }

  Widget _buildPaymentCustomisationSection() {
    return PaymentCustomisationDropdown(
      value: _viewModel.orderData.paymentCustomisation,
      isDisabled: _viewModel.enableAddressCod || _viewModel.selectedCurrency != 'INR', // Matching web UI
      onChanged: (value) {
        _viewModel.handlePaymentTypeChange(value);
      },
    );
  }

  Widget _buildSubPaymentCustomisationSection() {
    return SubPaymentCustomisationDropdown(
      paymentType: _viewModel.orderData.paymentCustomisation,
      value: _viewModel.orderData.subPaymentCustomisation,
      onChanged: (value) {
        _viewModel.updateSubPaymentCustomisation(value);
      },
    );
  }

  Widget _buildUserDetailsSection() {
    return ToggleOption(
      label: AppStrings.userDetailsQuestion,
      value: _viewModel.userDetails,
      onChanged: (value) {
        _viewModel.toggleUserDetails(value);
      },
    );
  }

  Widget _buildUserDetailInputFields() {
    return Column(
      children: [
        // First Name Field
        UserDetailField(
          label: AppStrings.firstName,
          controller: _viewModel.firstNameController,
          onChanged: (value) {
            _viewModel.updateFirstName(value);
          },
          hintText: AppStrings.enterFirstName,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Mobile Number Field
        UserDetailField(
          label: AppStrings.mobileNumber,
          controller: _viewModel.mobileController,
          onChanged: (value) {
            _viewModel.validateMobileNumber(value);
          },
          hintText: AppStrings.enterMobileNumber,
          keyboardType: TextInputType.phone,
          errorText: _viewModel.numberError,
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Email Field
        UserDetailField(
          label: AppStrings.email,
          controller: _viewModel.emailController,
          onChanged: (value) {
            _viewModel.validateEmail(value);
          },
          hintText: AppStrings.enterEmail,
          keyboardType: TextInputType.emailAddress,
          errorText: _viewModel.emailError,
        ),
      ],
    );
  }


  Widget _buildPayButton(BuildContext context) {
    return Container(
      width: double.infinity,
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
        onPressed: !_viewModel.isPayButtonEnabled()
            ? null 
            : () async {
          await _processPayment();
          // Show error toast if payment failed
          if (mounted && _viewModel.paymentError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _viewModel.paymentError!,
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
          backgroundColor: _viewModel.isPaymentLoading || !_viewModel.isPayButtonEnabled()
              ? Colors.grey[400] // Matching React: bg-gray-400 when disabled/loading
              : AppTheme.primaryColor, // Matching React: bg-black when enabled
          foregroundColor: Colors.white, // Matching React: text-white
          padding: const EdgeInsets.all(12), // Matching React: p-3 (12px)
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Matching React: rounded-[10px]
          ),
        ),
        child: _viewModel.isPaymentLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Matching React: w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                    ),
                  ),
                  const SizedBox(width: 8), // Matching React: gap-2 (8px)
                  const Text(
                    'Processing...', // Matching React: "Processing..."
                    style: TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Matching React: font-[Gordita-medium]
                      color: AppTheme.secondaryColor,
                      letterSpacing: -0.05,
                    ),
                  ),
                ],
              )
            : const Text(
                AppStrings.payNow,
                style: AppTheme.buttonText,
              ),
      ),
    );
  }

}
