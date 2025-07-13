// lib/services/enhanced_user_data_service.dart
/// خدمة بيانات المستخدم المحسنة - مبسطة وبدون Firebase

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/enhanced_game_stats.dart';

class EnhancedUserDataService {
  static EnhancedUserDataService? _instance;
  static EnhancedUserDataService get instance =>
      _instance ??= EnhancedUserDataService._();
  EnhancedUserDataService._();

  // Local Storage
  SharedPreferences? _prefs;

  // Cache
  final Map<String, dynamic> _userCache = {};
  final Map<String, EnhancedGameStats> _statsCache = {};

  // Controllers
  final StreamController<dynamic> _userController =
      StreamController<dynamic>.broadcast();
  final StreamController<EnhancedGameStats> _statsController =
      StreamController<EnhancedGameStats>.broadcast();

  // Streams
  Stream<dynamic> get userStream => _userController.stream;
  Stream<EnhancedGameStats> get statsStream => _statsController.stream;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('✅ Enhanced User Data Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Enhanced User Data Service: $e');
    }
  }

  /// حفظ بيانات المستخدم
  Future<void> saveUserData(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Save to cache
      _userCache[userId] = userData;

      // Save to local storage
      if (_prefs != null) {
        await _prefs!.setString('user_$userId', jsonEncode(userData));
      }

      // Notify listeners
      _userController.add(userData);

      debugPrint('✅ User data saved successfully for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving user data: $e');
    }
  }

  /// تحميل بيانات المستخدم
  Future<Map<String, dynamic>?> loadUserData(String userId) async {
    try {
      // Check cache first
      if (_userCache.containsKey(userId)) {
        return _userCache[userId] as Map<String, dynamic>;
      }

      // Load from local storage
      if (_prefs != null) {
        final String? userDataString = _prefs!.getString('user_$userId');
        if (userDataString != null) {
          final Map<String, dynamic> userData = jsonDecode(userDataString);
          _userCache[userId] = userData;
          return userData;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      return null;
    }
  }

  /// حفظ إحصائيات اللعبة
  Future<void> saveGameStats(String userId, EnhancedGameStats stats) async {
    try {
      // Save to cache
      _statsCache[userId] = stats;

      // Save to local storage
      if (_prefs != null) {
        await _prefs!.setString('stats_$userId', jsonEncode(stats.toJson()));
      }

      // Notify listeners
      _statsController.add(stats);

      debugPrint('✅ Game stats saved successfully for user: $userId');
    } catch (e) {
      debugPrint('❌ Error saving game stats: $e');
    }
  }

  /// تحميل إحصائيات اللعبة
  Future<EnhancedGameStats?> loadGameStats(String userId) async {
    try {
      // Check cache first
      if (_statsCache.containsKey(userId)) {
        return _statsCache[userId];
      }

      // Load from local storage
      if (_prefs != null) {
        final String? statsString = _prefs!.getString('stats_$userId');
        if (statsString != null) {
          final Map<String, dynamic> statsData = jsonDecode(statsString);
          final EnhancedGameStats stats = EnhancedGameStats.fromJson(statsData);
          _statsCache[userId] = stats;
          return stats;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error loading game stats: $e');
      return null;
    }
  }

  /// تحديث إحصائيات اللعبة
  Future<void> updateGameStats(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      EnhancedGameStats? currentStats = await loadGameStats(userId);
      if (currentStats == null) {
        currentStats = EnhancedGameStats(
          userId: userId,
          totalGamesPlayed: 0,
          totalWins: 0,
          totalLosses: 0,
          totalDraws: 0,
          currentWinStreak: 0,
          bestWinStreak: 0,
          totalPlayTime: 0,
          lastPlayedAt: DateTime.now(),
        );
      }

      // Apply updates
      final updatedStats = currentStats.copyWith(
        totalGamesPlayed:
            updates['totalGames'] ?? currentStats.totalGamesPlayed,
        totalWins: updates['totalWins'] ?? currentStats.totalWins,
        totalLosses: updates['totalLosses'] ?? currentStats.totalLosses,
        totalDraws: updates['totalDraws'] ?? currentStats.totalDraws,
        currentWinStreak:
            updates['currentStreak'] ?? currentStats.currentWinStreak,
        bestWinStreak: updates['bestStreak'] ?? currentStats.bestWinStreak,
        totalPlayTime: updates['totalPlayTime'] ?? currentStats.totalPlayTime,
        lastPlayedAt: updates['lastPlayed'] ?? currentStats.lastPlayedAt,
      );

      await saveGameStats(userId, updatedStats);

      debugPrint('✅ Game stats updated successfully for user: $userId');
    } catch (e) {
      debugPrint('❌ Error updating game stats: $e');
    }
  }

  /// حذف بيانات المستخدم
  Future<void> deleteUserData(String userId) async {
    try {
      // Remove from cache
      _userCache.remove(userId);
      _statsCache.remove(userId);

      // Remove from local storage
      if (_prefs != null) {
        await _prefs!.remove('user_$userId');
        await _prefs!.remove('stats_$userId');
      }

      debugPrint('✅ User data deleted successfully for user: $userId');
    } catch (e) {
      debugPrint('❌ Error deleting user data: $e');
    }
  }

  /// تنظيف الكاش
  void clearCache() {
    _userCache.clear();
    _statsCache.clear();
    debugPrint('✅ Cache cleared successfully');
  }

  /// تحرير الموارد
  void dispose() {
    _userController.close();
    _statsController.close();
    clearCache();
  }
}
