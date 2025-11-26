/// Settings data model for application configuration - Matching Android app approach
class SettingsData {
  final String environment;
  final String qaUrl;
  final String experience;
  final String baseUrl; // Single base URL like Android app
  final bool useAccessCredentials; // Toggle for using access key/secret
  final String? accessKey; // Access key for checkout (QA only)
  final String? accessSecret; // Access secret for checkout (QA only)

  const SettingsData({
    required this.environment,
    required this.qaUrl,
    required this.experience,
    required this.baseUrl,
    this.useAccessCredentials = false,
    this.accessKey,
    this.accessSecret,
  });

  /// Create a copy of this SettingsData with the given fields replaced with new values
  SettingsData copyWith({
    String? environment,
    String? qaUrl,
    String? experience,
    String? baseUrl,
    bool? useAccessCredentials,
    String? accessKey,
    String? accessSecret,
  }) {
    return SettingsData(
      environment: environment ?? this.environment,
      qaUrl: qaUrl ?? this.qaUrl,
      experience: experience ?? this.experience,
      baseUrl: baseUrl ?? this.baseUrl,
      useAccessCredentials: useAccessCredentials ?? this.useAccessCredentials,
      accessKey: accessKey ?? this.accessKey,
      accessSecret: accessSecret ?? this.accessSecret,
    );
  }

  @override
  String toString() {
    return 'SettingsData(environment: $environment, qaUrl: $qaUrl, experience: $experience, baseUrl: $baseUrl, useAccessCredentials: $useAccessCredentials)';
  }
}
