import 'package:flutter/material.dart';
import 'modern_theme.dart';

/// مكونات التصميم الحديثة
class ModernComponents {
  /// بطاقة حديثة مع تأثيرات بصرية متقدمة
  static Widget modernCard({
    required Widget child,
    EdgeInsets? padding,
    Gradient? gradient,
    Color? color,
    double? borderRadius,
    List<BoxShadow>? shadows,
    Border? border,
    bool withGlow = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(ModernSpacing.lg),
        decoration: BoxDecoration(
          gradient: gradient,
          color: color ?? ModernColors.surface,
          borderRadius: BorderRadius.circular(borderRadius ?? ModernRadius.lg),
          boxShadow: withGlow
              ? ModernDesignSystem.glowShadow
              : (shadows ?? ModernDesignSystem.smallShadow),
          border: border ?? Border.all(color: ModernColors.border, width: 1),
        ),
        child: child,
      ),
    );
  }

  /// زر حديث متدرج مع تحريكات
  static Widget modernButton({
    required String text,
    required VoidCallback? onPressed,
    Gradient? gradient,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isLoading = false,
    bool isSmall = false,
    bool isOutlined = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: isOutlined
          ? _buildOutlinedButton(
              text: text,
              onPressed: onPressed,
              icon: icon,
              isLoading: isLoading,
              isSmall: isSmall,
            )
          : _buildFilledButton(
              text: text,
              onPressed: onPressed,
              gradient: gradient,
              backgroundColor: backgroundColor,
              textColor: textColor,
              icon: icon,
              isLoading: isLoading,
              isSmall: isSmall,
            ),
    );
  }

  static Widget _buildFilledButton({
    required String text,
    required VoidCallback? onPressed,
    Gradient? gradient,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    bool isLoading = false,
    bool isSmall = false,
  }) {
    return Container(
      height: isSmall ? 40 : 56,
      decoration: BoxDecoration(
        gradient: gradient ?? ModernDesignSystem.primaryGradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(ModernRadius.md),
        boxShadow: onPressed != null ? ModernDesignSystem.mediumShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(ModernRadius.md),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? ModernSpacing.md : ModernSpacing.lg,
              vertical: ModernSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? ModernColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor ?? ModernColors.textOnPrimary,
                    size: isSmall ? 18 : 20,
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                ],
                Text(
                  text,
                  style:
                      (isSmall
                              ? ModernTextStyles.bodyMedium
                              : ModernTextStyles.labelLarge)
                          .copyWith(
                            color: textColor ?? ModernColors.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildOutlinedButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isSmall = false,
  }) {
    return Container(
      height: isSmall ? 40 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ModernRadius.md),
        border: Border.all(color: ModernColors.primary, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(ModernRadius.md),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? ModernSpacing.md : ModernSpacing.lg,
              vertical: ModernSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ModernColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    color: ModernColors.primary,
                    size: isSmall ? 18 : 20,
                  ),
                  const SizedBox(width: ModernSpacing.sm),
                ],
                Text(
                  text,
                  style:
                      (isSmall
                              ? ModernTextStyles.bodyMedium
                              : ModernTextStyles.labelLarge)
                          .copyWith(
                            color: ModernColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// حقل إدخال حديث
  static Widget modernTextField({
    required String label,
    String? hint,
    TextEditingController? controller,
    Function(String)? onChanged,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ModernTextStyles.bodyMedium.copyWith(
            color: ModernColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: ModernSpacing.xs),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ModernRadius.md),
            boxShadow: ModernDesignSystem.smallShadow,
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            enabled: enabled,
            style: ModernTextStyles.bodyLarge.copyWith(
              color: ModernColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: ModernColors.textSecondary)
                  : null,
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Icon(
                        suffixIcon,
                        color: ModernColors.textSecondary,
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ModernRadius.md),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: enabled
                  ? ModernColors.surfaceVariant
                  : ModernColors.surfaceTint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ModernSpacing.lg,
                vertical: ModernSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// شريط تطبيق حديث
  static PreferredSizeWidget modernAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = true,
    Color? backgroundColor,
    double elevation = 0,
  }) {
    return AppBar(
      title: Text(
        title,
        style: ModernTextStyles.headlineMedium.copyWith(
          color: ModernColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      leading: leading,
      actions: actions,
      flexibleSpace: elevation > 0
          ? Container(
              decoration: BoxDecoration(
                boxShadow: ModernDesignSystem.smallShadow,
              ),
            )
          : null,
    );
  }

  /// مؤشر تحميل حديث
  static Widget modernLoader({double size = 24, Color? color, String? text}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? ModernColors.primary,
            ),
          ),
        ),
        if (text != null) ...[
          const SizedBox(height: ModernSpacing.md),
          Text(
            text,
            style: ModernTextStyles.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// حالة فارغة حديثة
  static Widget modernEmptyState({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(ModernSpacing.xl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ModernColors.surfaceTint,
            ),
            child: Icon(icon, size: 64, color: ModernColors.textTertiary),
          ),
          const SizedBox(height: ModernSpacing.lg),
          Text(
            title,
            style: ModernTextStyles.headlineMedium.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: ModernSpacing.sm),
            Text(
              subtitle,
              style: ModernTextStyles.bodyMedium.copyWith(
                color: ModernColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: ModernSpacing.xl),
            action,
          ],
        ],
      ),
    );
  }
}

/// ويدجت التحريكات المتقدمة
class ModernAnimations {
  /// تحريكة الظهور التدريجي
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Offset? offset,
    Curve curve = Curves.easeOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: offset != null
              ? Transform.translate(
                  offset: Offset.lerp(offset, Offset.zero, value)!,
                  child: child,
                )
              : child,
        );
      },
    );
  }

  /// تحريكة التحجيم
  static Widget scaleIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.elasticOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: duration,
      curve: curve,
      child: child,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
    );
  }
}
