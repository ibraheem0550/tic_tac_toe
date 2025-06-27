import 'package:flutter/material.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_sizes.dart';

/// مكون لعرض رسائل التحذير للمستخدمين الضيوف
class GuestRestrictionDialog extends StatelessWidget {
  final String featureName;
  final String description;
  final VoidCallback? onUpgrade;

  const GuestRestrictionDialog({
    super.key,
    required this.featureName,
    required this.description,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSizes = ResponsiveSizes(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.warning,
            size: responsiveSizes.buttonSizes.iconSize,
          ),
          SizedBox(width: responsiveSizes.paddingSmall),
          Expanded(
            child: Text(
              'ميزة محدودة',
              style: TextStyle(
                fontSize: responsiveSizes.textSizes.subtitle,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              fontSize: responsiveSizes.textSizes.body,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: responsiveSizes.paddingMedium),
          Container(
            padding: EdgeInsets.all(responsiveSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: responsiveSizes.buttonSizes.iconSize * 0.8,
                ),
                SizedBox(width: responsiveSizes.paddingSmall),
                Expanded(
                  child: Text(
                    'أنت تستخدم التطبيق كضيف. قم بإنشاء حساب للوصول إلى جميع المزايا.',
                    style: TextStyle(
                      fontSize: responsiveSizes.textSizes.body * 0.9,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'إلغاء',
            style: TextStyle(
              fontSize: responsiveSizes.buttonSizes.fontSize,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (onUpgrade != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUpgrade!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: responsiveSizes.buttonSizes.padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  responsiveSizes.buttonSizes.borderRadius,
                ),
              ),
            ),
            child: Text(
              'إنشاء حساب',
              style: TextStyle(
                fontSize: responsiveSizes.buttonSizes.fontSize,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// عرض مربع حوار التحذير
  static Future<void> show(
    BuildContext context, {
    required String featureName,
    required String description,
    VoidCallback? onUpgrade,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => GuestRestrictionDialog(
        featureName: featureName,
        description: description,
        onUpgrade: onUpgrade,
      ),
    );
  }
}

/// مكون لعرض شارة الضيف في الواجهة
class GuestBadge extends StatelessWidget {
  final User? user;

  const GuestBadge({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    if (user?.provider != AuthProvider.guest) {
      return const SizedBox.shrink();
    }

    final responsiveSizes = ResponsiveSizes(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsiveSizes.paddingSmall,
        vertical: responsiveSizes.paddingSmall / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline,
            size: responsiveSizes.textSizes.caption + 2,
            color: AppColors.warning,
          ),
          SizedBox(width: responsiveSizes.paddingSmall / 2),
          Text(
            'ضيف',
            style: TextStyle(
              fontSize: responsiveSizes.textSizes.caption,
              color: AppColors.warning,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// خدمة للتحقق من القيود وعرض التحذيرات
class GuestRestrictionService {
  /// التحقق من إمكانية الوصول لميزة وعرض تحذير إذا لزم الأمر
  static Future<bool> checkFeatureAccess(
    BuildContext context, {
    required User? user,
    required String featureName,
    required String description,
    VoidCallback? onUpgrade,
  }) async {
    if (user?.provider != AuthProvider.guest) {
      return true; // المستخدم مسجل، يمكنه الوصول
    }

    // عرض تحذير للضيف
    await GuestRestrictionDialog.show(
      context,
      featureName: featureName,
      description: description,
      onUpgrade: onUpgrade,
    );

    return false; // لا يمكن للضيف الوصول
  }

  /// قائمة بالميزات المقيدة مع أوصافها
  static const Map<String, String> restrictedFeatures = {
    'friends': 'إضافة الأصدقاء والدردشة معهم متاحة فقط للمستخدمين المسجلين.',
    'payments': 'عمليات الشراء والدفع متاحة فقط للمستخدمين المسجلين.',
    'cloud_save':
        'حفظ التقدم في السحابة ومزامنة البيانات متاح فقط للمستخدمين المسجلين.',
    'leaderboard':
        'قوائم المتصدرين والتنافس العالمي متاح فقط للمستخدمين المسجلين.',
    'premium_themes': 'الثيمات المميزة متاحة فقط للمستخدمين المسجلين.',
    'tournaments': 'المشاركة في البطولات متاحة فقط للمستخدمين المسجلين.',
    'achievements_sync': 'مزامنة الإنجازات متاحة فقط للمستخدمين المسجلين.',
  };

  /// الحصول على وصف ميزة مقيدة
  static String getFeatureDescription(String featureKey) {
    return restrictedFeatures[featureKey] ??
        'هذه الميزة متاحة فقط للمستخدمين المسجلين.';
  }
}

/// أمثلة على كيفية الاستخدام:
/// 
/// // في أي مكان تريد التحقق من صلاحية الضيف
/// final canAccess = await GuestRestrictionService.checkFeatureAccess(
///   context,
///   user: AuthService().currentUser,
///   featureName: 'الأصدقاء',
///   description: GuestRestrictionService.getFeatureDescription('friends'),
///   onUpgrade: () => Navigator.pushNamed(context, '/register'),
/// );
/// 
/// if (canAccess) {
///   // تنفيذ الميزة
/// }
/// 
/// // لعرض شارة الضيف
/// GuestBadge(user: AuthService().currentUser)
