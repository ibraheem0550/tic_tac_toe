import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament_models.dart';
import '../utils/logger.dart';

/// خدمة إدارة المسابقات والبطولات النجمية
class TournamentService {
  static final TournamentService _instance = TournamentService._internal();
  factory TournamentService() => _instance;
  TournamentService._internal();

  final String _tournamentsKey = 'stellar_tournaments';
  final String _participantsKey = 'tournament_participants';
  final Random _random = Random();

  /// توليد ID فريد بسيط
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = _random.nextInt(999999);
    return '${timestamp}_$randomNumber';
  }

  List<Tournament> _tournaments = [];
  Map<String, List<TournamentParticipant>> _participants = {};

  // إحصائيات المسابقات
  Map<String, dynamic> _tournamentStats = {
    'totalTournaments': 0,
    'activeTournaments': 0,
    'totalParticipants': 0,
    'completedTournaments': 0,
  };

  /// تهيئة الخدمة وتحميل البيانات
  Future<void> initialize() async {
    try {
      await _loadTournaments();
      await _loadParticipants();
      _updateStats();
    } catch (e) {
      Logger.logError('خطأ في تهيئة خدمة المسابقات', e);
    }
  }

  /// تحميل المسابقات من التخزين المحلي
  Future<void> _loadTournaments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tournamentsJson = prefs.getString(_tournamentsKey);

      if (tournamentsJson != null) {
        final List<dynamic> tournamentsList = json.decode(tournamentsJson);
        _tournaments =
            tournamentsList.map((json) => Tournament.fromJson(json)).toList();
      }
    } catch (e) {
      Logger.logError('خطأ في تحميل المسابقات', e);
      _tournaments = [];
    }
  }

  /// تحميل المشاركين من التخزين المحلي
  Future<void> _loadParticipants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final participantsJson = prefs.getString(_participantsKey);

      if (participantsJson != null) {
        final Map<String, dynamic> participantsData =
            json.decode(participantsJson);
        _participants = participantsData.map(
          (key, value) => MapEntry(
            key,
            (value as List)
                .map((json) => TournamentParticipant.fromJson(json))
                .toList(),
          ),
        );
      }
    } catch (e) {
      Logger.logError('خطأ في تحميل المشاركين', e);
      _participants = {};
    }
  }

  /// حفظ المسابقات في التخزين المحلي
  Future<void> _saveTournaments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tournamentsJson = json.encode(
        _tournaments.map((tournament) => tournament.toJson()).toList(),
      );
      await prefs.setString(_tournamentsKey, tournamentsJson);
    } catch (e) {
      Logger.logError('خطأ في حفظ المسابقات', e);
    }
  }

  /// حفظ المشاركين في التخزين المحلي
  Future<void> _saveParticipants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final participantsJson = json.encode(
        _participants.map(
          (key, value) => MapEntry(
            key,
            value.map((participant) => participant.toJson()).toList(),
          ),
        ),
      );
      await prefs.setString(_participantsKey, participantsJson);
    } catch (e) {
      Logger.logError('خطأ في حفظ المشاركين', e);
    }
  }

  /// تحديث الإحصائيات
  void _updateStats() {
    _tournamentStats = {
      'totalTournaments': _tournaments.length,
      'activeTournaments': _tournaments.where((t) => t.isActive).length,
      'totalParticipants':
          _participants.values.expand((participants) => participants).length,
      'completedTournaments': _tournaments.where((t) => t.isCompleted).length,
    };
  }

  /// إنشاء مسابقة جديدة
  Future<Tournament> createTournament({
    required String name,
    required String description,
    required TournamentType type,
    required TournamentFormat format,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime registrationDeadline,
    required int maxParticipants,
    required String createdBy,
    double entryFee = 0,
    Map<int, TournamentReward>? rewards,
    Map<String, dynamic>? settings,
  }) async {
    final tournament = Tournament(
      id: _generateId(),
      name: name,
      description: description,
      type: type,
      status: TournamentStatus.upcoming,
      format: format,
      startDate: startDate,
      endDate: endDate,
      registrationDeadline: registrationDeadline,
      maxParticipants: maxParticipants,
      entryFee: entryFee,
      rewards: rewards ?? _getDefaultRewards(),
      settings: settings ?? {},
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _tournaments.add(tournament);
    _participants[tournament.id] = [];

    await _saveTournaments();
    await _saveParticipants();
    _updateStats();

    return tournament;
  }

  /// تحديث مسابقة موجودة
  Future<Tournament?> updateTournament(
    String tournamentId,
    Tournament updatedTournament,
  ) async {
    final index = _tournaments.indexWhere((t) => t.id == tournamentId);
    if (index != -1) {
      _tournaments[index] = updatedTournament;
      await _saveTournaments();
      _updateStats();
      return updatedTournament;
    }
    return null;
  }

  /// حذف مسابقة
  Future<bool> deleteTournament(String tournamentId) async {
    try {
      _tournaments.removeWhere((t) => t.id == tournamentId);
      _participants.remove(tournamentId);

      await _saveTournaments();
      await _saveParticipants();
      _updateStats();

      return true;
    } catch (e) {
      Logger.logError('خطأ في حذف المسابقة', e);
      return false;
    }
  }

  /// تغيير حالة المسابقة
  Future<Tournament?> updateTournamentStatus(
    String tournamentId,
    TournamentStatus newStatus,
  ) async {
    final tournament = getTournamentById(tournamentId);
    if (tournament != null) {
      final updatedTournament = tournament.copyWith(status: newStatus);
      return await updateTournament(tournamentId, updatedTournament);
    }
    return null;
  }

  /// بدء التسجيل في المسابقة
  Future<Tournament?> openRegistration(String tournamentId) async {
    return await updateTournamentStatus(
        tournamentId, TournamentStatus.registration);
  }

  /// بدء المسابقة
  Future<Tournament?> startTournament(String tournamentId) async {
    final tournament = getTournamentById(tournamentId);
    if (tournament != null &&
        tournament.status == TournamentStatus.registration) {
      // إنشاء الجولات والمباريات
      await _generateMatches(tournamentId);
      return await updateTournamentStatus(
          tournamentId, TournamentStatus.inProgress);
    }
    return null;
  }

  /// إنهاء المسابقة
  Future<Tournament?> completeTournament(String tournamentId) async {
    return await updateTournamentStatus(
        tournamentId, TournamentStatus.completed);
  }

  /// إلغاء المسابقة
  Future<Tournament?> cancelTournament(String tournamentId) async {
    return await updateTournamentStatus(
        tournamentId, TournamentStatus.cancelled);
  }

  /// تسجيل مشارك في المسابقة
  Future<bool> registerParticipant(String tournamentId, String userId) async {
    try {
      final tournament = getTournamentById(tournamentId);
      if (tournament == null || !tournament.canRegister) {
        return false;
      }

      final participants = _participants[tournamentId] ?? [];

      // التحقق من عدم التسجيل المسبق
      if (participants.any((p) => p.userId == userId)) {
        return false;
      }

      final participant = TournamentParticipant(
        userId: userId,
        tournamentId: tournamentId,
        registrationTime: DateTime.now(),
      );

      participants.add(participant);
      _participants[tournamentId] = participants;

      // تحديث عدد المشاركين في المسابقة
      final updatedTournament = tournament.copyWith(
        currentParticipants: participants.length,
        participantIds: participants.map((p) => p.userId).toList(),
      );

      await updateTournament(tournamentId, updatedTournament);
      await _saveParticipants();

      return true;
    } catch (e) {
      Logger.logError('خطأ في تسجيل المشارك', e);
      return false;
    }
  }

  /// إلغاء التسجيل من المسابقة
  Future<bool> unregisterParticipant(String tournamentId, String userId) async {
    try {
      final participants = _participants[tournamentId] ?? [];
      participants.removeWhere((p) => p.userId == userId);
      _participants[tournamentId] = participants;

      final tournament = getTournamentById(tournamentId);
      if (tournament != null) {
        final updatedTournament = tournament.copyWith(
          currentParticipants: participants.length,
          participantIds: participants.map((p) => p.userId).toList(),
        );
        await updateTournament(tournamentId, updatedTournament);
      }

      await _saveParticipants();
      return true;
    } catch (e) {
      Logger.logError('خطأ في إلغاء التسجيل', e);
      return false;
    }
  }

  /// إنشاء المباريات للمسابقة
  Future<void> _generateMatches(String tournamentId) async {
    final tournament = getTournamentById(tournamentId);
    final participants = _participants[tournamentId] ?? [];

    if (tournament == null || participants.isEmpty) return;

    List<TournamentMatch> matches = [];

    switch (tournament.type) {
      case TournamentType.knockout:
        matches = _generateKnockoutMatches(tournament, participants);
        break;
      case TournamentType.roundRobin:
        matches = _generateRoundRobinMatches(tournament, participants);
        break;
      case TournamentType.swiss:
        matches = _generateSwissMatches(tournament, participants);
        break;
      case TournamentType.bracket:
        matches = _generateBracketMatches(tournament, participants);
        break;
    }

    final updatedTournament = tournament.copyWith(matches: matches);
    await updateTournament(tournamentId, updatedTournament);
  }

  /// إنشاء مباريات خروج المغلوب
  List<TournamentMatch> _generateKnockoutMatches(
    Tournament tournament,
    List<TournamentParticipant> participants,
  ) {
    final matches = <TournamentMatch>[];
    final shuffledParticipants = List<TournamentParticipant>.from(participants)
      ..shuffle();

    // الجولة الأولى
    for (int i = 0; i < shuffledParticipants.length - 1; i += 2) {
      final match = TournamentMatch(
        id: _generateId(),
        tournamentId: tournament.id,
        player1Id: shuffledParticipants[i].userId,
        player2Id: shuffledParticipants[i + 1].userId,
        round: 1,
        scheduledTime: tournament.startDate,
      );
      matches.add(match);
    }

    return matches;
  }

  /// إنشاء مباريات الدوري
  List<TournamentMatch> _generateRoundRobinMatches(
    Tournament tournament,
    List<TournamentParticipant> participants,
  ) {
    final matches = <TournamentMatch>[];

    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        final match = TournamentMatch(
          id: _generateId(),
          tournamentId: tournament.id,
          player1Id: participants[i].userId,
          player2Id: participants[j].userId,
          round: 1,
          scheduledTime: tournament.startDate,
        );
        matches.add(match);
      }
    }

    return matches;
  }

  /// إنشاء مباريات السويسري
  List<TournamentMatch> _generateSwissMatches(
    Tournament tournament,
    List<TournamentParticipant> participants,
  ) {
    // تنفيذ مبسط للنظام السويسري
    return _generateRoundRobinMatches(tournament, participants);
  }

  /// إنشاء مباريات الأقواس
  List<TournamentMatch> _generateBracketMatches(
    Tournament tournament,
    List<TournamentParticipant> participants,
  ) {
    return _generateKnockoutMatches(tournament, participants);
  }

  /// الحصول على الجوائز الافتراضية
  Map<int, TournamentReward> _getDefaultRewards() {
    return {
      1: const TournamentReward(position: 1, gems: 100, coins: 500),
      2: const TournamentReward(position: 2, gems: 75, coins: 300),
      3: const TournamentReward(position: 3, gems: 50, coins: 200),
    };
  }

  // Getters للوصول إلى البيانات
  List<Tournament> get allTournaments => List.unmodifiable(_tournaments);

  List<Tournament> get activeTournaments => _tournaments
      .where((t) => t.status == TournamentStatus.inProgress)
      .toList();

  List<Tournament> get upcomingTournaments => _tournaments
      .where((t) =>
          t.status == TournamentStatus.upcoming ||
          t.status == TournamentStatus.registration)
      .toList();

  Tournament? getTournamentById(String id) {
    try {
      return _tournaments.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  List<TournamentParticipant> getTournamentParticipants(String tournamentId) {
    return _participants[tournamentId] ?? [];
  }

  Map<String, dynamic> get tournamentStats =>
      Map.unmodifiable(_tournamentStats);

  /// فلترة المسابقات
  List<Tournament> filterTournaments({
    TournamentStatus? status,
    TournamentType? type,
    TournamentFormat? format,
    String? searchQuery,
  }) {
    var filtered = _tournaments.asMap().values;

    if (status != null) {
      filtered = filtered.where((t) => t.status == status);
    }

    if (type != null) {
      filtered = filtered.where((t) => t.type == type);
    }

    if (format != null) {
      filtered = filtered.where((t) => t.format == format);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((t) =>
          t.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(searchQuery.toLowerCase()));
    }

    return filtered.toList();
  }

  /// مسح جميع البيانات (للاختبار)
  Future<void> clearAllData() async {
    _tournaments.clear();
    _participants.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tournamentsKey);
    await prefs.remove(_participantsKey);

    _updateStats();
  }
}
