import 'package:flutter/material.dart';
import 'dart:math' as math;

/// نظام التجاوب المتقدم للتطبيق
class ResponsiveSystem {
  static ResponsiveSystem? _instance;
  static ResponsiveSystem get instance => _instance ??= ResponsiveSystem._();
  ResponsiveSystem._();

  late Size _screenSize;
  late DeviceType _deviceType;
  late OrientationType _orientation;

  void initialize(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    _deviceType = _getDeviceType(_screenSize);
    _orientation = _getOrientation(_screenSize);
  }

  // حجم الشاشة
  Size get screenSize => _screenSize;
  double get screenWidth => _screenSize.width;
  double get screenHeight => _screenSize.height;
  double get screenDiagonal =>
      math.sqrt(math.pow(screenWidth, 2) + math.pow(screenHeight, 2));

  // نوع الجهاز
  DeviceType get deviceType => _deviceType;
  OrientationType get orientation => _orientation;

  // فحص نوع الجهاز
  bool get isMobile => _deviceType == DeviceType.mobile;
  bool get isTablet => _deviceType == DeviceType.tablet;
  bool get isDesktop => _deviceType == DeviceType.desktop;
  bool get isSmallScreen => screenWidth < 600;
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;
  bool get isLargeScreen => screenWidth >= 1200;

  // اتجاه الشاشة
  bool get isPortrait => _orientation == OrientationType.portrait;
  bool get isLandscape => _orientation == OrientationType.landscape;

  // أحجام الخطوط المتجاوبة
  double get titleFontSize {
    if (isMobile) return isPortrait ? 24 : 20;
    if (isTablet) return isPortrait ? 28 : 24;
    return 32;
  }

  double get headlineFontSize {
    if (isMobile) return isPortrait ? 20 : 18;
    if (isTablet) return isPortrait ? 24 : 20;
    return 28;
  }

  double get bodyFontSize {
    if (isMobile) return isPortrait ? 16 : 14;
    if (isTablet) return isPortrait ? 18 : 16;
    return 20;
  }

  double get captionFontSize {
    if (isMobile) return isPortrait ? 12 : 10;
    if (isTablet) return isPortrait ? 14 : 12;
    return 16;
  }

  // أحجام الأزرار المتجاوبة
  double get buttonHeight {
    if (isMobile) return isPortrait ? 48 : 40;
    if (isTablet) return isPortrait ? 56 : 48;
    return 64;
  }

  double get smallButtonHeight {
    if (isMobile) return isPortrait ? 36 : 32;
    if (isTablet) return isPortrait ? 40 : 36;
    return 48;
  }

  double get largeButtonHeight {
    if (isMobile) return isPortrait ? 56 : 48;
    if (isTablet) return isPortrait ? 64 : 56;
    return 72;
  }

  double get buttonWidth {
    if (isMobile) return screenWidth * 0.8;
    if (isTablet) return screenWidth * 0.6;
    return math.min(400, screenWidth * 0.4);
  }

  double get smallButtonWidth {
    if (isMobile) return screenWidth * 0.4;
    if (isTablet) return screenWidth * 0.3;
    return math.min(200, screenWidth * 0.2);
  }

  // المسافات المتجاوبة
  double get padding {
    if (isMobile) return isPortrait ? 16 : 12;
    if (isTablet) return isPortrait ? 24 : 20;
    return 32;
  }

  double get smallPadding {
    if (isMobile) return isPortrait ? 8 : 6;
    if (isTablet) return isPortrait ? 12 : 10;
    return 16;
  }

  double get largePadding {
    if (isMobile) return isPortrait ? 24 : 20;
    if (isTablet) return isPortrait ? 32 : 28;
    return 48;
  }

  double get margin {
    if (isMobile) return isPortrait ? 16 : 12;
    if (isTablet) return isPortrait ? 20 : 16;
    return 24;
  }

  // أحجام الأيقونات المتجاوبة
  double get iconSize {
    if (isMobile) return isPortrait ? 24 : 20;
    if (isTablet) return isPortrait ? 28 : 24;
    return 32;
  }

  double get smallIconSize {
    if (isMobile) return isPortrait ? 16 : 14;
    if (isTablet) return isPortrait ? 20 : 18;
    return 24;
  }

  double get largeIconSize {
    if (isMobile) return isPortrait ? 32 : 28;
    if (isTablet) return isPortrait ? 40 : 36;
    return 48;
  }

  // أحجام البطاقات المتجاوبة
  double get cardHeight {
    if (isMobile) return isPortrait ? 120 : 100;
    if (isTablet) return isPortrait ? 160 : 140;
    return 200;
  }

  double get cardWidth {
    if (isMobile) return screenWidth * 0.9;
    if (isTablet) return screenWidth * 0.7;
    return math.min(400, screenWidth * 0.5);
  }

  // نصف القطر المتجاوب
  double get borderRadius {
    if (isMobile) return isPortrait ? 12 : 10;
    if (isTablet) return isPortrait ? 16 : 14;
    return 20;
  }

  double get smallBorderRadius {
    if (isMobile) return isPortrait ? 8 : 6;
    if (isTablet) return isPortrait ? 10 : 8;
    return 12;
  }

  // عدد الأعمدة في الشبكة
  int get gridColumns {
    if (isMobile) return isPortrait ? 2 : 3;
    if (isTablet) return isPortrait ? 3 : 4;
    return isPortrait ? 4 : 5;
  }

  int get storeGridColumns {
    if (isMobile) return isPortrait ? 1 : 2;
    if (isTablet) return isPortrait ? 2 : 3;
    return isPortrait ? 3 : 4;
  }

  // عرض المحتوى الأقصى
  double get maxContentWidth {
    if (isMobile) return screenWidth;
    if (isTablet) return math.min(800, screenWidth * 0.9);
    return math.min(1200, screenWidth * 0.8);
  }

  // ارتفاع شريط التطبيق
  double get appBarHeight {
    if (isMobile) return isPortrait ? 56 : 48;
    if (isTablet) return isPortrait ? 64 : 56;
    return 72;
  }

  // تحديد نوع الجهاز
  DeviceType _getDeviceType(Size size) {
    double deviceWidth = size.shortestSide;
    if (deviceWidth < 600) return DeviceType.mobile;
    if (deviceWidth < 1200) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // تحديد اتجاه الشاشة
  OrientationType _getOrientation(Size size) {
    return size.width > size.height
        ? OrientationType.landscape
        : OrientationType.portrait;
  }

  // حساب حجم النص المتجاوب
  double getResponsiveFontSize(double baseFontSize) {
    double scaleFactor = screenWidth / 375; // iPhone base width
    return baseFontSize * math.max(0.8, math.min(scaleFactor, 1.5));
  }

  // حساب الحجم المتجاوب
  double getResponsiveSize(double baseSize) {
    double scaleFactor = screenDiagonal / 896; // iPhone 11 Pro diagonal
    return baseSize * math.max(0.7, math.min(scaleFactor, 1.8));
  }

  // تخطيط متجاوب للشبكة
  SliverGridDelegate getResponsiveGridDelegate({
    required int itemCount,
    double aspectRatio = 1.0,
    double spacing = 16.0,
  }) {
    int columns = math.min(gridColumns, itemCount);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: aspectRatio,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
    );
  }

  // تخطيط متجاوب للمتجر
  SliverGridDelegate getStoreGridDelegate({
    required int itemCount,
    double aspectRatio = 0.8,
    double spacing = 16.0,
  }) {
    int columns = math.min(storeGridColumns, itemCount);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: aspectRatio,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
    );
  }
}

// معلومات تحديد الحجم
class SizingInformation {
  final DeviceType deviceType;
  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;
  final bool isPortrait;
  final bool isLandscape;
  final Size screenSize;

  SizingInformation({
    required this.deviceType,
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
    required this.isPortrait,
    required this.isLandscape,
    required this.screenSize,
  });
}

// بناء الواجهات المتجاوبة
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, SizingInformation sizingInfo)
      builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    ResponsiveSystem.instance.initialize(context);
    final responsive = ResponsiveSystem.instance;

    final sizingInfo = SizingInformation(
      deviceType: responsive.deviceType,
      isDesktop: responsive.isDesktop,
      isTablet: responsive.isTablet,
      isMobile: responsive.isMobile,
      isPortrait: responsive.isPortrait,
      isLandscape: responsive.isLandscape,
      screenSize: responsive.screenSize,
    );

    return builder(context, sizingInfo);
  }
}

// أنواع الأجهزة
enum DeviceType { mobile, tablet, desktop }

// اتجاه الشاشة
enum OrientationType { portrait, landscape }

// ويدجت مساعدة للتجاوب
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
    ResponsiveSystem.instance.initialize(context);

    if (ResponsiveSystem.instance.isDesktop && desktop != null) {
      return desktop!;
    }
    if (ResponsiveSystem.instance.isTablet && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

// Extension للحصول على قيم متجاوبة
extension ResponsiveExtension on BuildContext {
  ResponsiveSystem get responsive {
    ResponsiveSystem.instance.initialize(this);
    return ResponsiveSystem.instance;
  }
}
