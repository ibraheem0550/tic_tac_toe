import 'package:flutter/material.dart';
import '../data/test_data.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_helper.dart';

/// شاشة عرض البيانات التجريبية للاختبار
class TestDataViewScreen extends StatelessWidget {
  const TestDataViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البيانات التجريبية - ثيم الفضاء'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.secondary,
              ],
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.backgroundLight,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final deviceType =
              ResponsiveHelper.getDeviceType(constraints.maxWidth);

          switch (deviceType) {
            case DeviceType.mobile:
              return _buildMobileLayout(context);
            case DeviceType.tablet:
              return _buildTabletLayout(context);
            case DeviceType.desktop:
            case DeviceType.largeDesktop:
              return _buildDesktopLayout(context);
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildContent(context, 1);
  }

  Widget _buildTabletLayout(BuildContext context) {
    return _buildContent(context, 2);
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return _buildContent(context, 3);
  }

  Widget _buildContent(BuildContext context, int columns) {
    final padding = ResponsiveHelper.getPadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(context),
          SizedBox(height: padding),

          // المهام التجريبية
          _buildSectionCard(
            context,
            title: '🚀 المهام الفضائية',
            items: TestData.getMockMissions(),
            itemBuilder: (mission) => _buildMissionItem(context, mission),
          ),

          SizedBox(height: padding),

          // الإنجازات التجريبية
          _buildSectionCard(
            context,
            title: '⭐ الإنجازات الكونية',
            items: TestData.getMockAchievements(),
            itemBuilder: (achievement) =>
                _buildAchievementItem(context, achievement),
          ),

          SizedBox(height: padding),

          // تاريخ الألعاب
          _buildSectionCard(
            context,
            title: '🌌 تاريخ المعارك الفضائية',
            items: TestData.getMockGameHistory().take(3).toList(),
            itemBuilder: (game) => _buildGameHistoryItem(context, game),
          ),

          SizedBox(height: padding),

          // الإحصائيات
          _buildStatsSection(context),

          SizedBox(height: padding),

          // النصائح الفضائية
          _buildTipsSection(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final messages = TestData.getSpaceWelcomeMessages();
    final randomMessage =
        messages[DateTime.now().millisecond % messages.length];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            randomMessage,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18,
                  scale: FontScale.large),
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
              height: ResponsiveHelper.getPadding(context,
                  size: PaddingSize.small)),
          Text(
            'هذه بيانات تجريبية لتسهيل اختبار التطبيق',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<dynamic> items,
    required Widget Function(dynamic) itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerPrimary,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16,
                    scale: FontScale.large),
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.dividerPrimary,
              height: 1,
            ),
            itemBuilder: (context, index) => itemBuilder(items[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem(BuildContext context, Map<String, dynamic> mission) {
    final progress = mission['currentProgress'] / mission['targetValue'];

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: mission['isCompleted']
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                mission['icon'] ?? '🎯',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          SizedBox(
              width: ResponsiveHelper.getPadding(context,
                  size: PaddingSize.small)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission['title'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  mission['description'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.dividerPrimary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    mission['isCompleted']
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${mission['currentProgress']}/${mission['targetValue']} - ${mission['reward']} نجمة ⭐',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 12),
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

  Widget _buildAchievementItem(
      BuildContext context, Map<String, dynamic> achievement) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement['isUnlocked']
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : AppColors.textDisabled.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                achievement['icon'] ?? '🏆',
                style: TextStyle(
                  fontSize: 24,
                  color:
                      achievement['isUnlocked'] ? null : AppColors.textDisabled,
                ),
              ),
            ),
          ),
          SizedBox(
              width: ResponsiveHelper.getPadding(context,
                  size: PaddingSize.small)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: achievement['isUnlocked']
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                ),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: achievement['isUnlocked']
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                ),
                Text(
                  'فئة: ${achievement['category']}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 12),
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

  Widget _buildGameHistoryItem(
      BuildContext context, Map<String, dynamic> game) {
    Color resultColor;
    IconData resultIcon;

    switch (game['result']) {
      case 'فوز':
        resultColor = AppColors.success;
        resultIcon = Icons.check_circle;
        break;
      case 'خسارة':
        resultColor = AppColors.error;
        resultIcon = Icons.cancel;
        break;
      default:
        resultColor = AppColors.info;
        resultIcon = Icons.remove_circle;
    }

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Row(
        children: [
          Icon(
            resultIcon,
            color: resultColor,
            size: 30,
          ),
          SizedBox(
              width: ResponsiveHelper.getPadding(context,
                  size: PaddingSize.small)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${game['playerSymbol']} ضد ${game['opponentType']}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'النتيجة: ${game['result']} - ${game['duration']} دقيقة',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
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

  Widget _buildStatsSection(BuildContext context) {
    final stats = TestData.getMockPlayerStats();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerPrimary,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Text(
              '📊 إحصائيات المحارب الفضائي',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16,
                    scale: FontScale.large),
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.getColumnsCount(context,
                  minColumns: 2, maxColumns: 4),
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard(
                    context, 'ألعاب لُعبت', '${stats['gamesPlayed']}', '🎮'),
                _buildStatCard(
                    context, 'انتصارات', '${stats['gamesWon']}', '🏆'),
                _buildStatCard(
                    context, 'معدل الفوز', '${stats['winRate']}%', '📈'),
                _buildStatCard(
                    context, 'أفضل سلسلة', '${stats['bestStreak']}', '🔥'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, String emoji) {
    return Container(
      padding: EdgeInsets.all(
          ResponsiveHelper.getPadding(context, size: PaddingSize.small)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.dividerPrimary,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 12),
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context) {
    final tips = TestData.getSpaceGameTips();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.dividerPrimary,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.info, AppColors.accent],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Text(
              '💡 نصائح المحارب الفضائي',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16,
                    scale: FontScale.large),
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tips.take(5).length,
            separatorBuilder: (context, index) => Divider(
              color: AppColors.dividerPrimary,
              height: 1,
            ),
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
                child: Text(
                  tips[index],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
