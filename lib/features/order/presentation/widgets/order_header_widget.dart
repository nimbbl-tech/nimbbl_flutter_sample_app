import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';

/// Header widget for the order creation screen
class OrderHeaderWidget extends StatelessWidget {
  const OrderHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 0,
      ),
      child: Row(
        children: [
          // App Logo
          Image.asset(
            'assets/images/headerLogo.png',
            height: 32,
            width: 32,
          ),
          const SizedBox(width: AppConstants.smallPadding),
          
          // App Title
          const Expanded(
            child: Text(
              'by nimbbl.',
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 12,
              ),
            ),
          ),
          
          // Settings Button
          IconButton(
            onPressed: () => _navigateToSettings(context),
            icon: const Icon(
              Icons.settings,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
