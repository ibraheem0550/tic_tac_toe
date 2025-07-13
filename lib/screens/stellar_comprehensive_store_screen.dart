import 'package:flutter/material.dart';
import '../services/unified_auth_services.dart';
import '../models/gems_models.dart';
import '../utils/app_theme_new.dart';

class StellarComprehensiveStoreScreen extends StatefulWidget {
  const StellarComprehensiveStoreScreen({super.key});

  @override
  State<StellarComprehensiveStoreScreen> createState() =>
      _StellarComprehensiveStoreScreenState();
}

class _StellarComprehensiveStoreScreenState
    extends State<StellarComprehensiveStoreScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _fadeAnimation;

  UserGems? _userGems;
  bool _isLoading = false;
  String _selectedCategory = 'gems'; // gems, themes, sounds, boosts, offers

  // البيانات
  List<GemsPackage> _gemsPackages = [];

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'gems',
      'title': 'الجواهر النجمية',
      'icon': Icons.diamond,
      'gradient': AppColors.stellarGradient,
    },
    {
      'id': 'themes',
      'title': 'الثيمات الكونية',
      'icon': Icons.palette,
      'gradient': const LinearGradient(
        colors: [AppColors.galaxyBlue, AppColors.nebulaPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'id': 'sounds',
      'title': 'مكتبة الأصوات',
      'icon': Icons.music_note,
      'gradient': const LinearGradient(
        colors: [AppColors.planetGreen, AppColors.cosmicTeal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'id': 'boosts',
      'title': 'التحسينات القوية',
      'icon': Icons.flash_on,
      'gradient': const LinearGradient(
        colors: [AppColors.stellarOrange, AppColors.warningDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'id': 'offers',
      'title': 'العروض المحدودة',
      'icon': Icons.local_offer,
      'gradient': const LinearGradient(
        colors: [AppColors.starGold, AppColors.stellarOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

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

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      // تحميل بيانات المستخدم
      final user = _authService.currentUserModel;
      if (user != null) {
        _userGems = UserGems(
          userId: user.id,
          currentGems: user.gems,
          totalEarned: user.gems,
          totalSpent: 0,
          lastUpdated: DateTime.now(),
        );
      }

      // تحميل البيانات من الخدمات
      await Future.wait([_loadGemsPackages()]);
    } catch (e) {
      debugPrint('Error initializing store data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGemsPackages() async {
    // Temporary mock data
    _gemsPackages = [
      GemsPackage(
        id: 'starter_gems',
        name: 'حزمة البداية النجمية',
        description: 'ابدأ رحلتك بهذه الحزمة الأساسية',
        gemsAmount: 100,
        price: 0.99,
        currency: 'USD',
        discount: 0,
        isPopular: false,
      ),
      GemsPackage(
        id: 'cosmic_gems',
        name: 'حزمة الكون الرائعة',
        description: 'احصل على جواهر أكثر مع مكافآت إضافية',
        gemsAmount: 500,
        price: 4.99,
        currency: 'USD',
        discount: 10,
        isPopular: true,
      ),
    ];
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
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildUserGems(),
                _buildCategoryTabs(),
                Expanded(child: _buildStoreContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: AppDimensions.iconLG,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppDimensions.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متجر النجوم الكوني',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'اكتشف كنوز المجرة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGems() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: AppColors.stellarGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: AppColors.starGold.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.diamond,
                  color: AppColors.textPrimary,
                  size: AppDimensions.iconLG,
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                Text(
                  '${_userGems?.currentGems ?? 0}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                Text(
                  'جوهرة نجمية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLG),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['id'];

          return GestureDetector(
            onTap: () => _selectCategory(category['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: AppDimensions.paddingMD),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLG,
                vertical: AppDimensions.paddingMD,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? category['gradient'] : null,
                color: isSelected
                    ? null
                    : AppColors.surfacePrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppColors.borderPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    size: AppDimensions.iconMD,
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    category['title'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.starGold),
        ),
      );
    }

    return _getContentForCategory();
  }

  Widget _getContentForCategory() {
    switch (_selectedCategory) {
      case 'gems':
        return _buildGemsContent();
      case 'themes':
        return _buildThemesContent();
      case 'sounds':
        return _buildSoundsContent();
      case 'boosts':
        return _buildBoostsContent();
      case 'offers':
        return _buildOffersContent();
      default:
        return _buildGemsContent();
    }
  }

  Widget _buildGemsContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      itemCount: _gemsPackages.length,
      itemBuilder: (context, index) {
        return _buildGemsPackageCard(_gemsPackages[index]);
      },
    );
  }

  Widget _buildGemsPackageCard(GemsPackage package) {
    final isPopular = package.isPopular;
    final hasDiscount = (package.discount ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: isPopular
            ? AppColors.stellarGradient
            : AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: (isPopular ? AppColors.starGold : AppColors.shadowPrimary)
                .withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          onTap: () => _purchaseGemsPackage(package),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        gradient: AppColors.cosmicButtonGradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD,
                        ),
                      ),
                      child: const Icon(
                        Icons.diamond,
                        color: AppColors.textPrimary,
                        size: AppDimensions.iconLG,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: isPopular
                                  ? AppColors.textPrimary
                                  : AppColors.starGold,
                            ),
                          ),
                          Text(
                            package.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  (isPopular
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary)
                                      .withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLG),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${package.gemsAmount} جوهرة',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.starGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            'خصم ${package.discount}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.successPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLG,
                        vertical: AppDimensions.paddingMD,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.cosmicButtonGradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLG,
                        ),
                      ),
                      child: Text(
                        '\$${package.price.toStringAsFixed(2)}',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemesContent() {
    return const Center(
      child: Text(
        'الثيمات قريباً...',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildSoundsContent() {
    return const Center(
      child: Text(
        'الأصوات قريباً...',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildBoostsContent() {
    return const Center(
      child: Text(
        'التحسينات قريباً...',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildOffersContent() {
    return const Center(
      child: Text(
        'العروض قريباً...',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
  }

  Future<void> _purchaseGemsPackage(GemsPackage package) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showPurchaseConfirmationDialog(
        package.name,
        package.price,
        package.currency,
        Icons.diamond,
      );

      if (confirmed == true) {
        // Process payment (mock for now)
        await Future.delayed(const Duration(seconds: 2));

        // Update user gems
        if (_userGems != null) {
          setState(() {
            _userGems = _userGems!.copyWith(
              currentGems: _userGems!.currentGems + package.gemsAmount,
              totalEarned: _userGems!.totalEarned + package.gemsAmount,
              lastUpdated: DateTime.now(),
            );
          });
        }

        _showSuccessMessage('تم شراء الحزمة بنجاح!');
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء الشراء');
    }
  }

  Future<bool?> _showPurchaseConfirmationDialog(
    String title,
    double price,
    String currency,
    IconData icon,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: Row(
          children: [
            Icon(icon, color: AppColors.starGold),
            const SizedBox(width: 8),
            Text(
              'تأكيد الشراء',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'هل تريد شراء $title مقابل \$${price.toStringAsFixed(2)}؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starGold,
            ),
            child: Text('شراء', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successPrimary,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorPrimary),
    );
  }
}
