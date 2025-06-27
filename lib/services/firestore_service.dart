import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complete_user_models.dart' as models;

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // البحث عن المستخدمين
  Future<List<models.User>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        return _mapToUser(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('خطأ في البحث عن المستخدمين: $e');
      return [];
    }
  }

  // إرسال طلب صداقة
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      // التحقق من عدم وجود طلب سابق
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw Exception('طلب الصداقة موجود بالفعل');
      }

      await _firestore.collection('friend_requests').add({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في إرسال طلب الصداقة: $e');
      throw e;
    }
  }

  // الحصول على طلبات الصداقة
  Future<List<models.FriendRequest>> getFriendRequests(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('friend_requests')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      List<models.FriendRequest> requests = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final fromUserId = data['fromUserId'];

        // جلب بيانات المرسل
        final userDoc =
            await _firestore.collection('users').doc(fromUserId).get();

        if (userDoc.exists) {
          final fromUser = _mapToUser(userDoc.data()!, userDoc.id);
          requests.add(models.FriendRequest(
            id: doc.id,
            fromUserId: fromUserId,
            toUserId: userId,
            fromUser: fromUser,
            status: 'pending',
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ));
        }
      }

      return requests;
    } catch (e) {
      print('خطأ في جلب طلبات الصداقة: $e');
      return [];
    }
  }

  // قبول طلب صداقة
  Future<void> acceptFriendRequest(
      String requestId, String userId, String friendId) async {
    try {
      final batch = _firestore.batch();

      // تحديث حالة طلب الصداقة
      batch.update(_firestore.collection('friend_requests').doc(requestId), {
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // إضافة الصداقة للطرفين
      batch.set(
          _firestore.collection('friendships').doc('${userId}_$friendId'), {
        'userId': userId,
        'friendId': friendId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      batch.set(
          _firestore.collection('friendships').doc('${friendId}_$userId'), {
        'userId': friendId,
        'friendId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      await batch.commit();
    } catch (e) {
      print('خطأ في قبول طلب الصداقة: $e');
      throw e;
    }
  }

  // رفض طلب صداقة
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      await _firestore.collection('friend_requests').doc(requestId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في رفض طلب الصداقة: $e');
      throw e;
    }
  }

  // الحصول على قائمة الأصدقاء
  Future<List<models.User>> getFriends(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('friendships')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      List<models.User> friends = [];
      for (var doc in querySnapshot.docs) {
        final friendId = doc.data()['friendId'];

        final userDoc =
            await _firestore.collection('users').doc(friendId).get();

        if (userDoc.exists) {
          friends.add(_mapToUser(userDoc.data()!, userDoc.id));
        }
      }

      return friends;
    } catch (e) {
      print('خطأ في جلب الأصدقاء: $e');
      return [];
    }
  }

  // حفظ بيانات المستخدم
  Future<void> saveUserProfile(models.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'createdAt': Timestamp.fromDate(user.createdAt),
        'lastLoginAt': Timestamp.fromDate(user.lastLoginAt),
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
        'gems': user.gems,
        'level': user.level,
        'experience': user.experience,
      }, SetOptions(merge: true));
    } catch (e) {
      print('خطأ في حفظ بيانات المستخدم: $e');
      throw e;
    }
  }

  // تحديث حالة الاتصال
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('خطأ في تحديث حالة الاتصال: $e');
    }
  }

  // حفظ إحصائيات اللعبة
  Future<void> saveGameStats(String userId, models.GameStats stats) async {
    try {
      await _firestore.collection('user_stats').doc(userId).set({
        'wins': stats.wins,
        'losses': stats.losses,
        'draws': stats.draws,
        'totalGames': stats.totalGames,
        'winRate': stats.winRate,
        'averageGameDuration': stats.averageGameDuration,
        'bestStreak': stats.bestStreak,
        'currentStreak': stats.streak,
        'totalPlayTime': stats.totalPlayTime,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('خطأ في حفظ إحصائيات اللعبة: $e');
      throw e;
    }
  }

  // جلب إحصائيات اللعبة
  Future<models.GameStats> getGameStats(String userId) async {
    try {
      final doc = await _firestore.collection('user_stats').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        return models.GameStats(
          userId: userId,
          wins: data['wins'] ?? 0,
          losses: data['losses'] ?? 0,
          draws: data['draws'] ?? 0,
          totalGames: data['totalGames'] ?? 0,
          streak: data['currentWinStreak'] ?? 0,
          bestStreak: data['longestWinStreak'] ?? 0,
          lastUpdated:
              DateTime.tryParse(data['lastUpdated'] ?? '') ?? DateTime.now(),
        );
      }

      return models.GameStats(
        userId: userId,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      print('خطأ في جلب إحصائيات اللعبة: $e');
      return models.GameStats(
        userId: userId,
        lastUpdated: DateTime.now(),
      );
    }
  }

  // حفظ نتيجة لعبة
  Future<void> saveGameResult({
    required String userId,
    required String gameType,
    required String result, // 'win', 'loss', 'draw'
    required Duration gameDuration,
    String? opponentId,
  }) async {
    try {
      await _firestore.collection('game_results').add({
        'userId': userId,
        'gameType': gameType,
        'result': result,
        'gameDuration': gameDuration.inSeconds,
        'opponentId': opponentId,
        'playedAt': FieldValue.serverTimestamp(),
      });

      // تحديث الإحصائيات
      final currentStats = await getGameStats(userId);
      late models.GameStats updatedStats;

      switch (result) {
        case 'win':
          updatedStats = models.GameStats(
            userId: userId,
            wins: currentStats.wins + 1,
            losses: currentStats.losses,
            draws: currentStats.draws,
            totalGames: currentStats.totalGames + 1,
            streak: currentStats.streak + 1,
            bestStreak: (currentStats.streak + 1) > currentStats.bestStreak
                ? currentStats.streak + 1
                : currentStats.bestStreak,
            totalPlayTime: currentStats.totalPlayTime + gameDuration.inSeconds,
            lastUpdated: DateTime.now(),
          );
          break;
        case 'loss':
          updatedStats = models.GameStats(
            userId: userId,
            wins: currentStats.wins,
            losses: currentStats.losses + 1,
            draws: currentStats.draws,
            totalGames: currentStats.totalGames + 1,
            streak: 0,
            bestStreak: currentStats.bestStreak,
            totalPlayTime: currentStats.totalPlayTime + gameDuration.inSeconds,
            lastUpdated: DateTime.now(),
          );
          break;
        case 'draw':
          updatedStats = models.GameStats(
            userId: userId,
            wins: currentStats.wins,
            losses: currentStats.losses,
            draws: currentStats.draws + 1,
            totalGames: currentStats.totalGames + 1,
            streak: 0,
            bestStreak: currentStats.bestStreak,
            totalPlayTime: currentStats.totalPlayTime + gameDuration.inSeconds,
            lastUpdated: DateTime.now(),
          );
          break;
      }

      // حفظ الإحصائيات المحدثة
      await saveGameStats(userId, updatedStats);
    } catch (e) {
      print('خطأ في حفظ نتيجة اللعبة: $e');
      throw e;
    }
  }

  // تحويل البيانات إلى نموذج User
  models.User _mapToUser(Map<String, dynamic> data, String id) {
    return models.User(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'مستخدم',
      photoURL: data['photoURL'],
      isGuest: data['isGuest'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt:
          (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      provider: models.AuthProvider.email,
      gems: data['gems'] ?? 0,
      level: data['level'] ?? 1,
      experience: data['experience'] ?? 0,
      achievements: List<String>.from(data['achievements'] ?? []),
      settings: Map<String, dynamic>.from(data['settings'] ?? {}),
      phoneNumber: data['phoneNumber'],
      isVerified: data['isVerified'] ?? false,
      bio: data['bio'],
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      linkedProviders: [models.AuthProvider.email],
      linkedAccounts: [],
    );
  }

  // Stream للاستماع لتحديثات الأصدقاء المباشرة
  Stream<List<models.User>> getFriendsStream(String userId) {
    return _firestore
        .collection('friendships')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((snapshot) async {
      List<models.User> friends = [];
      for (var doc in snapshot.docs) {
        final friendId = doc.data()['friendId'];
        final userDoc =
            await _firestore.collection('users').doc(friendId).get();
        if (userDoc.exists) {
          friends.add(_mapToUser(userDoc.data()!, userDoc.id));
        }
      }
      return friends;
    });
  }

  // Stream لطلبات الصداقة المباشرة
  Stream<List<models.FriendRequest>> getFriendRequestsStream(String userId) {
    return _firestore
        .collection('friend_requests')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<models.FriendRequest> requests = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final fromUserId = data['fromUserId'];

        final userDoc =
            await _firestore.collection('users').doc(fromUserId).get();
        if (userDoc.exists) {
          final fromUser = _mapToUser(userDoc.data()!, userDoc.id);
          requests.add(models.FriendRequest(
            id: doc.id,
            fromUserId: fromUserId,
            toUserId: userId,
            fromUser: fromUser,
            status: 'pending',
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ));
        }
      }
      return requests;
    });
  }
}
