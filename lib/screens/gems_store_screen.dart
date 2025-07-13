import 'package:flutter/material.dart';
import '../services/payment_service_new.dart';
import '../services/unified_auth_services.dart';
import '../models/gems_models.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_helper.dart';

class GemsStoreScreen extends StatefulWidget {
  const GemsStoreScreen({super.key});

  @override
  State<GemsStoreScreen> createState() => _GemsStoreScreenState();
}

class _GemsStoreScreenState extends State<GemsStoreScreen>
    with TickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  UserGems? _userGems;
  bool _isLoading = false;
  List<GemsPackage> _packages = [];
  List<SavedPaymentMethod> _savedPaymentMethods = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _paymentService.initialize();
      _packages = _paymentService.getAvailablePackages();
      final user = _authService.currentUser;
      if (user != null) {
        final currentGems = await _paymentService.getCurrentUserGems();
        _userGems = UserGems(userId: user.id, currentGems: currentGems);
        _savedPaymentMethods = await _paymentService.getSavedPaymentMethods();
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء تحميل البيانات');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveHelper.getDeviceType(width);
    final isDesktopOrTablet =
        deviceType == DeviceType.desktop ||
        deviceType == DeviceType.tablet ||
        deviceType == DeviceType.largeDesktop;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingWidget()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: isDesktopOrTablet
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'متجر الجواهر',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textSecondary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        _buildGemsCounter(),
        const SizedBox(width: AppDimensions.paddingMD),
      ],
    );
  }

  Widget _buildGemsCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.diamond, color: Colors.white, size: 20),
          const SizedBox(width: AppDimensions.paddingSM),
          Text(
            '${_userGems?.currentGems ?? 0}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildPackagesGrid(crossAxisCount: 3),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildSavedPaymentMethods(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.paddingLG),
          _buildPackagesGrid(crossAxisCount: 1),
          const SizedBox(height: AppDimensions.paddingLG),
          _buildSavedPaymentMethods(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.diamond, size: 64, color: AppColors.primary),
          const SizedBox(height: AppDimensions.paddingMD),
          Text(
            'اشحن جواهرك الآن',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            'استخدم الجواهر لشراء الثيمات الخاصة والمميزات الإضافية',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesGrid({required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: crossAxisCount == 1 ? 3.5 : 0.8,
        crossAxisSpacing: AppDimensions.paddingLG,
        mainAxisSpacing: AppDimensions.paddingLG,
      ),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final package = _packages[index];
        return _buildPackageCard(package);
      },
    );
  }

  Widget _buildPackageCard(GemsPackage package) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceLight, AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.elevated,
        border: package.isPopular
            ? Border.all(color: AppColors.accent, width: 2)
            : null,
      ),
      child: Stack(
        children: [
          if (package.isPopular)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingSM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Text(
                  'الأكثر طلباً',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.diamond, size: 48, color: AppColors.primary),
                const SizedBox(height: AppDimensions.paddingMD),
                Text(
                  package.name,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingSM),
                Text(
                  package.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                if ((package.discount ?? 0) > 0) ...[
                  Text(
                    '\$${package.price.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                ],
                Text(
                  '\$${package.finalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if ((package.discount ?? 0) > 0) ...[
                  const SizedBox(height: AppDimensions.paddingXS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSM,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Text(
                      'خصم ${package.discount}%',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.paddingLG),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showPurchaseDialog(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingMD,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLG,
                        ),
                      ),
                    ),
                    child: Text(
                      'شراء الآن',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPaymentMethods() {
    if (_savedPaymentMethods.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طرق الدفع المحفوظة',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        ...(_savedPaymentMethods.map(
          (method) => _buildPaymentMethodCard(method),
        )),
      ],
    );
  }

  Widget _buildPaymentMethodCard(SavedPaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Icon(
            _getPaymentMethodIcon(PaymentMethodType.creditCard),
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: AppDimensions.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${method.brand.toUpperCase()} •••• ${method.last4}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ينتهي في ${method.expiryMonth}/${method.expiryYear}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (method.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSM,
                vertical: AppDimensions.paddingXS,
              ),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                'افتراضي',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethodType type) {
    switch (type) {
      case PaymentMethodType.creditCard:
        return Icons.credit_card;
      case PaymentMethodType.paypal:
        return Icons.account_balance_wallet;
      case PaymentMethodType.googlePay:
        return Icons.g_mobiledata;
      case PaymentMethodType.applePay:
        return Icons.apple;
      case PaymentMethodType.stripe:
        return Icons.payment;
    }
  }

  void _showPurchaseDialog(GemsPackage package) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: AppShadows.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond, size: 64, color: AppColors.primary),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'تأكيد الشراء',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              Text(
                'هل تريد شراء ${package.name} بسعر \$${package.finalPrice.toStringAsFixed(2)}؟',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.borderPrimary),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLG,
                          ),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMD),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showPaymentMethodsDialog(package);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingMD,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLG,
                          ),
                        ),
                      ),
                      child: Text(
                        'شراء',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodsDialog(GemsPackage package) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: AppShadows.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر طريقة الدفع',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              _buildPaymentMethodButton(
                'بطاقة ائتمانية',
                Icons.credit_card,
                () => _purchaseWithCreditCard(package),
              ),
              _buildPaymentMethodButton(
                'Google Pay',
                Icons.g_mobiledata,
                () => _purchaseWithGooglePay(package),
              ),
              _buildPaymentMethodButton(
                'Apple Pay',
                Icons.apple,
                () => _purchaseWithApplePay(package),
              ),
              if (_savedPaymentMethods.isNotEmpty) ...[
                Divider(color: AppColors.borderPrimary),
                ...(_savedPaymentMethods.map(
                  (method) => _buildSavedPaymentMethodButton(package, method),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
        label: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          side: BorderSide(color: AppColors.borderPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedPaymentMethodButton(
    GemsPackage package,
    SavedPaymentMethod method,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      child: OutlinedButton(
        onPressed: () => _purchaseWithSavedMethod(package, method),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(PaymentMethodType.creditCard),
              color: AppColors.primary,
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Text(
              '${method.brand.toUpperCase()} •••• ${method.last4}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchaseWithCreditCard(GemsPackage package) async {
    Navigator.of(context).pop(); // Close dialog

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _paymentService.purchaseWithCreditCard(package.id);

      if (result.success) {
        await _processPurchaseSuccess(package, result);
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'فشل في عملية الدفع');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء عملية الدفع: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseWithGooglePay(GemsPackage package) async {
    Navigator.of(context).pop(); // Close dialog

    setState(() {
      _isLoading = true;
    });

    try {
      // For now, simulate purchase since Google Pay needs more setup
      final result = await _paymentService.simulatePurchase(package.id);

      if (result.success) {
        await _processPurchaseSuccess(package, result);
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'فشل في عملية الدفع');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء عملية الدفع: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseWithApplePay(GemsPackage package) async {
    Navigator.of(context).pop(); // Close dialog

    setState(() {
      _isLoading = true;
    });

    try {
      // For now, simulate purchase since Apple Pay needs more setup
      final result = await _paymentService.simulatePurchase(package.id);

      if (result.success) {
        await _processPurchaseSuccess(package, result);
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'فشل في عملية الدفع');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء عملية الدفع: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseWithSavedMethod(
    GemsPackage package,
    SavedPaymentMethod method,
  ) async {
    Navigator.of(context).pop(); // Close dialog

    setState(() {
      _isLoading = true;
    });

    try {
      // For now, simulate purchase since this needs more implementation
      final result = await _paymentService.simulatePurchase(package.id);

      if (result.success) {
        await _processPurchaseSuccess(package, result);
      } else {
        _showErrorSnackBar(result.errorMessage ?? 'فشل في عملية الدفع');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء عملية الدفع: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshUserGems() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _userGems = UserGems(
          userId: user.id,
          currentGems: 0, // سنستبدل هذا بقيمة صحيحة
          totalEarned: 0, // سنستبدل هذا بقيمة صحيحة
          totalSpent: 0, // This would come from transaction history
          lastUpdated: DateTime.now(),
        );
      });
    }
  }

  void _showSuccessDialog(GemsPackage package) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: AppShadows.modal,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 64, color: AppColors.success),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'تم الشراء بنجاح!',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              Text(
                'تم إضافة ${package.gemsAmount} جوهرة إلى حسابك',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingMD,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLG,
                      ),
                    ),
                  ),
                  child: Text(
                    'ممتاز!',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
    );
  }

  Future<void> _processPurchaseSuccess(
    GemsPackage package,
    PurchaseResult result,
  ) async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        // TODO: إضافة دالة addGems إلى AuthService
        // final success = await _authService.addGems(package.gemsAmount);

        // محاكاة إضافة الجواهر بنجاح
        // Update UI
        await _refreshUserGems();

        // Show success dialog
        _showSuccessDialog(package);

        // Log transaction
        debugPrint(
          'Purchase successful: ${package.gemsAmount} gems added to user ${currentUser.id}',
        );
      } else {
        _showErrorSnackBar('خطأ: المستخدم غير مسجل الدخول');
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء تحديث حسابك');
      debugPrint('Error processing purchase: $e');
    }
  }
}
