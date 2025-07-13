import 'package:flutter/material.dart';
import '../missions/mission_manager.dart';
import '../utils/app_theme_new.dart';
import 'dart:async';

class StellarMissionsScreen extends StatefulWidget {
  const StellarMissionsScreen({super.key});

  @override
  State<StellarMissionsScreen> createState() => _StellarMissionsScreenState();
}

class _StellarMissionsScreenState extends State<StellarMissionsScreen>
    with TickerProviderStateMixin {
  List<Mission> _missions = [];
  late AnimationController _starAnimationController;
  late AnimationController _shimmerController;
  late Animation<double> _starAnimation;
  late Animation<double> _shimmerAnimation;
  String _timeUntilReset = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadMissions();
    _startTimer();
  }

  void _setupAnimations() {
    _starAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _starAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _starAnimationController, curve: Curves.linear),
    );

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeUntilReset();
    });
    _updateTimeUntilReset();
  }

  void _updateTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final remaining = tomorrow.difference(now);

    if (remaining.isNegative) {
      _loadMissions();
      return;
    }

    setState(() {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      final seconds = remaining.inSeconds % 60;
      _timeUntilReset =
          '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    });
  }

  void _loadMissions() async {
    final missions = await MissionManager.getDailyMissions();
    setState(() {
      _missions = missions;
    });
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    _shimmerController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.starfieldGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(screenSize, isTablet),
              _buildTimeUntilReset(screenSize, isTablet),
              Expanded(child: _buildMissionsList(screenSize, isTablet)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size screenSize, bool isTablet) {
    final padding = isTablet ? 24.0 : 16.0;
    final titleSize = isTablet ? 28.0 : 24.0;
    final subtitleSize = isTablet ? 16.0 : 14.0;

    return Container(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.cosmicButtonGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مهام نجمية',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'أكمل المهام واحصل على مكافآت كونية',
                  style: TextStyle(
                    color: AppColors.secondaryLight,
                    fontSize: subtitleSize,
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _starAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _starAnimation.value * 2 * 3.14159,
                child: Container(
                  width: isTablet ? 60 : 48,
                  height: isTablet ? 60 : 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.starGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: isTablet ? 32 : 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUntilReset(Size screenSize, bool isTablet) {
    final padding = isTablet ? 24.0 : 16.0;
    final textSize = isTablet ? 18.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: padding),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            color: AppColors.accent,
            size: isTablet ? 24 : 20,
          ),
          SizedBox(width: isTablet ? 12 : 8),
          Text(
            'إعادة تعيين المهام خلال: ',
            style: TextStyle(
              color: AppColors.secondaryLight,
              fontSize: textSize,
            ),
          ),
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.5),
                      AppColors.accent,
                      AppColors.accent.withValues(alpha: 0.5),
                    ],
                    stops: [
                      (_shimmerAnimation.value - 1).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 1).clamp(0.0, 1.0),
                    ],
                  ).createShader(bounds);
                },
                child: Text(
                  _timeUntilReset,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: textSize + 2,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList(Size screenSize, bool isTablet) {
    if (_missions.isEmpty) {
      return _buildEmptyState(screenSize, isTablet);
    }

    final padding = isTablet ? 24.0 : 16.0;

    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: _missions.length,
      itemBuilder: (context, index) {
        return _buildMissionCard(_missions[index], screenSize, isTablet, index);
      },
    );
  }

  Widget _buildEmptyState(Size screenSize, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _starAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_starAnimation.value * 0.1),
                child: Container(
                  width: isTablet ? 120 : 80,
                  height: isTablet ? 120 : 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.starGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star_border,
                    color: Colors.white,
                    size: isTablet ? 60 : 40,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: isTablet ? 32 : 24),
          Text(
            'لا توجد مهام متاحة',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'تحقق مرة أخرى لاحقاً',
            style: TextStyle(
              color: AppColors.secondaryLight,
              fontSize: isTablet ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
    Mission mission,
    Size screenSize,
    bool isTablet,
    int index,
  ) {
    final isCompleted = mission.isCompleted;
    final padding = isTablet ? 20.0 : 16.0;
    final spacing = isTablet ? 16.0 : 12.0;

    return Container(
      margin: EdgeInsets.only(bottom: spacing),
      decoration: BoxDecoration(
        gradient: AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isTablet ? 56 : 48,
                  height: isTablet ? 56 : 48,
                  decoration: BoxDecoration(
                    gradient: isCompleted
                        ? const LinearGradient(
                            colors: [AppColors.success, AppColors.successLight],
                          )
                        : AppColors.cosmicButtonGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isCompleted
                                    ? AppColors.success
                                    : AppColors.primary)
                                .withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : mission.icon,
                    color: Colors.white,
                    size: isTablet ? 28 : 24,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.primaryLight,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'مهمة يومية - أكملها للحصول على المكافأة',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondaryLight,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: isTablet ? 16 : 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${mission.coinsReward}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            if (isCompleted) ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: isTablet ? 20 : 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'مكتملة',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing,
                  vertical: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.cosmicButtonGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: isTablet ? 20 : 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'ابدأ المهمة',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
