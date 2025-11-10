import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/order/presentation/screens/order_create_screen.dart';
import 'features/order/presentation/providers/order_provider.dart';
import 'features/payment/domain/services/payment_service.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final paymentService = PaymentService();
    
    return MultiProvider(
      providers: [
        // Settings Provider - manages app settings (environment, URLs, etc.)
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        // Order Provider - manages order creation and payment processing
        ChangeNotifierProxyProvider<SettingsProvider, OrderProvider>(
          create: (_) => OrderProvider(
            paymentService,
            SettingsProvider(),
          ),
          update: (_, settingsProvider, previous) =>
              previous ?? OrderProvider(paymentService, settingsProvider),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nimbbl Flutter SDK',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
          useMaterial3: true,
        ),
        home: const OrderCreateScreen(),
      ),
    );
  }
}



