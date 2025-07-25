import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late final AppConfig _instance;

  static AppConfig get instance => _instance;

  // Supabase Configuration
  late final String supabaseUrl;
  late final String supabaseAnonKey;

  // App Configuration
  late final String appName;
  late final String appVersion;
  late final String environment;
  late final bool debugMode;

  AppConfig._();

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    _instance = AppConfig._();
    _instance._loadConfig();
  }

  void _loadConfig() {
    // Supabase Configuration
    supabaseUrl = _getRequiredString('SUPABASE_URL');
    supabaseAnonKey = _getRequiredString('SUPABASE_ANON_KEY');

    // App Configuration
    appName = _getString('APP_NAME', 'Journalee');
    appVersion = _getString('APP_VERSION', '1.0.0');
    environment = _getString('ENVIRONMENT', 'development');
    debugMode = _getBool('DEBUG_MODE', true);

    // Validate configuration
    _validateConfig();
  }

  String _getRequiredString(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception(
          'Required environment variable $key is not set or is empty');
    }
    return value;
  }

  String _getString(String key, String defaultValue) {
    return dotenv.env[key] ?? defaultValue;
  }

  bool _getBool(String key, bool defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true';
  }

  int _getInt(String key, int defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  double _getDouble(String key, double defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  void _validateConfig() {
    // Validate Supabase URL format
    if (!supabaseUrl.startsWith('https://') ||
        !supabaseUrl.contains('.supabase.co')) {
      throw Exception(
          'Invalid Supabase URL format. Expected: https://your-project-id.supabase.co');
    }

    // Validate Supabase anon key (basic check for reasonable length)
    if (supabaseAnonKey.length < 100) {
      throw Exception('Supabase anon key appears to be invalid (too short)');
    }

    // Validate environment
    if (!['development', 'staging', 'production'].contains(environment)) {
      throw Exception(
          'Invalid environment. Must be one of: development, staging, production');
    }
  }

  // Convenience getters
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  bool get isProduction => environment == 'production';

  // Logging helper
  void log(String message) {
    if (debugMode) {
      print('[${DateTime.now().toIso8601String()}] $message');
    }
  }

  // Configuration summary (for debugging)
  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'environment': environment,
      'debugMode': debugMode,
      'supabaseUrl': supabaseUrl,
      'supabaseAnonKeyLength':
          supabaseAnonKey.length, // Don't expose the actual key
    };
  }

  @override
  String toString() {
    return 'AppConfig: ${toMap()}';
  }
}
