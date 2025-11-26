import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import 'radio_option.dart';

/// Shared checkout experience selector widget
/// Used by web screen for selecting pop-up or redirect checkout experience
class CheckoutExperienceSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CheckoutExperienceSelector({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.checkoutExperience,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.8),
            letterSpacing: -0.05,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            RadioOption(
              label: AppStrings.checkoutExperiencePopUpDisplay,
              isSelected: value == AppStrings.checkoutExperiencePopUp,
              onTap: () => onChanged(AppStrings.checkoutExperiencePopUp),
            ),
            const SizedBox(width: 64),
            RadioOption(
              label: AppStrings.checkoutExperienceRedirect,
              isSelected: value == AppStrings.checkoutExperienceRedirect,
              onTap: () => onChanged(AppStrings.checkoutExperienceRedirect),
            ),
          ],
        ),
      ],
    );
  }
}

