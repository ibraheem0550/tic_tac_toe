import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme_new.dart';
import '../services/unified_auth_services.dart';
import 'game_screen.dart';
import 'auth_screen.dart';
import 'stellar_friends_screen_simple.dart';

// Helper للتجاوب مع الشاشات المختلفة
class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isSmallScreen(BuildContext context) =>
      getScreenWidth(context) < 600;

  static bool isMediumScreen(BuildContext context) =>
      getScreenWidth(context) >= 600 && getScreenWidth(context) < 1200;

  static bool isLargeScreen(BuildContext context) =>
      getScreenWidth(context) >= 1200;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    if (screenWidth < 600) return baseSize * 0.9;
    if (screenWidth < 1200) return baseSize;
    return baseSize * 1.1;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (screenWidth < 600) return const EdgeInsets.all(8.0);
    if (screenWidth < 1200) return const EdgeInsets.all(16.0);
    return const EdgeInsets.all(24.0);
  }

  static int getGridColumns(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (screenWidth < 600) return 2;
    if (screenWidth < 1200) return 3;
    return 4;
  }
}

class ResponsiveHomeScreen extends StatefulWidget {
  const ResponsiveHomeScreen({super.key});

  @override
  State<ResponsiveHomeScreen> createState() => _ResponsiveHomeScreenState();
}

class _ResponsiveHomeScreenState extends State<ResponsiveHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUserModel;

    if (user.isGuest == true) {
      return const AuthScreen();
    }

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
                child: SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      _buildResponsiveAppBar(context),
                      SliverPadding(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildUserCard(context),
                            const SizedBox(height: 24),
                            _buildGameModes(context),
                            const SizedBox(height: 24),
                            _buildQuickActions(context),
                            const SizedBox(height: 32),
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

  Widget _buildResponsiveAppBar(BuildContext context) {
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return SliverAppBar(
      expandedHeight: isSmallScreen ? 150.0 : 200.0,
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
              SizedBox(height: isSmallScreen ? 40 : 60),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.stellarGradient,
                  boxShadow: AppShadows.stellar,
                ),
                child: Icon(
                  Icons.games,
                  size: isSmallScreen ? 40 : 50,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'X O الكوني',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'أفضل لعبة X O في المجرة',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context) {
    final user = _authService.currentUserModel;
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0 : 16),
      padding: ResponsiveHelper.getResponsivePadding(context),
      decoration: BoxDecoration(
        gradient: AppColors.stellarGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isSmallScreen ? 25 : 30,
            backgroundColor: AppColors.primary,
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName.substring(0, 1).toUpperCase()
                  : 'U',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName.isNotEmpty ? user.displayName : 'مستخدم',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      18,
                    ),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.isGuest ? 'مستخدم ضيف' : 'مستخدم مسجل',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.diamond,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${user.gems}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModes(BuildContext context) {
    final gameMode = [
      {
        'title': 'لعبة سريعة',
        'subtitle': 'ابدأ مباراة فورية',
        'icon': Icons.flash_on,
        'gradient': AppColors.stellarGradient,
        'onTap': () => _startQuickGame(),
      },
      {
        'title': 'ضد الذكي الاصطناعي',
        'subtitle': 'تحدى الكمبيوتر',
        'icon': Icons.smart_toy,
        'gradient': AppColors.stellarGradient,
        'onTap': () => _startAIGame(),
      },
      {
        'title': 'اللعب مع الأصدقاء',
        'subtitle': 'ادع أصدقائك للعب',
        'icon': Icons.people,
        'gradient': AppColors.nebularGradient,
        'onTap': () => _openFriendsScreen(),
      },
    ];

    final columns = ResponsiveHelper.getGridColumns(context);
    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 1 : (columns > 2 ? 2 : columns),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isSmallScreen ? 3.0 : 2.5,
      ),
      itemCount: gameMode.length,
      itemBuilder: (context, index) {
        final mode = gameMode[index];
        return _buildGameModeCard(context, mode);
      },
    );
  }

  Widget _buildGameModeCard(BuildContext context, Map<String, dynamic> mode) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        mode['onTap']();
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: Container(
        padding: ResponsiveHelper.getResponsivePadding(context),
        decoration: BoxDecoration(
          gradient: mode['gradient'],
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              mode['icon'],
              size: ResponsiveHelper.isSmallScreen(context) ? 32 : 40,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 12),
            Text(
              mode['title'],
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              mode['subtitle'],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'الإحصائيات',
        'icon': Icons.bar_chart,
        'onTap': () => _openStatistics(),
      },
      {'title': 'المتجر', 'icon': Icons.store, 'onTap': () => _openStore()},
      {
        'title': 'الإعدادات',
        'icon': Icons.settings,
        'onTap': () => _openSettings(),
      },
    ];

    final isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                if (action['onTap'] != null) {
                  (action['onTap'] as Function)();
                }
              },
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.borderPrimary, width: 1),
                ),
                child: Column(
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      size: isSmallScreen ? 20 : 24,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['title'] as String,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          12,
                        ),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // دوال الإجراءات
  void _startQuickGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen(aiLevel: 2)),
    );
  }

  void _startAIGame() {
    // تنفيذ لعبة ضد الذكي الاصطناعي
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة اللعب ضد الذكي الاصطناعي قريباً'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openFriendsScreen() {
    // فتح شاشة الأصدقاء
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarFriendsScreen()),
    );
  }

  void _openStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('شاشة الإحصائيات قريباً'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openStore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('المتجر قريباً'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _openSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('الإعدادات قريباً'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
