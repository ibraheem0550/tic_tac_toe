import 'package:flutter/material.dart';
import '../models/complete_user_models.dart';

/// أنواع الأجهزة للتوافق
enum ResponsiveDeviceType { mobile, tablet, desktop }

/// فئة مساعدة لتوفير أحجام متجاوبة للواجهة
class ResponsiveSizes {
  final BuildContext context;
  final Size screenSize;

  ResponsiveSizes(this.context) : screenSize = MediaQuery.of(context).size;

  /// عرض الشاشة
  double get screenWidth => screenSize.width;

  /// ارتفاع الشاشة
  double get screenHeight => screenSize.height;

  /// نوع الجهاز
  ResponsiveDeviceType get deviceType {
    if (screenWidth >= 1200) return ResponsiveDeviceType.desktop;
    if (screenWidth >= 768) return ResponsiveDeviceType.tablet;
    return ResponsiveDeviceType.mobile;
  }

  /// أحجام الأزرار حسب نوع الجهاز
  ButtonSizes get buttonSizes {
    switch (deviceType) {
      case ResponsiveDeviceType.desktop:
        return ButtonSizes(
          height: 60,
          fontSize: 18,
          iconSize: 28,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        );
      case ResponsiveDeviceType.tablet:
        return ButtonSizes(
          height: 56,
          fontSize: 16,
          iconSize: 24,
          borderRadius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        );
      case ResponsiveDeviceType.mobile:
        return ButtonSizes(
          height: 50,
          fontSize: 14,
          iconSize: 20,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
    }
  }

  /// مسافات متجاوبة
  double get paddingSmall => deviceType == ResponsiveDeviceType.mobile ? 8 : 12;
  double get paddingMedium =>
      deviceType == ResponsiveDeviceType.mobile ? 12 : 16;
  double get paddingLarge =>
      deviceType == ResponsiveDeviceType.mobile ? 16 : 24;
  double get paddingXLarge =>
      deviceType == ResponsiveDeviceType.mobile ? 24 : 32;

  /// أحجام النصوص
  TextSizes get textSizes {
    switch (deviceType) {
      case ResponsiveDeviceType.desktop:
        return TextSizes(
          title: 28,
          subtitle: 20,
          body: 16,
          caption: 14,
        );
      case ResponsiveDeviceType.tablet:
        return TextSizes(
          title: 24,
          subtitle: 18,
          body: 14,
          caption: 12,
        );
      case ResponsiveDeviceType.mobile:
        return TextSizes(
          title: 20,
          subtitle: 16,
          body: 12,
          caption: 10,
        );
    }
  }

  /// عرض مربع الحوار
  double get dialogWidth {
    switch (deviceType) {
      case ResponsiveDeviceType.desktop:
        return 500;
      case ResponsiveDeviceType.tablet:
        return 400;
      case ResponsiveDeviceType.mobile:
        return screenWidth * 0.9;
    }
  }
}

/// أنواع الأجهزة
enum DeviceType { mobile, tablet, desktop }

/// أحجام الأزرار
class ButtonSizes {
  final double height;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final EdgeInsets padding;

  const ButtonSizes({
    required this.height,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    required this.padding,
  });
}

/// أحجام النصوص
class TextSizes {
  final double title;
  final double subtitle;
  final double body;
  final double caption;

  const TextSizes({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.caption,
  });
}

/// خدمة للتحقق من صلاحيات المستخدم
class UserPermissions {
  static bool canUseFriends(User? user) {
    return user != null && !user.isGuest;
  }

  static bool canMakePayments(User? user) {
    return user != null && !user.isGuest;
  }

  static bool canSyncData(User? user) {
    return user != null && !user.isGuest;
  }

  static bool canUseOnlineFeatures(User? user) {
    return user != null && !user.isGuest;
  }

  static bool canAccessPremiumFeatures(User? user) {
    return user != null && !user.isGuest;
  }

  static bool canCustomizeProfile(User? user) {
    return user != null; // متاح حتى للضيوف
  }

  static bool canSaveProgress(User? user) {
    return user != null; // متاح حتى للضيوف (محلياً)
  }

  static String getRestrictionMessage(String feature) {
    return 'هذه الميزة متاحة فقط للمستخدمين المسجلين. يرجى إنشاء حساب للوصول إلى $feature.';
  }
}
