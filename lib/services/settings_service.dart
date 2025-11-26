import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../models/settings_data.dart';

/// Service for managing application settings - Singleton pattern
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  SettingsData _settingsData = SettingsData(
    environment: AppConstants.defaultEnvironment,
    qaUrl: ApiConstants.defaultQaUrl,
    experience: AppConstants.defaultExperience,
    baseUrl: ApiConstants.defaultEnvironment,
    useAccessCredentials: false,
    accessKey: null,
    accessSecret: null,
  );

  SettingsData get settingsData => _settingsData;

  // Callback for notifying listeners when settings change
  VoidCallback? onSettingsChanged;

  /// Initialize and load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load environment
      final savedBaseUrl = prefs.getString(AppConstants.shopBaseUrlKey) ?? ApiConstants.defaultEnvironment;
      String selectedEnvironment = AppConstants.environmentProd;
      
      // Determine environment based on saved base URL (like Android app)
      if (savedBaseUrl == ApiConstants.baseUrlProd) {
        selectedEnvironment = AppConstants.environmentProd;
      } else if (savedBaseUrl == ApiConstants.baseUrlPreProd) {
        selectedEnvironment = AppConstants.environmentPreProd;
      } else {
        selectedEnvironment = AppConstants.environmentQA;
      }
      
      // Load QA URL if it's a QA environment
      String qaUrl = ApiConstants.defaultQaUrl;
      if (selectedEnvironment == AppConstants.environmentQA) {
        qaUrl = prefs.getString(AppConstants.qaEnvironmentUrlKey) ?? ApiConstants.defaultQaUrl;
      }
      
      // Load experience
      final savedExperience = prefs.getString(AppConstants.sampleAppModeKey) ?? AppConstants.defaultExperience;
      
      // Load access credentials (only for QA environment)
      final useAccessCredentials = prefs.getBool(AppConstants.useAccessCredentialsKey) ?? false;
      final accessKey = prefs.getString(AppConstants.accessKeyKey);
      final accessSecret = prefs.getString(AppConstants.accessSecretKey);

      _settingsData = SettingsData(
        environment: selectedEnvironment,
        qaUrl: qaUrl,
        experience: savedExperience,
        baseUrl: savedBaseUrl,
        useAccessCredentials: useAccessCredentials,
        accessKey: accessKey,
        accessSecret: accessSecret,
      );

      onSettingsChanged?.call();
    } catch (error) {
    }
  }

  /// Update settings data and persist to SharedPreferences
  Future<void> updateSettingsData(SettingsData updates) async {
    try {
      _settingsData = updates;

      final prefs = await SharedPreferences.getInstance();
      
      // Determine the base URL based on environment (like Android app)
      String baseUrl = ApiConstants.defaultEnvironment;
      if (updates.environment == AppConstants.environmentProd) {
        baseUrl = ApiConstants.baseUrlProd;
      } else if (updates.environment == AppConstants.environmentPreProd) {
        baseUrl = ApiConstants.baseUrlPreProd;
      } else if (updates.environment == AppConstants.environmentQA) {
        baseUrl = _formatUrl(updates.qaUrl);
      }
      
      // Save preferences (matching Android app keys)
      await prefs.setString(AppConstants.shopBaseUrlKey, baseUrl);
      await prefs.setString(AppConstants.qaEnvironmentUrlKey, updates.qaUrl);
      await prefs.setString(AppConstants.sampleAppModeKey, updates.experience);
      
      // Save access credentials (only for QA environment)
      await prefs.setBool(AppConstants.useAccessCredentialsKey, updates.useAccessCredentials);
      if (updates.accessKey != null && updates.accessKey!.isNotEmpty) {
        await prefs.setString(AppConstants.accessKeyKey, updates.accessKey!);
      } else {
        await prefs.remove(AppConstants.accessKeyKey);
      }
      if (updates.accessSecret != null && updates.accessSecret!.isNotEmpty) {
        await prefs.setString(AppConstants.accessSecretKey, updates.accessSecret!);
      } else {
        await prefs.remove(AppConstants.accessSecretKey);
      }
      
      // Update the baseUrl in settings data
      _settingsData = _settingsData.copyWith(baseUrl: baseUrl);
      onSettingsChanged?.call();
      
    } catch (error) {
    }
  }

  /// Update specific field
  Future<void> updateField({
    String? environment,
    String? qaUrl,
    String? experience,
    bool? useAccessCredentials,
    String? accessKey,
    String? accessSecret,
  }) async {
    final updatedSettings = _settingsData.copyWith(
      environment: environment,
      qaUrl: qaUrl,
      experience: experience,
      useAccessCredentials: useAccessCredentials,
      accessKey: accessKey,
      accessSecret: accessSecret,
    );

    await updateSettingsData(updatedSettings);
  }

  /// Format URL to ensure proper formatting (like Android app)
  String _formatUrl(String url) {
    if (url.isEmpty) return ApiConstants.defaultQaUrl;
    
    // Ensure URL ends with '/'
    if (!url.endsWith('/')) {
      return '$url/';
    }
    return url;
  }

  /// Clear cache and reload settings
  /// Ensures current settings are saved before reloading
  Future<void> clearCacheAndReload() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the latest QA URL from SharedPreferences in case it was just updated
      // This ensures we use the most recent value
      final latestQaUrl = prefs.getString(AppConstants.qaEnvironmentUrlKey) ?? _settingsData.qaUrl;
      final currentQaUrl = _settingsData.qaUrl.isNotEmpty ? _settingsData.qaUrl : latestQaUrl;
      
      // Calculate and save the baseUrl based on current environment
      String baseUrl = ApiConstants.defaultEnvironment;
      if (_settingsData.environment == AppConstants.environmentProd) {
        baseUrl = ApiConstants.baseUrlProd;
      } else if (_settingsData.environment == AppConstants.environmentPreProd) {
        baseUrl = ApiConstants.baseUrlPreProd;
      } else if (_settingsData.environment == AppConstants.environmentQA) {
        // Use the current QA URL (from _settingsData or latest from prefs)
        baseUrl = _formatUrl(currentQaUrl);
      }
      
      // Save all preferences with current values
      await prefs.setString(AppConstants.shopBaseUrlKey, baseUrl);
      await prefs.setString(AppConstants.qaEnvironmentUrlKey, currentQaUrl);
      await prefs.setString(AppConstants.sampleAppModeKey, _settingsData.experience);
      
      // Save access credentials
      await prefs.setBool(AppConstants.useAccessCredentialsKey, _settingsData.useAccessCredentials);
      if (_settingsData.accessKey != null && _settingsData.accessKey!.isNotEmpty) {
        await prefs.setString(AppConstants.accessKeyKey, _settingsData.accessKey!);
      } else {
        await prefs.remove(AppConstants.accessKeyKey);
      }
      if (_settingsData.accessSecret != null && _settingsData.accessSecret!.isNotEmpty) {
        await prefs.setString(AppConstants.accessSecretKey, _settingsData.accessSecret!);
      } else {
        await prefs.remove(AppConstants.accessSecretKey);
      }
      
      // Update the baseUrl in current settings data WITHOUT reloading
      // This ensures the current environment is preserved
      _settingsData = SettingsData(
        environment: _settingsData.environment, // Preserve current environment
        qaUrl: currentQaUrl, // Use the latest QA URL
        experience: _settingsData.experience, // Preserve current experience
        baseUrl: baseUrl, // Update with calculated baseUrl
        useAccessCredentials: _settingsData.useAccessCredentials, // Preserve access credentials toggle
        accessKey: _settingsData.accessKey, // Preserve access key
        accessSecret: _settingsData.accessSecret, // Preserve access secret
      );
      
      // Notify listeners so UI and other services get the updated settings
      onSettingsChanged?.call();
      
    } catch (error) {
    }
  }
}

