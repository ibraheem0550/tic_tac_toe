import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ======================================================================
// 📊 UNIFIED GAME SERVICES
// جميع خدمات اللعبة موحدة في ملف واحد
// ======================================================================

// ======================================================================
// 📈 GAME STATS SERVICE (خدمة الإحصائيات)
// ======================================================================

class GameStatsService extends ChangeNotifier {
  static final GameStatsService _instance = GameStatsService._internal();
  factory GameStatsService() => _instance;
  GameStatsService._internal();

  Map<String, dynamic> _stats = {
    'totalGames': 0,
    'wins': 0,
    'losses': 0,
    'draws': 0,
    'winRate': 0.0,
    'averageGameTime': 0,
    'currentStreak': 0,
    'longestStreak': 0,
    'favoriteMode': 'classic',
    'totalPlayTime': 0,
  };

  Map<String, dynamic> get stats => Map.from(_stats);

  // تحديث الإحصائيات بعد انتهاء اللعبة
  Future<void> updateStats({
    required String result, // 'win', 'loss', 'draw'
    required int gameTimeSeconds,
    required String gameMode,
  }) async {
    _stats['totalGames'] = (_stats['totalGames'] ?? 0) + 1;
    _stats['totalPlayTime'] = (_stats['totalPlayTime'] ?? 0) + gameTimeSeconds;

    switch (result) {
      case 'win':
        _stats['wins'] = (_stats['wins'] ?? 0) + 1;
        _stats['currentStreak'] = (_stats['currentStreak'] ?? 0) + 1;
        if (_stats['currentStreak'] > (_stats['longestStreak'] ?? 0)) {
          _stats['longestStreak'] = _stats['currentStreak'];
        }
        break;
      case 'loss':
        _stats['losses'] = (_stats['losses'] ?? 0) + 1;
        _stats['currentStreak'] = 0;
        break;
      case 'draw':
        _stats['draws'] = (_stats['draws'] ?? 0) + 1;
        break;
    }

    // حساب معدل الفوز
    if (_stats['totalGames'] > 0) {
      _stats['winRate'] = (_stats['wins'] / _stats['totalGames'] * 100);
    }

    // حساب متوسط وقت اللعبة
    if (_stats['totalGames'] > 0) {
      _stats['averageGameTime'] =
          (_stats['totalPlayTime'] / _stats['totalGames']).round();
    }

    await _saveStats();
    notifyListeners();
  }

  // تحميل الإحصائيات
  Future<void> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('game_stats');
      if (statsJson != null) {
        // Parse JSON if needed
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الإحصائيات: $e');
    }
  }

  // حفظ الإحصائيات
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Save stats to local storage
      await prefs.setInt('total_games', _stats['totalGames']);
      await prefs.setInt('wins', _stats['wins']);
      await prefs.setInt('losses', _stats['losses']);
      await prefs.setInt('draws', _stats['draws']);
      await prefs.setDouble('win_rate', _stats['winRate']);
    } catch (e) {
      debugPrint('خطأ في حفظ الإحصائيات: $e');
    }
  }

  // إعادة تعيين الإحصائيات
  Future<void> resetStats() async {
    _stats = {
      'totalGames': 0,
      'wins': 0,
      'losses': 0,
      'draws': 0,
      'winRate': 0.0,
      'averageGameTime': 0,
      'currentStreak': 0,
      'longestStreak': 0,
      'favoriteMode': 'classic',
      'totalPlayTime': 0,
    };
    await _saveStats();
    notifyListeners();
  }
}

// ======================================================================
// 🏪 STORE SERVICE (خدمة المتجر)
// ======================================================================

class StoreService extends ChangeNotifier {
  static final StoreService _instance = StoreService._internal();
  factory StoreService() => _instance;
  StoreService._internal();

  int _gems = 100;
  int _coins = 500;
  List<String> _purchasedItems = [];

  int get gems => _gems;
  int get coins => _coins;
  List<String> get purchasedItems => List.from(_purchasedItems);

  // شراء عنصر
  Future<bool> purchaseItem(String itemId, int cost, String currency) async {
    try {
      if (currency == 'gems' && _gems >= cost) {
        _gems -= cost;
        _purchasedItems.add(itemId);
        await _saveData();
        notifyListeners();
        return true;
      } else if (currency == 'coins' && _coins >= cost) {
        _coins -= cost;
        _purchasedItems.add(itemId);
        await _saveData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في شراء العنصر: $e');
      return false;
    }
  }

  // إضافة جواهر
  Future<void> addGems(int amount) async {
    _gems += amount;
    await _saveData();
    notifyListeners();
  }

  // إضافة عملات
  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveData();
    notifyListeners();
  }

  // تحميل البيانات
  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _gems = prefs.getInt('gems') ?? 100;
      _coins = prefs.getInt('coins') ?? 500;
      _purchasedItems = prefs.getStringList('purchased_items') ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المتجر: $e');
    }
  }

  // حفظ البيانات
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gems', _gems);
      await prefs.setInt('coins', _coins);
      await prefs.setStringList('purchased_items', _purchasedItems);
    } catch (e) {
      debugPrint('خطأ في حفظ بيانات المتجر: $e');
    }
  }
}

// ======================================================================
// 🎮 ONLINE GAME SERVICE (خدمة الألعاب الجماعية)
// ======================================================================

class OnlineGameService extends ChangeNotifier {
  static final OnlineGameService _instance = OnlineGameService._internal();
  factory OnlineGameService() => _instance;
  OnlineGameService._internal();

  bool _isConnected = false;
  String? _gameRoomId;
  String? _opponentId;
  List<String> _gameBoard = List.filled(9, '');
  bool _isMyTurn = false;
  String _mySymbol = 'X';

  bool get isConnected => _isConnected;
  String? get gameRoomId => _gameRoomId;
  String? get opponentId => _opponentId;
  List<String> get gameBoard => List.from(_gameBoard);
  bool get isMyTurn => _isMyTurn;
  String get mySymbol => _mySymbol;

  // الاتصال بالخادم
  Future<void> connect() async {
    try {
      // محاكاة الاتصال
      await Future.delayed(const Duration(seconds: 2));
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في الاتصال: $e');
    }
  }

  // إنشاء غرفة لعب
  Future<String?> createRoom() async {
    try {
      if (!_isConnected) await connect();

      _gameRoomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
      _gameBoard = List.filled(9, '');
      _isMyTurn = true;
      _mySymbol = 'X';

      notifyListeners();
      return _gameRoomId;
    } catch (e) {
      debugPrint('خطأ في إنشاء الغرفة: $e');
      return null;
    }
  }

  // الانضمام لغرفة
  Future<bool> joinRoom(String roomId) async {
    try {
      if (!_isConnected) await connect();

      _gameRoomId = roomId;
      _mySymbol = 'O';
      _isMyTurn = false;

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في الانضمام للغرفة: $e');
      return false;
    }
  }

  // عمل حركة
  Future<bool> makeMove(int position) async {
    try {
      if (!_isMyTurn || _gameBoard[position].isNotEmpty) {
        return false;
      }

      _gameBoard[position] = _mySymbol;
      _isMyTurn = false;

      // محاكاة إرسال الحركة للخادم
      await Future.delayed(const Duration(milliseconds: 500));

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('خطأ في عمل الحركة: $e');
      return false;
    }
  }

  // قطع الاتصال
  Future<void> disconnect() async {
    _isConnected = false;
    _gameRoomId = null;
    _opponentId = null;
    _gameBoard = List.filled(9, '');
    _isMyTurn = false;
    notifyListeners();
  }
}

// ======================================================================
// 💳 PAYMENT SERVICE (خدمة المدفوعات)
// ======================================================================

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  bool _isProcessing = false;
  final List<Map<String, dynamic>> _transactions = [];

  bool get isProcessing => _isProcessing;
  List<Map<String, dynamic>> get transactions => List.from(_transactions);

  // معالجة الدفع
  Future<bool> processPayment({
    required String productId,
    required double amount,
    required String currency,
  }) async {
    try {
      _isProcessing = true;
      notifyListeners();

      // محاكاة معالجة الدفع
      await Future.delayed(const Duration(seconds: 3));

      // محاكاة نجاح الدفع (90% نجاح)
      final success = DateTime.now().millisecondsSinceEpoch % 10 != 0;

      final transaction = {
        'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
        'productId': productId,
        'amount': amount,
        'currency': currency,
        'status': success ? 'success' : 'failed',
        'timestamp': DateTime.now().toIso8601String(),
      };

      _transactions.add(transaction);
      _isProcessing = false;
      notifyListeners();

      return success;
    } catch (e) {
      debugPrint('خطأ في معالجة الدفع: $e');
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  // استعادة المشتريات
  Future<void> restorePurchases() async {
    try {
      // محاكاة استعادة المشتريات
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('تم استعادة المشتريات');
    } catch (e) {
      debugPrint('خطأ في استعادة المشتريات: $e');
    }
  }
}

// ======================================================================
// ⚡ PERFORMANCE MONITOR (مراقب الأداء)
// ======================================================================

class PerformanceMonitorService {
  static final PerformanceMonitorService _instance =
      PerformanceMonitorService._internal();
  factory PerformanceMonitorService() => _instance;
  PerformanceMonitorService._internal();

  final Map<String, DateTime> _startTimes = {};
  final Map<String, int> _metrics = {};

  // بدء قياس الوقت
  void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  // انهاء قياس الوقت
  void endTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      _metrics[operation] = duration;
      debugPrint('⚡ $operation took: ${duration}ms');
      _startTimes.remove(operation);
    }
  }

  // الحصول على المقاييس
  Map<String, int> getMetrics() => Map.from(_metrics);

  // مسح المقاييس
  void clearMetrics() {
    _metrics.clear();
    _startTimes.clear();
  }
}

// ======================================================================
// 🎯 TOURNAMENT SERVICE (خدمة البطولات)
// ======================================================================

class TournamentService extends ChangeNotifier {
  static final TournamentService _instance = TournamentService._internal();
  factory TournamentService() => _instance;
  TournamentService._internal();

  List<Map<String, dynamic>> _activeTournaments = [];
  final List<Map<String, dynamic>> _userTournaments = [];

  List<Map<String, dynamic>> get activeTournaments =>
      List.from(_activeTournaments);
  List<Map<String, dynamic>> get userTournaments => List.from(_userTournaments);

  // تحميل البطولات النشطة
  Future<void> loadActiveTournaments() async {
    try {
      // محاكاة تحميل البطولات
      await Future.delayed(const Duration(seconds: 1));

      _activeTournaments = [
        {
          'id': 'tournament_1',
          'name': 'بطولة الأسبوع',
          'description': 'أفضل لاعب هذا الأسبوع',
          'prize': '1000 جوهرة',
          'participants': 156,
          'endDate': DateTime.now()
              .add(const Duration(days: 3))
              .toIso8601String(),
          'isJoined': false,
        },
        {
          'id': 'tournament_2',
          'name': 'بطولة المبتدئين',
          'description': 'للاعبين الجدد فقط',
          'prize': '500 جوهرة',
          'participants': 89,
          'endDate': DateTime.now()
              .add(const Duration(days: 5))
              .toIso8601String(),
          'isJoined': true,
        },
      ];

      notifyListeners();
    } catch (e) {
      debugPrint('خطأ في تحميل البطولات: $e');
    }
  }

  // الانضمام لبطولة
  Future<bool> joinTournament(String tournamentId) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final tournament = _activeTournaments.firstWhere(
        (t) => t['id'] == tournamentId,
        orElse: () => {},
      );

      if (tournament.isNotEmpty) {
        tournament['isJoined'] = true;
        _userTournaments.add(tournament);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('خطأ في الانضمام للبطولة: $e');
      return false;
    }
  }
}
