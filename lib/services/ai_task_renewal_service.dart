import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../missions/mission_manager.dart';

/// خدمة الذكاء الاصطناعي لتجديد المهام
/// تقوم بتوليد مهام ديناميكية وذكية بناءً على أداء اللاعب ونشاطه
class AITaskRenewalService {
  static final Random _random = Random();
  static const String _lastAIRenewalKey = 'last_ai_renewal_date';
  static const String _playerStatsKey = 'player_stats';
  static const String _aiGeneratedMissionsKey = 'ai_generated_missions';

  /// إحصائيات اللاعب لتحليل الأداء
  static Map<String, dynamic> _playerStats = {
    'total_games': 0,
    'wins': 0,
    'losses': 0,
    'ai_wins': 0,
    'friend_games': 0,
    'consecutive_wins': 0,
    'favorite_difficulty': 'medium',
    'play_time_minutes': 0,
    'missions_completed': 0,
  };

  /// قوالب المهام الذكية بمستويات صعوبة مختلفة
  static final Map<String, List<MissionTemplate>> _missionTemplates = {
    'beginner': [
      MissionTemplate(
        id: 'ai_beginner_win',
        title: 'تحدى الذكاء الاصطناعي - مبتدئ',
        description: 'اهزم الكمبيوتر في المستوى السهل',
        icon: Icons.psychology,
        baseReward: 25,
        difficulty: 'easy',
        category: 'ai_challenge',
      ),
      MissionTemplate(
        id: 'play_streak_3',
        title: 'متواصل النشاط',
        description: 'العب 3 ألعاب متتالية',
        icon: Icons.flash_on,
        baseReward: 40,
        difficulty: 'easy',
        category: 'activity',
      ),
    ],
    'intermediate': [
      MissionTemplate(
        id: 'ai_medium_win_5',
        title: 'خبير المستوى المتوسط',
        description: 'اهزم الكمبيوتر 5 مرات في المستوى المتوسط',
        icon: Icons.military_tech,
        baseReward: 80,
        difficulty: 'medium',
        category: 'ai_challenge',
      ),
      MissionTemplate(
        id: 'perfect_game',
        title: 'اللعبة المثالية',
        description: 'اربح دون أن يحرز الخصم نقطة واحدة',
        icon: Icons.star,
        baseReward: 100,
        difficulty: 'medium',
        category: 'skill',
      ),
      MissionTemplate(
        id: 'quick_wins_10',
        title: 'سرعة البرق',
        description: 'اربح 10 ألعاب في أقل من 10 دقائق',
        icon: Icons.speed,
        baseReward: 120,
        difficulty: 'medium',
        category: 'speed',
      ),
    ],
    'advanced': [
      MissionTemplate(
        id: 'ai_hard_master',
        title: 'سيد الذكاء الاصطناعي',
        description: 'اهزم الكمبيوتر في المستوى الصعب 10 مرات',
        icon: Icons.emoji_events,
        baseReward: 200,
        difficulty: 'hard',
        category: 'ai_master',
      ),
      MissionTemplate(
        id: 'marathon_session',
        title: 'ماراثون الألعاب',
        description: 'العب لمدة 30 دقيقة متواصلة',
        icon: Icons.timer,
        baseReward: 150,
        difficulty: 'hard',
        category: 'endurance',
      ),
      MissionTemplate(
        id: 'win_streak_15',
        title: 'الانتصارات المتتالية',
        description: 'اربح 15 لعبة متتالية',
        icon: Icons.trending_up,
        baseReward: 250,
        difficulty: 'hard',
        category: 'streak',
      ),
    ],
    'expert': [
      MissionTemplate(
        id: 'impossible_challenge',
        title: 'التحدي المستحيل',
        description: 'اهزم الكمبيوتر في المستوى المستحيل 5 مرات',
        icon: Icons.whatshot,
        baseReward: 300,
        difficulty: 'impossible',
        category: 'ultimate',
      ),
      MissionTemplate(
        id: 'perfect_day',
        title: 'اليوم المثالي',
        description: 'اربح جميع ألعابك في يوم واحد (أكثر من 20 لعبة)',
        icon: Icons.diamond,
        baseReward: 400,
        difficulty: 'impossible',
        category: 'perfection',
      ),
    ],
  };

  /// المهام الخاصة الموسمية والأحداث
  static final List<MissionTemplate> _specialEventMissions = [
    MissionTemplate(
      id: 'weekend_warrior',
      title: 'محارب نهاية الأسبوع',
      description: 'العب 50 لعبة في نهاية الأسبوع',
      icon: Icons.weekend,
      baseReward: 200,
      difficulty: 'medium',
      category: 'weekend_special',
      isWeekendOnly: true,
    ),
    MissionTemplate(
      id: 'monthly_champion',
      title: 'بطل الشهر',
      description: 'كن الأول في التصنيف الشهري',
      icon: Icons.emoji_events,
      baseReward: 500,
      difficulty: 'hard',
      category: 'monthly_special',
      isMonthlyOnly: true,
    ),
    MissionTemplate(
      id: 'theme_explorer',
      title: 'مستكشف السمات',
      description: 'جرب 5 سمات مختلفة',
      icon: Icons.palette,
      baseReward: 80,
      difficulty: 'easy',
      category: 'exploration',
    ),
  ];

  /// تحليل أداء اللاعب وتحديد مستوى خبرته
  static Future<String> _analyzePlayerLevel() async {
    try {
      // في التطبيق الحقيقي، سنحلل الإحصائيات من JSON
      final totalGames = _playerStats['total_games'] ?? 0;
      final winRate =
          totalGames > 0 ? (_playerStats['wins'] ?? 0) / totalGames : 0;
      final consecutiveWins = _playerStats['consecutive_wins'] ?? 0;

      if (totalGames < 10) return 'beginner';
      if (totalGames < 50 || winRate < 0.6) return 'intermediate';
      if (totalGames < 100 || winRate < 0.8 || consecutiveWins < 10)
        return 'advanced';
      return 'expert';
    } catch (e) {
      return 'beginner';
    }
  }

  /// توليد مهام ذكية بناءً على أداء اللاعب
  static Future<List<Mission>> generateSmartMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastRenewal = prefs.getString(_lastAIRenewalKey);

    // التحقق من الحاجة لتجديد المهام (كل 6 ساعات)
    bool shouldRenew = false;
    if (lastRenewal == null) {
      shouldRenew = true;
    } else {
      final lastDate = DateTime.parse(lastRenewal);
      shouldRenew = now.difference(lastDate).inHours >= 6;
    }

    if (!shouldRenew) {
      return await _loadSavedAIMissions();
    }

    final playerLevel = await _analyzePlayerLevel();
    final generatedMissions = <Mission>[];

    // توليد مهام أساسية بناءً على مستوى اللاعب
    final levelTemplates =
        _missionTemplates[playerLevel] ?? _missionTemplates['beginner']!;

    // اختيار 2-3 مهام عشوائية من مستوى اللاعب
    final selectedTemplates = _selectRandomTemplates(levelTemplates, 2);

    // إضافة مهمة من مستوى أعلى للتحدي
    if (playerLevel != 'expert') {
      final nextLevel = _getNextLevel(playerLevel);
      final challengeTemplates = _missionTemplates[nextLevel] ?? [];
      if (challengeTemplates.isNotEmpty) {
        selectedTemplates.add(
            challengeTemplates[_random.nextInt(challengeTemplates.length)]);
      }
    }

    // إضافة مهام خاصة بناءً على اليوم/الموسم
    selectedTemplates.addAll(_getSpecialMissions(now));

    // تحويل القوالب إلى مهام فعلية
    for (final template in selectedTemplates) {
      generatedMissions.add(_createMissionFromTemplate(template));
    }

    // حفظ المهام المولدة
    await _saveAIMissions(generatedMissions);
    await prefs.setString(_lastAIRenewalKey, now.toIso8601String());

    return generatedMissions;
  }

  /// اختيار قوالب عشوائية من قائمة
  static List<MissionTemplate> _selectRandomTemplates(
      List<MissionTemplate> templates, int count) {
    final shuffled = List<MissionTemplate>.from(templates)..shuffle(_random);
    return shuffled.take(count).toList();
  }

  /// الحصول على المستوى التالي
  static String _getNextLevel(String currentLevel) {
    switch (currentLevel) {
      case 'beginner':
        return 'intermediate';
      case 'intermediate':
        return 'advanced';
      case 'advanced':
        return 'expert';
      default:
        return 'expert';
    }
  }

  /// الحصول على المهام الخاصة بناءً على التاريخ
  static List<MissionTemplate> _getSpecialMissions(DateTime date) {
    final special = <MissionTemplate>[];

    // مهام نهاية الأسبوع
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      special.addAll(_specialEventMissions.where((m) => m.isWeekendOnly));
    }

    // مهام شهرية (أول أسبوع من الشهر)
    if (date.day <= 7) {
      special.addAll(_specialEventMissions.where((m) => m.isMonthlyOnly));
    }

    // مهام عادية خاصة
    final regularSpecial = _specialEventMissions
        .where((m) => !m.isWeekendOnly && !m.isMonthlyOnly)
        .toList();
    if (regularSpecial.isNotEmpty && _random.nextBool()) {
      special.add(regularSpecial[_random.nextInt(regularSpecial.length)]);
    }

    return special;
  }

  /// تحويل قالب إلى مهمة فعلية
  static Mission _createMissionFromTemplate(MissionTemplate template) {
    // تعديل المكافأة بناءً على أداء اللاعب
    final adjustedReward = _calculateDynamicReward(template);

    return Mission(
      id: template.id,
      title: template.title,
      icon: template.icon,
      coinsReward: adjustedReward,
    );
  }

  /// حساب المكافأة الديناميكية
  static int _calculateDynamicReward(MissionTemplate template) {
    final baseReward = template.baseReward;
    final playerLevel = _playerStats['total_games'] ?? 0;

    // زيادة المكافأة للاعبين المتقدمين
    final multiplier = 1.0 + (playerLevel / 100).clamp(0.0, 2.0);

    // مكافأة إضافية للمهام الصعبة
    final difficultyBonus = {
          'easy': 1.0,
          'medium': 1.2,
          'hard': 1.5,
          'impossible': 2.0,
        }[template.difficulty] ??
        1.0;

    return (baseReward * multiplier * difficultyBonus).round();
  }

  /// حفظ المهام المولدة بواسطة AI
  static Future<void> _saveAIMissions(List<Mission> missions) async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = missions
        .map((m) => {
              'id': m.id,
              'title': m.title,
              'iconCodePoint': m.icon.codePoint,
              'coinsReward': m.coinsReward,
              'isCompleted': m.isCompleted,
            })
        .toList();

    await prefs.setString(_aiGeneratedMissionsKey, missionsJson.toString());
  }

  /// تحميل المهام المحفوظة
  static Future<List<Mission>> _loadSavedAIMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_aiGeneratedMissionsKey);

    if (savedData == null || savedData.isEmpty) {
      return [];
    }

    try {
      // في التطبيق الحقيقي، سنستخدم JSON parsing صحيح
      // هنا سنعيد مهام افتراضية للتجربة
      return [
        Mission(
          id: 'ai_adaptive_1',
          title: 'مهمة ذكية مُتكيفة',
          icon: Icons.psychology,
          coinsReward: 75,
        ),
        Mission(
          id: 'ai_adaptive_2',
          title: 'تحدي الذكاء الاصطناعي',
          icon: Icons.smart_toy,
          coinsReward: 100,
        ),
      ];
    } catch (e) {
      return [];
    }
  }

  /// تحديث إحصائيات اللاعب
  static Future<void> updatePlayerStats(Map<String, dynamic> newStats) async {
    final prefs = await SharedPreferences.getInstance();

    // دمج الإحصائيات الجديدة مع الموجودة
    _playerStats.addAll(newStats);

    // حفظ الإحصائيات
    await prefs.setString(_playerStatsKey, _playerStats.toString());
  }

  /// الحصول على التوصيات الذكية للاعب
  static Future<List<String>> getAIRecommendations() async {
    final playerLevel = await _analyzePlayerLevel();
    final recommendations = <String>[];

    switch (playerLevel) {
      case 'beginner':
        recommendations.addAll([
          'جرب اللعب ضد الكمبيوتر في المستوى السهل',
          'تدرب على استراتيجيات الفوز الأساسية',
          'العب مع الأصدقاء لتحسين مهاراتك',
        ]);
        break;
      case 'intermediate':
        recommendations.addAll([
          'تحدى نفسك في المستوى المتوسط',
          'حاول تحقيق انتصارات متتالية',
          'استكشف السمات الجديدة لتحسين التجربة',
        ]);
        break;
      case 'advanced':
        recommendations.addAll([
          'واجه التحدي في المستوى الصعب',
          'حاول تحقيق الألعاب المثالية',
          'ساعد الأصدقاء المبتدئين في التعلم',
        ]);
        break;
      case 'expert':
        recommendations.addAll([
          'أتقن المستوى المستحيل',
          'حطم الأرقام القياسية',
          'كن مرشداً للاعبين الجدد',
        ]);
        break;
    }

    return recommendations;
  }

  /// إعادة تعيين نظام AI
  static Future<void> resetAISystem() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastAIRenewalKey);
    await prefs.remove(_aiGeneratedMissionsKey);
    await prefs.remove(_playerStatsKey);
    _playerStats.clear();
  }
}

/// قالب المهمة للذكاء الاصطناعي
class MissionTemplate {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int baseReward;
  final String difficulty;
  final String category;
  final bool isWeekendOnly;
  final bool isMonthlyOnly;

  const MissionTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.baseReward,
    required this.difficulty,
    required this.category,
    this.isWeekendOnly = false,
    this.isMonthlyOnly = false,
  });
}
