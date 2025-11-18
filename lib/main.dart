import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/services/firebase_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/order_create_screen.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase conditionally (disabled by default)
  await FirebaseService.initialize();

  // Initialize services
  final settingsService = SettingsService();
  await settingsService.loadSettings();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nimbbl Flutter SDK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
        useMaterial3: true,
      ),
      home: const OrderCreateScreen(),
    );
  }
}



