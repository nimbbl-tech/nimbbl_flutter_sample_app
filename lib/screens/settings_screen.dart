import 'package:flutter/foundation.dart' show kIsWeb;
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
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _qaUrlController;
  late TextEditingController _accessKeyController;
  late TextEditingController _accessSecretController;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    final settingsData = _settingsService.settingsData;
    _qaUrlController = TextEditingController(text: settingsData.qaUrl);
    _accessKeyController = TextEditingController(text: settingsData.accessKey ?? '');
    _accessSecretController = TextEditingController(text: settingsData.accessSecret ?? '');
    
    // Listen to settings changes
    _settingsService.onSettingsChanged = () {
      if (mounted) {
        setState(() {
          final updatedData = _settingsService.settingsData;
          if (_qaUrlController.text != updatedData.qaUrl) {
            _qaUrlController.text = updatedData.qaUrl;
          }
          if (_accessKeyController.text != (updatedData.accessKey ?? '')) {
            _accessKeyController.text = updatedData.accessKey ?? '';
          }
          if (_accessSecretController.text != (updatedData.accessSecret ?? '')) {
            _accessSecretController.text = updatedData.accessSecret ?? '';
          }
        });
      }
    };
  }

  @override
  void dispose() {
    _settingsService.onSettingsChanged = null;
    _qaUrlController.dispose();
    _accessKeyController.dispose();
    _accessSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsData = _settingsService.settingsData;
    
    if (kIsWeb) {
      // Web-optimized layout
      return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header (matching web_order_create_screen style)
            _buildWebHeader(),
            
            // Content - Left-aligned layout (not centered)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Environment Section
                    _buildEnvironmentDropdown(settingsData, isWeb: true),
                    const SizedBox(height: 24),
                    
                    // QA URL Input (only show when QA is selected)
                    if (settingsData.environment == AppConstants.environmentQA) ...[
                      _buildQaUrlInput(settingsData, isWeb: true),
                      const SizedBox(height: 24),
                      // Access Credentials Section (only for QA)
                      _buildAccessCredentialsSection(settingsData, isWeb: true),
                      const SizedBox(height: 24),
                    ],
                    
                    // Experience Section
                    _buildExperienceDropdown(settingsData, isWeb: true),
                    const SizedBox(height: 32),
                    
                    // Done Button
                    _buildDoneButton(isWeb: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // Mobile layout
    return Scaffold(
      backgroundColor: Colors.white, // White background to match web and React app
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
                      // Access Credentials Section (only for QA)
                      _buildAccessCredentialsSection(settingsData),
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

  Widget _buildWebHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF0E0D10),
            Color(0xFF201F22),
            Color(0xFF0E0D10),
          ],
          stops: [0.1, 0.3, 0.9],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: _handleBackPress,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'Back',
          ),
          // Title
          const Expanded(
            child: Text(
              AppStrings.settings,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.05,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Spacer to balance back button
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEnvironmentDropdown(SettingsData settingsData, {bool isWeb = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.environment,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: isWeb ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: isWeb ? Colors.black.withOpacity(0.8) : AppTheme.textSecondaryColor,
            letterSpacing: -0.05,
          ),
        ),
        SizedBox(height: isWeb ? 16 : AppConstants.smallPadding),
        Container(
          height: isWeb ? 48 : AppConstants.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isWeb ? const Color(0x1A000000) : AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: isWeb
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : [
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
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: isWeb ? 14 : 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                letterSpacing: -0.05,
              ),
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

  Widget _buildQaUrlInput(SettingsData settingsData, {bool isWeb = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.qaUrl,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: isWeb ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: isWeb ? Colors.black.withOpacity(0.8) : AppTheme.textSecondaryColor,
            letterSpacing: -0.05,
          ),
        ),
        SizedBox(height: isWeb ? 16 : AppConstants.smallPadding),
        Container(
          height: isWeb ? 48 : AppConstants.inputFieldHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isWeb ? const Color(0x1A000000) : AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: isWeb
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          clipBehavior: Clip.hardEdge, // Ensure content is clipped properly
          child: TextFormField(
            controller: _qaUrlController,
            onChanged: (value) {
              _settingsService.updateField(qaUrl: value);
            },
            textAlignVertical: TextAlignVertical.center,
            autofillHints: const [AutofillHints.url],
            enableSuggestions: true,
            autocorrect: true,
            keyboardType: TextInputType.url,
            maxLines: 1, // Single line
            textInputAction: TextInputAction.done,
            scrollPadding: EdgeInsets.zero, // Prevent extra padding when scrolling
            style: TextStyle(
              fontFamily: 'Gordita',
              fontSize: isWeb ? 14 : 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
              letterSpacing: -0.05,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true, // Reduce internal padding
              hintText: 'Enter QA URL',
              hintStyle: TextStyle(
                fontFamily: 'Gordita',
                fontSize: isWeb ? 14 : 16,
                fontWeight: FontWeight.normal,
                color: const Color(0xFF8E8E93),
                letterSpacing: -0.05,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceDropdown(SettingsData settingsData, {bool isWeb = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.experience,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: isWeb ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: isWeb ? Colors.black.withOpacity(0.8) : AppTheme.textSecondaryColor,
            letterSpacing: -0.05,
          ),
        ),
        SizedBox(height: isWeb ? 16 : AppConstants.smallPadding),
        Container(
          height: isWeb ? 48 : AppConstants.inputFieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isWeb ? const Color(0x1A000000) : AppTheme.borderColor,
              width: 1,
            ),
            boxShadow: isWeb
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : [
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
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: isWeb ? 14 : 16,
                fontWeight: FontWeight.normal,
                color: Colors.black,
                letterSpacing: -0.05,
              ),
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

  Widget _buildDoneButton({bool isWeb = false}) {
    return Container(
      width: double.infinity,
      height: isWeb ? 48 : 50,
      decoration: isWeb
          ? null
          : BoxDecoration(
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
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: isWeb ? const EdgeInsets.all(12) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          AppStrings.done,
          style: TextStyle(
            fontFamily: 'Gordita',
            fontSize: isWeb ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            letterSpacing: -0.05,
          ),
        ),
      ),
    );
  }

  void _handleBackPress() {
    Navigator.of(context).pop();
  }

  Widget _buildAccessCredentialsSection(SettingsData settingsData, {bool isWeb = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle for using access credentials
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.useAccessCredentials,
              style: TextStyle(
                fontFamily: 'Gordita',
                fontSize: isWeb ? 14 : 12,
                fontWeight: FontWeight.w500,
                color: isWeb ? Colors.black.withOpacity(0.8) : AppTheme.textSecondaryColor,
                letterSpacing: -0.05,
              ),
            ),
            Checkbox(
              value: settingsData.useAccessCredentials,
              onChanged: (bool? value) {
                final newValue = value ?? false;
                _settingsService.updateField(useAccessCredentials: newValue);
                // Clear access credentials when unchecked
                if (!newValue) {
                  _accessKeyController.clear();
                  _accessSecretController.clear();
                  _settingsService.updateField(
                    accessKey: '',
                    accessSecret: '',
                  );
                }
              },
              activeColor: Colors.black,
            ),
          ],
        ),
        
        // Access Key and Secret inputs (only show when toggle is enabled)
        if (settingsData.useAccessCredentials) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              // Access Key
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.accessKey,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: isWeb ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: isWeb ? Colors.black.withOpacity(0.8) : AppTheme.textSecondaryColor,
                        letterSpacing: -0.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: isWeb ? 48 : AppConstants.inputFieldHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isWeb ? const Color(0x1A000000) : AppTheme.borderColor,
                          width: 1,
                        ),
                        boxShadow: isWeb
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                      ),
                      child: TextFormField(
                        controller: _accessKeyController,
                        onChanged: (value) {
                          _settingsService.updateField(accessKey: value);
                        },
                        textAlignVertical: TextAlignVertical.center,
                        autofillHints: const [AutofillHints.username],
                        enableSuggestions: true,
                        autocorrect: true,
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: isWeb ? 14 : 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          letterSpacing: -0.05,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: AppStrings.enterAccessKey,
                          hintStyle: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: isWeb ? 14 : 16,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFF8E8E93),
                            letterSpacing: -0.05,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Access Secret
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.accessSecret,
                      style: TextStyle(
                        fontFamily: 'Gordita',
                        fontSize: isWeb ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: isWeb ? Colors.black.withOpacity(0.8) : AppTheme.textSecondaryColor,
                        letterSpacing: -0.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: isWeb ? 48 : AppConstants.inputFieldHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isWeb ? const Color(0x1A000000) : AppTheme.borderColor,
                          width: 1,
                        ),
                        boxShadow: isWeb
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                      ),
                      child: TextFormField(
                        controller: _accessSecretController,
                        onChanged: (value) {
                          _settingsService.updateField(accessSecret: value);
                        },
                        textAlignVertical: TextAlignVertical.center,
                        obscureText: true, // Hide secret input
                        autofillHints: const [AutofillHints.password],
                        enableSuggestions: true,
                        autocorrect: false, // Keep autocorrect false for passwords
                        style: TextStyle(
                          fontFamily: 'Gordita',
                          fontSize: isWeb ? 14 : 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                          letterSpacing: -0.05,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: AppStrings.enterAccessSecret,
                          hintStyle: TextStyle(
                            fontFamily: 'Gordita',
                            fontSize: isWeb ? 14 : 16,
                            fontWeight: FontWeight.normal,
                            color: const Color(0xFF8E8E93),
                            letterSpacing: -0.05,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _handleDonePress() async {
    // If QA environment is selected, ensure the QA URL from the text controller is saved
    if (_settingsService.settingsData.environment == AppConstants.environmentQA) {
      final qaUrlFromController = _qaUrlController.text.trim();
      if (qaUrlFromController.isNotEmpty && qaUrlFromController != _settingsService.settingsData.qaUrl) {
        // Update the QA URL if it's different from what's in settings
        await _settingsService.updateField(qaUrl: qaUrlFromController);
      }
      
      // Save access credentials if enabled
      if (_settingsService.settingsData.useAccessCredentials) {
        await _settingsService.updateField(
          accessKey: _accessKeyController.text.trim(),
          accessSecret: _accessSecretController.text.trim(),
        );
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
