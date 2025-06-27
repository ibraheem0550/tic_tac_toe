import 'package:flutter/material.dart';

/// نظام الألوان الاحترافي - الثيم النجمي المتقدم
class AppColors {
  // الألوان الأساسية - النجوم والمجرات
  static const Color primary = Color(0xFF3B4CFF); // أزرق نجمي لامع
  static const Color primaryDark = Color(0xFF1A237E); // أزرق مجري عميق
  static const Color primaryLight = Color(0xFF7C4DFF); // بنفسجي نجمي

  static const Color secondary = Color(0xFF00E5FF); // سيان نجمي متوهج
  static const Color secondaryDark = Color(0xFF0091EA); // أزرق فضائي عميق
  static const Color secondaryLight = Color(0xFF64B5F6); // أزرق سماوي

  static const Color accent = Color(0xFFFF4081); // وردي نيون نجمي
  static const Color accentDark = Color(0xFFC51162); // وردي مجري
  static const Color accentLight = Color(0xFFFF80AB); // وردي شفقي

  // ألوان الكون والنجوم
  static const Color starGold = Color(0xFFFFD700); // ذهبي نجمي
  static const Color nebulaPurple = Color(0xFF9C27B0); // بنفسجي سديمي
  static const Color galaxyBlue = Color(0xFF2196F3); // أزرق مجري
  static const Color cosmicTeal = Color(0xFF00BCD4); // تركوازي كوني
  static const Color stellarOrange = Color(0xFFFF6D00); // برتقالي نجمي
  static const Color planetGreen = Color(0xFF4CAF50); // أخضر كوكبي

  // ألوان الحالة - نجمية محسنة
  static const Color success = Color(0xFF00E676); // أخضر نيون نجمي
  static const Color successDark = Color(0xFF00C853);
  static const Color successLight = Color(0xFF69F0AE);

  static const Color warning = Color(0xFFFFAB00); // كهرماني نجمي
  static const Color warningDark = Color(0xFFFF8F00);
  static const Color warningLight = Color(0xFFFFCC02);

  static const Color error = Color(0xFFFF1744); // أحمر نجمي متوهج
  static const Color errorDark = Color(0xFFD50000);
  static const Color errorLight = Color(0xFFFF5983);

  static const Color info = Color(0xFF2979FF); // أزرق معلوماتي نجمي
  static const Color infoDark = Color(0xFF2962FF);
  static const Color infoLight = Color(0xFF448AFF);

  // خلفيات نجمية متدرجة
  static const Color backgroundPrimary = Color(0xFF0A0A1A); // أسود فضائي عميق
  static const Color backgroundSecondary = Color(0xFF1A1A2E); // أزرق ليلي نجمي
  static const Color backgroundTertiary = Color(0xFF16213E); // أزرق داكن مجري

  static const Color surfacePrimary = Color(0xFF1F1F35); // سطح نجمي أساسي
  static const Color surfaceSecondary = Color(0xFF2A2A40); // سطح ثانوي
  static const Color surfaceElevated = Color(0xFF353550); // سطح مرتفع

  // ألوان النص النجمية
  static const Color textPrimary = Color(0xFFFFFFFF); // أبيض نجمي نقي
  static const Color textSecondary = Color(0xFFE8EAED); // أبيض نجمي ناعم
  static const Color textTertiary = Color(0xFFBDC1C6); // رمادي نجمي فاتح
  static const Color textMuted = Color(0xFF9AA0A6); // رمادي نجمي خافت
  static const Color textDisabled = Color(0xFF5F6368); // رمادي معطل

  // الحدود والتقسيمات النجمية
  static const Color borderPrimary = Color(0xFF3C4043); // حدود أساسية
  static const Color borderSecondary = Color(0xFF5F6368); // حدود ثانوية
  static const Color dividerPrimary = Color(0xFF2D3134); // فاصل أساسي
  static const Color dividerSecondary = Color(0xFF3C4043); // فاصل ثانوي

  // تأثيرات الإضاءة النجمية
  static const Color glowBlue = Color(0xFF64B5F6); // توهج أزرق
  static const Color glowPurple = Color(0xFFBA68C8); // توهج بنفسجي
  static const Color glowGreen = Color(0xFF81C784); // توهج أخضر
  static const Color glowOrange = Color(0xFFFFB74D); // توهج برتقالي

  // ألوان مختصرة للتوافق مع الكود الحالي
  static const Color background = backgroundPrimary;
  static const Color backgroundDark = backgroundPrimary;
  static const Color backgroundLight = backgroundSecondary;
  static const Color surface = surfacePrimary;
  static const Color surfaceLight = surfaceSecondary;
  static const Color surfaceDark = backgroundPrimary;
  static const Color textLight = textPrimary;

  // ألوان إضافية مطلوبة للمتجر الشامل
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfacePrimary, surfaceSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color shadowPrimary = Color(0x33000000);
  static const Color successPrimary = success;
  static const Color errorPrimary = error;

  // التدرجات النجمية المحسنة
  static const LinearGradient starfieldGradient = LinearGradient(
    colors: [backgroundPrimary, backgroundSecondary, backgroundTertiary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient nebularGradient = LinearGradient(
    colors: [
      Color(0xFF3B4CFF),
      Color(0xFF9C27B0),
      Color(0xFF2196F3),
      Color(0xFF00BCD4)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const RadialGradient stellarGradient = RadialGradient(
    colors: [
      Color(0xFFFFD700),
      Color(0xFFFF6D00),
      Color(0xFFFF1744),
      Color(0xFF3B4CFF)
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const LinearGradient cosmicButtonGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient galaxyGradient = LinearGradient(
    colors: [
      Color(0xFF1A237E),
      Color(0xFF3B4CFF),
      Color(0xFF9C27B0),
      Color(0xFF1A237E)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// أبعاد احترافية متجاوبة للثيم النجمي
class AppDimensions {
  // المساحات والحواف
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // أحجام الأيقونات النجمية
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // أنصاف الأقطار النجمية
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusCircular = 999.0;

  // ارتفاعات البطاقات والعناصر
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationMax = 16.0;

  // أحجام الأزرار النجمية
  static const double buttonHeightSM = 40.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightLG = 56.0;
  static const double buttonHeightXL = 64.0;

  // أبعاد البطاقات
  static const double cardHeightSM = 120.0;
  static const double cardHeightMD = 200.0;
  static const double cardHeightLG = 280.0;

  // عروض محددة
  static const double maxContentWidth = 1200.0;
  static const double sidebarWidth = 280.0;
  static const double appBarHeight = 64.0;

  // تأثيرات التوهج النجمي
  static const double glowRadius = 20.0;
  static const double glowSpread = 5.0;
}

/// أنماط النصوص النجمية الاحترافية
class AppTextStyles {
  // العناوين النجمية الرئيسية
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.0,
    height: 1.3,
  );

  // العناوين الثانوية
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.35,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.45,
  );

  // العناوين الصغيرة
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
    height: 1.5,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
    height: 1.55,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.4,
    height: 1.6,
  );

  // النصوص الأساسية
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
    height: 1.6,
  );

  // تسميات الأزرار والعناصر
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.8,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 1.0,
    height: 1.45,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
    letterSpacing: 1.2,
    height: 1.5,
  );

  // أنماط خاصة نجمية
  static const TextStyle stellarTitle = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w900,
    color: AppColors.starGold,
    letterSpacing: 1.0,
    height: 1.2,
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 10.0,
        color: AppColors.starGold,
      ),
    ],
  );

  static const TextStyle nebularSubtitle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.nebulaPurple,
    letterSpacing: 0.5,
    height: 1.3,
    shadows: [
      Shadow(
        offset: Offset(0, 0),
        blurRadius: 8.0,
        color: AppColors.nebulaPurple,
      ),
    ],
  );

  static const TextStyle cosmicButton = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 1.0,
    height: 1.2,
  );

  // أنماط مختصرة للتوافق مع الكود الحالي
  static const TextStyle h1 = displayLarge;
  static const TextStyle h2 = displayMedium;
  static const TextStyle h3 = displaySmall;
  static const TextStyle caption = labelSmall;
  static const TextStyle subtitle1 = headlineMedium;
  static const TextStyle subtitle2 = headlineSmall;
}

/// مكونات احترافية للواجهة النجمية
class AppComponents {
  /// زر نجمي احترافي
  static Widget stellarButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
    bool isLoading = false,
    IconData? icon,
    double? width,
    double height = AppDimensions.buttonHeightMD,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? AppColors.cosmicButtonGradient
            : AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: isPrimary
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.nebulaPurple.withValues(alpha: 0.3),
            blurRadius: AppDimensions.glowRadius,
            spreadRadius: AppDimensions.glowSpread,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
              vertical: AppDimensions.paddingMD,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.textPrimary),
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: AppColors.textPrimary,
                      size: AppDimensions.iconMD,
                    ),
                    const SizedBox(width: AppDimensions.paddingSM),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.cosmicButton,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// بطاقة نجمية احترافية
  static Widget stellarCard({
    required Widget child,
    EdgeInsets? padding,
    double? elevation,
    Color? backgroundColor,
    Gradient? gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfacePrimary,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: AppColors.borderPrimary,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.backgroundPrimary.withValues(alpha: 0.5),
            blurRadius: elevation ?? AppDimensions.elevationMedium,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.paddingLG),
        child: child,
      ),
    );
  }

  /// حقل إدخال نجمي
  static Widget stellarTextField({
    required String hintText,
    TextEditingController? controller,
    bool obscureText = false,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(
          color: AppColors.borderPrimary,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: AppColors.textTertiary,
                  size: AppDimensions.iconMD,
                )
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: AppColors.textTertiary,
                    size: AppDimensions.iconMD,
                  ),
                  onPressed: onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingMD,
          ),
        ),
      ),
    );
  }
}

/// ظلال نجمية احترافية
class AppShadows {
  // ظلال أساسية
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8.0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 16.0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 12.0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 24.0,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 20.0,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 40.0,
      offset: Offset(0, 16),
    ),
  ];

  // ظلال نجمية متوهجة
  static const List<BoxShadow> stellar = [
    BoxShadow(
      color: AppColors.starGold,
      blurRadius: 20.0,
      spreadRadius: 2.0,
    ),
    BoxShadow(
      color: AppColors.primary,
      blurRadius: 40.0,
      spreadRadius: -5.0,
    ),
  ];

  static const List<BoxShadow> nebular = [
    BoxShadow(
      color: AppColors.nebulaPurple,
      blurRadius: 30.0,
      spreadRadius: 1.0,
    ),
    BoxShadow(
      color: AppColors.galaxyBlue,
      blurRadius: 50.0,
      spreadRadius: -8.0,
    ),
  ];

  static const List<BoxShadow> cosmic = [
    BoxShadow(
      color: AppColors.cosmicTeal,
      blurRadius: 25.0,
      spreadRadius: 0.0,
    ),
    BoxShadow(
      color: AppColors.secondaryDark,
      blurRadius: 35.0,
      spreadRadius: -5.0,
    ),
  ];
}
