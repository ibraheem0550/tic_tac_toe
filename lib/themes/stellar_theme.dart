import 'package:flutter/material.dart';

/// StellarTheme: لوحة ألوان وتدرّجات «نجمية» للتطبيق.
///
/// • الخلفية: فراغ كوني داكن (Deep Space).
/// • primary  : بنفسجي ساطع يميل إلى النيلي.
/// • secondary: سيان/تركواز كهربائي.
/// • accent   : وردي-أرجواني متوهّج.
/// • error    : أحمر بركاني.
///
/// يمكن استخدام [StellarTheme.dark] مباشرةً في ThemeData للتطبيق.
class StellarTheme {
  // أساسيات الألوان
  static const Color background = Color(0xFF060B28); // فراغ كوني أعمق
  static const Color surface = Color(0xFF11163A); // سطح داكن مخملي

  static const Color primary = Color(0xFF6C5DD3); // نيلي-بنفسجي ساطع
  static const Color secondary = Color(0xFF00C6FF); // سيان كهربائي
  static const Color accent = Color(0xFFFF2CD8); // وردي مجري

  static const Color success = Color(0xFF00C853);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF5252);

  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFFB0BEC5);

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [primary, secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// ThemeData داكن مع تفعيل Material 3.
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Roboto',
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: secondary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
    );
  }
}
