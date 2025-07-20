import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'screens/modern_home_screen.dart';
import 'screens/modern_auth_screen.dart';
import 'design_system/modern_theme.dart';
import 'services/unified_auth_services.dart';

// ======================================================================
// 🚀 TIC TAC TOE - تطبيق حديث بالكامل
// إعادة تصميم شاملة بأسلوب مجري
// ======================================================================

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase إذا لم يكن مهيأً مسبقاً
  if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
  }

  // تهيئة خدمة المصادقة المحسنة
  await FirebaseAuthService().initialize();

  // تعيين اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تعيين شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ModernTicTacToeApp());
}

/// التطبيق الرئيسي بالتصميم الحديث
class ModernTicTacToeApp extends StatelessWidget {
  const ModernTicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe - Modern',
      debugShowCheckedModeBanner: false,

      // التصميم الحديث
      theme: ModernThemeManager.lightTheme,

      // الشاشة الرئيسية
      home: const AppRouter(),

      // دعم الاتجاه من اليمين لليسار للعربية
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },

      // المسارات
      routes: {
        '/home': (context) => const ModernHomeScreen(),
        '/auth': (context) => const ModernAuthScreen(),
      },
    );
  }
}

/// موجه التطبيق - يحدد الشاشة المناسبة بناءً على حالة المصادقة
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1500)); // شاشة splash

      final user = await _authService.getCurrentUser();
      setState(() {
        _isAuthenticated = user != null && !user.isGuest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ModernSplashScreen();
    }

    // دائماً عرض الشاشة الرئيسية - سيتم التعامل مع المصادقة بداخلها
    return const ModernHomeScreen();
  }
}

/// شاشة البداية الحديثة
class ModernSplashScreen extends StatelessWidget {
  const ModernSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ModernDesignSystem.primaryGradient,
        ),
        child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              // شعار التطبيق مع تحريكة
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                  child: Container(
                      width: 120,
                      height: 120,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(ModernRadius.xxl),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: ModernDesignSystem.largeShadow,
                      ),
                      child: const Icon(
                        Icons.games,
                        size: 60,
                        color: Colors.white,
                    ),
                  ),
                );
              },
            ),

              const SizedBox(height: ModernSpacing.xxl),

              // عنوان التطبيق
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 2000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Column(
                      children: [
                        Text(
                          'X O لعبة',
                          style: ModernTextStyles.displayLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(height: ModernSpacing.sm),
                        Text(
                          'تصميم حديث ومجري',
                          style: ModernTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
          ),
        ],
      ),
    );
                },
              ),

              const SizedBox(height: ModernSpacing.xxxl),

              // مؤشر التحميل
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),

              const SizedBox(height: ModernSpacing.lg),

              Text(
                'جاري التحضير...',
                style: ModernTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
