import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/stellar_game_screen_enhanced_real.dart';
import '../utils/app_theme_new.dart';

class StellarAILevelSelectionScreen extends StatefulWidget {
  const StellarAILevelSelectionScreen({super.key});

  @override
  State<StellarAILevelSelectionScreen> createState() =>
      _StellarAILevelSelectionScreenState();
}

class _StellarAILevelSelectionScreenState
    extends State<StellarAILevelSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  List<Map<String, dynamic>> _aiLevels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAILevels();
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

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadAILevels() async {
    setState(() => _isLoading = true);
    try {
      // محاكاة تحميل مستويات الذكاء الاصطناعي
      await Future.delayed(const Duration(milliseconds: 500));

      _aiLevels = [
        {
          'level': 1,
          'name': 'مبتدئ',
          'description': 'مثالي للمبتدئين\nسهل الفوز',
          'icon': Icons.child_care,
          'color': AppColors.success,
          'gradient': const LinearGradient(
            colors: [AppColors.success, AppColors.successLight],
          ),
          'difficulty': 'سهل',
          'winRate': '90%',
        },
        {
          'level': 2,
          'name': 'متوسط',
          'description': 'تحدي متوازن\nيتطلب تفكير',
          'icon': Icons.psychology,
          'color': AppColors.warning,
          'gradient': const LinearGradient(
            colors: [AppColors.warning, AppColors.warningLight],
          ),
          'difficulty': 'متوسط',
          'winRate': '60%',
        },
        {
          'level': 3,
          'name': 'صعب',
          'description': 'للخبراء فقط\nتحدي حقيقي',
          'icon': Icons.psychology_alt,
          'color': AppColors.error,
          'gradient': const LinearGradient(
            colors: [AppColors.error, AppColors.errorLight],
          ),
          'difficulty': 'صعب',
          'winRate': '30%',
        },
        {
          'level': 4,
          'name': 'أسطوري',
          'description': 'مستحيل الفوز\nللتحدي الأقصى',
          'icon': Icons.auto_awesome,
          'color': AppColors.nebulaPurple,
          'gradient': const LinearGradient(
            colors: [AppColors.nebulaPurple, AppColors.galaxyBlue],
          ),
          'difficulty': 'أسطوري',
          'winRate': '10%',
        },
      ];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startGame(int level) async {
    try {
      HapticFeedback.selectionClick();

      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              StellarGameScreenEnhanced(gameMode: 'ai', aiLevel: level),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeInOut)),
              ),
              child: child,
            );
          },
        ),
      );

      // إعادة تحميل المستويات بعد العودة من اللعبة
      await _loadAILevels();
    } catch (e) {
      debugPrint('خطأ في بدء اللعبة: $e');
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
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: CustomScrollView(
                    slivers: [
                      _buildStellarAppBar(),
                      SliverPadding(
                        padding: const EdgeInsets.all(AppDimensions.paddingLG),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildIntroSection(),
                            const SizedBox(height: AppDimensions.paddingXL),
                            _buildAILevelsGrid(),
                            const SizedBox(height: AppDimensions.paddingXXL),
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
      expandedHeight: 220.0,
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
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.nebularGradient),
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
                        Icons.smart_toy,
                        size: 50,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'اختر مستوى الذكاء الاصطناعي',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                'تحدى الذكاء الاصطناعي في مستويات مختلفة',
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

  Widget _buildIntroSection() {
    return AppComponents.stellarCard(
      gradient: AppColors.galaxyGradient,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.stellarGradient,
                  boxShadow: AppShadows.card,
                ),
                child: const Icon(
                  Icons.info,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMD),
              Expanded(
                child: Text(
                  'نصائح للفوز',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLG),
          _buildTip('🎯', 'حاول السيطرة على المركز أولاً'),
          const SizedBox(height: AppDimensions.paddingMD),
          _buildTip('🛡️', 'اعترض حركات الخصم المهددة'),
          const SizedBox(height: AppDimensions.paddingMD),
          _buildTip('⚔️', 'ابحث عن فرصتين للفوز معاً'),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: AppDimensions.paddingMD),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAILevelsGrid() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر مستوى التحدي',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final crossAxisCount = isTablet ? 2 : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: isTablet ? 1.2 : 2.5,
                crossAxisSpacing: AppDimensions.paddingMD,
                mainAxisSpacing: AppDimensions.paddingMD,
              ),
              itemCount: _aiLevels.length,
              itemBuilder: (context, index) {
                return _buildAILevelCard(_aiLevels[index], index);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAILevelCard(Map<String, dynamic> levelData, int index) {
    final isRecommended = index == 1; // متوسط هو المستوى المنصوح به

    return Container(
      decoration: BoxDecoration(
        gradient: levelData['gradient'],
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
        border: isRecommended
            ? Border.all(color: AppColors.starGold, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startGame(levelData['level']),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          child: Stack(
            children: [
              if (isRecommended)
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
                      'منصوح به',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.backgroundPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        levelData['icon'],
                        size: 32,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingLG),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            levelData['name'],
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            levelData['description'],
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingMD),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  levelData['difficulty'],
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingSM),
                              Text(
                                'نسبة الفوز: ${levelData['winRate']}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.play_arrow,
                      color: AppColors.textPrimary,
                      size: 32,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
