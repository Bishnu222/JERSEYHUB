import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeKey = 'theme_mode';
  bool _isDarkMode = false;
  bool _isAutoTheme = true;

  bool get isDarkMode => _isDarkMode;
  bool get isAutoTheme => _isAutoTheme;

  // Initialize theme service
  Future<void> initialize() async {
    await _loadThemePreference();
  }

  // Load theme preference from shared preferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAutoTheme = prefs.getBool(_themeKey) ?? true;
      notifyListeners();
    } catch (e) {
      print('❌ Failed to load theme preference: $e');
    }
  }

  // Save theme preference to shared preferences
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isAutoTheme);
    } catch (e) {
      print('❌ Failed to save theme preference: $e');
    }
  }

  // Set theme mode manually
  void setThemeMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    _isAutoTheme = false;
    _saveThemePreference();
    notifyListeners();
    print('🎨 Theme changed to: ${isDarkMode ? "Dark" : "Light"} mode');
  }

  // Enable auto theme based on time
  void enableAutoTheme() {
    _isAutoTheme = true;
    _saveThemePreference();
    notifyListeners();
    print('🎨 Auto theme enabled');
  }

  // Update theme based on time (called by sensor service)
  void updateThemeBasedOnTime(bool isDarkMode) {
    if (_isAutoTheme) {
      _isDarkMode = isDarkMode;
      notifyListeners();
      print('🎨 Auto theme updated: ${isDarkMode ? "Dark" : "Light"} mode');
    }
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _isAutoTheme = false;
    _saveThemePreference();
    notifyListeners();
    print('🎨 Theme toggled to: ${_isDarkMode ? "Dark" : "Light"} mode');
  }

  // Get current theme data
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  // Light theme
  ThemeData get _lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black87),
        headlineMedium: TextStyle(color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  // Dark theme
  ThemeData get _darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }
}
