import 'package:flutter/material.dart';
import '../services/unified_auth_services.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_sizes.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late TabController _tabController;
  final PageController _pageController = PageController();

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsiveSizes = ResponsiveSizes(context);
    final isDesktopOrTablet =
        responsiveSizes.deviceType == ResponsiveDeviceType.desktop ||
        responsiveSizes.deviceType == ResponsiveDeviceType.tablet;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.secondary.withValues(alpha: 0.05),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: isDesktopOrTablet
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 400,
        margin: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Card(
          elevation: 12,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surfaceLight, AppColors.surface],
              ),
            ),
            child: _buildAuthContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          children: [
            const SizedBox(height: 48),
            _buildLogo(),
            const SizedBox(height: 48),
            _buildAuthContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.grid_3x3_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        Text(
          'Tic Tac Toe',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingSM),
        Text(
          'اهلاً بك في اللعبة الأفضل',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthContent() {
    final responsiveSizes = ResponsiveSizes(context);
    final screenHeight = MediaQuery.of(context).size.height;

    // حساب الارتفاع المناسب حسب نوع الجهاز
    double formHeight;
    switch (responsiveSizes.deviceType) {
      case ResponsiveDeviceType.mobile:
        formHeight = screenHeight * 0.6; // 60% من ارتفاع الشاشة
        break;
      case ResponsiveDeviceType.tablet:
        formHeight = screenHeight * 0.5; // 50% من ارتفاع الشاشة
        break;
      case ResponsiveDeviceType.desktop:
        formHeight = 500; // ارتفاع ثابت للديسكتوب
        break;
    }

    return Column(
      children: [
        _buildTabBar(),
        SizedBox(height: responsiveSizes.paddingLarge),
        SizedBox(
          height: formHeight,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _tabController.animateTo(index);
            },
            children: [_buildLoginForm(), _buildSignUpForm()],
          ),
        ),
        _buildQuickSignInButton(), // زر الدخول السريع
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        color: AppColors.surface,
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'تسجيل الدخول'),
          Tab(text: 'إنشاء حساب'),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    final responsiveSizes = ResponsiveSizes(context);

    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildTextField(
          controller: _passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        SizedBox(height: responsiveSizes.paddingLarge),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Implement forgot password
              },
              child: Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: responsiveSizes.textSizes.body,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: responsiveSizes.paddingXLarge),
        _buildLoginButton(),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildDivider(),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildSocialLogins(),
      ],
    );
  }

  Widget _buildSignUpForm() {
    final responsiveSizes = ResponsiveSizes(context);

    return Column(
      children: [
        _buildTextField(
          controller: _displayNameController,
          label: 'اسم المستخدم',
          icon: Icons.person_outline,
        ),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildTextField(
          controller: _emailController,
          label: 'البريد الإلكتروني',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildTextField(
          controller: _passwordController,
          label: 'كلمة المرور',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildTextField(
          controller: _confirmPasswordController,
          label: 'تأكيد كلمة المرور',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
        ),
        SizedBox(height: responsiveSizes.paddingXLarge),
        _buildSignUpButton(),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildDivider(),
        SizedBox(height: responsiveSizes.paddingLarge),
        _buildSocialLogins(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            borderSide: BorderSide(
              color: AppColors.borderPrimary.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    final responsiveSizes = ResponsiveSizes(context);
    final buttonSizes = responsiveSizes.buttonSizes;

    return SizedBox(
      width: double.infinity,
      height: buttonSizes.height,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonSizes.borderRadius),
          ),
          padding: buttonSizes.padding,
        ),
        child: _isLoading
            ? SizedBox(
                height: buttonSizes.iconSize,
                width: buttonSizes.iconSize,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: buttonSizes.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    final responsiveSizes = ResponsiveSizes(context);
    final buttonSizes = responsiveSizes.buttonSizes;

    return SizedBox(
      width: double.infinity,
      height: buttonSizes.height,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppColors.secondary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonSizes.borderRadius),
          ),
          padding: buttonSizes.padding,
        ),
        child: _isLoading
            ? SizedBox(
                height: buttonSizes.iconSize,
                width: buttonSizes.iconSize,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: buttonSizes.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.borderPrimary.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMD,
          ),
          child: Text(
            'أو',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.borderPrimary.withValues(alpha: 0.3),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogins() {
    return Column(
      children: [
        _buildSocialLoginButton(
          label: 'الدخول مع Google',
          icon: Icons.g_mobiledata,
          color: Colors.red,
          onPressed: _handleGoogleSignIn,
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        _buildSocialLoginButton(
          label: 'الدخول مع Apple',
          icon: Icons.apple,
          color: Colors.black,
          onPressed: _handleAppleSignIn,
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        _buildSocialLoginButton(
          label: 'الدخول مع Google Play Games',
          icon: Icons.videogame_asset,
          color: Colors.green.shade700,
          onPressed: _handleGooglePlayGamesSignIn,
        ),
        const SizedBox(height: AppDimensions.paddingXL),
        _buildDivider(),
        const SizedBox(height: AppDimensions.paddingLG),
        _buildQuickSignInButton(),
        const SizedBox(height: AppDimensions.paddingMD),
        _buildGuestButton(),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final responsiveSizes = ResponsiveSizes(context);
    final buttonSizes = responsiveSizes.buttonSizes;

    return SizedBox(
      width: double.infinity,
      height: buttonSizes.height * 0.85, // أصغر قليلاً من الأزرار الأساسية
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: Icon(icon, color: color, size: buttonSizes.iconSize),
        label: Text(
          label,
          style: TextStyle(
            fontSize: buttonSizes.fontSize * 0.9,
            color: AppColors.textSecondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonSizes.borderRadius),
          ),
          padding: buttonSizes.padding,
        ),
      ),
    );
  }

  Widget _buildGuestButton() {
    final responsiveSizes = ResponsiveSizes(context);
    final buttonSizes = responsiveSizes.buttonSizes;

    return SizedBox(
      width: double.infinity,
      height: buttonSizes.height * 0.85, // أصغر قليلاً من الأزرار الأساسية
      child: TextButton.icon(
        onPressed: _isLoading ? null : _handleContinueAsGuest,
        icon: Icon(
          Icons.person_outline,
          color: AppColors.textSecondary,
          size: buttonSizes.iconSize,
        ),
        label: Text(
          'متابعة كضيف',
          style: TextStyle(
            fontSize: buttonSizes.fontSize * 0.9,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonSizes.borderRadius),
            side: BorderSide(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          padding: buttonSizes.padding,
        ),
      ),
    );
  }

  Widget _buildQuickSignInButton() {
    final responsiveSizes = ResponsiveSizes(context);
    final buttonSizes = responsiveSizes.buttonSizes;

    return SizedBox(
      width: double.infinity,
      height: buttonSizes.height * 0.85,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleQuickSignIn,
        icon: Icon(
          Icons.flash_on,
          color: Colors.orange,
          size: buttonSizes.iconSize,
        ),
        label: Text(
          'دخول سريع (تطوير)',
          style: TextStyle(
            fontSize: buttonSizes.fontSize * 0.9,
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonSizes.borderRadius),
            side: BorderSide(color: Colors.orange.withValues(alpha: 0.5)),
          ),
          padding: buttonSizes.padding,
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('يرجى ملء جميع الحقول');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      debugPrint('🔄 Starting login process...');
      final result = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      debugPrint('📋 Login result: ${result != null ? 'Success' : 'Failed'}');
      if (result != null) {
        debugPrint('✅ Login successful, navigating to home');
        _navigateToHome(); // دخول مباشر بدون رسائل
      } else {
        debugPrint('❌ Login failed');
        _showErrorSnackBar('خطأ في تسجيل الدخول');
      }
    } catch (e) {
      debugPrint('💥 Login exception: $e'); // Debug log
      _showErrorSnackBar('خطأ في تسجيل الدخول');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignUp() async {
    // التحقق من الحقول المطلوبة
    if (_displayNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    // التحقق من صحة البريد الإلكتروني
    if (!_isValidEmail(_emailController.text.trim())) {
      _showErrorSnackBar('يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    // التحقق من طول كلمة المرور
    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    // التحقق من تطابق كلمات المرور
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('كلمات المرور غير متطابقة');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Starting sign up process...');
      final result = await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      debugPrint('📋 Sign up result: ${result != null ? 'Success' : 'Failed'}');
      if (result != null) {
        debugPrint('✅ Sign up successful, navigating to home');
        _navigateToHome(); // دخول مباشر بدون رسائل
      } else {
        debugPrint('❌ Sign up failed');
        _showErrorSnackBar('خطأ في إنشاء الحساب');
      }
    } catch (e) {
      debugPrint('❌ Sign up exception: $e');
      _showErrorSnackBar('خطأ في إنشاء الحساب');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Starting Google sign in...');
      final result = await _authService.signInWithGoogle();
      debugPrint(
        '📋 Google sign in result: ${result != null ? 'Success' : 'Failed'}',
      );
      if (result != null) {
        debugPrint('✅ Google sign in successful');
        _navigateToHome(); // دخول مباشر بدون رسائل
      } else {
        debugPrint('❌ Google sign in failed');
        _showErrorSnackBar('خطأ في تسجيل الدخول');
      }
    } catch (e) {
      debugPrint('❌ Google sign in exception: $e');
      _showErrorSnackBar('خطأ في تسجيل الدخول');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Starting Apple sign in...');
      final result = await _authService.signInWithApple();
      debugPrint(
        '📋 Apple sign in result: ${result != null ? 'Success' : 'Failed'}',
      );
      if (result != null) {
        debugPrint('✅ Apple sign in successful');
        _navigateToHome(); // دخول مباشر بدون رسائل
      } else {
        debugPrint('❌ Apple sign in failed');
        _showErrorSnackBar('خطأ في تسجيل الدخول');
      }
    } catch (e) {
      debugPrint('❌ Apple sign in exception: $e');
      _showErrorSnackBar('خطأ في تسجيل الدخول');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGooglePlayGamesSignIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // استخدام Google Sign-In العادي
      final result = await _authService.signInWithGoogle();
      if (result != null) {
        _navigateToHome();
      } else {
        _showErrorSnackBar('حدث خطأ أثناء تسجيل الدخول');
      }
    } catch (e) {
      debugPrint('Google Play Games sign in error: $e'); // Debug log
      _showErrorSnackBar('حدث خطأ غير متوقع: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleContinueAsGuest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Starting guest mode...');
      await _authService.signInAsGuest();
      debugPrint('✅ Guest mode successful, navigating to home');
      _navigateToHome();
    } catch (e) {
      debugPrint('💥 Guest mode exception: $e');
      _showErrorSnackBar('خطأ في وضع الضيف');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleQuickSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // استخدام بيانات تجريبية أو البيانات المدخلة
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      if (email.isEmpty) email = 'test@example.com';
      if (password.isEmpty) password = '123456';

      final result = await _authService.signInWithEmail(email, password);

      if (result != null) {
        _navigateToHome();
      } else {
        _showErrorSnackBar('خطأ في الدخول السريع');
      }
    } catch (e) {
      _showErrorSnackBar('خطأ في الدخول السريع');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
