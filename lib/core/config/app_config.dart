import 'package:flutter/foundation.dart';
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
    try {
      debugPrint('🔧 [AppConfig] Starting configuration initialization...');

      await dotenv.load(fileName: ".env");
      debugPrint('🔧 [AppConfig] .env file loaded successfully');

      _instance = AppConfig._();
      _instance._loadConfig();

      debugPrint('✅ [AppConfig] Configuration initialization completed');
    } catch (e, stackTrace) {
      debugPrint('❌ [AppConfig] Configuration initialization failed: $e');
      debugPrint('📍 [AppConfig] Stack trace: $stackTrace');
      rethrow;
    }
  }

  void _loadConfig() {
    try {
      debugPrint('🔧 [AppConfig] Loading configuration values...');

      // Supabase Configuration
      supabaseUrl = _getRequiredString('SUPABASE_URL');
      supabaseAnonKey = _getRequiredString('SUPABASE_ANON_KEY');
      debugPrint('🔧 [AppConfig] Supabase URL: $supabaseUrl');
      debugPrint(
          '🔧 [AppConfig] Supabase key length: ${supabaseAnonKey.length}');

      // App Configuration
      appName = _getString('APP_NAME', 'Journalee');
      appVersion = _getString('APP_VERSION', '1.0.0');
      environment = _getString('ENVIRONMENT', 'development');
      debugMode = _getBool('DEBUG_MODE', true);

      debugPrint('🔧 [AppConfig] App name: $appName');
      debugPrint('🔧 [AppConfig] App version: $appVersion');
      debugPrint('🔧 [AppConfig] Environment: $environment');
      debugPrint('🔧 [AppConfig] Debug mode: $debugMode');

      // Validate configuration
      _validateConfig();
      debugPrint('✅ [AppConfig] Configuration validation passed');
    } catch (e, stackTrace) {
      debugPrint('❌ [AppConfig] Configuration loading failed: $e');
      debugPrint('📍 [AppConfig] Stack trace: $stackTrace');
      rethrow;
    }
  }

  String _getRequiredString(String key) {
    debugPrint('🔍 [AppConfig] Getting required string: $key');
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      debugPrint(
          '❌ [AppConfig] Required environment variable $key is missing or empty');
      throw Exception(
          'Required environment variable $key is not set or is empty');
    }
    debugPrint('✅ [AppConfig] Found required string: $key');
    return value;
  }

  String _getString(String key, String defaultValue) {
    debugPrint(
        '🔍 [AppConfig] Getting optional string: $key (default: $defaultValue)');
    final value = dotenv.env[key] ?? defaultValue;
    debugPrint('✅ [AppConfig] String value for $key: $value');
    return value;
  }

  bool _getBool(String key, bool defaultValue) {
    debugPrint('🔍 [AppConfig] Getting boolean: $key (default: $defaultValue)');
    final value = dotenv.env[key];
    if (value == null) {
      debugPrint('✅ [AppConfig] Using default boolean for $key: $defaultValue');
      return defaultValue;
    }
    final boolValue = value.toLowerCase() == 'true';
    debugPrint('✅ [AppConfig] Boolean value for $key: $boolValue');
    return boolValue;
  }

  int _getInt(String key, int defaultValue) {
    debugPrint('🔍 [AppConfig] Getting integer: $key (default: $defaultValue)');
    final value = dotenv.env[key];
    if (value == null) {
      debugPrint('✅ [AppConfig] Using default integer for $key: $defaultValue');
      return defaultValue;
    }
    final intValue = int.tryParse(value) ?? defaultValue;
    debugPrint('✅ [AppConfig] Integer value for $key: $intValue');
    return intValue;
  }

  double _getDouble(String key, double defaultValue) {
    debugPrint('🔍 [AppConfig] Getting double: $key (default: $defaultValue)');
    final value = dotenv.env[key];
    if (value == null) {
      debugPrint('✅ [AppConfig] Using default double for $key: $defaultValue');
      return defaultValue;
    }
    final doubleValue = double.tryParse(value) ?? defaultValue;
    debugPrint('✅ [AppConfig] Double value for $key: $doubleValue');
    return doubleValue;
  }

  void _validateConfig() {
    debugPrint('🔍 [AppConfig] Validating configuration...');

    // Validate Supabase URL format
    if (!supabaseUrl.startsWith('https://') ||
        !supabaseUrl.contains('.supabase.co')) {
      debugPrint('❌ [AppConfig] Invalid Supabase URL format: $supabaseUrl');
      throw Exception(
          'Invalid Supabase URL format. Expected: https://your-project-id.supabase.co');
    }
    debugPrint('✅ [AppConfig] Supabase URL format is valid');

    // Validate Supabase anon key (basic check for reasonable length)
    if (supabaseAnonKey.length < 100) {
      debugPrint(
          '❌ [AppConfig] Supabase anon key appears invalid (length: ${supabaseAnonKey.length})');
      throw Exception('Supabase anon key appears to be invalid (too short)');
    }
    debugPrint('✅ [AppConfig] Supabase anon key length is valid');

    // Validate environment
    if (!['development', 'staging', 'production'].contains(environment)) {
      debugPrint('❌ [AppConfig] Invalid environment: $environment');
      throw Exception(
          'Invalid environment. Must be one of: development, staging, production');
    }
    debugPrint('✅ [AppConfig] Environment is valid');
  }

  // Convenience getters
  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  bool get isProduction => environment == 'production';

  // Logging helper
  void log(String message) {
    if (debugMode && kDebugMode) {
      debugPrint('[${DateTime.now().toIso8601String()}] $message');
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
