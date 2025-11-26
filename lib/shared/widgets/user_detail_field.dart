import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Shared user detail field widget
/// Used by both mobile and web screens for user input fields
class UserDetailField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? errorText;

  const UserDetailField({
    Key? key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.keyboardType,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Gordita',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            letterSpacing: -0.05,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null ? Colors.red : AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Gordita',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              letterSpacing: -0.05,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
              isDense: true,
              hintText: hintText,
              hintStyle: AppTheme.hintText,
              // Remove errorText from InputDecoration to prevent overflow
              // Error text is displayed separately below the container
            ),
          ),
        ),
        // Display error text outside the container to prevent overflow
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: AppConstants.defaultPadding),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontFamily: 'Gordita',
                fontSize: 12,
                color: Colors.red,
                letterSpacing: -0.05,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

