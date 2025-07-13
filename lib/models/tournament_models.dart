/// نماذج بيانات المسابقات والبطولات النجمية
library tournament_models;

enum TournamentType {
  knockout, // خروج المغلوب
  roundRobin, // الدوري
  swiss, // السويسري
  bracket, // الأقواس
}

enum TournamentStatus {
  upcoming, // قادمة
  registration, // التسجيل مفتوح
  inProgress, // جارية
  completed, // مكتملة
  cancelled, // ملغية
}

enum TournamentFormat {
  classic, // كلاسيكي
  blitz, // خاطف
  bullet, // سريع
  ultraBullet, // سريع جداً
}

class Tournament {
  final String id;
  final String name;
  final String description;
  final TournamentType type;
  final TournamentStatus status;
  final TournamentFormat format;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime registrationDeadline;
  final int maxParticipants;
  final int currentParticipants;
  final double entryFee; // رسوم الدخول بالجواهر
  final Map<int, TournamentReward> rewards; // الجوائز حسب المرتبة
  final List<String> participantIds;
  final List<TournamentMatch> matches;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final String createdBy;

  const Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.registrationDeadline,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.entryFee = 0,
    this.rewards = const {},
    this.participantIds = const [],
    this.matches = const [],
    this.settings = const {},
    required this.createdAt,
    required this.createdBy,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: TournamentType.values.byName(json['type']),
      status: TournamentStatus.values.byName(json['status']),
      format: TournamentFormat.values.byName(json['format']),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      registrationDeadline: DateTime.parse(json['registrationDeadline']),
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'] ?? 0,
      entryFee: json['entryFee']?.toDouble() ?? 0,
      rewards: (json['rewards'] as Map<String, dynamic>? ?? {}).map(
          (key, value) =>
              MapEntry(int.parse(key), TournamentReward.fromJson(value))),
      participantIds: List<String>.from(json['participantIds'] ?? []),
      matches: (json['matches'] as List? ?? [])
          .map((match) => TournamentMatch.fromJson(match))
          .toList(),
      settings: json['settings'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'status': status.name,
      'format': format.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'entryFee': entryFee,
      'rewards':
          rewards.map((key, value) => MapEntry(key.toString(), value.toJson())),
      'participantIds': participantIds,
      'matches': matches.map((match) => match.toJson()).toList(),
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Tournament copyWith({
    String? name,
    String? description,
    TournamentType? type,
    TournamentStatus? status,
    TournamentFormat? format,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    int? maxParticipants,
    int? currentParticipants,
    double? entryFee,
    Map<int, TournamentReward>? rewards,
    List<String>? participantIds,
    List<TournamentMatch>? matches,
    Map<String, dynamic>? settings,
  }) {
    return Tournament(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      entryFee: entryFee ?? this.entryFee,
      rewards: rewards ?? this.rewards,
      participantIds: participantIds ?? this.participantIds,
      matches: matches ?? this.matches,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }

  // دوال مساعدة
  bool get canRegister =>
      status == TournamentStatus.registration &&
      currentParticipants < maxParticipants &&
      DateTime.now().isBefore(registrationDeadline);

  bool get isActive => status == TournamentStatus.inProgress;

  bool get isCompleted => status == TournamentStatus.completed;

  double get progressPercentage =>
      maxParticipants > 0 ? (currentParticipants / maxParticipants) * 100 : 0;

  String get formatDisplayName {
    switch (format) {
      case TournamentFormat.classic:
        return 'كلاسيكي';
      case TournamentFormat.blitz:
        return 'خاطف';
      case TournamentFormat.bullet:
        return 'سريع';
      case TournamentFormat.ultraBullet:
        return 'سريع جداً';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case TournamentType.knockout:
        return 'خروج المغلوب';
      case TournamentType.roundRobin:
        return 'الدوري';
      case TournamentType.swiss:
        return 'السويسري';
      case TournamentType.bracket:
        return 'الأقواس';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TournamentStatus.upcoming:
        return 'قادمة';
      case TournamentStatus.registration:
        return 'التسجيل مفتوح';
      case TournamentStatus.inProgress:
        return 'جارية';
      case TournamentStatus.completed:
        return 'مكتملة';
      case TournamentStatus.cancelled:
        return 'ملغية';
    }
  }
}

class TournamentReward {
  final int position;
  final double gems;
  final double coins;
  final String? badgeId;
  final String? titleId;
  final Map<String, dynamic> additionalRewards;

  const TournamentReward({
    required this.position,
    this.gems = 0,
    this.coins = 0,
    this.badgeId,
    this.titleId,
    this.additionalRewards = const {},
  });

  factory TournamentReward.fromJson(Map<String, dynamic> json) {
    return TournamentReward(
      position: json['position'],
      gems: json['gems']?.toDouble() ?? 0,
      coins: json['coins']?.toDouble() ?? 0,
      badgeId: json['badgeId'],
      titleId: json['titleId'],
      additionalRewards: json['additionalRewards'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'position': position,
      'gems': gems,
      'coins': coins,
      'badgeId': badgeId,
      'titleId': titleId,
      'additionalRewards': additionalRewards,
    };
  }
}

class TournamentMatch {
  final String id;
  final String tournamentId;
  final String player1Id;
  final String player2Id;
  final String? winnerId;
  final int round;
  final int? player1Score;
  final int? player2Score;
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final MatchStatus status;
  final List<String> gameIds; // IDs of individual games in the match

  const TournamentMatch({
    required this.id,
    required this.tournamentId,
    required this.player1Id,
    required this.player2Id,
    this.winnerId,
    required this.round,
    this.player1Score,
    this.player2Score,
    this.scheduledTime,
    this.startTime,
    this.endTime,
    this.status = MatchStatus.scheduled,
    this.gameIds = const [],
  });

  factory TournamentMatch.fromJson(Map<String, dynamic> json) {
    return TournamentMatch(
      id: json['id'],
      tournamentId: json['tournamentId'],
      player1Id: json['player1Id'],
      player2Id: json['player2Id'],
      winnerId: json['winnerId'],
      round: json['round'],
      player1Score: json['player1Score'],
      player2Score: json['player2Score'],
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.parse(json['scheduledTime'])
          : null,
      startTime:
          json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      status: MatchStatus.values.byName(json['status']),
      gameIds: List<String>.from(json['gameIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'player1Id': player1Id,
      'player2Id': player2Id,
      'winnerId': winnerId,
      'round': round,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'scheduledTime': scheduledTime?.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.name,
      'gameIds': gameIds,
    };
  }
}

enum MatchStatus {
  scheduled, // مجدولة
  inProgress, // جارية
  completed, // مكتملة
  cancelled, // ملغية
  walkover, // انسحاب
}

class TournamentParticipant {
  final String userId;
  final String tournamentId;
  final DateTime registrationTime;
  final int currentRound;
  final int wins;
  final int losses;
  final int draws;
  final double score;
  final int ranking;
  final bool isEliminated;
  final Map<String, dynamic> additionalStats;

  const TournamentParticipant({
    required this.userId,
    required this.tournamentId,
    required this.registrationTime,
    this.currentRound = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.score = 0,
    this.ranking = 0,
    this.isEliminated = false,
    this.additionalStats = const {},
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      userId: json['userId'],
      tournamentId: json['tournamentId'],
      registrationTime: DateTime.parse(json['registrationTime']),
      currentRound: json['currentRound'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      score: json['score']?.toDouble() ?? 0,
      ranking: json['ranking'] ?? 0,
      isEliminated: json['isEliminated'] ?? false,
      additionalStats: json['additionalStats'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tournamentId': tournamentId,
      'registrationTime': registrationTime.toIso8601String(),
      'currentRound': currentRound,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'score': score,
      'ranking': ranking,
      'isEliminated': isEliminated,
      'additionalStats': additionalStats,
    };
  }

  int get totalGames => wins + losses + draws;

  double get winRate => totalGames > 0 ? wins / totalGames : 0;
}
