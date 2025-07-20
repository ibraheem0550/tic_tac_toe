// lib/services/unified_auth_services.dart
// خدمة المصادقة الحقيقية مع Firebase

import 'package:flutter/foundation.dart' show debugPrint, VoidCallback;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/complete_user_models.dart';

/// خدمة المصادقة الحقيقية مع Firebase
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  SharedPreferences? _prefs;
  User? _currentUser;
  List<VoidCallback> _authListeners = [];

  /// تهيئة الخدمة
  Future<void> initialize() async {
    debugPrint('🔄 تهيئة خدمة Firebase Auth...');
    _prefs = await SharedPreferences.getInstance();

    // استماع لتغييرات حالة المصادقة
    _firebaseAuth.authStateChanges().listen((firebase_auth.User? user) {
      _updateCurrentUser(user);
    });

    // تحميل المستخدم الحالي
    final currentFirebaseUser = _firebaseAuth.currentUser;
    if (currentFirebaseUser != null) {
      _updateCurrentUser(currentFirebaseUser);
    }

    debugPrint('✅ تم تهيئة Firebase Auth بنجاح');
  }

  /// تحديث المستخدم الحالي
  void _updateCurrentUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser != null) {
      _currentUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName:
            firebaseUser.displayName ??
            firebaseUser.email?.split('@')[0] ??
            'مستخدم',
        isGuest: firebaseUser.isAnonymous,
        photoURL: firebaseUser.photoURL,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
        provider: _getProviderType(firebaseUser.providerData),
        phoneNumber: firebaseUser.phoneNumber,
        isVerified: firebaseUser.emailVerified,
      );
    } else {
      _currentUser = null;
    }
    _notifyListeners();
  }

  /// تحديد نوع مقدم الخدمة
  AuthProvider _getProviderType(List<firebase_auth.UserInfo> providerData) {
    for (final provider in providerData) {
      switch (provider.providerId) {
        case 'google.com':
          return AuthProvider.google;
        case 'apple.com':
          return AuthProvider.apple;
        case 'facebook.com':
          return AuthProvider.facebook;
        case 'password':
          return AuthProvider.email;
      }
    }
    return AuthProvider.guest;
  }

  // ------------------------------------------------------------------
  // 🔥 Auth Support Helpers
  // ------------------------------------------------------------------

  /// الحصول على المستخدم الحالي
  User? get currentUser => _currentUser;

  /// نموذج المستخدم الحالي (للتوافق مع الكود الموجود)
  User get currentUserModel => _currentUser ?? _createGuestUser();

  /// الحصول على المستخدم الحالي بشكل غير متزامن (للتوافق مع استدعاءات await)
  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  /// إنشاء مستخدم ضيف
  User _createGuestUser() {
    return User(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@example.com',
      displayName: 'ضيف',
      isGuest: true,
      photoURL: null,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      provider: AuthProvider.guest,
      phoneNumber: null,
      isVerified: false,
    );
  }

  /// تسجيل الدخول كضيف
  Future<User?> signInAnonymously() async {
    try {
      debugPrint('🔄 تسجيل الدخول كضيف...');
      final credential = await _firebaseAuth.signInAnonymously();
      debugPrint('✅ تم تسجيل الدخول كضيف بنجاح');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول كضيف: $e');
      return null;
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔄 محاولة تسجيل الدخول: $email');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        debugPrint('✅ تم تسجيل الدخول بنجاح: $email');
        return _currentUser;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ خطأ Firebase Auth: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ خطأ عام في تسجيل الدخول: $e');
      return null;
    }
  }

  /// إنشاء حساب جديد بالبريد الإلكتروني
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔄 محاولة إنشاء حساب جديد: $email');

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // تحديث الاسم المعروض
        await credential.user!.updateDisplayName(email.split('@')[0]);
        debugPrint('✅ تم إنشاء حساب جديد بنجاح: $email');
        return _currentUser;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('❌ خطأ Firebase Auth: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ خطأ عام في إنشاء الحساب: $e');
      return null;
    }
  }

  /// تسجيل الدخول باستخدام Google (مؤقتاً معطل)
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔄 محاولة تسجيل الدخول باستخدام Google');
      debugPrint('ℹ️ Google Sign In يحتاج إعداد إضافي - استخدام وضع تجريبي');

      // مؤقتاً، إنشاء مستخدم تجريبي
      final credential = await _firebaseAuth.signInAnonymously();
      if (credential.user != null) {
        await credential.user!.updateDisplayName('مستخدم Google');
        debugPrint('✅ تم تسجيل الدخول (وضع تجريبي Google)');
        return _currentUser;
      }

      return null;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول باستخدام Google: $e');
      return null;
    }
  }

  /// تسجيل الدخول باستخدام Apple (مؤقتاً معطل)
  Future<User?> signInWithApple() async {
    try {
      debugPrint('🔄 محاولة تسجيل الدخول باستخدام Apple');
      debugPrint('ℹ️ Apple Sign In يحتاج إعداد إضافي - استخدام وضع تجريبي');

      // مؤقتاً، إنشاء مستخدم تجريبي
      final credential = await _firebaseAuth.signInAnonymously();
      if (credential.user != null) {
        await credential.user!.updateDisplayName('مستخدم Apple');
        debugPrint('✅ تم تسجيل الدخول (وضع تجريبي Apple)');
        return _currentUser;
      }

      return null;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول باستخدام Apple: $e');
      return null;
    }
  }

  /// تسجيل الدخول باستخدام منصات التواصل الاجتماعي
  Future<User?> signInWithSocial(dynamic platform) async {
    if (platform.toString().contains('google')) {
      return await signInWithGoogle();
    } else if (platform.toString().contains('apple')) {
      return await signInWithApple();
    }
    return null;
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      debugPrint('🔄 تسجيل الخروج...');
      await _firebaseAuth.signOut();
      debugPrint('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
    }
  }

  /// التحقق من حالة تسجيل الدخول
  bool get isSignedIn => _currentUser != null && !_currentUser!.isGuest;

  /// التحقق من كون المستخدم ضيف
  bool get isGuest => _currentUser?.isGuest ?? true;

  /// الحصول على UID المستخدم
  String? get currentUserId => _currentUser?.id;

  /// تحديث بيانات المستخدم
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        debugPrint('🔄 تحديث بيانات المستخدم...');

        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }

        await user.reload();
        _updateCurrentUser(user);

        debugPrint('✅ تم تحديث البيانات بنجاح');
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحديث البيانات: $e');
    }
  }

  /// إرسال رمز التحقق من البريد الإلكتروني
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('📧 تم إرسال رمز التحقق بنجاح');
      }
    } catch (e) {
      debugPrint('❌ خطأ في إرسال رمز التحقق: $e');
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('📧 تم إرسال رابط إعادة تعيين كلمة المرور');
    } catch (e) {
      debugPrint('❌ خطأ في إرسال رابط إعادة التعيين: $e');
    }
  }

  /// الاستماع لتغييرات حالة المصادقة
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        _updateCurrentUser(firebaseUser);
      }
      return _currentUser;
    });
  }

  // ------------------------------------------------------------------
  // 🔄 دوال الاستماع والإشعارات
  // ------------------------------------------------------------------

  /// إضافة مستمع لتغييرات المصادقة
  void addAuthListener(VoidCallback listener) {
    _authListeners.add(listener);
  }

  /// إزالة مستمع تغييرات المصادقة
  void removeAuthListener(VoidCallback listener) {
    _authListeners.remove(listener);
  }

  /// إشعار جميع المستمعين
  void _notifyListeners() {
    for (final listener in _authListeners) {
      try {
        listener();
      } catch (e) {
        debugPrint('❌ خطأ في إشعار المستمع: $e');
      }
    }
  }

  // ------------------------------------------------------------------
  // 🔄 دوال التوافق مع الكود الموجود
  // ------------------------------------------------------------------

  /// تسجيل الدخول بالبريد الإلكتروني (للتوافق)
  Future<User?> signInWithEmail(String email, String password) async {
    return await signInWithEmailAndPassword(email, password);
  }

  /// إنشاء حساب جديد (للتوافق)
  Future<User?> signUpWithEmail(String email, String password) async {
    return await createUserWithEmailAndPassword(email, password);
  }

  /// تسجيل الدخول كضيف (للتوافق)
  Future<User?> signInAsGuest() async {
    return await signInAnonymously();
  }
}
