import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/order_provider.dart';
import '../widgets/order_form_widget.dart';
import '../widgets/order_header_widget.dart';
import '../widgets/order_footer_widget.dart';
import 'order_success_screen.dart';

/// Main order creation screen using proper Flutter architecture
class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen({super.key});

  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializePaymentService();
  }

  /// Initialize payment service (simplified - no callback needed)
  void _initializePaymentService() {
    // Payment service callback is no longer needed - results are handled directly in OrderProvider
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        // Listen for checkout results and navigate accordingly
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (orderProvider.checkoutResult != null && !_hasNavigated) {
            _hasNavigated = true;
            // Navigate to success screen (handles both success and failure cases)
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OrderSuccessScreen(
                  paymentData: orderProvider.checkoutResult!,
                ),
              ),
            );
          }
        });

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                const OrderHeaderWidget(),
                
                // Scrollable Content
                const Expanded(
                  child: OrderFormWidget(),
                ),
                
                // Footer
                const OrderFooterWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
