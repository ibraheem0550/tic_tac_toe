import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/payment_service_new.dart';
import '../services/firebase_auth_service.dart';
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
  final PaymentService _paymentService = PaymentService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  UserGems? _userGems;
  bool _isLoading = false;
  String _selectedCategory = 'gems';
  List<GemsPackage> _gemsPackages = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _userGems = UserGems(
          userId: user.id,
          currentGems: user.gems,
          totalEarned: user.gems,
          totalSpent: 0,
          lastUpdated: DateTime.now(),
        );
      }
      await _loadGemsPackages();
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGemsPackages() async {
    try {
      _gemsPackages = _paymentService.getAvailablePackages();
    } catch (e) {
      print('خطأ في تحميل حزم الجواهر: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        appBar: _buildAppBar(),
        body: _isLoading ? _buildLoadingWidget() : _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'متجر المجرة الشامل',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.backgroundSecondary,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_userGems != null) _buildUserGemsHeader(),
            const SizedBox(height: 24),
            _buildGemsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGemsHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.stellarGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.diamond,
            color: AppColors.starGold,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'جواهرك النجمية',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${_userGems!.currentGems}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.starGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'حزم الجواهر النجمية',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _gemsPackages.length,
          itemBuilder: (context, index) {
            return _buildGemsPackageCard(_gemsPackages[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildGemsPackageCard(GemsPackage package, int index) {
    final isPopular = package.isPopular;

    return Container(
      decoration: BoxDecoration(
        gradient: isPopular
            ? AppColors.stellarGradient
            : const LinearGradient(
                colors: [AppColors.surfacePrimary, AppColors.surfaceSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.starGold : AppColors.borderPrimary,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPopular ? AppColors.starGold : AppColors.primary)
                .withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                if (isPopular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.starGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'الأكثر شعبية',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.backgroundPrimary,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.diamond,
                  color: AppColors.starGold,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${package.gemsAmount} جوهرة',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.starGold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  '\$${package.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handlePurchase(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isPopular ? AppColors.starGold : AppColors.primary,
                      foregroundColor: AppColors.backgroundPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'اشتراء',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(GemsPackage package) async {
    try {
      // عرض حوار التأكيد
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => _buildPurchaseDialog(package),
      );

      if (confirm == true) {
        setState(() => _isLoading = true);

        // محاكاة عملية الشراء
        await Future.delayed(const Duration(seconds: 2));

        // تحديث الجواهر
        if (_userGems != null) {
          _userGems!.addGems(package.gemsAmount);
        }

        _showSuccessMessage('تم شراء ${package.gemsAmount} جوهرة بنجاح!');
      }
    } catch (e) {
      _showErrorMessage('فشل في إتمام الشراء: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPurchaseDialog(GemsPackage package) {
    return AlertDialog(
      backgroundColor: AppColors.surfacePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'تأكيد الشراء',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
      content: Text(
        'هل تريد شراء ${package.gemsAmount} جوهرة مقابل \$${package.price.toStringAsFixed(2)}؟',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child:
              const Text('إلغاء', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
          ),
          child: const Text('تأكيد'),
        ),
      ],
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
