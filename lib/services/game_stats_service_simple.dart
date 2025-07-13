import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complete_user_models.dart';
import 'unified_auth_services.dart';

/// خدمة إحصائيات اللعبة - مبسطة للعمل مع التخزين المحلي
class GameStatsService {
  static final GameStatsService _instance = GameStatsService._internal();
  factory GameStatsService() => _instance;
  GameStatsService._internal();

  final FirebaseAuthService _authService = FirebaseAuthService();

  GameStats? _currentStats;
  final StreamController<GameStats> _statsController =
      StreamController<GameStats>.broadcast();

  Stream<GameStats> get statsStream => _statsController.stream;
  GameStats? get currentStats => _currentStats;

  /// تحميل إحصائيات اللعبة من التخزين المحلي
  Future<GameStats> loadGameStats() async {
    try {
      final user = _authService.currentUserModel;
      final userId = user?.id ?? 'guest';

      _currentStats = await _loadFromLocalStorage(userId);
      _currentStats ??= GameStats(userId: userId, lastUpdated: DateTime.now());

      _statsController.add(_currentStats!);
      return _currentStats!;
    } catch (e) {
      debugPrint('خطأ في تحميل إحصائيات اللعبة: $e');
      final currentUser = _authService.currentUserModel;
      _currentStats = GameStats(
        userId: currentUser?.id ?? 'guest',
        lastUpdated: DateTime.now(),
      );
      return _currentStats!;
    }
  }

  /// حفظ إحصائيات اللعبة
  Future<void> saveGameStats(GameStats stats) async {
    try {
      _currentStats = stats;
      await _saveToLocalStorage(stats);
      _statsController.add(stats);
    } catch (e) {
      debugPrint('خطأ في حفظ الإحصائيات: $e');
    }
  }

  /// تسجيل نتيجة لعبة جديدة
  Future<void> recordGameResult({
    required String gameResult, // 'win', 'loss', 'draw'
    required Duration gameDuration,
    required String gameMode, // 'ai', 'local', 'online'
    int? aiLevel,
    String? opponentId,
  }) async {
    try {
      final currentStats = await loadGameStats();
      GameStats updatedStats;

      switch (gameResult) {
        case 'win':
          updatedStats = currentStats.copyWith(
            wins: currentStats.wins + 1,
            totalGames: currentStats.totalGames + 1,
            streak: currentStats.streak + 1,
            bestStreak: (currentStats.streak + 1) > currentStats.bestStreak
                ? currentStats.streak + 1
                : currentStats.bestStreak,
            totalPlayTime: currentStats.totalPlayTime + gameDuration.inSeconds,
            lastUpdated: DateTime.now(),
          );
          break;
        case 'loss':
          updatedStats = currentStats.copyWith(
            losses: currentStats.losses + 1,
            totalGames: currentStats.totalGames + 1,
            streak: 0,
            totalPlayTime: currentStats.totalPlayTime + gameDuration.inSeconds,
            lastUpdated: DateTime.now(),
          );
          break;
        case 'draw':
          updatedStats = currentStats.copyWith(
            draws: currentStats.draws + 1,
            totalGames: currentStats.totalGames + 1,
            streak: 0,
            totalPlayTime: currentStats.totalPlayTime + gameDuration.inSeconds,
            lastUpdated: DateTime.now(),
          );
          break;
        default:
          return;
      }

      await saveGameStats(updatedStats);
      await _recordGameHistory(
        gameResult: gameResult,
        gameDuration: gameDuration,
        gameMode: gameMode,
        aiLevel: aiLevel,
        opponentId: opponentId,
      );
    } catch (e) {
      debugPrint('خطأ في تسجيل نتيجة اللعبة: $e');
    }
  }

  /// تسجيل تاريخ اللعبة
  Future<void> _recordGameHistory({
    required String gameResult,
    required Duration gameDuration,
    required String gameMode,
    int? aiLevel,
    String? opponentId,
  }) async {
    try {
      final user = _authService.currentUserModel;
      if (user == null) return;

      final gameRecord = {
        'user_id': user.id,
        'game_mode': gameMode,
        'game_result': gameResult,
        'game_duration': gameDuration.inSeconds,
        'ai_level': aiLevel,
        'opponent_id': opponentId,
        'played_at': DateTime.now().toIso8601String(),
        'difficulty': _getDifficultyString(gameMode, aiLevel),
      };

      await _saveGameHistoryLocally(gameRecord);
    } catch (e) {
      debugPrint('خطأ في تسجيل تاريخ اللعبة: $e');
    }
  }

  /// الحصول على نص مستوى الصعوبة
  String _getDifficultyString(String gameMode, int? aiLevel) {
    if (gameMode == 'ai' && aiLevel != null) {
      switch (aiLevel) {
        case 1:
          return 'سهل';
        case 2:
          return 'متوسط';
        case 3:
          return 'صعب';
        case 4:
          return 'خبير';
        case 5:
          return 'مستحيل';
        default:
          return 'مخصص';
      }
    } else if (gameMode == 'local') {
      return 'محلي';
    } else if (gameMode == 'online') {
      return 'أونلاين';
    }
    return 'عام';
  }

  /// تحميل الإحصائيات من التخزين المحلي
  Future<GameStats?> _loadFromLocalStorage(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('game_stats_$userId');
      if (statsJson != null) {
        final statsMap = jsonDecode(statsJson);
        return GameStats.fromJson(statsMap);
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الإحصائيات من التخزين المحلي: $e');
    }
    return null;
  }

  /// حفظ الإحصائيات في التخزين المحلي
  Future<void> _saveToLocalStorage(GameStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(stats.toJson());
      await prefs.setString('game_stats_${stats.userId}', statsJson);
    } catch (e) {
      debugPrint('خطأ في حفظ الإحصائيات في التخزين المحلي: $e');
    }
  }

  /// حفظ تاريخ اللعبة محلياً
  Future<void> _saveGameHistoryLocally(Map<String, dynamic> gameRecord) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('game_history') ?? '[]';
      final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));

      history.insert(0, gameRecord); // إضافة في البداية

      // الاحتفاظ بآخر 100 لعبة فقط
      if (history.length > 100) {
        history.removeRange(100, history.length);
      }

      await prefs.setString('game_history', jsonEncode(history));
    } catch (e) {
      debugPrint('خطأ في حفظ تاريخ اللعبة: $e');
    }
  }

  /// الحصول على تاريخ الألعاب
  Future<List<Map<String, dynamic>>> getGameHistory({int limit = 50}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('game_history') ?? '[]';
      final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));

      return history.take(limit).toList();
    } catch (e) {
      debugPrint('خطأ في جلب تاريخ الألعاب: $e');
      return [];
    }
  }

  /// مسح جميع الإحصائيات
  Future<void> clearAllStats() async {
    try {
      final user = _authService.currentUserModel;
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('game_stats_${user.id}');
        await prefs.remove('game_history');

        _currentStats = GameStats(userId: user.id, lastUpdated: DateTime.now());
        _statsController.add(_currentStats!);
      }
    } catch (e) {
      debugPrint('خطأ في مسح الإحصائيات: $e');
    }
  }

  void dispose() {
    _statsController.close();
  }
}
