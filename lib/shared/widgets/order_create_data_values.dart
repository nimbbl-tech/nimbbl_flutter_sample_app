import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

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
const String selectedHeaderEnabled = 'your brand name and brand logo';
const String selectedHeaderDisable = 'your brand name';

/// Payment type list with icons
const List<IconWithName> paymentTypeList = [
  IconWithName(icon: Icons.payment, name: AppConstants.defaultPaymentMode),
  IconWithName(icon: Icons.account_balance, name: 'netbanking'),
  IconWithName(icon: Icons.account_balance_wallet, name: 'wallet'),
  IconWithName(icon: Icons.credit_card, name: 'card'),
  IconWithName(icon: Icons.phone_android, name: 'upi'),
];

/// Header customisation options when order line items are enabled
const List<IconWithName> headerCustomTypeEnabledList = [
  IconWithName(icon: Icons.fiber_manual_record, name: 'your brand name and brand logo'),
  IconWithName(icon: Icons.fiber_manual_record, name: 'your brand logo'),
];

/// Header customisation options when order line items are disabled
const List<IconWithName> headerCustomTypeDisabledList = [
  IconWithName(icon: Icons.fiber_manual_record, name: 'your brand name'),
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
