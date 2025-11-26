import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Application theme configuration
class AppTheme {
  // Color Palette - Enhanced for prominence
  static const Color primaryColor = Color(0xFF1A1A1A);
  static const Color secondaryColor = Colors.white;
  static const Color accentColor = Color(0xFF007AFF);
  static const Color successColor = Color(0xFF34C759);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color warningColor = Color(0xFFFF9500);
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color surfaceColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF1A1A1A);
  static const Color textSecondaryColor = Color(0xFF48484A);
  static const Color textHintColor = Color(0xFF8E8E93);
  static const Color borderColor = Color(0xFFC7C7CC);
  static const Color inputBackgroundColor = Color(0xFFFFFFFF);

  // Text Styles - Using Gordita font (matching React implementation)
  static const TextStyle headingLarge = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Using medium weight (matching React font-[Gordita-medium])
    color: secondaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle inputText = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 16,
    fontWeight: FontWeight.normal, // Matching Material-UI TextField default (normal weight)
    color: textPrimaryColor,
    letterSpacing: -0.05,
  );

  static const TextStyle hintText = TextStyle(
    fontFamily: 'Gordita',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textHintColor,
    letterSpacing: -0.05,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Gordita', // Set default font family (matching React)
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      textTheme: const TextTheme(
        headlineLarge: headingLarge,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelMedium: labelMedium,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor,
          minimumSize: Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: buttonText,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        hintStyle: hintText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }
}
