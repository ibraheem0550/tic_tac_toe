import 'package:flutter/material.dart';

/// أنماط الألعاب المختلفة
enum GameMode {
  singlePlayer,
  multiPlayer,
  ai,
  online,
  tournament,
  practice,
  challenge,
  mission,
  tutorial,
}

/// فئة للتعامل مع أنماط الألعاب
class GameModeManager {
  static String getModeName(GameMode mode) {
    switch (mode) {
      case GameMode.singlePlayer:
        return 'لاعب واحد';
      case GameMode.multiPlayer:
        return 'لاعبان';
      case GameMode.ai:
        return 'ضد الذكاء الاصطناعي';
      case GameMode.online:
        return 'أونلاين';
      case GameMode.tournament:
        return 'بطولة';
      case GameMode.practice:
        return 'تدريب';
      case GameMode.challenge:
        return 'تحدي';
      case GameMode.mission:
        return 'مهمة';
      case GameMode.tutorial:
        return 'تعليمي';
    }
  }

  static String getModeDescription(GameMode mode) {
    switch (mode) {
      case GameMode.singlePlayer:
        return 'العب بمفردك ضد الكمبيوتر';
      case GameMode.multiPlayer:
        return 'العب مع صديق على نفس الجهاز';
      case GameMode.ai:
        return 'اختبر مهاراتك ضد الذكاء الاصطناعي';
      case GameMode.online:
        return 'العب مع أصدقائك عبر الإنترنت';
      case GameMode.tournament:
        return 'شارك في البطولات واربح الجوائز';
      case GameMode.practice:
        return 'تدرب وحسن من مهاراتك';
      case GameMode.challenge:
        return 'تحدى نفسك بألغاز صعبة';
      case GameMode.mission:
        return 'أكمل المهام واجمع النقاط';
      case GameMode.tutorial:
        return 'تعلم كيفية اللعب';
    }
  }

  static IconData getModeIcon(GameMode mode) {
    switch (mode) {
      case GameMode.singlePlayer:
        return Icons.person;
      case GameMode.multiPlayer:
        return Icons.people;
      case GameMode.ai:
        return Icons.smart_toy;
      case GameMode.online:
        return Icons.wifi;
      case GameMode.tournament:
        return Icons.emoji_events;
      case GameMode.practice:
        return Icons.fitness_center;
      case GameMode.challenge:
        return Icons.psychology;
      case GameMode.mission:
        return Icons.assignment;
      case GameMode.tutorial:
        return Icons.school;
    }
  }

  static Color getModeColor(GameMode mode) {
    switch (mode) {
      case GameMode.singlePlayer:
        return const Color(0xFF3B82F6);
      case GameMode.multiPlayer:
        return const Color(0xFF10B981);
      case GameMode.ai:
        return const Color(0xFF8B5CF6);
      case GameMode.online:
        return const Color(0xFF06B6D4);
      case GameMode.tournament:
        return const Color(0xFFF59E0B);
      case GameMode.practice:
        return const Color(0xFF84CC16);
      case GameMode.challenge:
        return const Color(0xFFEF4444);
      case GameMode.mission:
        return const Color(0xFF6366F1);
      case GameMode.tutorial:
        return const Color(0xFF14B8A6);
    }
  }

  static List<GameMode> get availableModes => [
    GameMode.singlePlayer,
    GameMode.multiPlayer,
    GameMode.ai,
    GameMode.online,
    GameMode.tournament,
    GameMode.practice,
    GameMode.challenge,
    GameMode.mission,
    GameMode.tutorial,
  ];

  static List<GameMode> get mainModes => [
    GameMode.singlePlayer,
    GameMode.multiPlayer,
    GameMode.ai,
    GameMode.online,
  ];

  static List<GameMode> get specialModes => [
    GameMode.tournament,
    GameMode.practice,
    GameMode.challenge,
    GameMode.mission,
  ];
}

/// مستويات الصعوبة
enum DifficultyLevel { easy, medium, hard, expert, impossible }

/// فئة لإدارة مستويات الصعوبة
class DifficultyManager {
  static String getLevelName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 'سهل';
      case DifficultyLevel.medium:
        return 'متوسط';
      case DifficultyLevel.hard:
        return 'صعب';
      case DifficultyLevel.expert:
        return 'خبير';
      case DifficultyLevel.impossible:
        return 'مستحيل';
    }
  }

  static String getLevelDescription(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 'مناسب للمبتدئين';
      case DifficultyLevel.medium:
        return 'متوسط الصعوبة';
      case DifficultyLevel.hard:
        return 'يتطلب خبرة';
      case DifficultyLevel.expert:
        return 'للمحترفين فقط';
      case DifficultyLevel.impossible:
        return 'تحدي الخبراء';
    }
  }

  static Color getLevelColor(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return const Color(0xFF10B981);
      case DifficultyLevel.medium:
        return const Color(0xFF3B82F6);
      case DifficultyLevel.hard:
        return const Color(0xFFF59E0B);
      case DifficultyLevel.expert:
        return const Color(0xFFEF4444);
      case DifficultyLevel.impossible:
        return const Color(0xFF7C3AED);
    }
  }

  static int getLevelStars(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 1;
      case DifficultyLevel.medium:
        return 2;
      case DifficultyLevel.hard:
        return 3;
      case DifficultyLevel.expert:
        return 4;
      case DifficultyLevel.impossible:
        return 5;
    }
  }

  static double getLevelMultiplier(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return 1.0;
      case DifficultyLevel.medium:
        return 1.5;
      case DifficultyLevel.hard:
        return 2.0;
      case DifficultyLevel.expert:
        return 3.0;
      case DifficultyLevel.impossible:
        return 5.0;
    }
  }
}

/// حالات اللعبة
enum GameState { waiting, playing, paused, finished, abandoned }

/// نتائج اللعبة
enum GameResult { win, lose, draw, abandoned }

/// أنواع الخصوم
enum OpponentType { human, ai, online, random }

/// فئة إعدادات اللعبة
class GameSettings {
  final GameMode mode;
  final DifficultyLevel? difficulty;
  final OpponentType opponentType;
  final bool soundEnabled;
  final bool musicEnabled;
  final bool animationsEnabled;
  final bool hintsEnabled;
  final Duration timeLimit;

  const GameSettings({
    required this.mode,
    this.difficulty,
    required this.opponentType,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.animationsEnabled = true,
    this.hintsEnabled = true,
    this.timeLimit = const Duration(minutes: 5),
  });

  GameSettings copyWith({
    GameMode? mode,
    DifficultyLevel? difficulty,
    OpponentType? opponentType,
    bool? soundEnabled,
    bool? musicEnabled,
    bool? animationsEnabled,
    bool? hintsEnabled,
    Duration? timeLimit,
  }) {
    return GameSettings(
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      opponentType: opponentType ?? this.opponentType,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      hintsEnabled: hintsEnabled ?? this.hintsEnabled,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.index,
      'difficulty': difficulty?.index,
      'opponentType': opponentType.index,
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'animationsEnabled': animationsEnabled,
      'hintsEnabled': hintsEnabled,
      'timeLimitMinutes': timeLimit.inMinutes,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      mode: GameMode.values[json['mode'] ?? 0],
      difficulty: json['difficulty'] != null
          ? DifficultyLevel.values[json['difficulty']]
          : null,
      opponentType: OpponentType.values[json['opponentType'] ?? 0],
      soundEnabled: json['soundEnabled'] ?? true,
      musicEnabled: json['musicEnabled'] ?? true,
      animationsEnabled: json['animationsEnabled'] ?? true,
      hintsEnabled: json['hintsEnabled'] ?? true,
      timeLimit: Duration(minutes: json['timeLimitMinutes'] ?? 5),
    );
  }

  static const GameSettings defaultSettings = GameSettings(
    mode: GameMode.singlePlayer,
    difficulty: DifficultyLevel.medium,
    opponentType: OpponentType.ai,
  );
}
