import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart';
import '../models/complete_user_models.dart' as models;

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  models.User? _currentUser;
  final List<Function(models.User?)> _authListeners = [];

  // Encryption for sensitive data
  late final Encrypter _encrypter;
  late final IV _iv;

  // الحصول على المستخدم الحالي
  models.User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isGuest => _currentUser?.isGuest == true;
  bool get isLoggedIn => _currentUser != null;

  // Stream للمستخدم
  Stream<models.User?> get userStream => 
    _auth.authStateChanges().map((user) => user != null ? _convertFirebaseUser(user) : null);

  // تهيئة الخدمة
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      // إعداد التشفير
      final key = Key.fromSecureRandom(32);
      _iv = IV.fromSecureRandom(16);
      _encrypter = Encrypter(AES(key));

      // الاستماع لتغييرات حالة المصادقة
      _auth.authStateChanges().listen(_onAuthStateChanged);

      // تحميل المستخدم الحالي إذا كان موجوداً
      if (_auth.currentUser != null) {
        await _loadCurrentUser();
      } else {
        await _loadUserFromStorage();
      }

      print('FirebaseAuthService initialized successfully');
    } catch (e) {
      print('Error initializing FirebaseAuthService: $e');
    }
  }

  // تسجيل الدخول بالإيميل وكلمة المرور
  Future<AuthResult> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _loadCurrentUser();
        await _saveUserToStorage(_currentUser!);
        return AuthResult.success(_currentUser, message: 'تم تسجيل الدخول بنجاح');
      }
      
      return AuthResult.failure('فشل في تسجيل الدخول');
    } catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // إنشاء حساب جديد
  Future<AuthResult> createUserWithEmailPassword(
    String email, 
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // تحديث اسم المستخدم
        if (displayName != null && displayName.isNotEmpty) {
          await credential.user!.updateDisplayName(displayName);
        }
        
        await _loadCurrentUser();
        await _saveUserToStorage(_currentUser!);
        return AuthResult.success(_currentUser, message: 'تم إنشاء الحساب بنجاح');
      }
      
      return AuthResult.failure('فشل في إنشاء الحساب');
    } catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // تسجيل الدخول بجوجل
  Future<AuthResult> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.failure('تم إلغاء تسجيل الدخول');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _loadCurrentUser();
        await _saveUserToStorage(_currentUser!);
        return AuthResult.success(_currentUser, message: 'تم تسجيل الدخول بجوجل بنجاح');
      }
      
      return AuthResult.failure('فشل في تسجيل الدخول بجوجل');
    } catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // تسجيل الدخول بـ Apple
  Future<AuthResult> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      if (!await SignInWithApple.isAvailable()) {
        return AuthResult.failure('تسجيل الدخول بـ Apple غير متاح على هذا الجهاز');
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create OAuth credential for Firebase
      final oauthCredential = firebase_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      
      if (userCredential.user != null) {
        // Update display name if provided by Apple
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          final displayName = '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'.trim();
          if (displayName.isNotEmpty) {
            await userCredential.user!.updateDisplayName(displayName);
          }
        }
        
        await _loadCurrentUser();
        await _saveUserToStorage(_currentUser!);
        return AuthResult.success(_currentUser, message: 'تم تسجيل الدخول بـ Apple بنجاح');
      }

      return AuthResult.failure('فشل في تسجيل الدخول بـ Apple');
    } catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // تسجيل الدخول كضيف
  Future<AuthResult> signInAsGuest() async {
    try {
      final guestUser = _createGuestUser();
      _currentUser = guestUser;
      await _saveUserToStorage(guestUser);
      _notifyListeners();
      return AuthResult.success(guestUser, message: 'تم الدخول كضيف');
    } catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // دخول سريع للتطوير
  Future<AuthResult> quickSignIn({
    required String email,
    required String password,
  }) async {
    try {
      // محاولة تسجيل الدخول أولاً
      final signInResult = await signInWithEmailPassword(email, password);
      if (signInResult.isSuccess) {
        return signInResult;
      }

      // إذا فشل، إنشاء حساب جديد
      final signUpResult = await createUserWithEmailPassword(
        email,
        password,
        displayName: 'مستخدم تجريبي',
      );

      return signUpResult;
    } catch (e) {
      return AuthResult.failure(_getErrorMessage(e));
    }
  }

  // تحديث الملف الشخصي
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        if (displayName != null) {
          await user.updateDisplayName(displayName);
        }
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await _loadCurrentUser();
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();

      _currentUser = null;
      await _clearUserFromStorage();
      _notifyListeners();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // تحميل بيانات المستخدم الحالي
  Future<void> _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      _currentUser = _convertFirebaseUser(user);
      _notifyListeners();
    }
  }

  // تحويل Firebase User إلى نموذج التطبيق
  models.User _convertFirebaseUser(firebase_auth.User firebaseUser) {
    return models.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? 'مستخدم',
      photoURL: firebaseUser.photoURL,
      isGuest: false,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
      provider: _getAuthProvider(firebaseUser),
      gems: 100, // افتراضي
      level: 1,
      experience: 0,
      achievements: [],
      settings: {},
      preferences: {},
      linkedProviders: [_getAuthProvider(firebaseUser)],
      linkedAccounts: [],
      profile: models.UserProfile(
        isEmailVerified: firebaseUser.emailVerified,
        isPhoneVerified: false,
        preferences: const models.UserPreferences(),
        gameStats: models.GameStats(
          userId: firebaseUser.uid,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  // إنشاء مستخدم ضيف
  models.User _createGuestUser() {
    final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    return models.User(
      id: guestId,
      email: '',
      displayName: 'ضيف',
      isGuest: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      provider: models.AuthProvider.guest,
      gems: 50, // أقل من المستخدم المسجل
      level: 1,
      experience: 0,
      achievements: [],
      settings: {},
      preferences: {},
      linkedProviders: [models.AuthProvider.guest],
      linkedAccounts: [],
      profile: models.UserProfile(
        isEmailVerified: false,
        isPhoneVerified: false,
        preferences: const models.UserPreferences(),
        gameStats: models.GameStats(
          userId: guestId,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  // تحديد نوع مقدم الخدمة
  models.AuthProvider _getAuthProvider(firebase_auth.User user) {
    if (user.providerData.isEmpty) return models.AuthProvider.email;
    
    final providerId = user.providerData.first.providerId;
    switch (providerId) {
      case 'google.com':
        return models.AuthProvider.google;
      case 'apple.com':
        return models.AuthProvider.apple;
      default:
        return models.AuthProvider.email;
    }
  }

  // معالجة تغيير حالة المصادقة
  void _onAuthStateChanged(firebase_auth.User? user) {
    if (user == null) {
      // إذا لم يكن مستخدم ضيف، امسح البيانات
      if (_currentUser?.isGuest != true) {
        _currentUser = null;
      }
    } else {
      _currentUser = _convertFirebaseUser(user);
    }
    _notifyListeners();
  }

  // حفظ المستخدم في التخزين المحلي
  Future<void> _saveUserToStorage(models.User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      final encrypted = _encrypter.encrypt(userJson, iv: _iv);
      await prefs.setString('firebase_user_encrypted', encrypted.base64);
      await prefs.setString('firebase_user_iv', _iv.base64);
    } catch (e) {
      print('Error saving user to storage: $e');
    }
  }

  // تحميل المستخدم من التخزين المحلي
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedData = prefs.getString('firebase_user_encrypted');
      final ivData = prefs.getString('firebase_user_iv');
      
      if (encryptedData != null && ivData != null) {
        final encrypted = Encrypted.fromBase64(encryptedData);
        final iv = IV.fromBase64(ivData);
        final decrypted = _encrypter.decrypt(encrypted, iv: iv);
        final userMap = jsonDecode(decrypted) as Map<String, dynamic>;
        _currentUser = models.User.fromJson(userMap);
        _notifyListeners();
      }
    } catch (e) {
      print('Error loading user from storage: $e');
      await _clearUserFromStorage();
    }
  }

  // مسح المستخدم من التخزين المحلي
  Future<void> _clearUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('firebase_user_encrypted');
      await prefs.remove('firebase_user_iv');
    } catch (e) {
      print('Error clearing user storage: $e');
    }
  }

  // إضافة مستمع
  void addAuthListener(Function(models.User?) listener) {
    _authListeners.add(listener);
  }

  // إزالة مستمع
  void removeAuthListener(Function(models.User?) listener) {
    _authListeners.remove(listener);
  }

  // إشعار المستمعين
  void _notifyListeners() {
    for (final listener in _authListeners) {
      listener(_currentUser);
    }
  }

  // رسائل الأخطاء
  String _getErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'لم يتم العثور على المستخدم';
        case 'wrong-password':
          return 'كلمة المرور غير صحيحة';
        case 'email-already-in-use':
          return 'البريد الإلكتروني مستخدم بالفعل';
        case 'weak-password':
          return 'كلمة المرور ضعيفة';
        case 'invalid-email':
          return 'البريد الإلكتروني غير صحيح';
        default:
          return 'حدث خطأ: ${error.message}';
      }
    }
    return 'حدث خطأ غير متوقع';
  }
}

// نموذج نتيجة المصادقة
class AuthResult {
  final bool isSuccess;
  final models.User? user;
  final String? message;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.message,
    this.error,
  });

  factory AuthResult.success(models.User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
