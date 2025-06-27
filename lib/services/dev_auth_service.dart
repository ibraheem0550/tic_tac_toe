import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complete_user_models.dart';
import '../utils/logger.dart';

// Mock auth service for development without Firebase
class DevAuthService {
  static final DevAuthService _instance = DevAuthService._internal();
  factory DevAuthService() => _instance;
  DevAuthService._internal();

  User? _currentUser;
  final List<Function(User?)> _authListeners = [];
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest ?? false;
  bool get isLoggedIn => _currentUser != null;
  Stream<User?> get userStream => _userController.stream;

  // Initialize service
  Future<void> initialize() async {
    try {
      // Load saved user if exists
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('dev_current_user');
      if (userData != null) {
        final userMap = jsonDecode(userData);
        _currentUser = User.fromJson(userMap);
        _notifyListeners();
      }
      Logger.logInfo('✅ Dev Auth Service initialized');
    } catch (e) {
      Logger.logError('❌ Failed to initialize Dev Auth Service', e);
    }
  }

  // Sign in with email and password (mock)
  Future<AuthResult> signInWithEmailPassword(
      String email, String password) async {
    try {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay

      final user = User(
        id: 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        photoURL: null,
        linkedProviders: [AuthProvider.email],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats(
            userId: 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
            lastUpdated: DateTime.now(),
          ),
        ),
      );

      _currentUser = user;
      await _saveCurrentUser();
      _notifyListeners();

      return AuthResult(
        isSuccess: true,
        user: user,
        message: 'تم تسجيل الدخول بنجاح',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'فشل في تسجيل الدخول: $e',
      );
    }
  }

  // Create account (mock)
  Future<AuthResult> createUserWithEmailPassword(
      String email, String password, String? displayName) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final user = User(
        id: 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName ?? email.split('@')[0],
        photoURL: null,
        linkedProviders: [AuthProvider.email],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats(
            userId: 'dev_user_${DateTime.now().millisecondsSinceEpoch}',
            lastUpdated: DateTime.now(),
          ),
        ),
      );

      _currentUser = user;
      await _saveCurrentUser();
      _notifyListeners();

      return AuthResult(
        isSuccess: true,
        user: user,
        message: 'تم إنشاء الحساب بنجاح',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'فشل في إنشاء الحساب: $e',
      );
    }
  }

  // Sign in with Google (mock)
  Future<AuthResult> signInWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final user = User(
        id: 'dev_google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'google.user@gmail.com',
        displayName: 'Google User',
        photoURL: 'https://via.placeholder.com/100',
        linkedProviders: [AuthProvider.google],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats(
            userId: 'dev_google_${DateTime.now().millisecondsSinceEpoch}',
            lastUpdated: DateTime.now(),
          ),
        ),
      );

      _currentUser = user;
      await _saveCurrentUser();
      _notifyListeners();

      return AuthResult(
        isSuccess: true,
        user: user,
        message: 'تم تسجيل الدخول بـ Google بنجاح',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'فشل في تسجيل الدخول بـ Google: $e',
      );
    }
  }

  // Sign in with Apple (mock)
  Future<AuthResult> signInWithApple() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final user = User(
        id: 'dev_apple_${DateTime.now().millisecondsSinceEpoch}',
        email: 'apple.user@icloud.com',
        displayName: 'Apple User',
        photoURL: null,
        linkedProviders: [AuthProvider.apple],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats(
            userId: 'dev_apple_${DateTime.now().millisecondsSinceEpoch}',
            lastUpdated: DateTime.now(),
          ),
        ),
      );

      _currentUser = user;
      await _saveCurrentUser();
      _notifyListeners();

      return AuthResult(
        isSuccess: true,
        user: user,
        message: 'تم تسجيل الدخول بـ Apple بنجاح',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'فشل في تسجيل الدخول بـ Apple: $e',
      );
    }
  }

  // Sign in as guest
  Future<AuthResult> signInAsGuest() async {
    try {
      final user = User(
        id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@app.com',
        displayName: 'ضيف ${DateTime.now().day}/${DateTime.now().month}',
        photoURL: null,
        linkedProviders: [AuthProvider.guest],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats(
            userId: 'guest_${DateTime.now().millisecondsSinceEpoch}',
            lastUpdated: DateTime.now(),
          ),
        ),
      );

      _currentUser = user;
      await _saveCurrentUser();
      _notifyListeners();

      return AuthResult(
        isSuccess: true,
        user: user,
        message: 'مرحباً أيها الضيف!',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'فشل في الدخول كضيف: $e',
      );
    }
  }

  // Quick sign in for development
  Future<AuthResult> quickSignIn(
      {String email = 'dev@test.com', required String password}) async {
    return await signInWithEmailPassword(email, password);
  }

  // Update profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    if (_currentUser != null) {
      final updatedUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
        linkedProviders: _currentUser!.linkedProviders,
        createdAt: _currentUser!.createdAt,
        lastLoginAt: _currentUser!.lastLoginAt,
        profile: _currentUser!.profile,
      );

      _currentUser = updatedUser;
      await _saveCurrentUser();
      _notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dev_current_user');
    _notifyListeners();
  }

  // Add auth listener
  void addAuthListener(Function(User?) listener) {
    _authListeners.add(listener);
  }

  // Remove auth listener
  void removeAuthListener(Function(User?) listener) {
    _authListeners.remove(listener);
  }

  // Private methods
  void _notifyListeners() {
    for (final listener in _authListeners) {
      listener(_currentUser);
    }
    _userController.add(_currentUser);
  }

  Future<void> _saveCurrentUser() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'dev_current_user', jsonEncode(_currentUser!.toJson()));
    }
  }

  void dispose() {
    _userController.close();
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? message;
  final String? errorCode;

  AuthResult({
    required this.isSuccess,
    this.user,
    this.message,
    this.errorCode,
  });
}
