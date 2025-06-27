/// بيانات تجريبية لتسهيل اختبار التطبيق
class TestData {
  /// إحصائيات لاعب وهمية مبسطة
  static Map<String, dynamic> getMockPlayerStats() {
    return {
      'gamesPlayed': 147,
      'gamesWon': 89,
      'gamesLost': 43,
      'gamesDraw': 15,
      'winRate': 60.5,
      'currentStreak': 5,
      'bestStreak': 12,
      'totalPlayTime': 1250, // بالدقائق
      'favoriteLevel': 'صعب',
      'averageGameDuration': 8.5, // بالدقائق
      'easyWins': 25,
      'mediumWins': 35,
      'hardWins': 29,
      'xWins': 45,
      'oWins': 44,
    };
  }

  /// تاريخ ألعاب وهمي مبسط
  static List<Map<String, dynamic>> getMockGameHistory() {
    return [
      {
        'id': '1',
        'playerSymbol': 'X',
        'opponentSymbol': 'O',
        'opponentType': 'AI - صعب',
        'result': 'فوز',
        'duration': 7,
        'date': DateTime.now().subtract(Duration(hours: 2)),
        'winningPattern': [0, 1, 2],
        'boardState': ['X', 'X', 'X', 'O', 'O', '', '', '', ''],
      },
      {
        'id': '2',
        'playerSymbol': 'O',
        'opponentSymbol': 'X',
        'opponentType': 'AI - متوسط',
        'result': 'فوز',
        'duration': 5,
        'date': DateTime.now().subtract(Duration(hours: 4)),
        'winningPattern': [0, 3, 6],
        'boardState': ['O', 'X', '', 'O', 'X', '', 'O', '', ''],
      },
      {
        'id': '3',
        'playerSymbol': 'X',
        'opponentSymbol': 'O',
        'opponentType': 'AI - صعب',
        'result': 'خسارة',
        'duration': 12,
        'date': DateTime.now().subtract(Duration(hours: 6)),
        'winningPattern': [2, 5, 8],
        'boardState': ['X', 'X', 'O', '', 'X', 'O', '', '', 'O'],
      },
      {
        'id': '4',
        'playerSymbol': 'O',
        'opponentSymbol': 'X',
        'opponentType': 'AI - سهل',
        'result': 'فوز',
        'duration': 3,
        'date': DateTime.now().subtract(Duration(hours: 8)),
        'winningPattern': [1, 4, 7],
        'boardState': ['X', 'O', '', '', 'O', '', 'X', 'O', ''],
      },
      {
        'id': '5',
        'playerSymbol': 'X',
        'opponentSymbol': 'O',
        'opponentType': 'AI - متوسط',
        'result': 'تعادل',
        'duration': 9,
        'date': DateTime.now().subtract(Duration(days: 1)),
        'winningPattern': null,
        'boardState': ['X', 'O', 'X', 'O', 'X', 'O', 'O', 'X', 'O'],
      },
      {
        'id': '6',
        'playerSymbol': 'O',
        'opponentSymbol': 'X',
        'opponentType': 'AI - صعب',
        'result': 'فوز',
        'duration': 15,
        'date': DateTime.now().subtract(Duration(days: 1, hours: 3)),
        'winningPattern': [0, 4, 8],
        'boardState': ['O', 'X', 'X', 'X', 'O', '', '', '', 'O'],
      },
    ];
  }

  /// مهام وهمية مبسطة
  static List<Map<String, dynamic>> getMockMissions() {
    return [
      {
        'id': 'daily_1',
        'title': 'فوز سريع ⚡',
        'description': 'اربح لعبة في أقل من 5 دقائق',
        'type': 'يومية',
        'targetValue': 1,
        'currentProgress': 1,
        'reward': 50,
        'isCompleted': true,
        'expiryDate': DateTime.now().add(Duration(hours: 12)),
        'icon': '⚡',
      },
      {
        'id': 'daily_2',
        'title': 'متتالية انتصارات 🔥',
        'description': 'اربح 3 ألعاب متتالية',
        'type': 'يومية',
        'targetValue': 3,
        'currentProgress': 2,
        'reward': 75,
        'isCompleted': false,
        'expiryDate': DateTime.now().add(Duration(hours: 8)),
        'icon': '🔥',
      },
      {
        'id': 'weekly_1',
        'title': 'خبير الذكاء الاصطناعي 🤖',
        'description': 'اربح 10 ألعاب ضد الذكاء الاصطناعي الصعب',
        'type': 'أسبوعية',
        'targetValue': 10,
        'currentProgress': 7,
        'reward': 200,
        'isCompleted': false,
        'expiryDate': DateTime.now().add(Duration(days: 4)),
        'icon': '🤖',
      },
      {
        'id': 'weekly_2',
        'title': 'ماراثون الألعاب 🏃',
        'description': 'العب 25 لعبة هذا الأسبوع',
        'type': 'أسبوعية',
        'targetValue': 25,
        'currentProgress': 18,
        'reward': 150,
        'isCompleted': false,
        'expiryDate': DateTime.now().add(Duration(days: 2)),
        'icon': '🏃',
      },
      {
        'id': 'achievement_1',
        'title': 'أسطورة التيك تاك تو 👑',
        'description': 'اربح 100 لعبة إجمالي',
        'type': 'إنجاز',
        'targetValue': 100,
        'currentProgress': 89,
        'reward': 500,
        'isCompleted': false,
        'expiryDate': null,
        'icon': '👑',
      },
      {
        'id': 'achievement_2',
        'title': 'الفوز السريع 🏆',
        'description': 'اربح لعبة في أقل من دقيقتين',
        'type': 'إنجاز',
        'targetValue': 1,
        'currentProgress': 0,
        'reward': 100,
        'isCompleted': false,
        'expiryDate': null,
        'icon': '🏆',
      },
    ];
  }

  /// إنجازات وهمية مبسطة
  static List<Map<String, dynamic>> getMockAchievements() {
    return [
      {
        'id': 'first_win',
        'title': 'أول نصر 🥇',
        'description': 'اربح لعبتك الأولى',
        'icon': '🥇',
        'isUnlocked': true,
        'unlockedDate': DateTime.now().subtract(Duration(days: 30)),
        'category': 'اللعب',
      },
      {
        'id': 'speed_demon',
        'title': 'الشيطان السريع ⚡',
        'description': 'اربح لعبة في أقل من دقيقة',
        'icon': '⚡',
        'isUnlocked': true,
        'unlockedDate': DateTime.now().subtract(Duration(days: 15)),
        'category': 'السرعة',
      },
      {
        'id': 'ai_master',
        'title': 'سيد الذكاء الاصطناعي 🤖',
        'description': 'اربح 50 لعبة ضد الذكاء الاصطناعي الصعب',
        'icon': '🤖',
        'isUnlocked': false,
        'unlockedDate': null,
        'category': 'الصعوبة',
      },
      {
        'id': 'perfectionist',
        'title': 'المثالي ⭐',
        'description': 'اربح بدون خسارة أي خانة',
        'icon': '⭐',
        'isUnlocked': true,
        'unlockedDate': DateTime.now().subtract(Duration(days: 5)),
        'category': 'خاص',
      },
      {
        'id': 'marathon_player',
        'title': 'لاعب الماراثون 🕐',
        'description': 'العب لمدة 10 ساعات إجمالي',
        'icon': '🕐',
        'isUnlocked': false,
        'unlockedDate': null,
        'category': 'الوقت',
      },
      {
        'id': 'space_explorer',
        'title': 'مستكشف الفضاء 🚀',
        'description': 'جرب جميع ثيمات الفضاء',
        'icon': '🚀',
        'isUnlocked': false,
        'unlockedDate': null,
        'category': 'استكشاف',
      },
    ];
  }

  /// معدل الفوز حسب المستوى
  static Map<String, double> getWinRatesByLevel() {
    return {
      'سهل': 85.5,
      'متوسط': 62.3,
      'صعب': 45.8,
      'خبير': 28.2,
    };
  }

  /// إحصائيات الأداء
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'averageThinkingTime': 3.2, // ثواني
      'quickestWin': 45, // ثانية
      'longestGame': 25, // دقيقة
      'favoritePosition': 4, // الوسط
      'mostUsedStrategy': 'الدفاع ثم الهجوم',
      'peakPlayingHour': 20, // 8 مساءً
      'averageMovesPerGame': 7.8,
      'comebackWins': 12, // انتصارات بعد تأخر
      'cosmicThemeUsage': 78, // نسبة استخدام ثيم الفضاء
      'favoriteSpaceTheme': 'المجرة الحلزونية',
    };
  }

  /// نصائح وإرشادات فضائية
  static List<String> getSpaceGameTips() {
    return [
      '🌟 ابدأ بالمركز (النجم المركزي) للحصول على أفضل الفرص',
      '🪐 راقب الأركان - هي أقوى المواقع في المجرة',
      '🛡️ دافع أولاً! امنع العدو من غزو مجرتك',
      '⚡ في الفضاء العميق، فكر في خطوتين مقدماً',
      '🌌 استخدم استراتيجية "الثقب الأسود" لإنشاء فرصتين للفوز',
      '🚀 تدرب على أنماط الانتصار الكونية',
      '🔄 غير مسار سفينتك حسب نمط العدو',
      '⏰ في الفضاء، الصبر يقود إلى النجوم',
      '🌠 استخدم قوة الجاذبية لصالحك',
      '🛸 كن مستكشف فضاء ذكي، ليس مجرد لاعب',
    ];
  }

  /// بيانات لوحة القيادة الفضائية
  static Map<String, dynamic> getSpaceLeaderboardData() {
    return {
      'dailyRank': 15,
      'weeklyRank': 8,
      'allTimeRank': 42,
      'totalSpaceExplorers': 1250,
      'starsToNext': 85,
      'currentStars': 2340,
      'galaxyLevel': 'محارب النجوم',
      'nextGalaxyLevel': 'قائد المجرة',
      'cosmicRanking': 'مستكشف فضائي متقدم',
    };
  }

  /// ثيمات الفضاء المتاحة
  static List<Map<String, dynamic>> getSpaceThemes() {
    return [
      {
        'id': 'nebula',
        'name': 'سديم الألوان',
        'description': 'ألوان زاهية مثل السدم الكونية',
        'primaryColor': 0xFF6366F1,
        'secondaryColor': 0xFF06B6D4,
        'isUnlocked': true,
        'icon': '🌌',
      },
      {
        'id': 'galaxy',
        'name': 'المجرة الحلزونية',
        'description': 'ألوان المجرة الحلزونية الساحرة',
        'primaryColor': 0xFF8B5CF6,
        'secondaryColor': 0xFFEC4899,
        'isUnlocked': true,
        'icon': '🌀',
      },
      {
        'id': 'supernova',
        'name': 'انفجار النجم العملاق',
        'description': 'ألوان ساطعة مثل انفجار النجوم',
        'primaryColor': 0xFFEF4444,
        'secondaryColor': 0xFFF59E0B,
        'isUnlocked': false,
        'icon': '💥',
      },
      {
        'id': 'deep_space',
        'name': 'الفضاء العميق',
        'description': 'ألوان داكنة غامضة للفضاء البعيد',
        'primaryColor': 0xFF1E1B4B,
        'secondaryColor': 0xFF312E81,
        'isUnlocked': false,
        'icon': '🌑',
      },
      {
        'id': 'aurora',
        'name': 'الشفق القطبي الفضائي',
        'description': 'ألوان الشفق في الكواكب البعيدة',
        'primaryColor': 0xFF10B981,
        'secondaryColor': 0xFF06B6D4,
        'isUnlocked': false,
        'icon': '🌈',
      },
    ];
  }

  /// رسائل ترحيب فضائية
  static List<String> getSpaceWelcomeMessages() {
    return [
      '🚀 مرحباً أيها المستكشف الفضائي!',
      '🌟 استعد لرحلة عبر النجوم!',
      '🛸 المجرة تنتظر تحديك!',
      '🌌 ادخل إلى عالم التيك تاك تو الكوني!',
      '⭐ كن النجم اللامع في سماء اللعبة!',
    ];
  }

  /// أصوات فضائية (أسماء الملفات)
  static Map<String, String> getSpaceSounds() {
    return {
      'click': 'space_click.mp3',
      'win': 'cosmic_victory.mp3',
      'lose': 'asteroid_impact.mp3',
      'draw': 'nebula_calm.mp3',
      'background': 'space_ambient.mp3',
    };
  }
}
