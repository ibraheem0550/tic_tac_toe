import 'package:flutter/material.dart';

/// الألوان الحديثة
class ModernColors {
  // الألوان الأساسية - نظام Material 3
  static const primary = Color(0xFF6366F1); // بنفسجي حديث
  static const primaryLight = Color(0xFF818CF8);
  static const primaryDark = Color(0xFF4338CA);

  static const secondary = Color(0xFF06B6D4); // سماوي حديث
  static const secondaryLight = Color(0xFF67E8F9);
  static const secondaryDark = Color(0xFF0891B2);

  // الألوان الوظيفية
  static const accent = Color(0xFFF59E0B); // برتقالي ذهبي
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // الخلفيات
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF8FAFC);
  static const surfaceTint = Color(0xFFF1F5F9);

  // الخلفيات المظلمة
  static const backgroundDark = Color(0xFF0F172A); // خلفية مظلمة
  static const surfaceDark = Color(0xFF1E293B); // سطح مظلم
  static const surfaceVariantDark = Color(0xFF334155); // سطح مظلم متنوع

  // النصوص
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);
  static const textOnPrimary = Color(0xFFFFFFFF);

  // الحدود والفواصل
  static const border = Color(0xFFE2E8F0);
  static const borderStrong = Color(0xFFCBD5E1);
  static const divider = Color(0xFFF1F5F9);
}

/// المسافات الحديثة
class ModernSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  static const xxxl = 64.0;
}

/// الانحناءات
class ModernRadius {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const full = 999.0;
}

/// أنماط النصوص الحديثة
class ModernTextStyles {
  static const displayLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const headlineLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const headlineMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const titleLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
}

/// نظام التصميم الحديث الشامل
class ModernDesignSystem {
  // 🌈 التدرجات الحديثة
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ModernColors.primary, ModernColors.primaryLight],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ModernColors.secondary, ModernColors.secondaryLight],
  );

  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444), Color(0xFFEC4899)],
  );

  static const oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF6366F1)],
  );

  // 🎭 الظلال
  static const smallShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 4.0, offset: Offset(0, 1)),
  ];

  static const mediumShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8.0, offset: Offset(0, 4)),
  ];

  static const largeShadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16.0, offset: Offset(0, 8)),
  ];

  static const glowShadow = [
    BoxShadow(color: Color(0x336366F1), blurRadius: 20.0, spreadRadius: -2.0),
  ];
}

/// مدير الثيم الحديث
class ModernThemeManager {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ModernColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: ModernColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: ModernColors.textPrimary,
      centerTitle: true,
      titleTextStyle: ModernTextStyles.headlineMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: ModernColors.primary,
        foregroundColor: ModernColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: ModernSpacing.lg,
          vertical: ModernSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernRadius.md),
        ),
        textStyle: ModernTextStyles.labelLarge,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: ModernColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ModernRadius.lg),
        side: const BorderSide(color: ModernColors.border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ModernRadius.md),
        borderSide: const BorderSide(color: ModernColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ModernRadius.md),
        borderSide: const BorderSide(color: ModernColors.primary, width: 2),
      ),
      filled: true,
      fillColor: ModernColors.surfaceVariant,
    ),
  );
}
