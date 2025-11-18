/// Settings data model for application configuration - Matching Android app approach
class SettingsData {
  final String environment;
  final String qaUrl;
  final String experience;
  final String baseUrl; // Single base URL like Android app

  const SettingsData({
    required this.environment,
    required this.qaUrl,
    required this.experience,
    required this.baseUrl,
  });

  /// Create a copy of this SettingsData with the given fields replaced with new values
  SettingsData copyWith({
    String? environment,
    String? qaUrl,
    String? experience,
    String? baseUrl,
  }) {
    return SettingsData(
      environment: environment ?? this.environment,
      qaUrl: qaUrl ?? this.qaUrl,
      experience: experience ?? this.experience,
      baseUrl: baseUrl ?? this.baseUrl,
    );
  }

  @override
  String toString() {
    return 'SettingsData(environment: $environment, qaUrl: $qaUrl, experience: $experience, baseUrl: $baseUrl)';
  }
}
