# Nimbbl Flutter Sample App

**🎉 Complete Sample Application Demonstrating Nimbbl Payment Integration!**

## Overview

This is a comprehensive Flutter sample application that demonstrates how to integrate the **Nimbbl Flutter WebView SDK** for payment processing.

**🎯 For Merchants:** The integration is actually very simple - just 3 steps! See the [Simple Integration](#-simple-merchant-integration-3-steps) section below.

**📱 Full Demo App:** This sample app includes many demo features for testing and showcasing capabilities:

- ✅ **Multi-Platform Support**: Android, iOS, and **Web** platforms
- ✅ **Complete Payment Flow**: Order creation, checkout, and payment processing
- ✅ **UI Customization**: Header customization, payment mode selection, checkout experience options (for demo/testing)
- ✅ **Responsive Design**: Optimized UI for both mobile and web platforms
- ✅ **Real-World Examples**: Production-ready code patterns and best practices

## 🚀 Features

### Payment Integration
- Order creation with customizable options
- Multiple payment modes (All, Netbanking, UPI, Wallet, Card, EMI)
- Sub-payment mode selection
- Checkout experience options (Redirect, Pop-up)
- User details prefill support

### Platform Support
- **Android**: Full native Android WebView integration
- **iOS**: Full native iOS WebView integration
- **Web**: Native web support with browser-based payment flow

### Customization Options
- Header customization (Brand name, logo, or both)
- Payment mode filtering
- View mode selector (Mobile/Desktop) for web
- Address & COD enablement
- Order line items toggle

Ready to explore? Let's get started! 🚀

## Getting Started

### Prerequisites

- Flutter SDK 3.3.0 or higher
- Dart SDK 2.12.0 or higher
- Android Studio / Xcode (for mobile development)
- Modern web browser (for web platform)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/nimbbl-tech/nimbbl_flutter_sample_app.git
   cd nimbbl_flutter_sample_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   
   # For Web
   flutter run -d chrome
   ```

## App Structure

### Screens

- **Order Create Screen** (`lib/screens/order_create_screen.dart`)
  - Mobile-optimized payment interface
  - Product visualization
  - Payment configuration options

- **Web Order Create Screen** (`lib/screens/web_order_create_screen.dart`)
  - Web-optimized payment interface
  - Split-panel layout (product preview + configuration)
  - View mode selector (Mobile/Desktop)

- **Order Success Screen** (`lib/screens/order_success_screen.dart`)
  - Payment result display
  - Transaction details

### Key Components

- **View Mode Selector**: Toggle between mobile and desktop view modes (web only)
- **Currency Amount Input**: Currency dropdown with amount input
- **Header Customisation Dropdown**: Select header style
- **Payment Customisation Dropdown**: Select payment modes
- **Checkout Experience Selector**: Choose redirect or popup experience
- **Toggle Options**: Various configuration toggles

## Usage

### 🎯 Simple Merchant Integration (3 Steps)

For merchants who just want to integrate payments, here's all you need:

**1. Initialize SDK** (once in your app)
```dart
await NimbblCheckoutSDK.instance.initialize();
```

**2. Get Order Token** (from your backend - S2S order creation)
```dart
// Your backend creates order via Nimbbl API and returns orderToken
String orderToken = await yourBackend.createOrder(...);
```

**3. Process Payment**
```dart
final result = await NimbblCheckoutSDK.instance.checkout(
  CheckoutOptions(orderToken: orderToken)
);

if (result['status'] == 'success') {
  // Payment successful!
} else if (result['status'] == 'failed') {
  // Payment failed
}
```

**That's it!** See `lib/examples/simple_integration_example.dart` for complete minimal example.

---

### 📱 Full Sample App Features

This sample app includes many demo features for testing. For production, you typically only need the 3 steps above.

**Demo Features (for testing only):**
1. **Create Order** - Client-side order creation (use S2S in production)
   - Enter amount and select currency
   - Configure payment options
   - Customize header and payment modes
   - Click "Pay Now" to process payment

2. **Handle Payment Result**
   - Success: Redirects to success screen with transaction details
   - Failed: Shows error message
   - Cancelled: Returns to order screen

**What Merchants Actually Need:**
- SDK initialization
- Order token from backend
- Checkout call
- Result handling

## Platform-Specific Notes

### Web Platform
- Automatically detects web platform
- Uses browser navigation for payment flow
- Supports both redirect and popup checkout experiences
- View mode selector available for desktop screens (≥1024px)
- Callback URLs automatically handled

### Mobile Platforms
- Native WebView integration
- Full support for all payment methods
- Optimized UI for mobile screens
- Portrait orientation lock (mobile only)

## Dependencies

### Core Dependencies
- `nimbbl_mobile_kit_flutter_webview_sdk`: Nimbbl Flutter WebView SDK (v1.1.1-alpha.2)
- `dio`: HTTP client for API calls
- `url_launcher`: External URL handling

### UI Dependencies
- `flutter_svg`: SVG image support
- `dropdown_button2`: Enhanced dropdown widgets
- `dotted_border`: Dotted border styling
- `google_fonts`: Font management

### Optional Dependencies
- `firebase_core`, `firebase_crashlytics`, `firebase_analytics`: Firebase integration (disabled by default)

## Project Structure

```
lib/
├── examples/
│   └── simple_integration_example.dart  # ⭐ START HERE - Minimal integration example
├── core/
│   ├── constants/        # App constants and configuration
│   ├── services/         # Core services
│   └── theme/            # App theme and styling
├── models/               # Data models
├── screens/              # Full demo app screens
│   ├── order_create_screen.dart      # Mobile order creation
│   ├── web_order_create_screen.dart  # Web order creation
│   └── order_success_screen.dart     # Payment success
├── services/             # Business logic services
│   ├── payment_service.dart          # Payment processing wrapper
│   └── order_creation_service.dart   # Order creation API (demo only - use S2S in production)
├── shared/
│   ├── constants/        # Shared constants
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets
└── viewmodels/          # View models for state management (demo app complexity)
```

**For Merchant Integration:**
- Focus on: `lib/examples/simple_integration_example.dart`
- The rest is for demo/testing purposes

## Platform-Specific Setup

### Android
- Minimum SDK: 21
- Target SDK: 34
- Compile SDK: 34

### iOS
- Minimum iOS: 13.0
- Swift-based implementation

### Web
- Flutter 3.3.0 or higher
- Modern browser support
- HTTPS recommended for production

## Support

- 📚 **SDK Documentation**: [Nimbbl Flutter SDK Docs](https://pub.dev/documentation/nimbbl_mobile_kit_flutter_webview_sdk/latest/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/nimbbl-tech/nimbbl_flutter_sample_app/issues)
- 💬 **Support**: [support@nimbbl.biz](mailto:support@nimbbl.biz)
- 🌐 **Website**: [nimbbl.biz](https://nimbbl.biz/)

## License

This sample app is provided as-is for demonstration purposes.
