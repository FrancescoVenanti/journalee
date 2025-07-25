import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _key = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_key);

      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      // If there's an error loading, keep system default
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, themeMode.toString());
    } catch (e) {
      // Handle error silently, the theme change will still work for the session
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    };

    await setThemeMode(newTheme);
  }
}

// Current brightness provider (useful for widgets that need to know current theme)
final currentBrightnessProvider = Provider<Brightness>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.system:
      // This will be determined by the system, but we default to light
      // In practice, MediaQuery.of(context).platformBrightness should be used
      return Brightness.light;
  }
});

// Helper to check if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final brightness = ref.watch(currentBrightnessProvider);
  return brightness == Brightness.dark;
});
