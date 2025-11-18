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

      _settingsData = SettingsData(
        environment: selectedEnvironment,
        qaUrl: qaUrl,
        experience: savedExperience,
        baseUrl: savedBaseUrl,
      );

      onSettingsChanged?.call();
    } catch (error) {
      debugPrint('SettingsService: Error loading settings: $error');
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
      
      // Update the baseUrl in settings data
      _settingsData = _settingsData.copyWith(baseUrl: baseUrl);
      onSettingsChanged?.call();
      
    } catch (error) {
      debugPrint('SettingsService: Error saving settings: $error');
    }
  }

  /// Update specific field
  Future<void> updateField({
    String? environment,
    String? qaUrl,
    String? experience,
  }) async {
    final updatedSettings = _settingsData.copyWith(
      environment: environment,
      qaUrl: qaUrl,
      experience: experience,
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
      
      // Update the baseUrl in current settings data WITHOUT reloading
      // This ensures the current environment is preserved
      _settingsData = SettingsData(
        environment: _settingsData.environment, // Preserve current environment
        qaUrl: currentQaUrl, // Use the latest QA URL
        experience: _settingsData.experience, // Preserve current experience
        baseUrl: baseUrl, // Update with calculated baseUrl
      );
      
      // Notify listeners so UI and other services get the updated settings
      onSettingsChanged?.call();
      
    } catch (error) {
      debugPrint('SettingsService: Error in clearCacheAndReload: $error');
    }
  }
}

