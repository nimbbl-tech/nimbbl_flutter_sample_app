import 'package:flutter/material.dart';

import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/settings_data.dart';
import '../services/settings_service.dart';
import '../shared/constants/app_strings.dart';
import '../shared/constants/order_create_data_values.dart';

/// Settings screen for configuring application settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _qaUrlController;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _qaUrlController = TextEditingController(text: _settingsService.settingsData.qaUrl);
    
    // Listen to settings changes
    _settingsService.onSettingsChanged = () {
      if (mounted) {
        setState(() {
          if (_qaUrlController.text != _settingsService.settingsData.qaUrl) {
            _qaUrlController.text = _settingsService.settingsData.qaUrl;
          }
        });
      }
    };
  }

  @override
  void dispose() {
    _settingsService.onSettingsChanged = null;
    _qaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsData = _settingsService.settingsData;
    
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppConstants.defaultPadding,
                  top: AppConstants.smallPadding,
                  right: AppConstants.defaultPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Environment Section
                    _buildEnvironmentDropdown(settingsData),
                    const SizedBox(height: AppConstants.defaultPadding),
                    
                    // QA URL Input (only show when QA is selected)
                    if (settingsData.environment == AppConstants.environmentQA) ...[
                      _buildQaUrlInput(settingsData),
                      const SizedBox(height: AppConstants.defaultPadding),
                    ],
                    
                    // Experience Section
                    _buildExperienceDropdown(settingsData),
                    const SizedBox(height: AppConstants.largePadding),
                    
                    // Done Button
                    _buildDoneButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          IconButton(
            color: Colors.transparent,
            onPressed: _handleBackPress,
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.secondaryColor,
            ),
          ),
          const Expanded(
            child: Text(
              AppStrings.settings,
              style: TextStyle(
                color: AppTheme.secondaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildEnvironmentDropdown(SettingsData settingsData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.environment,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: settingsData.environment,
              isExpanded: true,
              style: AppTheme.inputText,
              items: environmentOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _settingsService.updateField(environment: newValue);
                  
                  // Set default QA URL when QA is selected (like Android app)
                  if (newValue == AppConstants.environmentQA) {
                    _qaUrlController.text = ApiConstants.defaultQaUrl;
                    _settingsService.updateField(qaUrl: ApiConstants.defaultQaUrl);
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQaUrlInput(SettingsData settingsData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.qaUrl,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: TextFormField(
            controller: _qaUrlController,
            onChanged: (value) {
              _settingsService.updateField(qaUrl: value);
            },
            textAlignVertical: TextAlignVertical.center,
            style: AppTheme.inputText,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Enter QA URL',
              hintStyle: AppTheme.hintText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceDropdown(SettingsData settingsData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.experience,
          style: AppTheme.labelMedium,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          height: AppConstants.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: AppTheme.inputBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: settingsData.experience,
              isExpanded: true,
              style: AppTheme.inputText,
              items: experienceOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _settingsService.updateField(experience: newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleDonePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          AppStrings.done,
          style: AppTheme.buttonText,
        ),
      ),
    );
  }

  void _handleBackPress() {
    Navigator.of(context).pop();
  }

  void _handleDonePress() async {
    // If QA environment is selected, ensure the QA URL from the text controller is saved
    if (_settingsService.settingsData.environment == AppConstants.environmentQA) {
      final qaUrlFromController = _qaUrlController.text.trim();
      if (qaUrlFromController.isNotEmpty && qaUrlFromController != _settingsService.settingsData.qaUrl) {
        // Update the QA URL if it's different from what's in settings
        await _settingsService.updateField(qaUrl: qaUrlFromController);
      }
    }
    
    // Clear cache and reload with current settings
    await _settingsService.clearCacheAndReload();
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
    
    Navigator.of(context).pop();
  }
}
