import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/settings_data.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/api_constants.dart';

/// Provider for managing application settings - Matching Android app approach
class SettingsProvider extends ChangeNotifier {
  SettingsData _settingsData = SettingsData(
    environment: AppConstants.defaultEnvironment,
    qaUrl: ApiConstants.defaultQaUrl,
    experience: AppConstants.defaultExperience,
    baseUrl: ApiConstants.defaultEnvironment,
  );

  SettingsData get settingsData => _settingsData;

  SettingsProvider() {
    _loadSettings();
  }

  /// Load settings from SharedPreferences - Matching Android app approach
  Future<void> _loadSettings() async {
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

      notifyListeners();
    } catch (error) {
      debugPrint('🔧 SettingsProvider: Error loading settings: $error');
    }
  }

  /// Update settings data and persist to SharedPreferences - Matching Android app approach
  Future<void> updateSettingsData(SettingsData updates) async {
    try {
      _settingsData = updates;
      notifyListeners();

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
      notifyListeners();
      
    } catch (error) {
      debugPrint('🔧 SettingsProvider: Error saving settings: $error');
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
  Future<void> clearCacheAndReload() async {
    await _loadSettings();
  }
}