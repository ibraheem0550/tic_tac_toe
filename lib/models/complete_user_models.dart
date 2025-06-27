// lib/models/complete_user_models.dart
/// نماذج المستخدم والإحصائيات الكاملة - تحتوي على جميع النماذج المطلوبة

/// مقدمي الخدمة للمصادقة
enum AuthProvider {
  email,
  google,
  facebook,
  apple,
  guest,
  googlePlay,
}

/// حالات طلب الصداقة
enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}

/// أنواع طرق الدفع
enum PaymentMethodType {
  creditCard,
  paypal,
  googlePay,
  applePay,
  stripe,
}

/// نموذج تفضيلات المستخدم
class UserPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final double masterVolume;
  final String language;
  final String theme;
  final bool autoSave;
  final bool shareData;

  const UserPreferences({
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.masterVolume = 0.8,
    this.language = 'ar',
    this.theme = 'stellar',
    this.autoSave = true,
    this.shareData = false,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      notificationsEnabled: json['notifications_enabled'] ?? true,
      soundEnabled: json['sound_enabled'] ?? true,
      vibrationEnabled: json['vibration_enabled'] ?? true,
      masterVolume: (json['master_volume'] ?? 0.8).toDouble(),
      language: json['language'] ?? 'ar',
      theme: json['theme'] ?? 'stellar',
      autoSave: json['auto_save'] ?? true,
      shareData: json['share_data'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'master_volume': masterVolume,
      'language': language,
      'theme': theme,
      'auto_save': autoSave,
      'share_data': shareData,
    };
  }
}

/// نموذج إحصائيات اللعبة الشامل
class GameStats {
  final String userId;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final int streak;
  final int bestStreak;
  final Map<String, int> modeStats;
  final Map<String, int> difficultyStats;
  final DateTime lastUpdated;
  final int totalPlayTime;
  final List<Achievement> achievements;
  final Map<String, dynamic> additionalData;

  const GameStats({
    required this.userId,
    this.totalGames = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.streak = 0,
    this.bestStreak = 0,
    this.modeStats = const {},
    this.difficultyStats = const {},
    required this.lastUpdated,
    this.totalPlayTime = 0,
    this.achievements = const [],
    this.additionalData = const {},
  });

  /// نسبة الفوز
  double get winRate {
    if (totalGames == 0) return 0.0;
    return (wins / totalGames) * 100;
  }

  /// أفضل سلسلة انتصارات (مرادف لـ bestStreak)
  int get bestWinStreak => bestStreak;

  /// متوسط وقت اللعبة (بالثواني)
  double get averageGameTime {
    if (totalGames == 0) return 0.0;
    return totalPlayTime / totalGames;
  }

  /// متوسط مدة اللعبة - مرادف لـ averageGameTime للتوافق مع الإصدارات السابقة
  double get averageGameDuration {
    return averageGameTime;
  }

  /// سلسلة الانتصارات الحالية - مرادف لـ streak للتوافق مع الإصدارات السابقة
  int get currentWinStreak {
    return streak;
  }

  /// إحصائيات الصعوبة (مرادف لـ difficultyStats)
  Map<String, int> get difficultyGames => difficultyStats;

  /// إنشاء من JSON
  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      userId: json['user_id'] ?? json['userId'] ?? '',
      totalGames: json['total_games'] ?? json['totalGames'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      streak: json['streak'] ?? 0,
      bestStreak: json['best_streak'] ?? json['bestStreak'] ?? 0,
      modeStats:
          Map<String, int>.from(json['mode_stats'] ?? json['modeStats'] ?? {}),
      difficultyStats: Map<String, int>.from(
          json['difficulty_stats'] ?? json['difficultyStats'] ?? {}),
      lastUpdated: DateTime.tryParse(
              json['last_updated'] ?? json['lastUpdated'] ?? '') ??
          DateTime.now(),
      totalPlayTime: json['total_play_time'] ?? json['totalPlayTime'] ?? 0,
      achievements: (json['achievements'] as List?)
              ?.map((a) => Achievement.fromJson(a))
              .toList() ??
          [],
      additionalData: Map<String, dynamic>.from(
          json['additional_data'] ?? json['additionalData'] ?? {}),
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_games': totalGames,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'streak': streak,
      'best_streak': bestStreak,
      'mode_stats': modeStats,
      'difficulty_stats': difficultyStats,
      'last_updated': lastUpdated.toIso8601String(),
      'total_play_time': totalPlayTime,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'additional_data': additionalData,
    };
  }

  /// نسخ مع تعديلات
  GameStats copyWith({
    String? userId,
    int? totalGames,
    int? wins,
    int? losses,
    int? draws,
    int? streak,
    int? bestStreak,
    Map<String, int>? modeStats,
    Map<String, int>? difficultyStats,
    DateTime? lastUpdated,
    int? totalPlayTime,
    List<Achievement>? achievements,
    Map<String, dynamic>? additionalData,
  }) {
    return GameStats(
      userId: userId ?? this.userId,
      totalGames: totalGames ?? this.totalGames,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      modeStats: modeStats ?? this.modeStats,
      difficultyStats: difficultyStats ?? this.difficultyStats,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      achievements: achievements ?? this.achievements,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// إنشاء إحصائيات فارغة
  factory GameStats.empty(String userId) {
    return GameStats(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
  }

  /// تسجيل نتيجة لعبة جديدة
  GameStats recordGame(String result, {String? gameMode, String? difficulty}) {
    final newModeStats = Map<String, int>.from(modeStats);
    final newDifficultyStats = Map<String, int>.from(difficultyStats);

    // تحديث إحصائيات وضع اللعب
    if (gameMode != null) {
      newModeStats[gameMode] = (newModeStats[gameMode] ?? 0) + 1;
    }

    // تحديث إحصائيات مستوى الصعوبة
    if (difficulty != null) {
      newDifficultyStats[difficulty] =
          (newDifficultyStats[difficulty] ?? 0) + 1;
    }

    int newWins = wins;
    int newLosses = losses;
    int newDraws = draws;
    int newStreak = streak;
    int newBestStreak = bestStreak;

    switch (result.toLowerCase()) {
      case 'win':
        newWins++;
        newStreak++;
        if (newStreak > newBestStreak) {
          newBestStreak = newStreak;
        }
        break;
      case 'loss':
        newLosses++;
        newStreak = 0;
        break;
      case 'draw':
        newDraws++;
        break;
    }

    return copyWith(
      totalGames: totalGames + 1,
      wins: newWins,
      losses: newLosses,
      draws: newDraws,
      streak: newStreak,
      bestStreak: newBestStreak,
      modeStats: newModeStats,
      difficultyStats: newDifficultyStats,
      lastUpdated: DateTime.now(),
    );
  }
}

/// نموذج ملف تعريف المستخدم
class UserProfile {
  final String? bio;
  final String? location;
  final String? website;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final UserPreferences preferences;
  final GameStats gameStats;

  const UserProfile({
    this.bio,
    this.location,
    this.website,
    this.dateOfBirth,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.preferences,
    required this.gameStats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'])
          : null,
      phoneNumber: json['phone_number'],
      isEmailVerified: json['is_email_verified'] ?? false,
      isPhoneVerified: json['is_phone_verified'] ?? false,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      gameStats: GameStats.fromJson(json['game_stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bio': bio,
      'location': location,
      'website': website,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'preferences': preferences.toJson(),
      'game_stats': gameStats.toJson(),
    };
  }

  /// نسخ مع تعديلات
  UserProfile copyWith({
    String? bio,
    String? location,
    String? website,
    DateTime? dateOfBirth,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    UserPreferences? preferences,
    GameStats? gameStats,
  }) {
    return UserProfile(
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      preferences: preferences ?? this.preferences,
      gameStats: gameStats ?? this.gameStats,
    );
  }
}

/// نموذج المستخدم الشامل
class User {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final AuthProvider provider;

  // إعدادات المستخدم
  final int gems;
  final int level;
  final int experience;
  final List<String> achievements;
  final Map<String, dynamic> settings;

  // بيانات إضافية
  final String? phoneNumber;
  final bool isVerified;
  final String? bio;
  final Map<String, dynamic> preferences;
  final List<AuthProvider> linkedProviders;
  final List<LinkedAccount> linkedAccounts;
  final UserProfile? profile;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.isGuest = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.provider = AuthProvider.email,
    this.gems = 0,
    this.level = 1,
    this.experience = 0,
    this.achievements = const [],
    this.settings = const {},
    this.phoneNumber,
    this.isVerified = false,
    this.bio,
    this.preferences = const {},
    this.linkedProviders = const [],
    this.linkedAccounts = const [],
    this.profile,
  });

  /// إنشاء مستخدم من JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? 'مستخدم',
      photoURL: json['photo_url'] ?? json['photoURL'],
      isGuest: json['is_guest'] ?? json['isGuest'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      lastLoginAt:
          DateTime.tryParse(json['last_login_at'] ?? '') ?? DateTime.now(),
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AuthProvider.email,
      ),
      gems: json['gems'] ?? 0,
      level: json['level'] ?? 1,
      experience: json['experience'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      phoneNumber: json['phone_number'] ?? json['phoneNumber'],
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      bio: json['bio'],
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      linkedProviders: (json['linked_providers'] as List?)
              ?.map((p) => AuthProvider.values.firstWhere((ap) => ap.name == p,
                  orElse: () => AuthProvider.email))
              .toList() ??
          [],
      linkedAccounts: (json['linked_accounts'] as List?)
              ?.map((a) => LinkedAccount.fromJson(a))
              .toList() ??
          [],
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoURL,
      'is_guest': isGuest,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt.toIso8601String(),
      'provider': provider.name,
      'gems': gems,
      'level': level,
      'experience': experience,
      'achievements': achievements,
      'settings': settings,
      'phone_number': phoneNumber,
      'is_verified': isVerified,
      'bio': bio,
      'preferences': preferences,
      'linked_providers': linkedProviders.map((p) => p.name).toList(),
      'linked_accounts': linkedAccounts.map((a) => a.toJson()).toList(),
      'profile': profile?.toJson(),
    };
  }

  /// نسخ مع تعديلات
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isGuest,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    AuthProvider? provider,
    int? gems,
    int? level,
    int? experience,
    List<String>? achievements,
    Map<String, dynamic>? settings,
    String? phoneNumber,
    bool? isVerified,
    String? bio,
    Map<String, dynamic>? preferences,
    List<AuthProvider>? linkedProviders,
    List<LinkedAccount>? linkedAccounts,
    UserProfile? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      provider: provider ?? this.provider,
      gems: gems ?? this.gems,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      linkedProviders: linkedProviders ?? this.linkedProviders,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      profile: profile ?? this.profile,
    );
  }

  /// إنشاء مستخدم ضيف
  factory User.guest() {
    final now = DateTime.now();
    return User(
      id: 'guest_${now.millisecondsSinceEpoch}',
      email: '',
      displayName: 'ضيف',
      isGuest: true,
      createdAt: now,
      lastLoginAt: now,
      provider: AuthProvider.guest,
    );
  }
}

/// نموذج الحساب المرتبط
class LinkedAccount {
  final String id;
  final AuthProvider provider;
  final String email;
  final String? displayName;
  final DateTime connectedAt;
  final bool isActive;

  const LinkedAccount({
    required this.id,
    required this.provider,
    required this.email,
    this.displayName,
    required this.connectedAt,
    this.isActive = true,
  });

  factory LinkedAccount.fromJson(Map<String, dynamic> json) {
    return LinkedAccount(
      id: json['id'] ?? '',
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == json['provider'],
        orElse: () => AuthProvider.email,
      ),
      email: json['email'] ?? '',
      displayName: json['display_name'],
      connectedAt:
          DateTime.tryParse(json['connected_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider.name,
      'email': email,
      'display_name': displayName,
      'connected_at': connectedAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}

/// نموذج الإنجاز
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final DateTime unlockedAt;
  final int points;
  final String category;
  final Map<String, dynamic> metadata;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.unlockedAt,
    this.points = 0,
    this.category = 'general',
    this.metadata = const {},
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? json['iconName'] ?? 'star',
      unlockedAt:
          DateTime.tryParse(json['unlocked_at'] ?? json['unlockedAt'] ?? '') ??
              DateTime.now(),
      points: json['points'] ?? 0,
      category: json['category'] ?? 'general',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'unlocked_at': unlockedAt.toIso8601String(),
      'points': points,
      'category': category,
      'metadata': metadata,
    };
  }
}

/// نموذج تسجيل اللعبة
class GameRecord {
  final String id;
  final String userId;
  final String gameMode;
  final String difficulty;
  final String result;
  final int duration;
  final DateTime playedAt;
  final Map<String, dynamic> gameData;
  final int pointsEarned;

  const GameRecord({
    required this.id,
    required this.userId,
    required this.gameMode,
    required this.difficulty,
    required this.result,
    required this.duration,
    required this.playedAt,
    this.gameData = const {},
    this.pointsEarned = 0,
  });

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? json['userId'] ?? '',
      gameMode: json['game_mode'] ?? json['gameMode'] ?? 'local',
      difficulty: json['difficulty'] ?? 'medium',
      result: json['result'] ?? 'draw',
      duration: json['duration'] ?? 0,
      playedAt:
          DateTime.tryParse(json['played_at'] ?? json['playedAt'] ?? '') ??
              DateTime.now(),
      gameData: Map<String, dynamic>.from(
          json['game_data'] ?? json['gameData'] ?? {}),
      pointsEarned: json['points_earned'] ?? json['pointsEarned'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'game_mode': gameMode,
      'difficulty': difficulty,
      'result': result,
      'duration': duration,
      'played_at': playedAt.toIso8601String(),
      'game_data': gameData,
      'points_earned': pointsEarned,
    };
  }
}

/// نموذج صديق
class Friend {
  final String id;
  final String displayName;
  final String? photoURL;
  final bool isOnline;
  final DateTime lastSeen;
  final Map<String, dynamic> gameStats;
  final String status;

  const Friend({
    required this.id,
    required this.displayName,
    this.photoURL,
    this.isOnline = false,
    required this.lastSeen,
    this.gameStats = const {},
    this.status = 'offline',
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? '',
      displayName: json['display_name'] ?? json['displayName'] ?? 'صديق',
      photoURL: json['photo_url'] ?? json['photoURL'],
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
      lastSeen:
          DateTime.tryParse(json['last_seen'] ?? json['lastSeen'] ?? '') ??
              DateTime.now(),
      gameStats: Map<String, dynamic>.from(
          json['game_stats'] ?? json['gameStats'] ?? {}),
      status: json['status'] ?? 'offline',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'photo_url': photoURL,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
      'game_stats': gameStats,
      'status': status,
    };
  }
}

/// نموذج طلب الصداقة
class FriendRequest {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final User? fromUser;
  final User? toUser;

  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
    this.fromUser,
    this.toUser,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? '',
      fromUserId: json['from_user_id'] ?? json['fromUserId'] ?? '',
      toUserId: json['to_user_id'] ?? json['toUserId'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
      respondedAt: json['responded_at'] != null
          ? DateTime.tryParse(json['responded_at'])
          : null,
      fromUser:
          json['from_user'] != null ? User.fromJson(json['from_user']) : null,
      toUser: json['to_user'] != null ? User.fromJson(json['to_user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'responded_at': respondedAt?.toIso8601String(),
      'from_user': fromUser?.toJson(),
      'to_user': toUser?.toJson(),
    };
  }
}

/// نموذج تحدي
class Challenge {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String gameMode;
  final String difficulty;
  final String status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> settings;

  const Challenge({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.gameMode,
    required this.difficulty,
    this.status = 'pending',
    required this.createdAt,
    this.expiresAt,
    this.settings = const {},
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] ?? '',
      fromUserId: json['from_user_id'] ?? json['fromUserId'] ?? '',
      toUserId: json['to_user_id'] ?? json['toUserId'] ?? '',
      gameMode: json['game_mode'] ?? json['gameMode'] ?? 'local',
      difficulty: json['difficulty'] ?? 'medium',
      status: json['status'] ?? 'pending',
      createdAt:
          DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? '') ??
              DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'game_mode': gameMode,
      'difficulty': difficulty,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'settings': settings,
    };
  }
}
