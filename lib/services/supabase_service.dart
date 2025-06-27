// SupabaseService placeholder - redirects to FirestoreService
// This file exists for compatibility with existing code that imports SupabaseService

import 'firestore_service.dart';
import '../utils/logger.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static final FirestoreService _firestoreService = FirestoreService();

  factory SupabaseService() {
    return _instance;
  }

  SupabaseService._internal();

  // Redirect methods to FirestoreService for compatibility

  Future<void> initialize() async {
    // Firestore is initialized through Firebase, so nothing to do here
    Logger.logInfo('SupabaseService: Using FirestoreService instead');
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    // TODO: تحديث لتستخدم FirestoreService
    Logger.logInfo('SupabaseService: getUserData placeholder');
    return null;
  }

  Future<bool> updateUserData(String userId, Map<String, dynamic> data) async {
    // TODO: تحديث لتستخدم FirestoreService
    Logger.logInfo('SupabaseService: updateUserData placeholder');
    return false;
  }

  Future<bool> createUserData(String userId, Map<String, dynamic> data) async {
    // TODO: تحديث لتستخدم FirestoreService
    Logger.logInfo('SupabaseService: createUserData placeholder');
    return false;
  }

  Future<List<Map<String, dynamic>>> getGameHistory(String userId) async {
    // TODO: Implement game history in FirestoreService
    Logger.logInfo('SupabaseService: getGameHistory not implemented yet');
    return [];
  }

  Future<bool> saveGameResult(
      String userId, Map<String, dynamic> gameData) async {
    // TODO: Implement save game result in FirestoreService
    Logger.logInfo('SupabaseService: saveGameResult not implemented yet');
    return true;
  }

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    // TODO: Implement friends system in FirestoreService
    Logger.logInfo('SupabaseService: getFriends not implemented yet');
    return [];
  }

  Future<bool> addFriend(String userId, String friendId) async {
    // TODO: Implement add friend in FirestoreService
    Logger.logInfo('SupabaseService: addFriend not implemented yet');
    return true;
  }

  Future<bool> removeFriend(String userId, String friendId) async {
    // TODO: Implement remove friend in FirestoreService
    Logger.logInfo('SupabaseService: removeFriend not implemented yet');
    return true;
  }
}
