import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'app_strings.dart';

/// Helper classes for dropdown items with icons and images
class IconWithName {
  final IconData icon;
  final String name;

  const IconWithName({
    required this.icon,
    required this.name,
  });
}

class ImageWithName {
  final String image;
  final String name;

  const ImageWithName({
    required this.image,
    required this.name,
  });
}


/// Default values for header customisation
const String selectedHeaderEnabled = AppStrings.brandNameAndLogo;
const String selectedHeaderDisable = AppStrings.brandName;

/// Payment type list with icons
/// Matching React icons:
/// - 'all payments modes': GrAppsRounded → Icons.apps (grid/apps icon)
/// - 'netbanking': RiBankLine → Icons.account_balance (bank icon)
/// - 'wallet': TbWallet → Icons.account_balance_wallet (wallet icon)
/// - 'card': TbCreditCard → Icons.credit_card (credit card icon)
/// - 'upi': UpiIcon (custom SVG) → Icons.qr_code (UPI QR code icon)
/// - 'emi': MdCreditCard → Icons.credit_card (credit card icon, but EMI is not in main list)
const List<IconWithName> paymentTypeList = [
  IconWithName(icon: Icons.apps, name: AppConstants.defaultPaymentMode), // GrAppsRounded → grid/apps icon
  IconWithName(icon: Icons.account_balance, name: 'netbanking'), // RiBankLine → bank icon
  IconWithName(icon: Icons.account_balance_wallet, name: 'wallet'), // TbWallet → wallet icon
  IconWithName(icon: Icons.credit_card, name: 'card'), // TbCreditCard → credit card icon
  IconWithName(icon: Icons.qr_code, name: 'upi'), // UpiIcon (custom SVG) → UPI QR code icon
];

/// Header customisation options when order line items are enabled
const List<IconWithName> headerCustomTypeEnabledList = [
  IconWithName(icon: Icons.fiber_manual_record, name: AppStrings.brandNameAndLogo),
  IconWithName(icon: Icons.fiber_manual_record, name: AppStrings.brandLogo),
];

/// Header customisation options when order line items are disabled
const List<IconWithName> headerCustomTypeDisabledList = [
  IconWithName(icon: Icons.fiber_manual_record, name: AppStrings.brandName),
];

/// Header customisation options when Address & COD is enabled
/// Should show: MustBuy, BallMart, TripKart (PRODUCT_LIST[5], PRODUCT_LIST[6], PRODUCT_LIST[7])
/// - PRODUCT_LIST[5]: value '5', label 'MustBuy'
/// - PRODUCT_LIST[6]: value '6', label 'BallMart'
/// - PRODUCT_LIST[7]: value '7', label 'TripKart'
const List<IconWithName> headerCustomTypeAddressCodList = [
  IconWithName(icon: Icons.fiber_manual_record, name: AppStrings.mustBuy), // value '5'
  IconWithName(icon: Icons.fiber_manual_record, name: AppStrings.ballMart), // value '6'
  IconWithName(icon: Icons.fiber_manual_record, name: AppStrings.tripKart), // value '7'
];

/// Netbanking sub-payment types with images
const List<ImageWithName> netBankingSubPaymentTypeList = [
  ImageWithName(image: 'assets/icons/hdfcBankLogo.png', name: 'hdfc bank'),
  ImageWithName(image: 'assets/icons/sbiBankLogo.png', name: 'sbi bank'),
  ImageWithName(image: 'assets/icons/kotakBankLogo.png', name: 'kotak bank'),
  ImageWithName(image: 'assets/icons/grid.png', name: 'all banks'),
];

/// Wallet sub-payment types with images
const List<ImageWithName> walletSubPaymentTypeList = [
  ImageWithName(image: 'assets/icons/freecharge.png', name: 'freecharge'),
  ImageWithName(image: 'assets/icons/jiomoney.png', name: 'jio money'),
  ImageWithName(image: 'assets/icons/phonepe.png', name: 'phonepe'),
  ImageWithName(image: 'assets/icons/grid.png', name: 'all wallets'),
];

/// UPI sub-payment types with images
const List<ImageWithName> upiSubPaymentTypeList = [
  ImageWithName(image: 'assets/icons/upi.png', name: 'collect + intent'),
  ImageWithName(image: 'assets/icons/phonepe.png', name: 'collect'),
  ImageWithName(image: 'assets/icons/upi.png', name: 'intent'),
];

/// Currency options
const List<String> currencyOptions = [
  AppConstants.defaultCurrency,
  'USD',
  'CAD',
  'EUR'
];

/// Environment options - Matching Android app exactly
const List<String> environmentOptions = [
  AppConstants.environmentProd,
  AppConstants.environmentPreProd,
  AppConstants.environmentQA,
];

/// Experience options - Matching Android app exactly
const List<String> experienceOptions = [
  AppConstants.experienceWebView,
  AppConstants.experienceNative,
];
