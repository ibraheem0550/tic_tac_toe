// lib/services/unified_auth_services.dart
// خدمة المصادقة الموحدة المبسطة (بدون Firebase للتشغيل على Windows)

import 'package:flutter/foundation.dart';
import '../models/complete_user_models.dart';

/// خدمة المصادقة المبسطة للتشغيل بدون Firebase
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  // مستخدم افتراضي للتجربة
  static final User _guestUser = User(
    id: 'guest_user_001',
    email: 'guest@example.com',
    displayName: 'Guest Player',
    isGuest: true,
    photoURL: null,
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
    provider: AuthProvider.guest,
    phoneNumber: null,
    isVerified: false,
  );

  User? _currentUser = _guestUser;

  /// الحصول على المستخدم الحالي
  User? get currentUser => _currentUser;

  /// نموذج المستخدم الحالي (للتوافق مع الكود الموجود)
  User get currentUserModel => _currentUser ?? _guestUser;

  /// الحصول على المستخدم الحالي بشكل غير متزامن (للتوافق مع استدعاءات await)
  Future<User?> getCurrentUser() async {
    // في هذا التطبيق غير المتصل، نعيد المستخدم المخزن مباشرةً
    return _currentUser;
  }

  /// تسجيل الدخول كضيف
  Future<User?> signInAnonymously() async {
    try {
      debugPrint('🔄 تسجيل الدخول كضيف...');
      _currentUser = _guestUser;
      debugPrint('✅ تم تسجيل الدخول كضيف بنجاح');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول كضيف: $e');
      return null;
    }
  }

  /// تسجيل الدخول بالبريد الإلكتروني (مبسط)
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔄 تسجيل الدخول بالبريد الإلكتروني...');

      // إنشاء مستخدم مؤقت
      _currentUser = User(
        id: 'user_${email.hashCode}',
        email: email,
        displayName: email.split('@')[0],
        isGuest: false,
        photoURL: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        provider: AuthProvider.email,
        phoneNumber: null,
        isVerified: true,
      );

      debugPrint('✅ تم تسجيل الدخول بنجاح');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول: $e');
      return null;
    }
  }

  /// إنشاء حساب جديد (مبسط)
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('🔄 إنشاء حساب جديد...');

      // إنشاء مستخدم جديد
      _currentUser = User(
        id: 'new_user_${email.hashCode}',
        email: email,
        displayName: email.split('@')[0],
        isGuest: false,
        photoURL: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        provider: AuthProvider.email,
        phoneNumber: null,
        isVerified: false,
      );

      debugPrint('✅ تم إنشاء الحساب بنجاح');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء الحساب: $e');
      return null;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      debugPrint('🔄 تسجيل الخروج...');
      _currentUser = _guestUser; // العودة للضيف
      debugPrint('✅ تم تسجيل الخروج بنجاح');
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
    }
  }

  /// التحقق من حالة تسجيل الدخول
  bool get isSignedIn => _currentUser != null;

  /// التحقق من كون المستخدم ضيف
  bool get isGuest => _currentUser?.isGuest ?? true;

  /// الحصول على UID المستخدم
  String? get currentUserId => _currentUser?.id;

  /// تحديث بيانات المستخدم
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_currentUser != null) {
      debugPrint('🔄 تحديث بيانات المستخدم...');
      // تحديث البيانات محلياً فقط
      debugPrint('✅ تم تحديث البيانات محلياً');
    }
  }

  /// إرسال رمز التحقق من البريد الإلكتروني (مبسط)
  Future<void> sendEmailVerification() async {
    debugPrint('📧 تم إرسال رمز التحقق (محاكاة)');
  }

  /// إعادة تعيين كلمة المرور (مبسط)
  Future<void> sendPasswordResetEmail(String email) async {
    debugPrint('🔄 إرسال إعادة تعيين كلمة المرور إلى: $email');
  }

  /// الاستماع لتغييرات حالة المصادقة
  Stream<User?> authStateChanges() {
    return Stream.value(_currentUser);
  }

  /// دوال إضافية للتوافق مع الكود الموجود

  /// تسجيل الدخول بالبريد الإلكتروني (اسم مختلف للتوافق)
  Future<User?> signInWithEmail(String email, String password) async {
    return await signInWithEmailAndPassword(email, password);
  }

  /// إنشاء حساب جديد (اسم مختلف للتوافق)
  Future<User?> signUpWithEmail(String email, String password) async {
    return await createUserWithEmailAndPassword(email, password);
  }

  /// تسجيل الدخول بـ Google (محاكاة)
  Future<User?> signInWithGoogle() async {
    try {
      debugPrint('🔄 تسجيل الدخول بـ Google (محاكاة)...');

      _currentUser = User(
        id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'google.user@gmail.com',
        displayName: 'Google User',
        isGuest: false,
        photoURL: 'https://via.placeholder.com/150',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        provider: AuthProvider.google,
        phoneNumber: null,
        isVerified: true,
      );

      debugPrint('✅ تم تسجيل الدخول بـ Google بنجاح (محاكاة)');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول بـ Google: $e');
      return null;
    }
  }

  /// تسجيل الدخول بـ Apple (محاكاة)
  Future<User?> signInWithApple() async {
    try {
      debugPrint('🔄 تسجيل الدخول بـ Apple (محاكاة)...');

      _currentUser = User(
        id: 'apple_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'apple.user@icloud.com',
        displayName: 'Apple User',
        isGuest: false,
        photoURL: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        provider: AuthProvider.apple,
        phoneNumber: null,
        isVerified: true,
      );

      debugPrint('✅ تم تسجيل الدخول بـ Apple بنجاح (محاكاة)');
      return _currentUser;
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الدخول بـ Apple: $e');
      return null;
    }
  }

  /// تسجيل الدخول كضيف (اسم مختلف للتوافق)
  Future<User?> signInAsGuest() async {
    return await signInAnonymously();
  }

  /// التحقق من المصادقة
  bool get isAuthenticated => isSignedIn;

  /// خصائص إضافية للتوافق
  bool get isAnonymous => isGuest;

  /// دوال مراقبة الأحداث (للتوافق)
  void addAuthListener(Function(User?) listener) {
    // للتوافق مع الكود القديم - لا تفعل شيئاً حالياً
    debugPrint('🔧 Auth listener added (compatibility mode)');
  }

  void removeAuthListener(Function(User?) listener) {
    // للتوافق مع الكود القديم - لا تفعل شيئاً حالياً
    debugPrint('🔧 Auth listener removed (compatibility mode)');
  }
}

/// كلاس مساعد للأخطاء
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException: $code - $message';
}
