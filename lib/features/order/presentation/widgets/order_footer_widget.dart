import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Footer widget for the order creation screen
class OrderFooterWidget extends StatelessWidget {
  const OrderFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
}
