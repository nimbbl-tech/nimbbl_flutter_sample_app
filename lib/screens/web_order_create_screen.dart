import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../shared/constants/app_strings.dart';
import '../shared/utils/navigation_utils.dart';
import '../viewmodels/order_create_viewmodel.dart';
import '../shared/widgets/currency_amount_input.dart';
import '../shared/widgets/header_customisation_dropdown.dart';
import '../shared/widgets/payment_customisation_dropdown.dart';
import '../shared/widgets/sub_payment_customisation_dropdown.dart';
import '../shared/widgets/toggle_option.dart';
import '../shared/widgets/info_message.dart';
import '../shared/widgets/user_detail_field.dart';
import '../shared/widgets/view_mode_selector.dart';
import '../shared/widgets/checkout_experience_selector.dart';
import '../shared/constants/order_create_data_values.dart';
import 'order_success_screen.dart';
import 'settings_screen.dart';

/// Web-optimized order creation screen matching SONIC by nimbbl design
class WebOrderCreateScreen extends StatefulWidget {
  const WebOrderCreateScreen({Key? key}) : super(key: key);

  @override
  State<WebOrderCreateScreen> createState() => _WebOrderCreateScreenState();
}

class _WebOrderCreateScreenState extends State<WebOrderCreateScreen> {
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
      defaultAmount: '4.00',
      defaultCheckoutExperience: AppStrings.checkoutExperiencePopUp,
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


  // Header customisation logic matching React implementation
  // Based on addressCodEnabled, orderLineItems, and render_desktop_ui
  Widget _buildHeaderCustomisation() {
    // If addressCodEnabled, show merchant dropdown (MustBuy, BallMart, TripKart)
    // PRODUCT_LIST[5], PRODUCT_LIST[6], PRODUCT_LIST[7]
    if (_viewModel.enableAddressCod) {
      final options = headerCustomTypeAddressCodList;
      
      // Ensure the current value is valid for Address & COD options
      // Valid options are: 'MustBuy', 'BallMart', 'TripKart'
      final currentValue = _viewModel.orderData.headerCustomisation;
      final isValid = options.any((option) => option.name == currentValue);
      
      // Use valid value or default to 'MustBuy' (product ID 5)
      final validValue = isValid ? currentValue : AppStrings.mustBuy;
      
      // If current value is not valid, update it in the next frame
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
                style: AppTheme.inputText,
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

    // If orderLineItems is false, show disabled state with "your brand name" (PRODUCT_LIST[2])
    // Matching React: disabled state with OrangeIcon
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
            constraints: const BoxConstraints(maxHeight: 38), // Matching React: max-h-[38px]
            decoration: BoxDecoration(
              color: AppTheme.inputBackgroundColor,
              borderRadius: BorderRadius.circular(4), // Matching React: rounded-[4px]
              border: Border.all(
                color: const Color(0xFFE5E7EB), // Matching React: border-gray-200
                width: 0.4, // Matching React: border-[0.4px]
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 18, // Matching React: icon size={18}
                  color: _viewModel.getHeaderIndicatorColor(AppStrings.brandName),
                ),
                const SizedBox(width: 16), // Matching React: gap-4 (16px)
                Text(
                  AppStrings.brandName,
                  // Matching React: font-[Gordita-medium] text-sm lg:text-base md:text-base
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

    // If render_desktop_ui is true and orderLineItems is true, show disabled state with PinkEllipse option
    // This would be PRODUCT_LIST[3] which is "your brand name" (desktop UI variant)
    // Matching React: disabled state with PinkEllipse
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
            constraints: const BoxConstraints(maxHeight: 38), // Matching React: max-h-[38px]
            decoration: BoxDecoration(
              color: AppTheme.inputBackgroundColor,
              borderRadius: BorderRadius.circular(4), // Matching React: rounded-[4px]
              border: Border.all(
                color: const Color(0xFFE5E7EB), // Matching React: border-gray-200
                width: 0.4, // Matching React: border-[0.4px]
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  size: 18, // Matching React: icon size={18}
                  color: const Color(0xFFFB381D), // Pink/Red color for desktop UI (PinkEllipse)
                ),
                const SizedBox(width: 16), // Matching React: gap-4 (16px)
                Text(
                  AppStrings.brandName,
                  // Matching React: font-[Gordita-medium] text-sm lg:text-base md:text-base
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
    // Show dropdown with PRODUCT_LIST[0] and PRODUCT_LIST[1] options
    return HeaderCustomisationDropdown(
      value: _viewModel.orderData.headerCustomisation,
      orderLineItems: _viewModel.orderLineItems,
      onChanged: (value) {
        _viewModel.updateHeaderCustomisation(value);
      },
    );
  }

  Future<void> _processPayment() async {
    final checkoutResult = await _viewModel.processPayment();
    
    if (checkoutResult != null && mounted) {
      // Check if checkout experience is redirect mode
      final isRedirect = _viewModel.checkoutExperience == AppStrings.checkoutExperienceRedirect;
      
      if (isRedirect && checkoutResult['status'] == 'redirect') {
        // For redirect mode, checkout will redirect the browser
        // The response will be available on the redirect page
        // Don't navigate - let the checkout redirect handle it
      } else {
        // For pop-up mode, navigate to success screen with result
        // Navigate immediately for smooth transition
        await NavigationUtils.navigateTo(
          context,
          OrderSuccessScreen(paymentData: checkoutResult),
        );
      }
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
          backgroundColor: Colors.white, // White background like React app
          body: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(),
                // Main Content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Panel - Product Visualization
                        Expanded(
                          flex: 1,
                          child: _buildLeftPanel(),
                        ),
                        // Divider
                        Container(
                          width: 0.5,
                          color: const Color(0x1A000000), // #0000001A
                        ),
                        // Right Panel - Configuration
                        Expanded(
                          flex: 1,
                          child: _buildRightPanel(),
                        ),
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

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0E0D10),
            Color(0xFF201F22),
            Color(0xFF0E0D10),
          ],
          stops: [0.1, 0.3, 0.9],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8), // Matching React: py-2 (8px)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo with SonicLogo image
          // Matching React: <img src={SonicLogo} alt='' className='' />
          // React uses natural size (134x49px), no explicit height/width
          Row(
            children: [
              Image.asset(
                'assets/images/SonicLogo.png',
                // No explicit height to match React's natural size behavior
                // Image will use its natural aspect ratio (134x49)
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.byNimbbl,
                style: const TextStyle(
                  fontFamily: 'Gordita',
                  fontSize: 14, // Matching React: text-sm lg:text-base md:text-base (base = 14px)
                  fontWeight: FontWeight.w900, // Matching React: font-black (heaviest weight)
                  color: Colors.white, // Matching React: text-white
                ),
                maxLines: 1, // Matching React: text-nowrap
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // Navigation Links and Settings
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  // Open contact sales link
                  final uri = Uri.parse(AppConstants.nimbblContactSalesUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  AppStrings.contactSales,
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.05,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () async {
                  // Open website link
                  final uri = Uri.parse(AppConstants.nimbblWebsiteUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Row(
                  children: [
                    Text(
                      AppStrings.visitWebsite,
                      style: const TextStyle(
                        fontFamily: 'Gordita',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.05,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Use SVG or icon for right arrow
                    Image.asset(
                      'assets/images/RightArrow.svg',
                      width: 16,
                      height: 16,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.arrow_forward, size: 16, color: Colors.white);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Settings Icon Button (at the right end)
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ).then((_) {
                    // Reload settings and re-initialize SDK when returning from settings
                    _viewModel.initialize(
                      defaultAmount: '4.00',
                      defaultCheckoutExperience: AppStrings.checkoutExperiencePopUp,
                    );
                  });
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: AppStrings.settings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      padding: const EdgeInsets.all(40),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Product Image - on white background with rounded corners
          // Matching React: mb-6 h-max rounded-lg width='100%'
          ClipRRect(
            borderRadius: BorderRadius.circular(12), // rounded-lg (12px)
            child: Image.asset(
              'assets/images/PaperPlane.png',
              fit: BoxFit.contain,
              width: double.infinity, // width='100%'
              // h-max means height: max-content (natural height, not stretched)
              // Using BoxFit.contain ensures image maintains aspect ratio
            ),
          ),
          const SizedBox(height: 24), // Matching React: mb-6 (24px)
          // Thumbnails with labels (nose, wing, tail) - only visible on large screens
          // Matching React: hidden lg:flex lg:flex-row lg:justify-between mb-10 text-black text-opacity-80
          // React: w-[30%] for each item (90% total, 10% for spacing with justify-between)
          Container(
            margin: const EdgeInsets.only(bottom: 40), // Matching React: mb-10 (40px)
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Matching React: justify-between
              children: [
                _buildThumbnailWithLabel('assets/images/Nose.png', 'nose'),
                // Spacing between items - React's justify-between with 30% items creates natural spacing
                _buildThumbnailWithLabel('assets/images/Wingpic.png', 'wing'),
                _buildThumbnailWithLabel('assets/images/Tail.png', 'tail'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailWithLabel(String image, String label) {
    // Matching React: w-[30%] (30% width for each item)
    // Using Expanded but constraining content width to ~30% to match React spacing
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate 30% of available width, matching React's w-[30%]
          final itemWidth = constraints.maxWidth * 0.30;
          return SizedBox(
            width: itemWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image - matching React: <img src={Nose} alt='' />
                Image.asset(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
                // Text label - matching React: text-lg font-[Gordita-medium] text-black text-opacity-80
                // Note: React has a space between img and span, so adding small spacing
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Gordita',
                    fontSize: 18, // Matching React: text-lg (18px)
                    fontWeight: FontWeight.w500, // Matching React: font-[Gordita-medium]
                    color: Colors.black.withOpacity(0.8), // Matching React: text-black text-opacity-80
                    letterSpacing: -0.02,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      // Matching React: lg:px-10 (padding horizontal: 40px = 2.5rem)
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      color: Colors.white,
      // Matching React: lg:border-l-[0.5px] lg:border-[#0000001A]
      // Border is handled in parent Row widget
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Title and Currency/Amount Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                // Matching React: text-[20px] lg:text-4xl md:text-4xl tracking-tighter text-nowrap font-[Gordita-bold]
                Expanded(
                  child: Text(
                    AppStrings.paperPlane,
                    style: const TextStyle(
                      fontFamily: 'Gordita',
                      fontSize: 36, // Matching React: lg:text-4xl md:text-4xl (36px on desktop)
                      fontWeight: FontWeight.w700, // Matching React: font-[Gordita-bold]
                      color: Colors.black,
                      letterSpacing: -0.05, // Matching React: tracking-tighter (tighter letter spacing)
                    ),
                    maxLines: 1, // Matching React: text-nowrap
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
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
            ),
            const SizedBox(height: 24),
            // Info Messages
            InfoMessage(
              message: AppStrings.infoRealTransaction,
            ),
            const SizedBox(height: 8),
            InfoMessage(
              message: AppStrings.infoEmiAmount,
            ),
            const SizedBox(height: 30),
            // Configuration Options - Matching React component order:
            // 1. OrderLineItem
            // 2. ViewMode
            // 3. Enable Address & COD
            // 4. HeaderCoustomizer
            // 5. PaymentCustomizer
            // 6. CheckoutExperience
            
            // 1. OrderLineItem (matching React OrderLineItem component)
            // Disabled when enableAddressCOD is true (matching React: disabled={enableAddressCOD})
            ToggleOption(
              label: AppStrings.orderLineItems,
              value: _viewModel.orderLineItems,
              disabled: _viewModel.enableAddressCod, // Matching React: disabled={enableAddressCOD}
              onChanged: (value) {
                _viewModel.handleOrderLineItemsChange(value);
              },
            ),
            const SizedBox(height: 24), // Matching React: mb-6 (24px)
            // 2. ViewMode (matching React ViewMode component)
            // React: disabled={enableAddressCOD}, checked={render_desktop_ui && orderLineItems}
            ViewModeSelector(
              value: _viewModel.renderDesktopUi,
              orderLineItems: _viewModel.orderLineItems,
              disabled: _viewModel.enableAddressCod, // disabled prop (enableAddressCOD)
              onChanged: (value) {
                _viewModel.toggleRenderDesktopUi(value);
              },
            ),
            const SizedBox(height: 20),
            // 3. Enable Address & COD (matching React label with toggle)
            ToggleOption(
              label: AppStrings.enableAddressCod,
              value: _viewModel.enableAddressCod,
              onChanged: (value) {
                _viewModel.toggleAddressCod(value);
              },
            ),
            const SizedBox(height: 20),
            // 4. HeaderCoustomizer (matching React HeaderCoustomizer component)
            _buildHeaderCustomisation(),
            const SizedBox(height: 20),
            // 5. PaymentCustomizer (matching React PaymentCustomizer component)
            PaymentCustomisationDropdown(
              value: _viewModel.orderData.paymentCustomisation,
              onChanged: (value) {
                _viewModel.handlePaymentTypeChange(value);
              },
              isDisabled: _viewModel.enableAddressCod || _viewModel.selectedCurrency != 'INR',
            ),
            const SizedBox(height: 20),
            // Sub Payment Customisation Section (only shown for netbanking, wallet, upi)
            if (_viewModel.shouldShowSubPayment(_viewModel.orderData.paymentCustomisation)) ...[
              SubPaymentCustomisationDropdown(
                paymentType: _viewModel.orderData.paymentCustomisation,
                value: _viewModel.orderData.subPaymentCustomisation,
                onChanged: (value) {
                  _viewModel.updateSubPaymentCustomisation(value);
                },
              ),
              const SizedBox(height: 20),
            ],
            // 6. CheckoutExperience (matching React CheckoutExperience component)
            CheckoutExperienceSelector(
              value: _viewModel.checkoutExperience,
              onChanged: (value) {
                _viewModel.updateCheckoutExperience(value);
              },
            ),
            const SizedBox(height: 20),
            ToggleOption(
              label: AppStrings.userDetailsQuestion,
              value: _viewModel.userDetails,
              onChanged: (value) {
                _viewModel.toggleUserDetails(value);
              },
            ),
            if (_viewModel.userDetails) ...[
              const SizedBox(height: 20),
              _buildUserDetailsForm(),
            ],
            const SizedBox(height: 30),
            // Error Message
            if (_viewModel.paymentError != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                ),
                child: Text(
                  _viewModel.paymentError!,
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    color: Colors.red,
                    fontSize: 14,
                    letterSpacing: -0.05,
                  ),
                ),
              ),
            // Pay Now Button
            // Matching React: mt-4 (16px top margin), p-3 (12px padding), rounded-[10px] w-full
            // font-[Gordita-medium] flex items-center justify-center gap-2
            // bg-black text-white hover:bg-gray-800 when enabled
            // bg-gray-400 text-white cursor-not-allowed when disabled/loading
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 40), // Matching React: mt-4 mb-10 (40px on mobile)
              width: double.infinity, // Matching React: w-full
              child: ElevatedButton(
                onPressed: !_viewModel.isPayButtonEnabled()
                    ? null 
                    : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _viewModel.isPaymentLoading || !_viewModel.isPayButtonEnabled()
                      ? Colors.grey[400] // Matching React: bg-gray-400 when disabled/loading
                      : Colors.black, // Matching React: bg-black when enabled
                  foregroundColor: Colors.white, // Matching React: text-white
                  padding: const EdgeInsets.all(12), // Matching React: p-3 (12px)
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Matching React: rounded-[10px]
                  ),
                  elevation: 0,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8), // Matching React: gap-2 (8px)
                          const Text(
                            'Processing...', // Matching React: "Processing..."
                            style: TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 16,
                              fontWeight: FontWeight.w500, // Matching React: font-[Gordita-medium]
                              color: Colors.white,
                              letterSpacing: -0.05,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        AppStrings.payNow,
                        style: const TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: 16,
                          fontWeight: FontWeight.w500, // Matching React: font-[Gordita-medium]
                          color: Colors.white,
                          letterSpacing: -0.05,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }


  Widget _buildUserDetailsForm() {
    return Container(
      margin: const EdgeInsets.only(top: AppConstants.defaultPadding),
      child: Column(
        children: [
          UserDetailField(
            label: AppStrings.name,
            controller: _viewModel.firstNameController,
            onChanged: (value) {
              _viewModel.updateFirstName(value);
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          UserDetailField(
            label: AppStrings.number,
            controller: _viewModel.mobileController,
            keyboardType: TextInputType.phone,
            errorText: _viewModel.numberError,
            onChanged: (value) {
              _viewModel.validateMobileNumber(value);
            },
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          UserDetailField(
            label: AppStrings.emailLowercase,
            controller: _viewModel.emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: _viewModel.emailError,
            onChanged: (value) {
              _viewModel.validateEmail(value);
            },
          ),
        ],
      ),
    );
  }


  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0E0D10),
            Color(0xFF201F22),
            Color(0xFF0E0D10),
          ],
          stops: [0.1, 0.3, 0.9],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Copyright with NimbblIcon
          Row(
            children: [
              Image.asset(
                'assets/images/NimbblIcon.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'N',
                        style: const TextStyle(
                          fontFamily: 'Gordita',
                          letterSpacing: -0.05,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                '© 2025 nimbbl by bigital technologies pvt ltd',
                style: const TextStyle(
                  fontFamily: 'Gordita',
                  color: Color(0xFF606060),
                  fontSize: 12,
                  fontWeight: FontWeight.w500, // Matching React: font-semibold (using medium as closest)
                  letterSpacing: -0.05,
                ),
              ),
            ],
          ),
          // Social Icons
          Row(
            children: [
              _buildSocialIcon(Icons.business, () {}),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.chat_bubble_outline, () {}),
              const SizedBox(width: 16),
              _buildSocialIcon(Icons.play_circle_outline, () {}),
            ],
          ),
          // Legal Links
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'privacy',
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    letterSpacing: -0.05,
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'terms and conditions',
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    letterSpacing: -0.05,
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'about us',
                  style: const TextStyle(
                    fontFamily: 'Gordita',
                    letterSpacing: -0.05,
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        color: Colors.white70,
        size: 20,
      ),
    );
  }
}
