import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'data/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize app configuration from .env file
    await AppConfig.initialize();

    // Initialize Supabase with environment variables
    await SupabaseService.instance.initialize(
      url: AppConfig.instance.supabaseUrl,
      anonKey: AppConfig.instance.supabaseAnonKey,
    );

    // Log configuration in development
    if (AppConfig.instance.isDevelopment) {
      AppConfig.instance.log('App configuration loaded: ${AppConfig.instance}');
    }
  } catch (e) {
    // Handle configuration errors
    print('❌ Configuration Error: $e');
    print(
        '📝 Please check your .env file and ensure all required variables are set.');
    print(
        '💡 Copy .env.example to .env and fill in your Supabase credentials.');

    // In production, you might want to show an error screen instead of crashing
    runApp(const ConfigErrorApp());
    return;
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: JournaleeApp(),
    ),
  );
}

// Error app to show when configuration fails
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuration Error',
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 24),
                Text(
                  'Configuration Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Please check your .env file and ensure all required variables are set.\n\nCopy .env.example to .env and fill in your Supabase credentials.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'Required variables:\n• SUPABASE_URL\n• SUPABASE_ANON_KEY',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
