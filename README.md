# Nimbbl Flutter SDK - Merchant Integration Guide

**🎉 Production Ready SDK - Simple Integration!**

## 🚀 Release Announcement

We are pleased to announce the release of **Nimbbl Flutter SDK v1.1.0**. This major update brings:

- ✅ **Simplified Integration**: Get started with just 3 lines of code
- ✅ **Enhanced Error Handling**: Better debugging and error management
- ✅ **Improved Performance**: Faster initialization and payment processing

**What's New:**
- Streamlined API for easier integration
- Comprehensive documentation with real-world examples
- Optimized for Flutter 3.x compatibility
- **App Code Support**: Enhanced SDK identification
- **Latest Native SDKs**: Updated to Android v4.0.9 and iOS ~> 2.0.16
- **Semantic Versioning**: Implemented proper semantic versioning for better dependency management

Ready to integrate? Let's get started! 🚀

## Quick Start (3 Lines of Code)

### 1. Add Dependency

```yaml
dependencies:
  nimbbl_mobile_kit_flutter_webview_sdk: ^1.1.0
```

### 2. Initialize SDK

```dart
await NimbblCheckoutSDK.instance.initialize();
```

### 3. Process Payment

```dart
final result = await NimbblCheckoutSDK.instance.checkout(
  CheckoutOptions(orderToken: "your_order_token_from_backend")
);

// Handle payment result
if (result['status'] == 'success') {
  print('Payment successful!');
  print('Order ID: ${result['order_id']}');
  print('Transaction ID: ${result['transaction_id']}');
} else if (result['status'] == 'failed') {
  print('Payment failed: ${result['message']}');
} else if (result['status'] == 'cancelled') {
  print('Payment cancelled by user');
}
```

## Complete Integration Example

Here's a complete Flutter widget implementation showing how to integrate the Nimbbl SDK:

```dart
import 'package:flutter/material.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/nimbbl_checkout_sdk.dart';
import 'package:nimbbl_mobile_kit_flutter_webview_sdk/types.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  // Step 1: Initialize SDK
  Future<void> _initializeSDK() async {
    await NimbblCheckoutSDK.instance.initialize();
  }

  // Step 2: Process Payment
  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final options = CheckoutOptions(
        orderToken: "your_order_token_from_backend",
      );

      final result = await NimbblCheckoutSDK.instance.checkout(options);

      // Handle payment result
      if (result['status'] == 'success') {
        print('Payment successful!');
        print('Order ID: ${result['order_id']}');
        print('Transaction ID: ${result['transaction_id']}');
      } else if (result['status'] == 'failed') {
        print('Payment failed: ${result['message']}');
      } else if (result['status'] == 'cancelled') {
        print('Payment cancelled by user');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _processPayment,
          child: _isLoading ? CircularProgressIndicator() : Text('Pay Now'),
        ),
      ),
    );
  }
}
```

## Advanced Configuration

### Error Handling Best Practices

```dart
try {
  final result = await NimbblCheckoutSDK.instance.checkout(options);
  
  switch (result['status']) {
    case 'success':
      // Payment successful
      print('Order ID: ${result['order_id']}');
      print('Transaction ID: ${result['transaction_id']}');
      print('Amount: ${result['amount']}');
      print('Currency: ${result['currency']}');
      break;
    case 'failed':
      // Payment failed
      print('Error: ${result['message']}');
      print('Reason: ${result['reason']}');
      break;
    case 'cancelled':
      // User cancelled payment
      print('Payment cancelled by user');
      break;
    default:
      print('Unknown status: ${result['status']}');
  }
} catch (e) {
  // Handle SDK errors
  print('SDK Error: $e');
}
```

## Platform-Specific Setup

### Android Setup

Add to your `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS Setup

Add to your `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

## Support

- 📚 **Documentation**: [Flutter SDK Docs](https://nimbbl.biz/docs/standard-checkout/setting-client/flutter/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/nimbbl-tech/nimbbl_flutter_sample_app/issues)
- 💬 **Support**: [support@nimbbl.biz](mailto:support@nimbbl.biz)

## Changelog

### v1.1.0 (Latest)
- ✅ **Semantic Versioning**: Implemented proper semantic versioning for better dependency management
- ✅ **Enhanced iOS Integration**: Improved Flutter plugin configuration for iOS WebView SDK compatibility
- ✅ **Module Resolution**: Fixed iOS module import issues with proper podspec configuration
- ✅ **Updated Native SDKs**: Android v4.0.9, iOS ~> 2.0.16
- ✅ **iOS Build Issues**: Enhanced Flutter plugin configuration for better iOS WebView SDK integration
