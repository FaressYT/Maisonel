import 'package:flutter/material.dart';

/// Theme controller to manage dark/light mode switching
class ThemeController {
  // Private constructor to prevent instantiation
  ThemeController._();

  // Singleton instance
  static final ThemeController instance = ThemeController._();

  // Theme mode notifier
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

  /// Get current theme mode
  ThemeMode get themeMode => themeNotifier.value;

  /// Check if dark mode is enabled
  bool get isDarkMode => themeNotifier.value == ThemeMode.dark;

  /// Toggle between light and dark mode
  void toggleTheme() {
    themeNotifier.value = themeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  /// Set theme mode explicitly
  void setThemeMode(ThemeMode mode) {
    themeNotifier.value = mode;
  }

  /// Set to light mode
  void setLightMode() {
    themeNotifier.value = ThemeMode.light;
  }

  /// Set to dark mode
  void setDarkMode() {
    themeNotifier.value = ThemeMode.dark;
  }

  /// Set to system mode (follows device settings)
  void setSystemMode() {
    themeNotifier.value = ThemeMode.system;
  }
}
