/// Simple Merchant Integration Example
/// 
/// This file demonstrates the MINIMAL code needed for Nimbbl payment integration.
/// This is what merchants should focus on - just 3 simple steps!
/// 
/// For a full-featured demo with UI customization options, see the main app screens.

import 'package:flutter/material.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_sdk.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/types.dart';

/// STEP 1: Initialize SDK (Do this once in your app startup)
/// 
/// In your main.dart or app initialization:
Future<void> initializeNimbblSDK() async {
  // Initialize with default configuration
  await NimbblCheckoutSDK.instance.initialize();
  
  // OR initialize with custom API base URL:
  // await NimbblCheckoutSDK.instance.initialize(
  //   SDKConfig(apiBaseUrl: 'https://api.nimbbl.tech/')
  // );
}

/// STEP 2: Create Order (Usually done on your backend - S2S)
/// 
/// ⚠️ IMPORTANT: In production, order creation should be done server-to-server
/// by your backend. This example shows client-side for demo purposes only.
/// 
/// Your backend should:
/// 1. Call Nimbbl API to create order
/// 2. Return order token to your Flutter app
/// 
/// For demo/testing, you can use OrderCreationService from the sample app.

/// STEP 3: Process Payment (This is all you need in your Flutter app!)
/// 
/// This is the core integration - just call checkout with order token.
Future<void> processPayment(String orderToken) async {
  try {
    // Create checkout options with order token
    final checkoutOptions = CheckoutOptions(
      orderToken: orderToken, // Get this from your backend
    );

    // Call checkout - SDK handles everything!
    final result = await NimbblCheckoutSDK.instance.checkout(checkoutOptions);

    // Handle payment result
    if (result['status'] == 'success') {
      print('✅ Payment successful!');
      print('Payment ID: ${result['payment_id']}');
      print('Order ID: ${result['order_id']}');
      // Navigate to success screen, show success message, etc.
    } else if (result['status'] == 'failed') {
      print('❌ Payment failed: ${result['message']}');
      // Show error message to user
    } else if (result['status'] == 'cancelled') {
      print('⚠️ Payment cancelled by user');
      // User cancelled - return to previous screen
    } else if (result['status'] == 'redirect') {
      // Web platform: redirect mode - browser will redirect automatically
      print('🔄 Redirecting to checkout...');
      // No action needed - browser handles redirect
    }
  } catch (e) {
    print('❌ Error: $e');
    // Handle error
  }
}

/// Complete Example Widget - Minimal Payment Button
/// 
/// This shows the simplest possible integration in a Flutter widget.
class SimplePaymentButton extends StatefulWidget {
  final String orderToken; // Get this from your backend

  const SimplePaymentButton({Key? key, required this.orderToken}) : super(key: key);

  @override
  State<SimplePaymentButton> createState() => _SimplePaymentButtonState();
}

class _SimplePaymentButtonState extends State<SimplePaymentButton> {
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    try {
      // This is all you need - just 2 lines!
      final checkoutOptions = CheckoutOptions(orderToken: widget.orderToken);
      final result = await NimbblCheckoutSDK.instance.checkout(checkoutOptions);

      // Handle result
      if (result['status'] == 'success') {
        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful!')),
        );
      } else if (result['status'] == 'failed') {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePayment,
      child: _isLoading 
        ? CircularProgressIndicator() 
        : Text('Pay Now'),
    );
  }
}

/// That's it! Just 3 simple steps:
/// 
/// 1. Initialize SDK: await NimbblCheckoutSDK.instance.initialize();
/// 2. Get order token from your backend (S2S order creation)
/// 3. Call checkout: await NimbblCheckoutSDK.instance.checkout(CheckoutOptions(orderToken: token));
/// 
/// The SDK handles everything else automatically:
/// - Platform detection (Android/iOS/Web)
/// - Payment flow navigation
/// - Result handling
/// - Error management
/// 
/// For advanced options (payment mode, checkout experience, etc.), see the full sample app.

