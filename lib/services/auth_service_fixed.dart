import 'dart:async';
import '../models/complete_user_models.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  User? _currentUser;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  User? get currentUser => _currentUser;
  Stream<User?> get userStream => _userController.stream;
  bool get isLoggedIn => _currentUser != null;

  // تسجيل الدخول بالبريد الإلكتروني
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // هنا يتم التكامل مع Firebase Auth أو أي خدمة مصادقة أخرى
      await Future.delayed(const Duration(seconds: 2)); // محاكاة الشبكة

      final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: userId,
        email: email,
        displayName: email.split('@')[0],
        provider: AuthProvider.email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats.empty(userId),
        ),
        linkedProviders: [AuthProvider.email],
      );

      _setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  // تسجيل الدخول بـ Google
  Future<User?> signInWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final userId = 'google_user_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: userId,
        email: 'user@gmail.com',
        displayName: 'مستخدم Google',
        photoURL: 'https://example.com/avatar.jpg',
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats.empty(userId),
        ),
        linkedProviders: [AuthProvider.google],
      );

      _setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('فشل تسجيل الدخول بـ Google: ${e.toString()}');
    }
  }

  // تسجيل الدخول بـ Facebook
  Future<User?> signInWithFacebook() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final userId = 'fb_user_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: userId,
        email: 'user@facebook.com',
        displayName: 'مستخدم Facebook',
        photoURL: 'https://example.com/fb_avatar.jpg',
        provider: AuthProvider.facebook,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats.empty(userId),
        ),
        linkedProviders: [AuthProvider.facebook],
      );

      _setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('فشل تسجيل الدخول بـ Facebook: ${e.toString()}');
    }
  }

  // تسجيل الدخول بـ Google Play Games
  Future<User?> signInWithGooglePlayGames() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final userId = 'gpg_user_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: userId,
        email: 'gamer@playstore.com',
        displayName: 'اللاعب المجهول',
        provider: AuthProvider.googlePlay,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats.empty(userId),
        ),
        linkedProviders: [AuthProvider.googlePlay],
      );

      _setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('فشل تسجيل الدخول بـ Google Play Games: ${e.toString()}');
    }
  }

  // إنشاء حساب جديد
  Future<User?> createAccount({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final userId = 'new_user_${DateTime.now().millisecondsSinceEpoch}';
      final user = User(
        id: userId,
        email: email,
        displayName: username,
        provider: AuthProvider.email,
        gems: 100, // جواهر ترحيبية
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserProfile(
          preferences: const UserPreferences(),
          gameStats: GameStats.empty(userId),
        ),
        linkedProviders: [AuthProvider.email],
      );

      _setCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('فشل إنشاء الحساب: ${e.toString()}');
    }
  }

  // ربط موفر جديد
  Future<void> linkProvider(AuthProvider provider) async {
    if (_currentUser == null) throw Exception('يجب تسجيل الدخول أولاً');

    try {
      await Future.delayed(const Duration(seconds: 1));

      final updatedProviders = [..._currentUser!.linkedProviders];
      if (!updatedProviders.contains(provider)) {
        updatedProviders.add(provider);
      }

      _setCurrentUser(
          _currentUser!.copyWith(linkedProviders: updatedProviders));
    } catch (e) {
      throw Exception('فشل ربط الحساب: ${e.toString()}');
    }
  }

  // إلغاء ربط موفر
  Future<void> unlinkProvider(AuthProvider provider) async {
    if (_currentUser == null) throw Exception('يجب تسجيل الدخول أولاً');
    if (_currentUser!.linkedProviders.length <= 1) {
      throw Exception('لا يمكن إلغاء ربط آخر طريقة دخول');
    }

    try {
      await Future.delayed(const Duration(seconds: 1));

      final updatedProviders = [..._currentUser!.linkedProviders];
      updatedProviders.remove(provider);

      _setCurrentUser(
          _currentUser!.copyWith(linkedProviders: updatedProviders));
    } catch (e) {
      throw Exception('فشل إلغاء ربط الحساب: ${e.toString()}');
    }
  }

  // تحديث الملف الشخصي
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? photoURL,
  }) async {
    if (_currentUser == null) throw Exception('يجب تسجيل الدخول أولاً');

    try {
      await Future.delayed(const Duration(seconds: 1));

      final updatedProfile = _currentUser!.profile?.copyWith(
        bio: bio ?? _currentUser!.profile?.bio,
      );

      _setCurrentUser(_currentUser!.copyWith(
        displayName: displayName ?? _currentUser!.displayName,
        photoURL: photoURL ?? _currentUser!.photoURL,
        profile: updatedProfile,
      ));
    } catch (e) {
      throw Exception('فشل تحديث الملف الشخصي: ${e.toString()}');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    _setCurrentUser(null);
  }

  // إضافة جواهر
  Future<void> addGems(int amount) async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      gems: _currentUser!.gems + amount,
    );
    _setCurrentUser(updatedUser);
  }

  // خصم جواهر
  Future<bool> spendGems(int amount) async {
    if (_currentUser == null || _currentUser!.gems < amount) return false;

    final updatedUser = _currentUser!.copyWith(
      gems: _currentUser!.gems - amount,
    );
    _setCurrentUser(updatedUser);
    return true;
  }

  void _setCurrentUser(User? user) {
    _currentUser = user;
    _userController.add(user);
  }

  void dispose() {
    _userController.close();
  }
}
