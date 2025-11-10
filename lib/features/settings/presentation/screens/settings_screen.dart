import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_strings.dart';
import '../../../../shared/widgets/order_create_data_values.dart';
import '../providers/settings_provider.dart';

/// Settings screen for configuring application settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _qaUrlController;

  @override
  void initState() {
    super.initState();
    _qaUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _qaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, child) {
                    // Update the QA URL controller when settings change
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_qaUrlController.text != settingsProvider.settingsData.qaUrl) {
                        _qaUrlController.text = settingsProvider.settingsData.qaUrl;
                      }
                    });
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Environment Section
                        _buildEnvironmentDropdown(settingsProvider),
                        const SizedBox(height: AppConstants.defaultPadding),
                        
                        // QA URL Input (only show when QA is selected)
                        if (settingsProvider.settingsData.environment == AppConstants.environmentQA) ...[
                          _buildQaUrlInput(settingsProvider),
                          const SizedBox(height: AppConstants.defaultPadding),
                        ],
                        
                        // Experience Section
                        _buildExperienceDropdown(settingsProvider),
                        const SizedBox(height: AppConstants.largePadding),
                        
        // Done Button
        _buildDoneButton(),
                      ],
                    );
                  },
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

  Widget _buildEnvironmentDropdown(SettingsProvider settingsProvider) {
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
              value: settingsProvider.settingsData.environment,
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
                  settingsProvider.updateField(environment: newValue);
                  
                  // Set default QA URL when QA is selected (like Android app)
                  if (newValue == AppConstants.environmentQA) {
                    _qaUrlController.text = ApiConstants.defaultQaUrl;
                    settingsProvider.updateField(qaUrl: ApiConstants.defaultQaUrl);
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQaUrlInput(SettingsProvider settingsProvider) {
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
              settingsProvider.updateField(qaUrl: value);
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

  Widget _buildExperienceDropdown(SettingsProvider settingsProvider) {
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
              value: settingsProvider.settingsData.experience,
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
                  settingsProvider.updateField(experience: newValue);
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    // Clear cache and reload with current settings
    await settingsProvider.clearCacheAndReload();
    
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
