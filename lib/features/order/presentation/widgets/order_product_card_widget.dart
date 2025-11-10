import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

/// Widget that displays just the product image card
class OrderProductCardWidget extends StatelessWidget {
  const OrderProductCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        0,
        AppConstants.defaultPadding,
        AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Image.asset(
          'assets/images/PaperPlane.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
