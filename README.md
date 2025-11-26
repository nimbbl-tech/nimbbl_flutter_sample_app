# Nimbbl Flutter Sample App

**🎉 Complete Sample Application Demonstrating Nimbbl Payment Integration!**

## Overview

This is a comprehensive Flutter sample application that demonstrates how to integrate the **Nimbbl Flutter WebView SDK** for payment processing. The app showcases:

- ✅ **Multi-Platform Support**: Android, iOS, and **Web** platforms
- ✅ **Complete Payment Flow**: Order creation, checkout, and payment processing
- ✅ **UI Customization**: Header customization, payment mode selection, checkout experience options
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

### Basic Payment Flow

1. **Create Order**
   - Enter amount and select currency
   - Configure payment options
   - Customize header and payment modes
   - Click "Pay Now" to process payment

2. **Handle Payment Result**
   - Success: Redirects to success screen with transaction details
   - Failed: Shows error message
   - Cancelled: Returns to order screen

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
├── core/
│   ├── constants/        # App constants and configuration
│   ├── services/         # Core services
│   └── theme/            # App theme and styling
├── models/               # Data models
├── screens/              # App screens
│   ├── order_create_screen.dart      # Mobile order creation
│   ├── web_order_create_screen.dart  # Web order creation
│   └── order_success_screen.dart     # Payment success
├── services/             # Business logic services
│   └── order_creation_service.dart   # Order creation API
├── shared/
│   ├── constants/        # Shared constants
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets
└── viewmodels/          # View models for state management
```

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
