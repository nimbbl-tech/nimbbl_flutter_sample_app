import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../constants/app_strings.dart';
import '../constants/order_create_data_values.dart';

/// Shared payment customisation dropdown widget
/// Used by both mobile and web screens
class PaymentCustomisationDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool isDisabled;

  const PaymentCustomisationDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.paymentCustomisation,
          // Matching React: text-sm lg:text-base md:text-base (14px mobile, 16px large)
          // font-[Gordita-medium] (weight 500), text-black text-opacity-80
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 14, // Will be 16px on large screens (responsive)
            fontWeight: FontWeight.w500, // Matching React: font-[Gordita-medium]
            color: isDisabled 
                ? Colors.grey[400] 
                : Colors.black.withOpacity(0.8), // Matching React: text-black text-opacity-80
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
            // Matching React: borderColor: '#0000001A' (very light black, ~10% opacity)
            border: Border.all(color: const Color(0x1A000000), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                style: AppTheme.inputText,
                items: paymentTypeList.map((option) {
                  return DropdownMenuItem(
                    value: option.name,
                    child: Row(
                      children: [
                        Icon(option.icon, size: 16), // Matching React: size={16}
                        const SizedBox(width: 16), // Matching React: gap-4 (16px)
                        Expanded(
                          child: Text(
                            option.name,
                            // Matching React: font-[Gordita-medium] text-sm lg:text-base md:text-base
                            style: const TextStyle(
                              fontFamily: 'Gordita',
                              fontSize: 14, // text-sm (14px on mobile, 16px on large screens)
                              fontWeight: FontWeight.w500, // font-[Gordita-medium]
                              letterSpacing: -0.05,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: isDisabled ? null : (String? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

