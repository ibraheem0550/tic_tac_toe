import 'package:flutter/material.dart';

/// أنواع الأجهزة
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// أحجام المسافات
enum PaddingSize { small, medium, large, extraLarge }

/// مقياس الخطوط
enum FontScale { small, medium, large, extraLarge }

/// أحجام البطاقات
enum CardSize { small, medium, large, extraLarge }

/// أحجام الأيقونات
enum IconSize { small, medium, large, extraLarge }

/// مساعد للتصميم المتجاوب المحسن - ثيم الفضاء الكوني
class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  static const double largeDesktopBreakpoint = 1920;

  /// تحديد نوع الجهاز بدقة أكبر
  static DeviceType getDeviceType(double width) {
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < largeDesktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// الحصول على عدد الأعمدة المناسب مع تحسينات
  static int getColumnsCount(BuildContext context,
      {int? minColumns, int? maxColumns}) {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    int columns;

    // تعديل العدد حسب الاتجاه أيضاً
    if (orientation == Orientation.landscape) {
      if (width < mobileBreakpoint) {
        columns = 2; // في الوضع الأفقي للموبايل
      } else if (width < tabletBreakpoint) {
        columns = 3;
      } else if (width < desktopBreakpoint) {
        columns = 4;
      } else if (width < largeDesktopBreakpoint) {
        columns = 5;
      } else {
        columns = 6;
      }
    } else {
      // الوضع العمودي
      if (width < mobileBreakpoint) {
        columns = 1;
      } else if (width < tabletBreakpoint) {
        columns = 2;
      } else if (width < desktopBreakpoint) {
        columns = 3;
      } else if (width < largeDesktopBreakpoint) {
        columns = 4;
      } else {
        columns = 5;
      }
    }

    // تطبيق الحدود المطلوبة
    if (minColumns != null && columns < minColumns) {
      columns = minColumns;
    }
    if (maxColumns != null && columns > maxColumns) {
      columns = maxColumns;
    }

    return columns;
  }

  /// الحصول على المسافات المناسبة مع تحسينات فضائية
  static double getPadding(BuildContext context,
      {PaddingSize size = PaddingSize.medium}) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);

    double basePadding;

    // قيم محسنة للثيم الفضائي
    switch (deviceType) {
      case DeviceType.mobile:
        basePadding = 12.0;
        break;
      case DeviceType.tablet:
        basePadding = 20.0;
        break;
      case DeviceType.desktop:
        basePadding = 28.0;
        break;
      case DeviceType.largeDesktop:
        basePadding = 36.0;
        break;
    }

    // تطبيق المقياس
    switch (size) {
      case PaddingSize.small:
        return basePadding * 0.5;
      case PaddingSize.medium:
        return basePadding;
      case PaddingSize.large:
        return basePadding * 1.5;
      case PaddingSize.extraLarge:
        return basePadding * 2.0;
    }
  }

  /// الحصول على حجم الخط المناسب للثيم الفضائي
  static double getFontSize(BuildContext context, double baseFontSize,
      {FontScale scale = FontScale.medium}) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(width);

    double multiplier;

    // مضاعفات محسنة للقراءة في الفضاء
    switch (deviceType) {
      case DeviceType.mobile:
        multiplier = 1.0;
        break;
      case DeviceType.tablet:
        multiplier = 1.15;
        break;
      case DeviceType.desktop:
        multiplier = 1.25;
        break;
      case DeviceType.largeDesktop:
        multiplier = 1.35;
        break;
    }

    // تطبيق مقياس إضافي
    switch (scale) {
      case FontScale.small:
        multiplier *= 0.85;
        break;
      case FontScale.medium:
        break; // البقاء على نفس المضاعف
      case FontScale.large:
        multiplier *= 1.15;
        break;
      case FontScale.extraLarge:
        multiplier *= 1.3;
        break;
    }

    return baseFontSize * multiplier;
  }

  /// الحصول على العرض المحدود للمحتوى
  static double getMaxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > largeDesktopBreakpoint) {
      return largeDesktopBreakpoint * 0.8;
    } else if (width > desktopBreakpoint) {
      return desktopBreakpoint * 0.9;
    }
    return width * 0.95;
  }

  /// تحديد ما إذا كان يجب إظهار الـ sidebar
  static bool shouldShowSidebar(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// تحديد حجم البطاقات - محسن للاستجابة
  static double getCardHeight(BuildContext context,
      {CardSize size = CardSize.medium}) {
    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width;
    final height = screenSize.height;
    final orientation = MediaQuery.of(context).orientation;

    // حساب الارتفاع الأساسي باستخدام نسبة من الشاشة
    double baseHeight;

    if (orientation == Orientation.landscape) {
      // في الوضع الأفقي، استخدم نسبة من الارتفاع
      baseHeight = height * 0.15;
    } else {
      // في الوضع العمودي، استخدم نسبة من العرض
      baseHeight = width * 0.2;
    }

    // تطبيق حدود معقولة
    if (width < mobileBreakpoint) {
      baseHeight = baseHeight.clamp(100.0, 140.0);
    } else if (width < tabletBreakpoint) {
      baseHeight = baseHeight.clamp(120.0, 160.0);
    } else if (width < desktopBreakpoint) {
      baseHeight = baseHeight.clamp(140.0, 180.0);
    } else {
      baseHeight = baseHeight.clamp(160.0, 200.0);
    }

    switch (size) {
      case CardSize.small:
        return baseHeight * 0.7;
      case CardSize.medium:
        return baseHeight;
      case CardSize.large:
        return baseHeight * 1.3;
      case CardSize.extraLarge:
        return baseHeight * 1.6;
    }
  }

  /// تحديد عرض البطاقات - محسن للاستجابة
  static double getCardWidth(BuildContext context,
      {required int totalColumns}) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final orientation = MediaQuery.of(context).orientation;
    final padding = getPadding(context);
    final spacing = padding * 0.5;

    // في الوضع الأفقي، قم بتقليل المسافات قليلاً لإفساح المجال أكثر
    final adjustedPadding =
        orientation == Orientation.landscape ? padding * 0.8 : padding;

    final availableWidth =
        screenWidth - (adjustedPadding * 2) - (spacing * (totalColumns - 1));
    final cardWidth = availableWidth / totalColumns;

    // تطبيق حد أدنى وأقصى للعرض
    final minWidth = screenWidth < mobileBreakpoint ? 120.0 : 150.0;
    final maxWidth = screenWidth < tabletBreakpoint ? 300.0 : 400.0;

    return cardWidth.clamp(minWidth, maxWidth);
  }

  /// تحديد ما إذا كان يجب استخدام التمرير الأفقي
  static bool shouldUseHorizontalScroll(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// الحصول على نسبة العرض إلى الارتفاع للبطاقات
  static double getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 1.5; // عرض أكبر للموبايل
    } else if (width < tabletBreakpoint) {
      return 1.3;
    } else {
      return 1.2;
    }
  }

  /// تحديد حجم الآيقونات
  static double getIconSize(BuildContext context,
      {IconSize size = IconSize.medium}) {
    final width = MediaQuery.of(context).size.width;
    double baseSize;

    if (width < mobileBreakpoint) {
      baseSize = 24.0;
    } else if (width < tabletBreakpoint) {
      baseSize = 28.0;
    } else {
      baseSize = 32.0;
    }

    switch (size) {
      case IconSize.small:
        return baseSize * 0.75;
      case IconSize.medium:
        return baseSize;
      case IconSize.large:
        return baseSize * 1.25;
      case IconSize.extraLarge:
        return baseSize * 1.5;
    }
  }

  /// تحديد ما إذا كان الجهاز في الوضع الأفقي
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// الحصول على ارتفاع شريط التطبيق المناسب
  static double getAppBarHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return kToolbarHeight;
    } else if (width < tabletBreakpoint) {
      return kToolbarHeight + 8;
    } else {
      return kToolbarHeight + 16;
    }
  }

  /// تحديد ما إذا كان يجب استخدام القوائم المنسدلة أم الشبكة
  static bool shouldUseGrid(BuildContext context, int itemCount) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return itemCount > 4;
    } else if (width < tabletBreakpoint) {
      return itemCount > 6;
    } else {
      return itemCount > 8;
    }
  }
}

/// ويدجت متجاوب
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHelper.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveHelper.tabletBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// حاوي متجاوب للمحتوى
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? ResponsiveHelper.getMaxContentWidth(context),
      ),
      child: child,
    );
  }
}
