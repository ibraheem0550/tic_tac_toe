import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/performance_monitor_service.dart';
import '../utils/app_theme_new.dart';

class PerformanceDashboardScreen extends StatefulWidget {
  const PerformanceDashboardScreen({super.key});

  @override
  State<PerformanceDashboardScreen> createState() =>
      _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState extends State<PerformanceDashboardScreen>
    with TickerProviderStateMixin {
  final PerformanceMonitorService _performanceService =
      PerformanceMonitorService();
  late TabController _tabController;
  bool _isRealTimeMode = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _performanceService.addListener(_onPerformanceUpdate);
    _performanceService.startMonitoring();
  }

  @override
  void dispose() {
    _performanceService.removeListener(_onPerformanceUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onPerformanceUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقبة الأداء والإحصائيات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.7),
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'لوحة التحكم'),
            Tab(icon: Icon(Icons.analytics), text: 'الإحصائيات'),
            Tab(icon: Icon(Icons.history), text: 'السجلات'),
            Tab(icon: Icon(Icons.warning), text: 'التنبيهات'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isRealTimeMode = !_isRealTimeMode;
              });
            },
            icon: Icon(
              _isRealTimeMode ? Icons.pause : Icons.play_arrow,
              color: AppColors.textLight,
            ),
            tooltip: _isRealTimeMode
                ? 'إيقاف التحديث التلقائي'
                : 'تفعيل التحديث التلقائي',
          ),
          IconButton(
            onPressed: _clearAllData,
            icon: const Icon(Icons.clear_all, color: AppColors.textLight),
            tooltip: 'مسح جميع البيانات',
          ),
          IconButton(
            onPressed: () {
              _performanceService.generateSampleData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنشاء بيانات تجريبية بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.data_usage, color: AppColors.textLight),
            tooltip: 'إنشاء بيانات تجريبية',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            _buildStatisticsTab(),
            _buildLogsTab(),
            _buildAlertsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final health = _performanceService.systemHealth;
    final stats = _performanceService.statistics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة صحة النظام
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: AppColors.nebularGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Text(
                  'صحة النظام',
                  style: AppTextStyles.h3.copyWith(color: AppColors.textLight),
                ),
                const SizedBox(height: AppDimensions.paddingSM),
                CircularProgressIndicator(
                  value: health / 100,
                  backgroundColor: AppColors.textLight.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    health > 80
                        ? AppColors.success
                        : health > 60
                            ? AppColors.warning
                            : AppColors.error,
                  ),
                  strokeWidth: 8,
                ),
                const SizedBox(height: AppDimensions.paddingSM),
                Text(
                  '${health.toStringAsFixed(1)}%',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLG),

          // إحصائيات سريعة
          Text('الإحصائيات السريعة', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.paddingMD),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingMD,
            mainAxisSpacing: AppDimensions.paddingMD,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'إجمالي العمليات',
                '${stats['totalOperations'] ?? 0}',
                Icons.analytics,
                AppColors.info,
              ),
              _buildStatCard(
                'العمليات الناجحة',
                '${stats['successfulOperations'] ?? 0}',
                Icons.check_circle,
                AppColors.success,
              ),
              _buildStatCard(
                'العمليات الفاشلة',
                '${stats['failedOperations'] ?? 0}',
                Icons.error,
                AppColors.error,
              ),
              _buildStatCard(
                'متوسط وقت الاستجابة',
                '${(stats['averageResponseTime'] ?? 0.0).toStringAsFixed(1)} مللي ثانية',
                Icons.speed,
                AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLG),

          // رسم بياني لوقت الاستجابة
          Container(
            height: 300,
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('أوقات الاستجابة', style: AppTextStyles.titleLarge),
                const SizedBox(height: AppDimensions.paddingMD),
                Expanded(
                  child: _buildResponseTimeChart(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingMD),

          // بطاقات استخدام الموارد
          Row(
            children: [
              Expanded(
                child: _buildResourceCard(
                  'استخدام الذاكرة',
                  '${(stats['memoryUsage'] ?? 0.0).toStringAsFixed(1)}%',
                  Icons.memory,
                  AppColors.info,
                  stats['memoryUsage'] ?? 0.0,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMD),
              Expanded(
                child: _buildResourceCard(
                  'استخدام المعالج',
                  '${(stats['cpuUsage'] ?? 0.0).toStringAsFixed(1)}%',
                  Icons.psychology,
                  AppColors.secondary,
                  stats['cpuUsage'] ?? 0.0,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLG),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppDimensions.iconMD),
              const SizedBox(width: AppDimensions.paddingSM),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeChart() {
    final responseTimes = _performanceService.responseTimes;

    if (responseTimes.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: const Center(
          child: Text(
            'لا توجد بيانات لعرضها',
            style: AppTextStyles.bodyMedium,
          ),
        ),
      );
    }

    // تحويل البيانات إلى نقاط للرسم البياني
    final spots = responseTimes.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 100,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.secondary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}ms',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: responseTimes.length > 10
                    ? (responseTimes.length / 5).ceil().toDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: spots.length <= 20,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.accent,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
          minX: 0,
          maxX: (responseTimes.length - 1).toDouble(),
          minY: responseTimes.isNotEmpty
              ? responseTimes.reduce((a, b) => a < b ? a : b) * 0.8
              : 0,
          maxY: responseTimes.isNotEmpty
              ? responseTimes.reduce((a, b) => a > b ? a : b) * 1.2
              : 100,
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final stats = _performanceService.statistics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإحصائيات التفصيلية', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.paddingMD),

          // رسم بياني دائري لتوزيع الطلبات
          Container(
            height: 250,
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              children: [
                Text(
                  'توزيع الطلبات',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppDimensions.paddingMD),
                Expanded(child: _buildRequestsPieChart()),
              ],
            ),
          ),

          ...stats.entries
              .map((entry) => Container(
                    margin:
                        const EdgeInsets.only(bottom: AppDimensions.paddingMD),
                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLG),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getStatDisplayName(entry.key),
                          style: AppTextStyles.bodyLarge,
                        ),
                        Text(
                          entry.value.toString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    final logs = _performanceService.systemLogs;

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            boxShadow: AppShadows.card,
            border: Border.all(
              color: _getLogTypeColor(log.type).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getLogTypeIcon(log.type),
                    color: _getLogTypeColor(log.type),
                    size: AppDimensions.iconSM,
                  ),
                  const SizedBox(width: AppDimensions.paddingSM),
                  Text(
                    _getLogTypeText(log.type),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getLogTypeColor(log.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(log.timestamp),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                log.message,
                style: AppTextStyles.bodyMedium,
              ),
              if (log.details != null && log.details!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingSM),
                Text(
                  'التفاصيل: ${log.details}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertsTab() {
    final alerts = _performanceService.alerts;

    if (alerts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              'لا توجد تنبيهات حالياً',
              style:
                  AppTextStyles.titleLarge.copyWith(color: AppColors.success),
            ),
            Text(
              'النظام يعمل بشكل طبيعي',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            boxShadow: AppShadows.card,
            border: Border.all(
              color: _getAlertSeverityColor(alert.severity).withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getAlertSeverityIcon(alert.severity),
                    color: _getAlertSeverityColor(alert.severity),
                  ),
                  const SizedBox(width: AppDimensions.paddingSM),
                  Text(
                    _getAlertSeverityText(alert.severity),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getAlertSeverityColor(alert.severity),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(alert.timestamp),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                alert.message,
                style: AppTextStyles.bodyMedium,
              ),
              if (alert.details != null && alert.details!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingSM),
                Text(
                  alert.details!,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestsPieChart() {
    final totalRequests =
        _performanceService.statistics['totalOperations'] ?? 0;
    final successfulRequests =
        _performanceService.statistics['successfulOperations'] ?? 0;
    final failedRequests =
        _performanceService.statistics['failedOperations'] ?? 0;

    if (totalRequests == 0) {
      return const Center(
        child: Text(
          'لا توجد بيانات لعرضها',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: AppColors.success,
            value: successfulRequests.toDouble(),
            title:
                '${((successfulRequests / totalRequests) * 100).toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          PieChartSectionData(
            color: AppColors.error,
            value: failedRequests.toDouble(),
            title:
                '${((failedRequests / totalRequests) * 100).toStringAsFixed(1)}%',
            radius: 60,
            titleStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  // Helper methods
  String _getStatDisplayName(String key) {
    switch (key) {
      case 'totalOperations':
        return 'إجمالي العمليات';
      case 'successfulOperations':
        return 'العمليات الناجحة';
      case 'failedOperations':
        return 'العمليات الفاشلة';
      case 'averageResponseTime':
        return 'متوسط وقت الاستجابة (مللي ثانية)';
      case 'memoryUsage':
        return 'استخدام الذاكرة (%)';
      case 'cpuUsage':
        return 'استخدام المعالج (%)';
      case 'activeConnections':
        return 'الاتصالات النشطة';
      default:
        return key;
    }
  }

  Color _getLogTypeColor(LogType type) {
    switch (type) {
      case LogType.info:
        return AppColors.info;
      case LogType.warning:
        return AppColors.warning;
      case LogType.error:
        return AppColors.error;
      case LogType.success:
        return AppColors.success;
    }
  }

  IconData _getLogTypeIcon(LogType type) {
    switch (type) {
      case LogType.info:
        return Icons.info;
      case LogType.warning:
        return Icons.warning;
      case LogType.error:
        return Icons.error;
      case LogType.success:
        return Icons.check_circle;
    }
  }

  String _getLogTypeText(LogType type) {
    switch (type) {
      case LogType.info:
        return 'معلومات';
      case LogType.warning:
        return 'تحذير';
      case LogType.error:
        return 'خطأ';
      case LogType.success:
        return 'نجح';
    }
  }

  Color _getAlertSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return AppColors.info;
      case AlertSeverity.medium:
        return AppColors.warning;
      case AlertSeverity.high:
        return AppColors.error;
      case AlertSeverity.critical:
        return AppColors.errorDark;
    }
  }

  IconData _getAlertSeverityIcon(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Icons.info;
      case AlertSeverity.medium:
        return Icons.warning;
      case AlertSeverity.high:
        return Icons.error;
      case AlertSeverity.critical:
        return Icons.dangerous;
    }
  }

  String _getAlertSeverityText(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return 'منخفض';
      case AlertSeverity.medium:
        return 'متوسط';
      case AlertSeverity.high:
        return 'عالي';
      case AlertSeverity.critical:
        return 'حرج';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد المسح'),
        content: const Text(
            'هل أنت متأكد من رغبتك في مسح جميع بيانات الأداء والسجلات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _performanceService.clearAllData();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح جميع البيانات بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(String title, String value, IconData icon,
      Color color, double percentage) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppDimensions.iconMD),
              const SizedBox(width: AppDimensions.paddingSM),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
