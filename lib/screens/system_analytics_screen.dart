import 'package:flutter/material.dart';
import '../utils/app_theme_new.dart';
import 'dart:math';

class SystemAnalyticsScreen extends StatefulWidget {
  const SystemAnalyticsScreen({super.key});

  @override
  State<SystemAnalyticsScreen> createState() => _SystemAnalyticsScreenState();
}

class _SystemAnalyticsScreenState extends State<SystemAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadAnalytics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 1500));

    // بيانات تحليلية وهمية
    _analytics = {
      'users': {
        'total': 12543,
        'active': 8901,
        'newToday': 156,
        'newThisWeek': 1089,
        'growth': 12.5,
      },
      'games': {
        'totalGames': 45678,
        'todayGames': 2341,
        'averageDaily': 1980,
        'winRate': 68.4,
        'averageDuration': '4:32',
      },
      'revenue': {
        'totalRevenue': 15678.90,
        'todayRevenue': 234.56,
        'monthlyRevenue': 4567.89,
        'averageTransaction': 12.34,
      },
      'performance': {
        'serverUptime': 99.8,
        'averageResponseTime': 245,
        'errorRate': 0.2,
        'peakConcurrentUsers': 1456,
      },
      'features': {
        'aiGamesPercentage': 45.6,
        'multiplayerPercentage': 34.2,
        'storeUsage': 23.8,
        'friendsFeatureUsage': 67.3,
      },
      'devices': {'android': 65.4, 'ios': 28.9, 'windows': 4.2, 'web': 1.5},
    };

    setState(() => _isLoading = false);
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات النظام'),
        backgroundColor: AppColors.surfacePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'تحديث',
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: _isLoading ? _buildLoadingView() : _buildContent(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري تحميل البيانات...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildQuickStats(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildUsersAnalytics(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildGamesAnalytics(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildRevenueAnalytics(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildPerformanceMetrics(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildDeviceDistribution(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'إحصائيات النظام',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'تحليل شامل لأداء التطبيق والمستخدمين',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'آخر تحديث: ${DateTime.now().toString().substring(0, 16)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {
        'title': 'إجمالي المستخدمين',
        'value': '${_analytics['users']['total']}',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'الألعاب اليوم',
        'value': '${_analytics['games']['todayGames']}',
        'icon': Icons.games,
        'color': Colors.green,
      },
      {
        'title': 'الإيرادات الشهرية',
        'value': '\$${_analytics['revenue']['monthlyRevenue']}',
        'icon': Icons.attach_money,
        'color': Colors.orange,
      },
      {
        'title': 'معدل الأخطاء',
        'value': '${_analytics['performance']['errorRate']}%',
        'icon': Icons.error_outline,
        'color': Colors.red,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingMD,
        mainAxisSpacing: AppDimensions.paddingMD,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return _buildStatCard(stats[index]);
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              stat['icon'] as IconData,
              color: stat['color'] as Color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat['value'] as String,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stat['title'] as String,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersAnalytics() {
    final users = _analytics['users'];
    return _buildAnalyticsSection('تحليل المستخدمين', Icons.people_outline, [
      _buildMetricRow('إجمالي المستخدمين', '${users['total']}'),
      _buildMetricRow('المستخدمون النشطون', '${users['active']}'),
      _buildMetricRow('مستخدمون جدد اليوم', '${users['newToday']}'),
      _buildMetricRow('مستخدمون جدد هذا الأسبوع', '${users['newThisWeek']}'),
      _buildMetricRow('معدل النمو', '${users['growth']}%', isPositive: true),
    ]);
  }

  Widget _buildGamesAnalytics() {
    final games = _analytics['games'];
    return _buildAnalyticsSection('تحليل الألعاب', Icons.sports_esports, [
      _buildMetricRow('إجمالي الألعاب', '${games['totalGames']}'),
      _buildMetricRow('ألعاب اليوم', '${games['todayGames']}'),
      _buildMetricRow('المتوسط اليومي', '${games['averageDaily']}'),
      _buildMetricRow('معدل الفوز', '${games['winRate']}%'),
      _buildMetricRow('متوسط مدة اللعبة', '${games['averageDuration']}'),
    ]);
  }

  Widget _buildRevenueAnalytics() {
    final revenue = _analytics['revenue'];
    return _buildAnalyticsSection('تحليل الإيرادات', Icons.monetization_on, [
      _buildMetricRow('إجمالي الإيرادات', '\$${revenue['totalRevenue']}'),
      _buildMetricRow('إيرادات اليوم', '\$${revenue['todayRevenue']}'),
      _buildMetricRow('الإيرادات الشهرية', '\$${revenue['monthlyRevenue']}'),
      _buildMetricRow('متوسط المعاملة', '\$${revenue['averageTransaction']}'),
    ]);
  }

  Widget _buildPerformanceMetrics() {
    final performance = _analytics['performance'];
    return _buildAnalyticsSection('مقاييس الأداء', Icons.speed, [
      _buildMetricRow(
        'وقت تشغيل الخادم',
        '${performance['serverUptime']}%',
        isPositive: true,
      ),
      _buildMetricRow(
        'متوسط وقت الاستجابة',
        '${performance['averageResponseTime']}ms',
      ),
      _buildMetricRow(
        'معدل الأخطاء',
        '${performance['errorRate']}%',
        isNegative: true,
      ),
      _buildMetricRow(
        'ذروة المستخدمين المتزامنين',
        '${performance['peakConcurrentUsers']}',
      ),
    ]);
  }

  Widget _buildDeviceDistribution() {
    final devices = _analytics['devices'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'توزيع الأجهزة',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.surfacePrimary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderPrimary),
          ),
          child: Column(
            children: [
              _buildDeviceBar('Android', devices['android'], Colors.green),
              _buildDeviceBar('iOS', devices['ios'], Colors.blue),
              _buildDeviceBar('Windows', devices['windows'], Colors.purple),
              _buildDeviceBar('Web', devices['web'], Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(
    String title,
    IconData icon,
    List<Widget> metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.surfacePrimary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderPrimary),
          ),
          child: Column(children: metrics),
        ),
      ],
    );
  }

  Widget _buildMetricRow(
    String label,
    String value, {
    bool isPositive = false,
    bool isNegative = false,
  }) {
    Color valueColor = AppColors.textPrimary;
    if (isPositive) valueColor = AppColors.success;
    if (isNegative) valueColor = AppColors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceBar(String platform, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                platform,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.borderSecondary,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage / 100,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
