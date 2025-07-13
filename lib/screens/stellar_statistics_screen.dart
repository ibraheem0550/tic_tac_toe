import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme_new.dart';

class StellarStatisticsScreen extends StatefulWidget {
  const StellarStatisticsScreen({super.key});

  @override
  State<StellarStatisticsScreen> createState() =>
      _StellarStatisticsScreenState();
}

class _StellarStatisticsScreenState extends State<StellarStatisticsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _counterController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isLoading = false;
  String _selectedPeriod = 'all'; // all, month, week

  // إحصائيات اللعبة
  Map<String, dynamic> _gameStats = {};
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _recentMatches = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadStatistics();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _counterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _counterController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      // محاكاة تحميل الإحصائيات
      await Future.delayed(const Duration(milliseconds: 1000));

      setState(() {
        _gameStats = {
          'totalGames': 145,
          'wins': 98,
          'losses': 32,
          'draws': 15,
          'winRate': 67.6,
          'currentStreak': 7,
          'bestStreak': 15,
          'totalPlayTime': '12h 34m',
          'averageGameTime': '3m 45s',
          'gemsEarned': 2840,
          'coinsEarned': 15600,
          'rankPoints': 1850,
          'currentRank': 'ماسي',
        };

        _achievements = [
          {
            'id': 'first_win',
            'title': 'أول انتصار',
            'description': 'فز في أول مباراة لك',
            'icon': Icons.star,
            'unlocked': true,
            'unlockedAt': DateTime.now().subtract(const Duration(days: 30)),
            'progress': 1.0,
          },
          {
            'id': 'win_streak_5',
            'title': 'سلسلة انتصارات',
            'description': 'فز في 5 مباريات متتالية',
            'icon': Icons.local_fire_department,
            'unlocked': true,
            'unlockedAt': DateTime.now().subtract(const Duration(days: 10)),
            'progress': 1.0,
          },
          {
            'id': 'speed_demon',
            'title': 'شيطان السرعة',
            'description': 'فز في مباراة خلال أقل من دقيقة',
            'icon': Icons.flash_on,
            'unlocked': true,
            'unlockedAt': DateTime.now().subtract(const Duration(days: 5)),
            'progress': 1.0,
          },
          {
            'id': 'master_player',
            'title': 'لاعب خبير',
            'description': 'العب 100 مباراة',
            'icon': Icons.emoji_events,
            'unlocked': true,
            'unlockedAt': DateTime.now().subtract(const Duration(days: 2)),
            'progress': 1.0,
          },
          {
            'id': 'gem_collector',
            'title': 'جامع الجواهر',
            'description': 'اجمع 5000 جوهرة',
            'icon': Icons.diamond,
            'unlocked': false,
            'progress': 0.568, // 2840/5000
          },
          {
            'id': 'legendary',
            'title': 'أسطوري',
            'description': 'وصل إلى رتبة الأسطورة',
            'icon': Icons.military_tech,
            'unlocked': false,
            'progress': 0.74, // 1850/2500
          },
        ];

        _recentMatches = [
          {
            'opponent': 'أحمد علي',
            'result': 'win',
            'duration': '2m 34s',
            'gemsEarned': 25,
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          },
          {
            'opponent': 'سارة محمد',
            'result': 'win',
            'duration': '4m 12s',
            'gemsEarned': 20,
            'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          },
          {
            'opponent': 'محمد حسن',
            'result': 'loss',
            'duration': '6m 45s',
            'gemsEarned': 5,
            'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          },
          {
            'opponent': 'فاطمة أحمد',
            'result': 'draw',
            'duration': '8m 23s',
            'gemsEarned': 10,
            'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          },
          {
            'opponent': 'عمر سامي',
            'result': 'win',
            'duration': '3m 56s',
            'gemsEarned': 30,
            'timestamp': DateTime.now().subtract(const Duration(days: 2)),
          },
        ];
      });
    } finally {
      setState(() => _isLoading = false);
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
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingLG,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  _buildPeriodSelector(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildOverviewStats(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildPerformanceChart(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildAchievementsSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildRecentMatchesSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXL,
                                  ),
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
      flexibleSpace: FlexibleSpaceBar(
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.stellarGradient.createShader(bounds),
          child: const Text(
            'إحصائياتي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.stellarGradient),
          child: Stack(
            children: [
              // خلفية نجمية متحركة
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.starfieldGradient,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.backgroundPrimary.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Row(
        children: [
          _buildPeriodTab('all', 'الكل'),
          _buildPeriodTab('month', 'هذا الشهر'),
          _buildPeriodTab('week', 'هذا الأسبوع'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String period, String title) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedPeriod = period);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingMD,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.cosmicButtonGradient : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleSmall.copyWith(
              color: isSelected
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نظرة عامة',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.paddingMD,
          mainAxisSpacing: AppDimensions.paddingMD,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'إجمالي المباريات',
              _gameStats['totalGames'].toString(),
              Icons.sports_esports,
              AppColors.primary,
            ),
            _buildStatCard(
              'معدل الفوز',
              '${_gameStats['winRate']}%',
              Icons.trending_up,
              AppColors.success,
            ),
            _buildStatCard(
              'سلسلة الفوز الحالية',
              _gameStats['currentStreak'].toString(),
              Icons.local_fire_department,
              AppColors.warning,
            ),
            _buildStatCard(
              'أفضل سلسلة فوز',
              _gameStats['bestStreak'].toString(),
              Icons.emoji_events,
              AppColors.accent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: _counterController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _counterController.value),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.nebularGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              border: Border.all(color: AppColors.borderSecondary),
              boxShadow: AppShadows.stellar,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingSM),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMD,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: AppDimensions.iconLG,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        value,
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأداء',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLG),
          Row(
            children: [
              Expanded(
                flex: _gameStats['wins'],
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: _gameStats['losses'],
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: _gameStats['draws'],
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingMD),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPerformanceLegend(
                'انتصارات',
                _gameStats['wins'],
                AppColors.success,
              ),
              _buildPerformanceLegend(
                'هزائم',
                _gameStats['losses'],
                AppColors.error,
              ),
              _buildPerformanceLegend(
                'تعادل',
                _gameStats['draws'],
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceLegend(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الإنجازات',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_achievements.where((a) => a['unlocked']).length}/${_achievements.length}',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _achievements.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppDimensions.paddingMD),
          itemBuilder: (context, index) {
            final achievement = _achievements[index];
            return _buildAchievementCard(achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final bool unlocked = achievement['unlocked'];
    final double progress = achievement['progress'];

    return Container(
      decoration: BoxDecoration(
        gradient: unlocked
            ? AppColors.nebularGradient
            : AppColors.starfieldGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: unlocked ? AppColors.accent : AppColors.borderPrimary,
        ),
      ),
      child: Stack(
        children: [
          if (unlocked)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMD),
                  decoration: BoxDecoration(
                    color: unlocked
                        ? AppColors.accent.withValues(alpha: 0.2)
                        : AppColors.surfaceSecondary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  child: Icon(
                    achievement['icon'],
                    color: unlocked ? AppColors.accent : AppColors.textMuted,
                    size: AppDimensions.iconLG,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingLG),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'],
                        style: AppTextStyles.titleMedium.copyWith(
                          color: unlocked
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement['description'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: unlocked
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                        ),
                      ),
                      if (!unlocked) ...[
                        const SizedBox(height: AppDimensions.paddingSM),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.surfaceSecondary,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accent,
                            ),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% مكتمل',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                      if (unlocked && achievement['unlockedAt'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'تم الإنجاز في ${_formatDate(achievement['unlockedAt'])}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المباريات الأخيرة',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentMatches.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppDimensions.paddingMD),
          itemBuilder: (context, index) {
            final match = _recentMatches[index];
            return _buildMatchCard(match);
          },
        ),
      ],
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final String result = match['result'];
    Color resultColor;
    IconData resultIcon;
    String resultText;

    switch (result) {
      case 'win':
        resultColor = AppColors.success;
        resultIcon = Icons.trending_up;
        resultText = 'فوز';
        break;
      case 'loss':
        resultColor = AppColors.error;
        resultIcon = Icons.trending_down;
        resultText = 'هزيمة';
        break;
      case 'draw':
        resultColor = AppColors.warning;
        resultIcon = Icons.trending_flat;
        resultText = 'تعادل';
        break;
      default:
        resultColor = AppColors.textTertiary;
        resultIcon = Icons.help;
        resultText = 'غير معروف';
    }
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingSM),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Icon(
              resultIcon,
              color: resultColor,
              size: AppDimensions.iconMD,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingLG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ضد ${match['opponent']}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingSM,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSM,
                        ),
                      ),
                      child: Text(
                        resultText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: resultColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      match['duration'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMD),
                    Icon(Icons.diamond, size: 16, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      '+${match['gemsEarned']}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatTimeAgo(match['timestamp']),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes}د';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours}س';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
