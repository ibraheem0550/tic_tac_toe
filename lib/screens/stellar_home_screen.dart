import 'package:flutter/material.dart';
import '../AI/stellar_ai_level_selection.dart';
import '../screens/stellar_game_screen_enhanced_real.dart';
import '../screens/gems_store_screen.dart';
import '../screens/stellar_settings_screen.dart';
import '../screens/stellar_friends_screen_real.dart';
import '../screens/stellar_online_game_screen.dart';
import '../screens/stellar_missions_screen.dart';
import '../screens/stellar_real_stats_screen.dart';
import '../screens/admin_screen.dart';
import '../services/unified_auth_services.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';
import '../screens/auth_screen.dart';

class StellarHomeScreen extends StatefulWidget {
  const StellarHomeScreen({super.key});

  @override
  State<StellarHomeScreen> createState() => _StellarHomeScreenState();
}

class _StellarHomeScreenState extends State<StellarHomeScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double>
  _scaleAnimation; // متغيرات للدخول لوضع الإدارة عبر النجمة
  int _starTapCount = 0;
  DateTime? _lastStarTap;
  int _adminAttempts = 0;
  bool _adminBlocked = false;

  @override
  void initState() {
    super.initState();
    _authService.addAuthListener(_onUserDataChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _authService.removeAuthListener(_onUserDataChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onUserDataChanged(User? user) {
    if (mounted) {
      setState(() {});
    }
  }

  // دالة التعامل مع الضغط على النجمة للدخول لوضع الإدارة
  void _handleStarTap() {
    final now = DateTime.now();

    if (_lastStarTap != null &&
        now.difference(_lastStarTap!).inMilliseconds < 500) {
      // ضغطة مزدوجة تم اكتشافها
      _starTapCount++;
      if (_starTapCount >= 2) {
        _showAdminAccessDialog();
        _starTapCount = 0;
        _lastStarTap = null;
        return;
      }
    } else {
      _starTapCount = 1;
    }

    _lastStarTap = now;

    // إعادة تعيين العداد بعد ثانية واحدة
    Future.delayed(const Duration(seconds: 1), () {
      _starTapCount = 0;
    });
  }

  void _showAdminAccessDialog() {
    // التحقق من الحظر
    if (_adminBlocked) {
      _showBlockedMessage();
      return;
    }

    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 350),
          decoration: BoxDecoration(
            gradient: AppColors.nebularGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.starGold.withValues(alpha: 0.3),
                spreadRadius: 2,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppColors.starGold.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة النجمة المتحركة
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.stellarGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.starGold.withValues(alpha: 0.4),
                        spreadRadius: 2,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // العنوان
                Text(
                  '🌟 وضع الإدارة النجمي 🌟',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.starGold,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // الوصف
                Text(
                  'أدخل كلمة مرور الإدارة للوصول إلى لوحة التحكم النجمية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // حقل كلمة المرور
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.starGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: '🔐 كلمة مرور المشرف',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // الأزرار
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: AppColors.stellarGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.starGold.withValues(alpha: 0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () {
                            _checkAdminPassword(passwordController.text);
                          },
                          child: Text(
                            '⭐ دخول',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
      ),
    );
  }

  void _showBlockedMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: AppDimensions.iconLG),
            const SizedBox(width: AppDimensions.paddingSM),
            Text(
              'وصول محظور',
              style: AppTextStyles.headlineMedium.copyWith(color: Colors.red),
            ),
          ],
        ),
        content: Text(
          'تم حظر الوصول مؤقتاً بسبب المحاولات الخاطئة المتعددة.\nحاول مرة أخرى بعد 5 دقائق.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.starGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkAdminPassword(String password) {
    if (password == '0550') {
      // كلمة مرور صحيحة
      _adminAttempts = 0;
      _adminBlocked = false;
      Navigator.pop(context); // إغلاق dialog كلمة المرور
      _navigateToAdmin();
    } else {
      // كلمة مرور خاطئة
      _adminAttempts++;
      if (_adminAttempts >= 3) {
        _adminBlocked = true;
        Navigator.pop(context);
        _showBlockedMessage();

        // إلغاء الحظر بعد 5 دقائق
        Future.delayed(const Duration(minutes: 5), () {
          _adminBlocked = false;
          _adminAttempts = 0;
        });
      } else {
        // إظهار رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'كلمة مرور خاطئة. المحاولات المتبقية: ${3 - _adminAttempts}',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: CustomScrollView(
                    slivers: [
                      // شريط التطبيق النجمي
                      _buildStellarAppBar(),

                      // المحتوى الرئيسي
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingLG,
                          ),
                          child: Column(
                            children: [
                              // معلومات المستخدم النجمية
                              _buildStellarUserInfo(),
                              const SizedBox(height: AppDimensions.paddingXL),

                              // أزرار اللعب النجمية
                              _buildStellarGameButtons(),
                              const SizedBox(height: AppDimensions.paddingXL),

                              // ميزات إضافية
                              _buildStellarFeatures(),

                              const SizedBox(height: AppDimensions.paddingXXL),
                            ],
                          ),
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
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.nebularGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              // أيقونة نجمية متوهجة - قابلة للضغط المزدوج للدخول لوضع الإدارة
              GestureDetector(
                onTap: _handleStarTap,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.stellarGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.starGold.withValues(alpha: 0.8),
                        blurRadius: 40,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.stars,
                    size: 80,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'TIC TAC TOE',
                style: AppTextStyles.stellarTitle.copyWith(fontSize: 36),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text('مغامرة نجمية ملحمية', style: AppTextStyles.nebularSubtitle),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.bar_chart,
            color: AppColors.textPrimary,
            size: AppDimensions.iconLG,
          ),
          onPressed: () => _navigateToStats(),
          tooltip: 'الإحصائيات',
        ), // زر تسجيل الدخول/الخروج حسب حالة المستخدم
        _buildAuthButton(),
        const SizedBox(width: AppDimensions.paddingSM),
      ],
    );
  }

  Widget _buildStellarUserInfo() {
    final user = _authService.currentUserModel;

    return AppComponents.stellarCard(
      gradient: AppColors.nebularGradient,
      child: Row(
        children: [
          // صورة المستخدم النجمية
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.stellarGradient,
              border: Border.all(color: AppColors.starGold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.starGold.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: user.photoURL != null
                ? ClipOval(
                    child: Image.network(
                      user.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: AppColors.textPrimary,
                          size: 35,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.person,
                    color: AppColors.textPrimary,
                    size: 35,
                  ),
          ),
          const SizedBox(width: AppDimensions.paddingLG),

          // معلومات المستخدم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName.isEmpty ? 'مستخدم نجمي' : user.displayName,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                const SizedBox(height: AppDimensions.paddingSM),
                // شارة الضيف
                if (user.isGuest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSM,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSM,
                      ),
                    ),
                    child: Text(
                      'ضيف',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // عداد الجواهر النجمي
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
              vertical: AppDimensions.paddingMD,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              border: Border.all(color: AppColors.starGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.starGold.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.diamond,
                  color: AppColors.starGold,
                  size: AppDimensions.iconMD,
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                Text(
                  '${user.gems}',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.starGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                GestureDetector(
                  onTap: () => _navigateToGemsStore(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.starGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusCircular,
                      ),
                      border: Border.all(color: AppColors.starGold, width: 1),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.starGold,
                      size: 18,
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

  Widget _buildStellarGameButtons() {
    return Column(
      children: [
        Text('اختر مغامرتك النجمية', style: AppTextStyles.headlineLarge),
        const SizedBox(height: AppDimensions.paddingLG),

        // الأزرار الرئيسية
        Row(
          children: [
            Expanded(
              child: AppComponents.stellarButton(
                text: 'ابدأ اللعب',
                icon: Icons.play_arrow,
                height: AppDimensions.buttonHeightLG,
                onPressed: () => _navigateToLocalGame(),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: AppComponents.stellarButton(
                text: 'ضد الكمبيوتر',
                icon: Icons.smart_toy,
                isPrimary: false,
                height: AppDimensions.buttonHeightLG,
                onPressed: () => _navigateToAIGame(),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: AppDimensions.paddingLG,
        ), // زر اللعب عبر الإنترنت
        AppComponents.stellarButton(
          text: 'مغامرة عبر المجرة',
          icon: Icons.wifi,
          width: double.infinity,
          height: AppDimensions.buttonHeightLG,
          onPressed: () => _navigateToOnlineGame(),
        ),
      ],
    );
  }

  Widget _buildStellarFeatures() {
    return Column(
      children: [
        Text('استكشف المزيد', style: AppTextStyles.headlineLarge),
        const SizedBox(height: AppDimensions.paddingLG),

        // الصف الأول
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'المتجر النجمي',
                subtitle: 'جواهر وعجائب',
                icon: Icons.store,
                gradient: AppColors.cosmicButtonGradient,
                onTap: () => _navigateToStore(),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: _buildFeatureCard(
                title: 'المهام الفضائية',
                subtitle: 'تحديات يومية',
                icon: Icons.assignment,
                gradient: AppColors.nebularGradient,
                onTap: () => _navigateToMissions(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMD),

        // الصف الثاني
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'رفاق المجرة',
                subtitle: 'اصدقاء وتحديات',
                icon: Icons.people,
                gradient: const LinearGradient(
                  colors: [AppColors.planetGreen, AppColors.cosmicTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _navigateToFriends(),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: _buildFeatureCard(
                title: 'محطة التحكم',
                subtitle: 'الإعدادات',
                icon: Icons.settings,
                gradient: const LinearGradient(
                  colors: [AppColors.stellarOrange, AppColors.warningDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () => _navigateToSettings(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [
            BoxShadow(
              color: AppColors.backgroundPrimary.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 3,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppDimensions.iconXL,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                title,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء زر تسجيل الدخول/الخروج حسب حالة المستخدم
  Widget _buildAuthButton() {
    final user = _authService.currentUser;
    final isGuest = user?.isGuest ?? true;

    if (isGuest) {
      // إذا كان المستخدم ضيف، أظهر زر تسجيل الدخول
      return IconButton(
        icon: const Icon(
          Icons.login,
          color: AppColors.accent,
          size: AppDimensions.iconLG,
        ),
        onPressed: () => _handleLogin(),
        tooltip: 'تسجيل الدخول',
      );
    } else {
      // إذا كان المستخدم مسجل، أظهر زر تسجيل الخروج
      return IconButton(
        icon: const Icon(
          Icons.logout,
          color: AppColors.textPrimary,
          size: AppDimensions.iconLG,
        ),
        onPressed: () => _handleLogout(),
        tooltip: 'تسجيل الخروج',
      );
    }
  }

  // دالة للانتقال إلى شاشة تسجيل الدخول
  void _handleLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  // Navigation Methods
  void _navigateToLocalGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const StellarGameScreenEnhanced(gameMode: 'local'),
      ),
    );
  }

  void _navigateToAIGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StellarAILevelSelectionScreen(),
      ),
    );
  }

  void _navigateToOnlineGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarOnlineGameScreen()),
    );
  }

  void _navigateToGemsStore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GemsStoreScreen()),
    );
  }

  void _navigateToStore() => _navigateToGemsStore();

  void _navigateToMissions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarMissionsScreen()),
    );
  }

  void _navigateToFriends() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarFriendsScreenReal()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarSettingsScreen()),
    );
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarRealStatsScreen()),
    );
  }

  void _navigateToAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminScreen()),
    );
  }

  Future<void> _handleLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        title: Text('تسجيل الخروج', style: AppTextStyles.headlineMedium),
        content: Text(
          'هل تريد تسجيل الخروج من حسابك؟',
          style: AppTextStyles.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          AppComponents.stellarButton(
            text: 'تسجيل الخروج',
            onPressed: () => Navigator.pop(context, true),
            width: 120,
            height: 40,
          ),
        ],
      ),
    );

    if (result == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }
}
