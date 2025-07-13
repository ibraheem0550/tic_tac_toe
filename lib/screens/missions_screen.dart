import 'package:flutter/material.dart';
import '../missions/mission_manager.dart';
import 'smart_missions_screen.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_theme_new.dart';
import 'dart:async';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen>
    with SingleTickerProviderStateMixin {
  List<Mission> _missions = [];
  late AnimationController _controller;
  String _timeUntilReset = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadMissions();
    _startTimer();
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
      _loadMissions(); // Reload missions if time is up
      return;
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    if (mounted) {
      setState(() {
        _timeUntilReset = '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _loadMissions() async {
    final missions = await MissionManager.getDailyMissions();
    if (mounted) {
      setState(() {
        _missions = missions;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: Text(
            'المهام اليومية',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 8,
          actions: [
            IconButton(
              icon: Icon(
                Icons.psychology,
                color: AppColors.accent,
                size: ResponsiveHelper.getIconSize(context),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SmartMissionsScreen(),
                  ),
                );
              },
              tooltip: 'المهام الذكية',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundDark,
                AppColors.primaryDark.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: ResponsiveWidget(
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSmartMissionsCard(),
          SizedBox(height: ResponsiveHelper.getPadding(context)),
          _buildTimeRemainingCard(),
          SizedBox(height: ResponsiveHelper.getPadding(context)),
          Expanded(child: _buildMissionsList()),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSmartMissionsCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildTimeRemainingCard()),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context)),
          Expanded(child: _buildMissionsList()),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1400),
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Row(
        children: [
          // Panel جانبي للمعلومات
          SizedBox(
            width: 400,
            child: Column(
              children: [
                _buildSmartMissionsCard(),
                SizedBox(height: ResponsiveHelper.getPadding(context)),
                _buildTimeRemainingCard(),
                SizedBox(height: ResponsiveHelper.getPadding(context)),
                _buildMissionsStats(),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // منطقة المهام
          Expanded(child: _buildMissionsList()),
        ],
      ),
    );
  }

  Widget _buildSmartMissionsCard() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SmartMissionsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology,
                color: AppColors.textLight,
                size: ResponsiveHelper.getIconSize(context) * 1.2,
              ),
            ),
            SizedBox(width: ResponsiveHelper.getPadding(context) * 0.5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المهام الذكية',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مهام متقدمة بالذكاء الاصطناعي',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: ResponsiveHelper.getIconSize(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRemainingCard() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timer,
                color: AppColors.primary,
                size: ResponsiveHelper.getIconSize(context),
              ),
              SizedBox(width: ResponsiveHelper.getPadding(context) * 0.25),
              Text(
                'تجديد المهام',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context) * 0.5),
          Text(
            _timeUntilReset,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveHelper.getFontSize(context, 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsStats() {
    final completedCount = _missions.where((m) => m.isCompleted).length;
    final totalCount = _missions.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'إحصائيات المهام',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context) * 0.5),
          CircularProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            strokeWidth: 6,
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context) * 0.5),
          Text(
            '$completedCount من $totalCount مكتملة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList() {
    if (_missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مهام متاحة حالياً',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textLight.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    final columns =
        ResponsiveHelper.getColumnsCount(context, maxColumns: 3, minColumns: 1);

    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context) * 0.5),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context) * 1.2,
      ),
      itemCount: _missions.length,
      itemBuilder: (context, index) {
        final mission = _missions[index];
        return _buildMissionCard(mission, index);
      },
    );
  }

  Widget _buildMissionCard(Mission mission, int index) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1 * index, 1.0, curve: Curves.easeOutBack),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mission.isCompleted
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: mission.isCompleted
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getPadding(context) * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    mission.icon,
                    color: mission.isCompleted
                        ? AppColors.accent
                        : AppColors.primary,
                    size: ResponsiveHelper.getIconSize(context),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${mission.coinsReward}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getPadding(context) * 0.5),
              Text(
                mission.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  decoration:
                      mission.isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (mission.isCompleted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مكتملة',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'في انتظار الإنجاز',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
