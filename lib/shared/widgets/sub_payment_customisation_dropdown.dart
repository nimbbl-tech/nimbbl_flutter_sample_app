import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../constants/app_strings.dart';
import '../constants/order_create_data_values.dart';

/// Shared sub payment customisation dropdown widget
/// Used by both mobile and web screens
class SubPaymentCustomisationDropdown extends StatelessWidget {
  final String paymentType;
  final String value;
  final ValueChanged<String> onChanged;

  const SubPaymentCustomisationDropdown({
    Key? key,
    required this.paymentType,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final items = _getSubPaymentItems(paymentType);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.subPaymentCustomisation,
          // Matching React: text-sm lg:text-base md:text-base (14px mobile, 16px large)
          // font-[Gordita-medium] (weight 500), text-black text-opacity-80
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 14, // Will be 16px on large screens (responsive)
            fontWeight: FontWeight.w500, // Matching React: font-[Gordita-medium]
            color: Colors.black.withOpacity(0.8), // Matching React: text-black text-opacity-80
            letterSpacing: -0.05,
          ),
        ),
        const SizedBox(height: 16), // Matching React: mb-4 (16px)
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
              value: value.isEmpty ? null : value,
              isExpanded: true,
              style: AppTheme.inputText,
              items: items.map((ImageWithName item) {
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Row(
                    children: [
                      Image.asset(
                        item.image,
                        width: 16,
                        height: 16,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(width: 16, height: 16);
                        },
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
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

