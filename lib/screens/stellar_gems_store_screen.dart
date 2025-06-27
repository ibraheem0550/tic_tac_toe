import 'package:flutter/material.dart';
import '../models/payment_models.dart' hide SavedPaymentMethod;
import 'package:flutter/services.dart';
import '../services/payment_service_new.dart';
import '../services/firebase_auth_service.dart';
import '../models/gems_models.dart';
import '../utils/app_theme_new.dart';
import '../utils/logger.dart';

class StellarGemsStoreScreen extends StatefulWidget {
  const StellarGemsStoreScreen({super.key});

  @override
  State<StellarGemsStoreScreen> createState() => _StellarGemsStoreScreenState();
}

class _StellarGemsStoreScreenState extends State<StellarGemsStoreScreen>
    with TickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  UserGems? _userGems;
  bool _isLoading = false;
  List<GemsPackage> _packages = [];
  List<SavedPaymentMethod> _savedPaymentMethods = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await _loadUserGems();
      await _loadGemsPackages();
      await _loadSavedPaymentMethods();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserGems() async {
    try {
      // في التطبيق الحقيقي، ستحمل من AuthService أو قاعدة البيانات
      final user = FirebaseAuthService().currentUser;
      if (user != null) {
        setState(() {
          _userGems = UserGems(
            userId: user.id,
            currentGems: user.gems,
            totalEarned: user.gems,
          );
        });
      }
    } catch (e) {
      Logger.logError('خطأ في تحميل الجواهر', e);
    }
  }

  Future<void> _loadGemsPackages() async {
    try {
      // حزم الجواهر المتاحة
      setState(() {
        _packages = [
          const GemsPackage(
            id: 'starter',
            name: 'حزمة المبتدئين',
            description: 'حزمة مثالية للبداية',
            gemsAmount: 100,
            price: 0.99,
          ),
          const GemsPackage(
            id: 'popular',
            name: 'حزمة شائعة',
            description: 'الأكثر مبيعاً - قيمة ممتازة',
            gemsAmount: 500,
            price: 4.99,
            isPopular: true,
            discount: 20,
          ),
          const GemsPackage(
            id: 'premium',
            name: 'حزمة مميزة',
            description: 'جواهر إضافية مجانية',
            gemsAmount: 1000,
            price: 9.99,
            discount: 30,
          ),
          const GemsPackage(
            id: 'mega',
            name: 'حزمة عملاقة',
            description: 'أفضل صفقة للاعبين النشطين',
            gemsAmount: 2500,
            price: 19.99,
            discount: 50,
          ),
        ];
      });
    } catch (e) {
      Logger.logError('خطأ في تحميل باقات الجواهر', e);
    }
  }

  Future<void> _loadSavedPaymentMethods() async {
    try {
      _savedPaymentMethods = await _paymentService.getSavedPaymentMethods();
    } catch (e) {
      Logger.logError('خطأ في تحميل طرق الدفع', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.starfieldGradient,
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                )
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: CustomScrollView(
                          slivers: [
                            _buildStellarAppBar(),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.all(AppDimensions.paddingLG),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  _buildUserGemsHeader(),
                                  const SizedBox(
                                      height: AppDimensions.paddingXL),
                                  _buildGemsPackagesGrid(),
                                  const SizedBox(
                                      height: AppDimensions.paddingXL),
                                  _buildPaymentMethodsSection(),
                                  const SizedBox(
                                      height: AppDimensions.paddingXXL),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildStellarAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.nebularGradient,
            boxShadow: AppShadows.card,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.nebularGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.stellarGradient,
                        boxShadow: AppShadows.stellar,
                      ),
                      child: const Icon(
                        Icons.diamond,
                        size: 50,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'متجر الجواهر النجمي',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                'اجمع الجواهر واستمتع بالمزايا الحصرية',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserGemsHeader() {
    if (_userGems == null) return const SizedBox.shrink();

    return AppComponents.stellarCard(
      gradient: AppColors.galaxyGradient,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.stellarGradient,
              boxShadow: AppShadows.stellar,
            ),
            child: const Icon(
              Icons.star,
              size: 32,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رصيدك الحالي',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_userGems!.currentGems} جوهرة',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.starGold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.cosmicButtonGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.card,
            ),
            child: Text(
              'VIP',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGemsPackagesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'باقات الجواهر المميزة',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final crossAxisCount = isTablet ? 3 : 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.8,
                crossAxisSpacing: AppDimensions.paddingMD,
                mainAxisSpacing: AppDimensions.paddingMD,
              ),
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                return _buildGemsPackageCard(_packages[index], index);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildGemsPackageCard(GemsPackage package, int index) {
    final isPopular = index == 1; // Make middle package popular

    return Container(
      decoration: BoxDecoration(
        gradient:
            isPopular ? AppColors.stellarGradient : AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: isPopular ? AppShadows.stellar : AppShadows.card,
        border:
            isPopular ? Border.all(color: AppColors.starGold, width: 2) : null,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.starGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'الأكثر شعبية',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.backgroundPrimary,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textPrimary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.textPrimary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.diamond,
                    size: 32,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                Text(
                  '${package.gemsAmount}',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'جوهرة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                if (package.discount != null && package.discount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '+${package.discount!.toInt()}% خصم',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  '\$${package.price}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.starGold,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                AppComponents.stellarButton(
                  text: 'شراء الآن',
                  onPressed: () => _handlePurchase(package),
                  icon: Icons.shopping_cart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'طرق الدفع المحفوظة',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        if (_savedPaymentMethods.isEmpty)
          AppComponents.stellarCard(
            child: Column(
              children: [
                Icon(
                  Icons.payment,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                Text(
                  'لا توجد طرق دفع محفوظة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                AppComponents.stellarButton(
                  text: 'إضافة طريقة دفع',
                  onPressed: _addPaymentMethod,
                  icon: Icons.add,
                ),
              ],
            ),
          )
        else
          ...(_savedPaymentMethods
              .map((method) => _buildPaymentMethodCard(method))),
      ],
    );
  }

  Widget _buildPaymentMethodCard(SavedPaymentMethod method) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      child: AppComponents.stellarCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.cosmicButtonGradient,
              ),
              child: Icon(
                // استخدام أيقونة افتراضية لبطاقة الائتمان
                Icons.credit_card,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingLG),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${method.brand} ****${method.last4}',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'طريقة دفع محفوظة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.textTertiary,
              ),
              onPressed: () => _showPaymentMethodOptions(method),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(GemsPackage package) async {
    try {
      HapticFeedback.lightImpact();

      showDialog(
        context: context,
        builder: (context) => _buildPurchaseDialog(package),
      );
    } catch (e) {
      _showErrorDialog('خطأ في الشراء: $e');
    }
  }

  Widget _buildPurchaseDialog(GemsPackage package) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.starfieldGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: AppShadows.modal,
          border: Border.all(
            color: AppColors.borderPrimary,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.stellarGradient,
                boxShadow: AppShadows.stellar,
              ),
              child: const Icon(
                Icons.diamond,
                size: 40,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text(
              'تأكيد الشراء',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              'هل تريد شراء ${package.gemsAmount} جوهرة بسعر \$${package.price}؟',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Row(
              children: [
                Expanded(
                  child: AppComponents.stellarButton(
                    text: 'إلغاء',
                    onPressed: () => Navigator.pop(context),
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                Expanded(
                  child: AppComponents.stellarButton(
                    text: 'تأكيد',
                    onPressed: () => _confirmPurchase(package),
                    icon: Icons.check,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmPurchase(GemsPackage package) async {
    Navigator.pop(context);
    setState(() => _isLoading = true);
    try {
      // محاكاة عملية الشراء
      await Future.delayed(const Duration(seconds: 2));

      // تحديث الجواهر للمستخدم
      final user = FirebaseAuthService().currentUser;
      if (user != null && _userGems != null) {
        _userGems!.addGems(package.gemsAmount);
        await _loadUserGems();
      }

      _showSuccessDialog('تم شراء ${package.gemsAmount} جوهرة بنجاح!');
    } catch (e) {
      _showErrorDialog('فشل في إتمام الشراء: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addPaymentMethod() {
    // TODO: Implement add payment method
    showDialog(
      context: context,
      builder: (context) => _buildAddPaymentMethodDialog(),
    );
  }

  Widget _buildAddPaymentMethodDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.starfieldGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: AppShadows.modal,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إضافة طريقة دفع',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Text(
              'هذه الميزة ستكون متاحة قريباً',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            AppComponents.stellarButton(
              text: 'موافق',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethodOptions(SavedPaymentMethod method) {
    // TODO: Implement payment method options
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.starfieldGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: AppShadows.modal,
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.success, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  size: 40,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'نجح!',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              Text(
                message,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              AppComponents.stellarButton(
                text: 'رائع!',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.starfieldGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: AppShadows.modal,
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.2),
                  border: Border.all(color: AppColors.error, width: 2),
                ),
                child: const Icon(
                  Icons.error,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'خطأ',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              Text(
                message,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              AppComponents.stellarButton(
                text: 'موافق',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
