import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complete_user_models.dart';
import 'firebase_auth_service.dart';
// import 'supabase_service.dart'; // معطل مؤقتاً
import '../utils/logger.dart';

/// خدمة إحصائيات اللعبة - تتعامل مع البيانات الحقيقية فقط
class GameStatsService {
  static final GameStatsService _instance = GameStatsService._internal();
  factory GameStatsService() => _instance;
  GameStatsService._internal();

  final FirebaseAuthService _authService = FirebaseAuthService();
  // final SupabaseService _supabaseService = SupabaseService(); // معطل مؤقتاً

  GameStats? _currentStats;
  final StreamController<GameStats> _statsController =
      StreamController<GameStats>.broadcast();

  Stream<GameStats> get statsStream => _statsController.stream;
  GameStats? get currentStats => _currentStats;

  /// تحميل إحصائيات اللعبة من قاعدة البيانات أو التخزين المحلي
  Future<GameStats> loadGameStats() async {
    try {
      final user = _authService.currentUser;

      if (user != null && !user.isGuest) {
        // تحميل من قاعدة البيانات للمستخدمين المسجلين
        _currentStats = await _loadFromDatabase(user.id);
      } else {
        // تحميل من التخزين المحلي للضيوف
        _currentStats = await _loadFromLocalStorage();
      }

      _currentStats ??= GameStats.empty(
          user?.id ?? 'guest'); // إنشاء إحصائيات جديدة إذا لم توجد
      _statsController.add(_currentStats!);

      return _currentStats!;
    } catch (e) {
      Logger.logError('خطأ في تحميل إحصائيات اللعبة', e);
      final currentUser = _authService.currentUser;
      _currentStats = GameStats.empty(currentUser?.id ?? 'guest');
      return _currentStats!;
    }
  }

  /// حفظ إحصائيات اللعبة
  Future<void> saveGameStats(GameStats stats) async {
    try {
      _currentStats = stats;
      final user = _authService.currentUser;

      if (user != null && !user.isGuest) {
        // حفظ في قاعدة البيانات للمستخدمين المسجلين
        await _saveToDatabase(user.id, stats);
      } else {
        // حفظ في التخزين المحلي للضيوف
        await _saveToLocalStorage(stats);
      }

      _statsController.add(stats);
    } catch (e) {
      Logger.logError('خطأ في حفظ إحصائيات اللعبة', e);
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
      final stats =
          _currentStats ?? await loadGameStats(); // تسجيل اللعبة في الإحصائيات
      final updatedStats = stats.recordGame(
        gameResult,
        gameMode: gameMode,
        difficulty: _getDifficultyString(gameMode, aiLevel),
      );

      // حفظ الإحصائيات المحدثة
      await saveGameStats(updatedStats);

      // تسجيل تفاصيل اللعبة في التاريخ
      await _recordGameHistory(
        gameResult: gameResult,
        gameDuration: gameDuration,
        gameMode: gameMode,
        aiLevel: aiLevel,
        opponentId: opponentId,
      );
    } catch (e) {
      print('خطأ في تسجيل نتيجة اللعبة: $e');
    }
  }

  /// الحصول على نص مستوى الصعوبة
  String _getDifficultyString(String gameMode, int? aiLevel) {
    if (gameMode == 'ai' && aiLevel != null) {
      switch (aiLevel) {
        case 1:
          return 'مبتدئ';
        case 2:
          return 'سهل';
        case 3:
          return 'متوسط';
        case 4:
          return 'صعب';
        case 5:
          return 'خبير';
        default:
          return 'متوسط';
      }
    } else if (gameMode == 'local') {
      return 'محلي';
    } else if (gameMode == 'online') {
      return 'أونلاين';
    }
    return 'عام';
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
      final user = _authService.currentUser;
      if (user == null) return;

      final gameRecord = {
        'user_id': user.id,
        'game_mode': gameMode,
        'game_result': gameResult,
        'game_duration': gameDuration.inSeconds,
        'ai_level': aiLevel,
        'opponent_id': opponentId,
        'played_at': DateTime.now().toIso8601String(),
      };

      if (!user.isGuest) {
        // حفظ في قاعدة البيانات (معطل مؤقتاً حتى يتم إصلاح SupabaseService)
        // await _supabaseService.client.from('game_history').insert(gameRecord);
        Logger.logInfo('تم محاكاة حفظ تاريخ اللعبة في قاعدة البيانات');
      } else {
        // حفظ في التخزين المحلي للضيوف
        await _saveGameHistoryLocally(gameRecord);
      }
    } catch (e) {
      Logger.logError('خطأ في تسجيل تاريخ اللعبة', e);
    }
  }

  /// تحميل الإحصائيات من قاعدة البيانات
  Future<GameStats?> _loadFromDatabase(String userId) async {
    try {
      // قاعدة البيانات معطلة مؤقتاً
      // final response = await _supabaseService.client
      //     .from('user_profiles')
      //     .select('game_stats')
      //     .eq('id', userId)
      //     .single();

      // if (response['game_stats'] != null) {
      //   return GameStats.fromJson(response['game_stats']);
      // }
      Logger.logInfo('تم محاكاة تحميل الإحصائيات من قاعدة البيانات');
      return null;
    } catch (e) {
      Logger.logError('خطأ في تحميل الإحصائيات من قاعدة البيانات', e);
    }
    return null;
  }

  /// حفظ الإحصائيات في قاعدة البيانات
  Future<void> _saveToDatabase(String userId, GameStats stats) async {
    try {
      // تم تعطيل Supabase مؤقتاً
      // await _supabaseService.client
      //     .from('user_profiles')
      //     .update({'game_stats': stats.toJson()}).eq('id', userId);
      print('حفظ إحصائيات المستخدم: $userId');
    } catch (e) {
      print('خطأ في حفظ الإحصائيات في قاعدة البيانات: $e');
    }
  }

  /// تحميل الإحصائيات من التخزين المحلي
  Future<GameStats?> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('game_stats');

      if (statsJson != null) {
        final statsMap = jsonDecode(statsJson);
        return GameStats.fromJson(statsMap);
      }
    } catch (e) {
      print('خطأ في تحميل الإحصائيات من التخزين المحلي: $e');
    }
    return null;
  }

  /// حفظ الإحصائيات في التخزين المحلي
  Future<void> _saveToLocalStorage(GameStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(stats.toJson());
      await prefs.setString('game_stats', statsJson);
    } catch (e) {
      print('خطأ في حفظ الإحصائيات في التخزين المحلي: $e');
    }
  }

  /// حفظ تاريخ اللعبة محلياً للضيوف
  Future<void> _saveGameHistoryLocally(Map<String, dynamic> gameRecord) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('game_history') ?? '[]';
      final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));

      history.add(gameRecord);

      // الاحتفاظ بآخر 100 لعبة فقط
      if (history.length > 100) {
        history.removeAt(0);
      }

      await prefs.setString('game_history', jsonEncode(history));
    } catch (e) {
      print('خطأ في حفظ تاريخ اللعبة محلياً: $e');
    }
  }

  /// الحصول على تاريخ الألعاب
  Future<List<Map<String, dynamic>>> getGameHistory({int limit = 50}) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      if (!user.isGuest) {
        // تحميل من قاعدة البيانات - معطل مؤقتاً
        // final response = await _supabaseService.client
        //     .from('game_history')
        //     .select()
        //     .eq('user_id', user.id)
        //     .order('played_at', ascending: false)
        //     .limit(limit);
        //
        // return List<Map<String, dynamic>>.from(response);

        // محاكاة بيانات مؤقتة
        return [];
      } else {
        // تحميل من التخزين المحلي
        final prefs = await SharedPreferences.getInstance();
        final historyJson = prefs.getString('game_history') ?? '[]';
        final history =
            List<Map<String, dynamic>>.from(jsonDecode(historyJson));

        // ترتيب حسب التاريخ وإرجاع العدد المطلوب
        history.sort((a, b) => b['played_at'].compareTo(a['played_at']));
        return history.take(limit).toList();
      }
    } catch (e) {
      print('خطأ في تحميل تاريخ الألعاب: $e');
      return [];
    }
  }

  /// مسح جميع الإحصائيات
  Future<void> clearAllStats() async {
    try {
      final user = _authService.currentUser;
      _currentStats = GameStats.empty(user?.id ?? 'guest');
      await saveGameStats(_currentStats!);

      // مسح تاريخ الألعاب أيضاً
      if (user != null && !user.isGuest) {
        // TODO: تم تعطيل قاعدة البيانات مؤقتاً
        // await _supabaseService.client
        //     .from('game_history')
        //     .delete()
        //     .eq('user_id', user.id);
        Logger.logInfo('مسح تاريخ الألعاب للمستخدم: ${user.id}');
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('game_history');
      }
    } catch (e) {
      Logger.logError('خطأ في مسح الإحصائيات', e);
    }
  }

  void dispose() {
    _statsController.close();
  }
}
