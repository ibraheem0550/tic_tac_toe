import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../store/store_manager.dart';
import '../services/ai_task_renewal_service.dart';

class Mission {
  final String id;
  final String title;
  final IconData icon;
  final int coinsReward;
  final bool isCompleted;

  const Mission({
    required this.id,
    required this.title,
    required this.icon,
    required this.coinsReward,
    this.isCompleted = false,
  });
}

class MissionManager {
  static final _prefs = SharedPreferences.getInstance();
  static const String _completedMissionsKey = 'completed_missions';
  static const String _lastResetDateKey = 'missions_last_reset_date';
  static const String _winCountKey = 'daily_win_count';

  static final List<Mission> _dailyMissions = [
    Mission(
      id: 'win_vs_ai',
      title: 'الفوز على الكمبيوتر',
      icon: Icons.computer,
      coinsReward: 50,
    ),
    Mission(
      id: 'play_friend',
      title: 'اللعب مع صديق',
      icon: Icons.people,
      coinsReward: 30,
    ),
    Mission(
      id: 'win_three',
      title: 'الفوز 3 مرات',
      icon: Icons.workspace_premium,
      coinsReward: 100,
    ),
  ];

  static Future<List<String>> getCompletedMissions() async {
    final prefs = await _prefs;
    return prefs.getStringList(_completedMissionsKey) ?? [];
  }

  static Future<bool> completeMission(String missionId) async {
    final prefs = await _prefs;
    final completedMissions = await getCompletedMissions();

    if (!completedMissions.contains(missionId)) {
      // خاص بمهمة الفوز 3 مرات
      if (missionId == 'win_vs_ai' || missionId == 'play_friend') {
        final winCount = (prefs.getInt(_winCountKey) ?? 0) + 1;
        await prefs.setInt(_winCountKey, winCount);

        if (winCount >= 3 && !completedMissions.contains('win_three')) {
          completedMissions.add('win_three');
          await StoreManager.addCoins(100); // مكافأة الفوز 3 مرات
        }
      }

      completedMissions.add(missionId);
      await prefs.setStringList(_completedMissionsKey, completedMissions);

      // إضافة المكافأة
      final mission = _dailyMissions.firstWhere((m) => m.id == missionId);
      await StoreManager.addCoins(mission.coinsReward);

      return true; // تم إكمال المهمة بنجاح
    }
    return false; // المهمة مكتملة مسبقاً
  }

  static Future<void> resetDailyMissions() async {
    final prefs = await _prefs;

    // التحقق من آخر تاريخ تم فيه إعادة تعيين المهام
    final lastResetStr = prefs.getString(_lastResetDateKey);
    final now = DateTime.now();

    if (lastResetStr == null) {
      // أول مرة يتم فيها تشغيل المهام
      await _resetMissionsData(prefs, now);
      return;
    }

    try {
      final lastReset = DateTime.parse(lastResetStr);
      if (lastReset.year != now.year ||
          lastReset.month != now.month ||
          lastReset.day != now.day) {
        await _resetMissionsData(prefs, now);
      }
    } catch (e) {
      // في حالة وجود خطأ في تحليل التاريخ، نقوم بإعادة التعيين
      await _resetMissionsData(prefs, now);
    }
  }

  static Future<void> _resetMissionsData(
      SharedPreferences prefs, DateTime now) async {
    await prefs.setStringList(_completedMissionsKey, []);
    await prefs.setInt(_winCountKey, 0);
    await prefs.setString(_lastResetDateKey, now.toIso8601String());
  }

  static Future<List<Mission>> getDailyMissions() async {
    await resetDailyMissions();
    final completedMissions = await getCompletedMissions();
    final prefs = await _prefs;
    final winCount = prefs.getInt(_winCountKey) ?? 0;

    return [
      Mission(
        id: 'win_vs_ai',
        title: 'الفوز على الكمبيوتر',
        icon: Icons.computer,
        coinsReward: 50,
        isCompleted: completedMissions.contains('win_vs_ai'),
      ),
      Mission(
        id: 'play_friend',
        title: 'اللعب مع صديق',
        icon: Icons.people,
        coinsReward: 30,
        isCompleted: completedMissions.contains('play_friend'),
      ),
      Mission(
        id: 'win_three',
        title: 'الفوز ${winCount}/3 مرات',
        icon: Icons.workspace_premium,
        coinsReward: 100,
        isCompleted: completedMissions.contains('win_three'),
      ),
    ];
  }

  static Future<int> getWinCount() async {
    final prefs = await _prefs;
    return prefs.getInt(_winCountKey) ?? 0;
  }

  static Future<DateTime> getNextResetTime() async {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  /// الحصول على جميع المهام (التقليدية + الذكية)
  static Future<List<Mission>> getAllMissions() async {
    await resetDailyMissions();

    // الحصول على المهام التقليدية
    final dailyMissions = await getDailyMissions();

    // الحصول على المهام الذكية من AI
    final aiMissions = await AITaskRenewalService.generateSmartMissions();

    // دمج المهام
    final allMissions = <Mission>[];
    allMissions.addAll(dailyMissions);
    allMissions.addAll(aiMissions);

    return allMissions;
  }

  /// تحديث إحصائيات اللاعب لنظام AI
  static Future<void> updateGameStats({
    required bool isWin,
    required bool isAI,
    required String difficulty,
    required int gameDurationMinutes,
  }) async {
    final stats = {
      'total_games': 1,
      'wins': isWin ? 1 : 0,
      'losses': isWin ? 0 : 1,
      'ai_wins': (isWin && isAI) ? 1 : 0,
      'friend_games': isAI ? 0 : 1,
      'favorite_difficulty': difficulty,
      'play_time_minutes': gameDurationMinutes,
    };

    // تحديث الانتصارات المتتالية
    if (isWin) {
      final prefs = await SharedPreferences.getInstance();
      final currentStreak = prefs.getInt('consecutive_wins') ?? 0;
      stats['consecutive_wins'] = currentStreak + 1;
    } else {
      stats['consecutive_wins'] = 0;
    }

    await AITaskRenewalService.updatePlayerStats(stats);
  }

  /// إكمال مهمة ذكية
  static Future<bool> completeAIMission(String missionId, int reward) async {
    final prefs = await _prefs;
    final completedMissions = await getCompletedMissions();

    if (!completedMissions.contains(missionId)) {
      completedMissions.add(missionId);
      await prefs.setStringList(_completedMissionsKey, completedMissions);

      // إضافة المكافأة
      await StoreManager.addCoins(reward);

      // تحديث إحصائيات إكمال المهام
      await AITaskRenewalService.updatePlayerStats({'missions_completed': 1});

      return true;
    }
    return false;
  }

  /// فرض تجديد المهام الذكية
  static Future<void> forceAIRenewal() async {
    await AITaskRenewalService.resetAISystem();
  }

  /// الحصول على توصيات AI للاعب
  static Future<List<String>> getAIRecommendations() async {
    return await AITaskRenewalService.getAIRecommendations();
  }
}
