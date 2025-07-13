/// نموذج إحصائيات اللعبة المحسن - يحتوي على جميع الخصائص المطلوبة
library enhanced_game_stats;

import 'game_mode_models.dart';

/// نموذج إحصائيات اللعبة الشامل والمحسن
class EnhancedGameStats {
  final String userId;

  // الإحصائيات الأساسية
  int totalGamesPlayed;
  int totalWins;
  int totalLosses;
  int totalDraws;
  int currentWinStreak;
  int bestWinStreak;

  // إحصائيات الحركات
  int totalMoves;
  int bestMoves;

  // إحصائيات الوقت
  int totalPlayTime; // بالثواني
  int fastestWin; // بالثواني
  DateTime lastPlayedAt;

  // إحصائيات النقاط والتجربة
  int totalCoinsEarned;
  int totalXpEarned;

  // إحصائيات أنماط اللعب
  int aiGamesPlayed;
  int aiWins;
  int localGamesPlayed;
  int localWins;
  int onlineGamesPlayed;
  int onlineWins;
  int tournamentGamesPlayed;
  int tournamentWins;

  // إحصائيات مستويات الصعوبة
  int easyGamesPlayed;
  int easyWins;
  int mediumGamesPlayed;
  int mediumWins;
  int hardGamesPlayed;
  int hardWins;
  int expertGamesPlayed;
  int expertWins;

  final DateTime createdAt;
  final DateTime lastUpdated;

  EnhancedGameStats({
    required this.userId,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalDraws = 0,
    this.currentWinStreak = 0,
    this.bestWinStreak = 0,
    this.totalMoves = 0,
    this.bestMoves = 0,
    this.totalPlayTime = 0,
    this.fastestWin = 0,
    DateTime? lastPlayedAt,
    this.totalCoinsEarned = 0,
    this.totalXpEarned = 0,
    this.aiGamesPlayed = 0,
    this.aiWins = 0,
    this.localGamesPlayed = 0,
    this.localWins = 0,
    this.onlineGamesPlayed = 0,
    this.onlineWins = 0,
    this.tournamentGamesPlayed = 0,
    this.tournamentWins = 0,
    this.easyGamesPlayed = 0,
    this.easyWins = 0,
    this.mediumGamesPlayed = 0,
    this.mediumWins = 0,
    this.hardGamesPlayed = 0,
    this.hardWins = 0,
    this.expertGamesPlayed = 0,
    this.expertWins = 0,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) : lastPlayedAt = lastPlayedAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();

  /// نسبة الفوز العامة
  double get winRate {
    if (totalGamesPlayed == 0) return 0.0;
    return (totalWins / totalGamesPlayed) * 100;
  }

  /// متوسط وقت اللعبة
  double get averageGameTime {
    if (totalGamesPlayed == 0) return 0.0;
    return totalPlayTime / totalGamesPlayed;
  }

  /// متوسط عدد الحركات لكل لعبة
  double get averageMoves {
    if (totalGamesPlayed == 0) return 0.0;
    return totalMoves / totalGamesPlayed;
  }

  /// نسبة الفوز ضد الذكاء الاصطناعي
  double get aiWinRate {
    if (aiGamesPlayed == 0) return 0.0;
    return (aiWins / aiGamesPlayed) * 100;
  }

  /// نسبة الفوز في الألعاب المحلية
  double get localWinRate {
    if (localGamesPlayed == 0) return 0.0;
    return (localWins / localGamesPlayed) * 100;
  }

  /// نسبة الفوز في الألعاب الأونلاين
  double get onlineWinRate {
    if (onlineGamesPlayed == 0) return 0.0;
    return (onlineWins / onlineGamesPlayed) * 100;
  }

  /// تسجيل نتيجة لعبة جديدة
  void recordGame({
    required String result, // 'win', 'loss', 'draw'
    required GameMode gameMode,
    required DifficultyLevel difficulty,
    int moves = 0,
    int playTime = 0,
    int coinsEarned = 0,
    int xpEarned = 0,
  }) {
    totalGamesPlayed++;
    totalMoves += moves;
    totalPlayTime += playTime;
    totalCoinsEarned += coinsEarned;
    totalXpEarned += xpEarned;
    lastPlayedAt = DateTime.now();

    // تحديث أفضل عدد حركات
    if (bestMoves == 0 || (moves > 0 && moves < bestMoves)) {
      bestMoves = moves;
    }

    // تسجيل النتيجة
    switch (result.toLowerCase()) {
      case 'win':
        totalWins++;
        currentWinStreak++;
        if (currentWinStreak > bestWinStreak) {
          bestWinStreak = currentWinStreak;
        }

        // تحديث أسرع فوز
        if (fastestWin == 0 || (playTime > 0 && playTime < fastestWin)) {
          fastestWin = playTime;
        }
        break;

      case 'loss':
        totalLosses++;
        currentWinStreak = 0;
        break;

      case 'draw':
        totalDraws++;
        currentWinStreak = 0;
        break;
    }

    // تحديث إحصائيات وضع اللعب
    switch (gameMode) {
      case GameMode.ai:
        aiGamesPlayed++;
        if (result == 'win') aiWins++;
        break;
      case GameMode.singlePlayer:
      case GameMode.multiPlayer:
        localGamesPlayed++;
        if (result == 'win') localWins++;
        break;
      case GameMode.online:
        onlineGamesPlayed++;
        if (result == 'win') onlineWins++;
        break;
      case GameMode.tournament:
        tournamentGamesPlayed++;
        if (result == 'win') tournamentWins++;
        break;
      default:
        break;
    }

    // تحديث إحصائيات مستوى الصعوبة
    switch (difficulty) {
      case DifficultyLevel.easy:
        easyGamesPlayed++;
        if (result == 'win') easyWins++;
        break;
      case DifficultyLevel.medium:
        mediumGamesPlayed++;
        if (result == 'win') mediumWins++;
        break;
      case DifficultyLevel.hard:
        hardGamesPlayed++;
        if (result == 'win') hardWins++;
        break;
      case DifficultyLevel.expert:
        expertGamesPlayed++;
        if (result == 'win') expertWins++;
        break;
      default:
        break;
    }
  }

  /// إنشاء من JSON
  factory EnhancedGameStats.fromJson(Map<String, dynamic> json) {
    return EnhancedGameStats(
      userId: json['userId'] ?? '',
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      totalDraws: json['totalDraws'] ?? 0,
      currentWinStreak: json['currentWinStreak'] ?? 0,
      bestWinStreak: json['bestWinStreak'] ?? 0,
      totalMoves: json['totalMoves'] ?? 0,
      bestMoves: json['bestMoves'] ?? 0,
      totalPlayTime: json['totalPlayTime'] ?? 0,
      fastestWin: json['fastestWin'] ?? 0,
      lastPlayedAt:
          DateTime.tryParse(json['lastPlayedAt'] ?? '') ?? DateTime.now(),
      totalCoinsEarned: json['totalCoinsEarned'] ?? 0,
      totalXpEarned: json['totalXpEarned'] ?? 0,
      aiGamesPlayed: json['aiGamesPlayed'] ?? 0,
      aiWins: json['aiWins'] ?? 0,
      localGamesPlayed: json['localGamesPlayed'] ?? 0,
      localWins: json['localWins'] ?? 0,
      onlineGamesPlayed: json['onlineGamesPlayed'] ?? 0,
      onlineWins: json['onlineWins'] ?? 0,
      tournamentGamesPlayed: json['tournamentGamesPlayed'] ?? 0,
      tournamentWins: json['tournamentWins'] ?? 0,
      easyGamesPlayed: json['easyGamesPlayed'] ?? 0,
      easyWins: json['easyWins'] ?? 0,
      mediumGamesPlayed: json['mediumGamesPlayed'] ?? 0,
      mediumWins: json['mediumWins'] ?? 0,
      hardGamesPlayed: json['hardGamesPlayed'] ?? 0,
      hardWins: json['hardWins'] ?? 0,
      expertGamesPlayed: json['expertGamesPlayed'] ?? 0,
      expertWins: json['expertWins'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      lastUpdated:
          DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'totalDraws': totalDraws,
      'currentWinStreak': currentWinStreak,
      'bestWinStreak': bestWinStreak,
      'totalMoves': totalMoves,
      'bestMoves': bestMoves,
      'totalPlayTime': totalPlayTime,
      'fastestWin': fastestWin,
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'totalCoinsEarned': totalCoinsEarned,
      'totalXpEarned': totalXpEarned,
      'aiGamesPlayed': aiGamesPlayed,
      'aiWins': aiWins,
      'localGamesPlayed': localGamesPlayed,
      'localWins': localWins,
      'onlineGamesPlayed': onlineGamesPlayed,
      'onlineWins': onlineWins,
      'tournamentGamesPlayed': tournamentGamesPlayed,
      'tournamentWins': tournamentWins,
      'easyGamesPlayed': easyGamesPlayed,
      'easyWins': easyWins,
      'mediumGamesPlayed': mediumGamesPlayed,
      'mediumWins': mediumWins,
      'hardGamesPlayed': hardGamesPlayed,
      'hardWins': hardWins,
      'expertGamesPlayed': expertGamesPlayed,
      'expertWins': expertWins,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// نسخ مع تعديلات
  EnhancedGameStats copyWith({
    String? userId,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalLosses,
    int? totalDraws,
    int? currentWinStreak,
    int? bestWinStreak,
    int? totalMoves,
    int? bestMoves,
    int? totalPlayTime,
    int? fastestWin,
    DateTime? lastPlayedAt,
    int? totalCoinsEarned,
    int? totalXpEarned,
    int? aiGamesPlayed,
    int? aiWins,
    int? localGamesPlayed,
    int? localWins,
    int? onlineGamesPlayed,
    int? onlineWins,
    int? tournamentGamesPlayed,
    int? tournamentWins,
    int? easyGamesPlayed,
    int? easyWins,
    int? mediumGamesPlayed,
    int? mediumWins,
    int? hardGamesPlayed,
    int? hardWins,
    int? expertGamesPlayed,
    int? expertWins,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return EnhancedGameStats(
      userId: userId ?? this.userId,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalDraws: totalDraws ?? this.totalDraws,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      bestWinStreak: bestWinStreak ?? this.bestWinStreak,
      totalMoves: totalMoves ?? this.totalMoves,
      bestMoves: bestMoves ?? this.bestMoves,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      fastestWin: fastestWin ?? this.fastestWin,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      aiGamesPlayed: aiGamesPlayed ?? this.aiGamesPlayed,
      aiWins: aiWins ?? this.aiWins,
      localGamesPlayed: localGamesPlayed ?? this.localGamesPlayed,
      localWins: localWins ?? this.localWins,
      onlineGamesPlayed: onlineGamesPlayed ?? this.onlineGamesPlayed,
      onlineWins: onlineWins ?? this.onlineWins,
      tournamentGamesPlayed:
          tournamentGamesPlayed ?? this.tournamentGamesPlayed,
      tournamentWins: tournamentWins ?? this.tournamentWins,
      easyGamesPlayed: easyGamesPlayed ?? this.easyGamesPlayed,
      easyWins: easyWins ?? this.easyWins,
      mediumGamesPlayed: mediumGamesPlayed ?? this.mediumGamesPlayed,
      mediumWins: mediumWins ?? this.mediumWins,
      hardGamesPlayed: hardGamesPlayed ?? this.hardGamesPlayed,
      hardWins: hardWins ?? this.hardWins,
      expertGamesPlayed: expertGamesPlayed ?? this.expertGamesPlayed,
      expertWins: expertWins ?? this.expertWins,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// إنشاء إحصائيات فارغة لمستخدم جديد
  factory EnhancedGameStats.empty(String userId) {
    return EnhancedGameStats(userId: userId);
  }
}
