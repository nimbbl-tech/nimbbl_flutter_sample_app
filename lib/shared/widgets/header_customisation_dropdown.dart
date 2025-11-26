import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../constants/app_strings.dart';
import '../constants/order_create_data_values.dart';

/// Shared header customisation dropdown widget
/// Used by both mobile and web screens
class HeaderCustomisationDropdown extends StatelessWidget {
  final String value;
  final bool orderLineItems;
  final ValueChanged<String> onChanged;

  const HeaderCustomisationDropdown({
    Key? key,
    required this.value,
    required this.orderLineItems,
    required this.onChanged,
  }) : super(key: key);

  /// Get the indicator color for header customisation options
  /// Matches the React implementation:
  /// - 'your brand name and brand logo' → Dark Blue (DarkBlueBulleticon)
  /// - 'your brand logo' → Light Blue (LighBlueBulletIcon)
  /// - 'your brand name' → Red/Orange (OrangeIcon)
  Color _getHeaderIndicatorColor(String optionName) {
    switch (optionName) {
      case AppStrings.brandNameAndLogo:
        return const Color(0xFF022860); // Dark Blue
      case AppStrings.brandLogo:
        return const Color(0xFF3E6F96); // Light Blue
      case AppStrings.brandName:
        return const Color(0xFFFB381D); // Red/Orange
      default:
        return const Color(0xFF022860); // Default to Dark Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = orderLineItems ? headerCustomTypeEnabledList : headerCustomTypeDisabledList;
    
    // Ensure the current value is valid for the current options
    final currentValue = value;
    final isValid = options.any((option) => option.name == currentValue);
    final validValue = isValid ? currentValue : (options.isNotEmpty ? options.first.name : null);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.headerCustomisation,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validValue,
              isExpanded: true,
              style: AppTheme.inputText,
              items: options.map((option) {
                return DropdownMenuItem(
                  value: option.name,
                  child: Row(
                    children: [
                      Icon(
                        option.icon,
                        size: 18, // Matching React: icon size={18}
                        color: _getHeaderIndicatorColor(option.name),
                      ),
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

