import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// أنواع السجلات
enum LogType {
  info,
  warning,
  error,
  success,
}

/// مستويات التنبيهات
enum AlertSeverity {
  low,
  medium,
  high,
  critical,
}

/// فئة سجل النظام
class SystemLog {
  final String id;
  final DateTime timestamp;
  final String message;
  final LogType type;
  final String? details;

  SystemLog({
    required this.id,
    required this.timestamp,
    required this.message,
    required this.type,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'type': type.name,
      'details': details,
    };
  }

  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      message: json['message'],
      type: LogType.values.firstWhere((e) => e.name == json['type']),
      details: json['details'],
    );
  }
}

/// فئة تنبيه النظام
class SystemAlert {
  final String id;
  final DateTime timestamp;
  final String title;
  final String message;
  final AlertSeverity severity;
  final bool isRead;
  final String? details;

  SystemAlert({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.message,
    required this.severity,
    this.isRead = false,
    this.details,
  });

  SystemAlert copyWith({
    String? id,
    DateTime? timestamp,
    String? title,
    String? message,
    AlertSeverity? severity,
    bool? isRead,
    String? details,
  }) {
    return SystemAlert(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      title: title ?? this.title,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      isRead: isRead ?? this.isRead,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'title': title,
      'message': message,
      'severity': severity.name,
      'isRead': isRead,
      'details': details,
    };
  }

  factory SystemAlert.fromJson(Map<String, dynamic> json) {
    return SystemAlert(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      title: json['title'],
      message: json['message'],
      severity:
          AlertSeverity.values.firstWhere((e) => e.name == json['severity']),
      isRead: json['isRead'] ?? false,
      details: json['details'],
    );
  }
}

/// خدمة مراقبة الأداء والإحصائيات الشاملة
class PerformanceMonitorService extends ChangeNotifier {
  static final PerformanceMonitorService _instance =
      PerformanceMonitorService._internal();
  factory PerformanceMonitorService() => _instance;
  PerformanceMonitorService._internal();

  // المفاتيح للحفظ
  static const String _performanceDataKey = 'performance_data';
  static const String _systemLogsKey = 'system_logs';
  static const String _statisticsKey = 'statistics';
  static const String _alertsKey = 'alerts';

  // البيانات الحالية
  Map<String, dynamic> _performanceData = {};
  List<SystemLog> _systemLogs = [];
  Map<String, dynamic> _statistics = {};
  List<SystemAlert> _alerts = [];

  // العدادات والمؤقتات
  Timer? _monitoringTimer;
  Timer? _statsUpdateTimer;
  DateTime _lastUpdateTime = DateTime.now();

  // معرفات للمراقبة
  int _totalRequests = 0;
  int _successfulRequests = 0;
  int _failedRequests = 0;
  double _averageResponseTime = 0.0;
  List<double> _responseTimes = [];

  // إحصائيات الذاكرة والأداء
  double _memoryUsage = 0.0;
  double _cpuUsage = 0.0;
  int _activeConnections = 0;
  // Getters للبيانات
  Map<String, dynamic> get performanceData => Map.from(_performanceData);
  List<SystemLog> get systemLogs => List.from(_systemLogs);
  Map<String, dynamic> get statistics => Map.from(_statistics);
  List<SystemAlert> get alerts => List.from(_alerts);
  List<double> get responseTimes => List.from(_responseTimes);

  double get systemHealth {
    if (_totalRequests == 0) return 100.0;

    final successRate = (_successfulRequests / _totalRequests) * 100;
    final responseTimeScore =
        min(100, (1000 / (_averageResponseTime + 1)) * 10);
    final memoryScore = max(0, 100 - _memoryUsage);

    return (successRate + responseTimeScore + memoryScore) / 3;
  }

  /// بدء خدمة المراقبة
  Future<void> startMonitoring() async {
    await _loadSavedData();

    // مراقبة كل ثانية
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRealTimeStats();
    });

    // تحديث الإحصائيات كل 10 ثواني
    _statsUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _updateStatistics();
    });

    addLog('تم بدء خدمة مراقبة الأداء', LogType.info);
  }

  /// إيقاف خدمة المراقبة
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _statsUpdateTimer?.cancel();
    _saveData();
    addLog('تم إيقاف خدمة مراقبة الأداء', LogType.info);
  }

  /// إنشاء بيانات تجريبية للاختبار
  void generateSampleData() {
    final random = Random();

    // إضافة عمليات تجريبية
    for (int i = 0; i < 20; i++) {
      final isSuccess = random.nextBool();
      final duration = Duration(milliseconds: 50 + random.nextInt(950));
      recordOperation(
        operation: 'test_operation_$i',
        duration: duration,
        isSuccess: isSuccess,
        metadata: {'test': true, 'index': i},
      );
    }

    // إضافة سجلات تجريبية
    final logTypes = [
      LogType.info,
      LogType.warning,
      LogType.error,
      LogType.success
    ];
    for (int i = 0; i < 15; i++) {
      addLog(
        'رسالة تجريبية رقم $i',
        logTypes[random.nextInt(logTypes.length)],
        details: 'تفاصيل إضافية للرسالة رقم $i',
      );
    }

    // تحديث إحصائيات الموارد
    _memoryUsage = 30 + random.nextDouble() * 40; // 30-70%
    _cpuUsage = 10 + random.nextDouble() * 50; // 10-60%
    _activeConnections = random.nextInt(20);

    _updateStatistics();
    addLog('تم إنشاء بيانات تجريبية بنجاح', LogType.success);
  }

  /// تسجيل عملية جديدة
  void recordOperation({
    required String operation,
    required Duration duration,
    bool isSuccess = true,
    Map<String, dynamic>? metadata,
  }) {
    _totalRequests++;
    if (isSuccess) {
      _successfulRequests++;
    } else {
      _failedRequests++;
    }

    final responseTime = duration.inMilliseconds.toDouble();
    _responseTimes.add(responseTime); // الاحتفاظ بآخر 100 قياس
    if (_responseTimes.length > 100) {
      _responseTimes.removeAt(0);
    }

    _averageResponseTime =
        _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;

    // تسجيل العملية
    addLog(
      'عملية $operation: ${isSuccess ? 'نجحت' : 'فشلت'} في ${duration.inMilliseconds}ms',
      isSuccess ? LogType.success : LogType.error,
      details: metadata != null ? metadata.toString() : null,
    );

    // فحص التنبيهات للعمليات البطيئة أو الفاشلة
    if (!isSuccess || duration.inMilliseconds > 1000) {
      final alert = SystemAlert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        title: !isSuccess ? 'فشل في العملية' : 'عملية بطيئة',
        message:
            'عملية $operation: ${!isSuccess ? 'فشلت' : 'استغرقت ${duration.inMilliseconds}ms'}',
        severity: !isSuccess ? AlertSeverity.high : AlertSeverity.medium,
        details: metadata != null ? metadata.toString() : null,
      );
      _alerts.add(alert);
    }

    notifyListeners();
  }

  /// إضافة سجل جديد
  void addLog(String message, LogType type, {String? details}) {
    final log = SystemLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      message: message,
      type: type,
      details: details,
    );

    _systemLogs.insert(0, log);

    // الاحتفاظ بآخر 100 سجل
    if (_systemLogs.length > 100) {
      _systemLogs = _systemLogs.take(100).toList();
    }

    _saveData();
    notifyListeners();
  }

  /// إضافة تنبيه جديد
  void addAlert({
    required String title,
    required String message,
    required AlertSeverity severity,
    String? details,
  }) {
    final alert = SystemAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      title: title,
      message: message,
      severity: severity,
      details: details,
    );

    _alerts.insert(0, alert);

    // الاحتفاظ بآخر 50 تنبيه
    if (_alerts.length > 50) {
      _alerts = _alerts.take(50).toList();
    }

    _saveData();
    notifyListeners();
  }

  /// وضع علامة قراءة على التنبيه
  void markAlertAsRead(String alertId) {
    final alertIndex = _alerts.indexWhere((alert) => alert.id == alertId);
    if (alertIndex != -1) {
      _alerts[alertIndex] = _alerts[alertIndex].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// مسح جميع التنبيهات المقروءة
  void clearReadAlerts() {
    _alerts.removeWhere((alert) => alert.isRead);
    notifyListeners();
  }

  /// الحصول على إحصائيات مفصلة
  Map<String, dynamic> getDetailedStats() {
    return {
      'system_health': systemHealth,
      'total_requests': _totalRequests,
      'successful_requests': _successfulRequests,
      'failed_requests': _failedRequests,
      'success_rate':
          _totalRequests > 0 ? (_successfulRequests / _totalRequests) * 100 : 0,
      'average_response_time': _averageResponseTime,
      'memory_usage': _memoryUsage,
      'cpu_usage': _cpuUsage,
      'active_connections': _activeConnections,
      'uptime': DateTime.now().difference(_lastUpdateTime).inSeconds,
      'alerts_count': _alerts.where((a) => !a.isRead).length,
      'logs_count': _systemLogs.length,
    };
  }

  /// الحصول على إحصائيات للفترة الزمنية
  Map<String, dynamic> getStatsForPeriod(Duration period) {
    final cutoff = DateTime.now().subtract(period);
    final recentLogs =
        _systemLogs.where((log) => log.timestamp.isAfter(cutoff)).toList();

    final successLogs =
        recentLogs.where((log) => log.type == LogType.success).length;
    final errorLogs =
        recentLogs.where((log) => log.type == LogType.error).length;
    final totalLogs = recentLogs.length;

    return {
      'period_hours': period.inHours,
      'total_operations': totalLogs,
      'successful_operations': successLogs,
      'failed_operations': errorLogs,
      'success_rate': totalLogs > 0 ? (successLogs / totalLogs) * 100 : 0,
    };
  }

  /// تحديث الإحصائيات
  void _updateStatistics() {
    _statistics = {
      'totalOperations': _totalRequests,
      'successfulOperations': _successfulRequests,
      'failedOperations': _failedRequests,
      'averageResponseTime': _averageResponseTime,
      'memoryUsage': _memoryUsage,
      'cpuUsage': _cpuUsage,
      'activeConnections': _activeConnections,
      'lastUpdate': DateTime.now().toIso8601String(),
      'systemHealth': systemHealth,
    };

    _saveData();
    notifyListeners();
  }

  /// تحديث الإحصائيات في الوقت الفعلي
  void _updateRealTimeStats() {
    // محاكاة بيانات النظام    _memoryUsage = 20 + Random().nextDouble() * 30;
    _cpuUsage = 10 + Random().nextDouble() * 40;
    _activeConnections = Random().nextInt(20) + 5;

    // فحص التنبيهات
    _checkThresholds();

    notifyListeners();
  }

  /// فحص العتبات والتنبيهات
  void _checkThresholds() {
    // فحص استخدام الذاكرة
    if (_memoryUsage > 80) {
      addAlert(
        title: 'استخدام مرتفع للذاكرة',
        message: 'استخدام الذاكرة وصل إلى ${_memoryUsage.toStringAsFixed(1)}%',
        severity: AlertSeverity.high,
      );
    }

    // فحص استخدام المعالج
    if (_cpuUsage > 80) {
      addAlert(
        title: 'استخدام مرتفع للمعالج',
        message: 'استخدام المعالج وصل إلى ${_cpuUsage.toStringAsFixed(1)}%',
        severity: AlertSeverity.high,
      );
    }

    // فحص معدل النجاح
    if (_totalRequests > 10) {
      final successRate = (_successfulRequests / _totalRequests) * 100;
      if (successRate < 80) {
        addAlert(
          title: 'انخفاض معدل النجاح',
          message:
              'معدل نجاح العمليات انخفض إلى ${successRate.toStringAsFixed(1)}%',
          severity: AlertSeverity.medium,
        );
      }
    }
  }

  /// حفظ البيانات
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // حفظ السجلات
      final logsJson = _systemLogs.map((log) => log.toJson()).toList();
      await prefs.setString(_systemLogsKey, jsonEncode(logsJson));

      // حفظ التنبيهات
      final alertsJson = _alerts.map((alert) => alert.toJson()).toList();
      await prefs.setString(_alertsKey, jsonEncode(alertsJson));

      // حفظ الإحصائيات
      await prefs.setString(_statisticsKey, jsonEncode(_statistics));

      // حفظ بيانات الأداء
      await prefs.setString(_performanceDataKey, jsonEncode(_performanceData));
    } catch (e) {
      addLog('خطأ في حفظ البيانات: $e', LogType.error);
    }
  }

  /// تحميل البيانات المحفوظة
  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // تحميل السجلات
      final logsString = prefs.getString(_systemLogsKey);
      if (logsString != null) {
        final logsJson = jsonDecode(logsString) as List;
        _systemLogs = logsJson.map((json) => SystemLog.fromJson(json)).toList();
      }

      // تحميل التنبيهات
      final alertsString = prefs.getString(_alertsKey);
      if (alertsString != null) {
        final alertsJson = jsonDecode(alertsString) as List;
        _alerts = alertsJson.map((json) => SystemAlert.fromJson(json)).toList();
      }

      // تحميل الإحصائيات
      final statsString = prefs.getString(_statisticsKey);
      if (statsString != null) {
        _statistics = jsonDecode(statsString) as Map<String, dynamic>;
      }

      // تحميل بيانات الأداء
      final performanceString = prefs.getString(_performanceDataKey);
      if (performanceString != null) {
        _performanceData =
            jsonDecode(performanceString) as Map<String, dynamic>;
      }
    } catch (e) {
      addLog('خطأ في تحميل البيانات: $e', LogType.error);
    }
  }

  /// مسح جميع البيانات
  Future<void> clearAllData() async {
    _systemLogs.clear();
    _alerts.clear();
    _statistics.clear();
    _performanceData.clear();

    _totalRequests = 0;
    _successfulRequests = 0;
    _failedRequests = 0;
    _averageResponseTime = 0.0;
    _responseTimes.clear();

    await _saveData();
    addLog('تم مسح جميع البيانات', LogType.info);
    notifyListeners();
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}
