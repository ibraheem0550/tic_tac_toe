import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/logger.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // الألوان الافتراضية
  Map<String, dynamic> _currentTheme = {
    'primaryColor': Colors.deepPurple.toARGB32(),
    'secondaryColor': Colors.teal.toARGB32(),
    'accentColor': Colors.amberAccent.toARGB32(),
    'backgroundColor': Colors.grey.shade900.toARGB32(),
    'surfaceColor': Colors.grey.shade800.toARGB32(),
    'cardColor': const Color(0xFF424242).toARGB32(),
    'primaryTextColor': Colors.white.toARGB32(),
    'secondaryTextColor': Colors.grey.shade300.toARGB32(),
    'titleTextColor': Colors.yellow.toARGB32(),
    'primaryButtonColor': Colors.deepPurple.shade500.toARGB32(),
    'secondaryButtonColor': Colors.teal.shade500.toARGB32(),
    'dangerButtonColor': Colors.red.shade500.toARGB32(),
    'successButtonColor': Colors.green.shade500.toARGB32(),
    'gameXColor': Colors.blue.shade400.toARGB32(),
    'gameOColor': Colors.red.shade400.toARGB32(),
    'gameBoardColor': Colors.grey.shade700.toARGB32(),
    'gameWinColor': Colors.green.shade400.toARGB32(),
    'gradientStart': Colors.grey.shade900.toARGB32(),
    'gradientMiddle': Colors.deepPurple.shade900.toARGB32(),
    'gradientEnd': Colors.grey.shade900.toARGB32(),
    'borderColor': Colors.grey.shade600.toARGB32(),
    'shadowColor': Colors.black54.toARGB32(),
    'highlightColor': Colors.white24.toARGB32(),
  };

  String _currentThemeName = 'السمة الافتراضية';

  // Getters للألوان
  Color get primaryColor => Color(_currentTheme['primaryColor']);
  Color get secondaryColor => Color(_currentTheme['secondaryColor']);
  Color get accentColor => Color(_currentTheme['accentColor']);
  Color get backgroundColor => Color(_currentTheme['backgroundColor']);
  Color get surfaceColor => Color(_currentTheme['surfaceColor']);
  Color get cardColor => Color(_currentTheme['cardColor']);
  Color get primaryTextColor => Color(_currentTheme['primaryTextColor']);
  Color get secondaryTextColor => Color(_currentTheme['secondaryTextColor']);
  Color get titleTextColor => Color(_currentTheme['titleTextColor']);
  Color get primaryButtonColor => Color(_currentTheme['primaryButtonColor']);
  Color get secondaryButtonColor =>
      Color(_currentTheme['secondaryButtonColor']);
  Color get dangerButtonColor => Color(_currentTheme['dangerButtonColor']);
  Color get successButtonColor => Color(_currentTheme['successButtonColor']);
  Color get gameXColor => Color(_currentTheme['gameXColor']);
  Color get gameOColor => Color(_currentTheme['gameOColor']);
  Color get gameBoardColor => Color(_currentTheme['gameBoardColor']);
  Color get gameWinColor => Color(_currentTheme['gameWinColor']);
  Color get gradientStart => Color(_currentTheme['gradientStart']);
  Color get gradientMiddle => Color(_currentTheme['gradientMiddle']);
  Color get gradientEnd => Color(_currentTheme['gradientEnd']);
  Color get borderColor => Color(_currentTheme['borderColor']);
  Color get shadowColor => Color(_currentTheme['shadowColor']);
  Color get highlightColor => Color(_currentTheme['highlightColor']);

  String get currentThemeName => _currentThemeName;

  // تحميل السمة المحفوظة
  Future<void> loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeJson = prefs.getString('current_theme');
      final themeName = prefs.getString('current_theme_name');

      if (themeJson != null) {
        _currentTheme = Map<String, dynamic>.from(jsonDecode(themeJson));
        _currentThemeName = themeName ?? 'سمة مخصصة';
        notifyListeners();
      }
    } catch (e) {
      Logger.logError('خطأ في تحميل السمة', e);
    }
  }

  // تطبيق سمة جديدة
  Future<void> applyTheme(
      Map<String, dynamic> themeData, String themeName) async {
    try {
      _currentTheme = Map<String, dynamic>.from(themeData);
      _currentThemeName = themeName;

      // حفظ السمة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_theme', jsonEncode(_currentTheme));
      await prefs.setString('current_theme_name', _currentThemeName);

      notifyListeners();
    } catch (e) {
      Logger.logError('خطأ في تطبيق السمة', e);
    }
  }

  // إعادة تعيين السمة للافتراضية
  Future<void> resetToDefault() async {
    try {
      _currentTheme = {
        'primaryColor': Colors.deepPurple.toARGB32(),
        'secondaryColor': Colors.teal.toARGB32(),
        'accentColor': Colors.amberAccent.toARGB32(),
        'backgroundColor': Colors.grey.shade900.toARGB32(),
        'surfaceColor': Colors.grey.shade800.toARGB32(),
        'cardColor': const Color(0xFF424242).toARGB32(),
        'primaryTextColor': Colors.white.toARGB32(),
        'secondaryTextColor': Colors.grey.shade300.toARGB32(),
        'titleTextColor': Colors.yellow.toARGB32(),
        'primaryButtonColor': Colors.deepPurple.shade500.toARGB32(),
        'secondaryButtonColor': Colors.teal.shade500.toARGB32(),
        'dangerButtonColor': Colors.red.shade500.toARGB32(),
        'successButtonColor': Colors.green.shade500.toARGB32(),
        'gameXColor': Colors.blue.shade400.toARGB32(),
        'gameOColor': Colors.red.shade400.toARGB32(),
        'gameBoardColor': Colors.grey.shade700.toARGB32(),
        'gameWinColor': Colors.green.shade400.toARGB32(),
        'gradientStart': Colors.grey.shade900.toARGB32(),
        'gradientMiddle': Colors.deepPurple.shade900.toARGB32(),
        'gradientEnd': Colors.grey.shade900.toARGB32(),
        'borderColor': Colors.grey.shade600.toARGB32(),
        'shadowColor': Colors.black54.toARGB32(),
        'highlightColor': Colors.white24.toARGB32(),
      };
      _currentThemeName = 'السمة الافتراضية';

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_theme');
      await prefs.remove('current_theme_name');

      notifyListeners();
    } catch (e) {
      Logger.logError('خطأ في إعادة تعيين السمة', e);
    }
  }

  // إنشاء ThemeData للتطبيق
  ThemeData createThemeData() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: primaryTextColor,
        error: dangerButtonColor,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge:
            TextStyle(color: titleTextColor, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: titleTextColor, fontWeight: FontWeight.bold),
        displaySmall:
            TextStyle(color: titleTextColor, fontWeight: FontWeight.bold),
        headlineLarge:
            TextStyle(color: titleTextColor, fontWeight: FontWeight.bold),
        headlineMedium:
            TextStyle(color: titleTextColor, fontWeight: FontWeight.bold),
        headlineSmall:
            TextStyle(color: titleTextColor, fontWeight: FontWeight.bold),
        titleLarge:
            TextStyle(color: titleTextColor, fontWeight: FontWeight.bold),
        titleMedium:
            TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
        titleSmall:
            TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: primaryTextColor),
        bodyMedium: TextStyle(color: primaryTextColor),
        bodySmall: TextStyle(color: secondaryTextColor),
        labelLarge: TextStyle(color: primaryTextColor),
        labelMedium: TextStyle(color: secondaryTextColor),
        labelSmall: TextStyle(color: secondaryTextColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryButtonColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        titleTextStyle: TextStyle(
          color: titleTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: TextStyle(color: primaryTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: secondaryTextColor),
        hintStyle: TextStyle(color: secondaryTextColor),
      ),
    );
  }

  // إنشاء تدرج الخلفية
  BoxDecoration createBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientStart, gradientMiddle, gradientEnd],
      ),
    );
  }
}
