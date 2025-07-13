/// خدمة بيانات المستخدم الموحدة - مبسطة وخالية من الأخطاء
library unified_user_data_service;

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/complete_user_models.dart' as models;

class UnifiedUserDataService {
  static UnifiedUserDataService? _instance;
  static UnifiedUserDataService get instance =>
      _instance ??= UnifiedUserDataService._();
  UnifiedUserDataService._();

  // Local Storage
  SharedPreferences? _prefs;

  // Configuration
  bool _isDevMode = false;

  // Cache
  final Map<String, models.User> _userCache = {};
  final Map<String, models.GameStats> _statsCache = {};

  // Streams
  StreamSubscription? _userSubscription;
  final StreamController<models.User?> _userStreamController =
      StreamController<models.User?>.broadcast();

  /// تهيئة الخدمة
  Future<void> initialize({bool devMode = false}) async {
    try {
      _isDevMode = devMode;

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      debugPrint('✅ UnifiedUserDataService initialized successfully');
    } catch (e) {
      debugPrint('❌ UnifiedUserDataService initialization failed: $e');
    }
  }

  /// حفظ بيانات المستخدم
  Future<bool> saveUserData(models.User user) async {
    try {
      // Cache locally
      _userCache[user.id] = user;

      // Save to local storage
      await _saveUserDataLocally(user);

      // Emit update
      _userStreamController.add(user);

      debugPrint('✅ User data saved successfully for ${user.id}');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to save user data: $e');
      return false;
    }
  }

  /// تحميل بيانات المستخدم
  Future<models.User?> loadUserData(String userId) async {
    try {
      // Check cache first
      if (_userCache.containsKey(userId)) {
        return _userCache[userId];
      }

      // Load from local storage
      final localUser = await _loadUserDataLocally(userId);
      if (localUser != null) {
        _userCache[userId] = localUser;
        return localUser;
      }

      debugPrint('⚠️ User data not found for $userId');
      return null;
    } catch (e) {
      debugPrint('❌ Failed to load user data: $e');
      return null;
    }
  }

  /// حفظ إحصائيات اللعبة
  Future<bool> saveGameStats(String userId, models.GameStats stats) async {
    try {
      // Cache locally
      _statsCache[userId] = stats;

      // Save to local storage
      await _saveGameStatsLocally(userId, stats);

      debugPrint('✅ Game stats saved successfully for $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to save game stats: $e');
      return false;
    }
  }

  /// تحميل إحصائيات اللعبة
  Future<models.GameStats?> loadGameStats(String userId) async {
    try {
      // Check cache first
      if (_statsCache.containsKey(userId)) {
        return _statsCache[userId];
      }

      // Load from local storage
      final localStats = await _loadGameStatsLocally(userId);
      if (localStats != null) {
        _statsCache[userId] = localStats;
        return localStats;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Failed to load game stats: $e');
      return null;
    }
  }

  /// حفظ بيانات المستخدم محلياً
  Future<void> _saveUserDataLocally(models.User user) async {
    if (_prefs == null) return;

    try {
      final userData = user.toJson();
      await _prefs!.setString('user_${user.id}', jsonEncode(userData));
      if (_isDevMode) {
        debugPrint('💾 User data saved locally for ${user.id}');
      }
    } catch (e) {
      debugPrint('❌ Failed to save user data locally: $e');
    }
  }

  /// تحميل بيانات المستخدم محلياً
  Future<models.User?> _loadUserDataLocally(String userId) async {
    if (_prefs == null) return null;

    try {
      final userDataString = _prefs!.getString('user_$userId');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        final user = models.User.fromJson(userData);
        if (_isDevMode) {
          debugPrint('💾 User data loaded locally for $userId');
        }
        return user;
      }
    } catch (e) {
      debugPrint('❌ Failed to load user data locally: $e');
    }
    return null;
  }

  /// حفظ إحصائيات اللعبة محلياً
  Future<void> _saveGameStatsLocally(
    String userId,
    models.GameStats stats,
  ) async {
    if (_prefs == null) return;

    try {
      final statsData = stats.toJson();
      await _prefs!.setString('stats_$userId', jsonEncode(statsData));
      if (_isDevMode) {
        debugPrint('💾 Game stats saved locally for $userId');
      }
    } catch (e) {
      debugPrint('❌ Failed to save game stats locally: $e');
    }
  }

  /// تحميل إحصائيات اللعبة محلياً
  Future<models.GameStats?> _loadGameStatsLocally(String userId) async {
    if (_prefs == null) return null;

    try {
      final statsDataString = _prefs!.getString('stats_$userId');
      if (statsDataString != null) {
        final statsData = jsonDecode(statsDataString) as Map<String, dynamic>;
        final stats = models.GameStats.fromJson(statsData);
        if (_isDevMode) {
          debugPrint('💾 Game stats loaded locally for $userId');
        }
        return stats;
      }
    } catch (e) {
      debugPrint('❌ Failed to load game stats locally: $e');
    }
    return null;
  }

  /// حذف بيانات المستخدم
  Future<bool> deleteUserData(String userId) async {
    try {
      // Remove from cache
      _userCache.remove(userId);
      _statsCache.remove(userId);

      // Remove from local storage
      if (_prefs != null) {
        await _prefs!.remove('user_$userId');
        await _prefs!.remove('stats_$userId');
      }

      debugPrint('✅ User data deleted successfully for $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete user data: $e');
      return false;
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUserData(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final user = await loadUserData(userId);
      if (user == null) {
        debugPrint('❌ User not found for update: $userId');
        return false;
      }

      // Create updated user
      final updatedUser = models.User(
        id: user.id,
        email: updates['email'] ?? user.email,
        displayName: updates['displayName'] ?? user.displayName,
        photoURL: updates['photoURL'] ?? user.photoURL,
        isGuest: updates['isGuest'] ?? user.isGuest,
        createdAt: user.createdAt,
        lastLoginAt: updates['lastLoginAt'] ?? DateTime.now(),
        gems: updates['gems'] ?? user.gems,
        level: updates['level'] ?? user.level,
        experience: updates['experience'] ?? user.experience,
        achievements: updates['achievements'] ?? user.achievements,
        preferences: updates['preferences'] ?? user.preferences,
        settings: updates['settings'] ?? user.settings,
      );

      return await saveUserData(updatedUser);
    } catch (e) {
      debugPrint('❌ Failed to update user data: $e');
      return false;
    }
  }

  /// تحديث إحصائيات اللعبة
  Future<bool> updateGameStats(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      models.GameStats? stats = await loadGameStats(userId);

      // Create new stats if none exist
      if (stats == null) {
        stats = models.GameStats(
          userId: userId,
          totalGames: 0,
          wins: 0,
          losses: 0,
          draws: 0,
          streak: 0,
          bestStreak: 0,
          lastUpdated: DateTime.now(),
          totalPlayTime: 0,
          modeStats: const {},
          difficultyStats: const {},
          achievements: const [],
          additionalData: const {},
        );
      }

      // Apply updates
      final updatedStats = models.GameStats(
        userId: userId,
        totalGames: updates['totalGames'] ?? stats.totalGames,
        wins: updates['wins'] ?? stats.wins,
        losses: updates['losses'] ?? stats.losses,
        draws: updates['draws'] ?? stats.draws,
        streak: updates['currentStreak'] ?? stats.streak,
        bestStreak: updates['bestStreak'] ?? stats.bestStreak,
        totalPlayTime: updates['totalPlayTime'] ?? stats.totalPlayTime,
        lastUpdated: DateTime.now(),
        modeStats: stats.modeStats,
        difficultyStats: stats.difficultyStats,
        achievements: stats.achievements,
        additionalData: stats.additionalData,
      );

      return await saveGameStats(userId, updatedStats);
    } catch (e) {
      debugPrint('❌ Failed to update game stats: $e');
      return false;
    }
  }

  /// الحصول على stream للمستخدم
  Stream<models.User?> get userStream => _userStreamController.stream;

  /// تنظيف الكاش
  void clearCache() {
    _userCache.clear();
    _statsCache.clear();
    debugPrint('✅ Cache cleared');
  }

  /// تحرير الموارد
  void dispose() {
    _userSubscription?.cancel();
    _userStreamController.close();
    clearCache();
  }
}
