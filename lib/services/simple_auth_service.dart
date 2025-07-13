import 'package:flutter/material.dart';
import '../models/complete_user_models.dart' as UserModels;

// ======================================================================
// 🔐 SIMPLIFIED AUTH SERVICE (No Firebase)
// خدمة مصادقة مبسطة بدون Firebase للتشغيل على Windows
// ======================================================================

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  // Current user (guest mode for now)
  UserModels.User? _currentUserModel;

  UserModels.User? get currentUserModel =>
      _currentUserModel ?? _createGuestUser();

  /// الحصول على المستخدم الحالي بشكل غير متزامن (للتوافق مع استدعاءات await)
  Future<UserModels.User?> getCurrentUser() async {
    return _currentUserModel ?? _createGuestUser();
  }

  // Create a guest user
  UserModels.User _createGuestUser() {
    return UserModels.User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@example.com',
      displayName: 'ضيف',
      isGuest: true,
      photoURL: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      provider: UserModels.AuthProvider.guest,
      phoneNumber: null,
      isVerified: false,
    );
  }

  // Sign in as guest
  Future<UserModels.User?> signInAsGuest() async {
    try {
      _currentUserModel = _createGuestUser();
      debugPrint('تم تسجيل الدخول كضيف');
      return _currentUserModel;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول كضيف: $e');
      return null;
    }
  }

  // Sign in with email (placeholder)
  Future<UserModels.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Placeholder implementation
      _currentUserModel = UserModels.User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        isGuest: false,
        photoURL: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        provider: UserModels.AuthProvider.email,
        phoneNumber: null,
        isVerified: true,
      );
      debugPrint('تم تسجيل الدخول بالإيميل (وضع تجريبي)');
      return _currentUserModel;
    } catch (e) {
      debugPrint('خطأ في تسجيل الدخول: $e');
      return null;
    }
  }

  // Create account (placeholder)
  Future<UserModels.User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Placeholder implementation
      _currentUserModel = UserModels.User(
        id: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@')[0],
        isGuest: false,
        photoURL: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        provider: UserModels.AuthProvider.email,
        phoneNumber: null,
        isVerified: false,
      );
      debugPrint('تم إنشاء حساب جديد (وضع تجريبي)');
      return _currentUserModel;
    } catch (e) {
      debugPrint('خطأ في إنشاء الحساب: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _currentUserModel = null;
      debugPrint('تم تسجيل الخروج');
    } catch (e) {
      debugPrint('خطأ في تسجيل الخروج: $e');
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _currentUserModel != null;

  // Google Sign In (disabled)
  Future<UserModels.User?> signInWithGoogle() async {
    debugPrint('Google Sign In معطل مؤقتاً');
    return await signInAsGuest();
  }
}
