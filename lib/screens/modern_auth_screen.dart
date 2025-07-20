import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../design_system/modern_theme.dart';
import '../design_system/modern_components.dart';
import '../services/unified_auth_services.dart';
import 'modern_home_screen.dart';

enum SocialPlatform { google, apple }

/// شاشة تسجيل الدخول الحديثة - تصميم جديد بالكامل
class ModernAuthScreen extends StatefulWidget {
  const ModernAuthScreen({super.key});

  @override
  State<ModernAuthScreen> createState() => _ModernAuthScreenState();
}

class _ModernAuthScreenState extends State<ModernAuthScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late AnimationController _backgroundController;
  late AnimationController _formController;
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentTab = 0; // 0: login, 1: register

  // متغيرات اختيار الصورة
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });

    _formController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [_buildAnimatedBackground(), _buildContent()]),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: ModernDesignSystem.oceanGradient,
      ),
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Stack(
            children: [
              // موجات متحركة
              ...List.generate(3, (index) {
                final progress =
                    (_backgroundController.value + index * 0.3) % 1.0;
                return Positioned(
                  left:
                      -200 +
                      (progress * (MediaQuery.of(context).size.width + 400)),
                  top: 100 + (index * 150.0),
                  child: Transform.rotate(
                    angle: progress * 6.28, // دوران كامل
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                );
              }),
              // جزيئات صغيرة
              ...List.generate(10, (index) {
                final offset = Offset(
                  (index * 50.0 + _backgroundController.value * 300) %
                      MediaQuery.of(context).size.width,
                  (index * 70.0 + _backgroundController.value * 100) %
                      MediaQuery.of(context).size.height,
                );

                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: Container(
                    width: 4 + (index % 3) * 2,
                    height: 4 + (index % 3) * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: AnimatedBuilder(
          animation: _formController,
          builder: (context, child) {
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ModernAnimations.fadeIn(child: _buildHeader()),
                const SizedBox(height: ModernSpacing.xxxl),
                ModernAnimations.fadeIn(
                  offset: const Offset(0, 50),
                  child: _buildAuthForm(),
                ),
                const SizedBox(height: ModernSpacing.xl),
                ModernAnimations.fadeIn(
                  offset: const Offset(0, 30),
                  child: _buildSocialLogin(),
                ),
                const SizedBox(height: ModernSpacing.lg),
                ModernAnimations.fadeIn(child: _buildGuestOption()),
                const SizedBox(height: ModernSpacing.lg),
                ModernAnimations.fadeIn(
                  child: Container(
                    padding: const EdgeInsets.all(ModernSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ModernRadius.md),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: ModernSpacing.xs),
                        Text(
                          'مدعوم بـ Firebase - آمن وموثوق',
                          style: ModernTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(ModernSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.lock_outlined, size: 60, color: Colors.white),
        ),
        const SizedBox(height: ModernSpacing.lg),
        Text(
          _currentTab == 0 ? 'مرحباً بعودتك!' : 'إنشاء حساب جديد',
          style: ModernTextStyles.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: ModernSpacing.sm),
        Text(
          _currentTab == 0 ? 'سجل دخولك للمتابعة' : 'انضم إلينا وابدأ التحدي',
          style: ModernTextStyles.bodyLarge.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(ModernRadius.xxl),
        boxShadow: ModernDesignSystem.largeShadow,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTabBar(),
            const SizedBox(height: ModernSpacing.xl),
            _buildFormFields(),
            const SizedBox(height: ModernSpacing.xl),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ModernColors.surfaceVariant,
        borderRadius: BorderRadius.circular(ModernRadius.md),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ModernColors.primary,
          borderRadius: BorderRadius.circular(ModernRadius.sm),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: ModernColors.textSecondary,
        labelStyle: ModernTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'تسجيل الدخول'),
          Tab(text: 'حساب جديد'),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _currentTab == 0 ? _buildLoginFields() : _buildRegisterFields(),
    );
  }

  Widget _buildLoginFields() {
    return Column(
      key: const ValueKey('login'),
      children: [
        ModernComponents.modernTextField(
          label: 'البريد الإلكتروني',
          hint: 'أدخل بريدك الإلكتروني',
          controller: _emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'بريد إلكتروني غير صالح';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernSpacing.lg),
        ModernComponents.modernTextField(
          label: 'كلمة المرور',
          hint: 'أدخل كلمة المرور',
          controller: _passwordController,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: _obscurePassword
              ? Icons.visibility
              : Icons.visibility_off,
          onSuffixTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernSpacing.md),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _forgotPassword,
            child: Text(
              'هل نسيت كلمة المرور؟',
              style: ModernTextStyles.bodyMedium.copyWith(
                color: ModernColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      key: const ValueKey('register'),
      children: [
        ModernComponents.modernTextField(
          label: 'الاسم الكامل',
          hint: 'أدخل اسمك الكامل',
          controller: _nameController,
          prefixIcon: Icons.person_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال الاسم';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernSpacing.lg),
        ModernComponents.modernTextField(
          label: 'البريد الإلكتروني',
          hint: 'أدخل بريدك الإلكتروني',
          controller: _emailController,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'بريد إلكتروني غير صالح';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernSpacing.lg),
        ModernComponents.modernTextField(
          label: 'كلمة المرور',
          hint: 'أدخل كلمة المرور (6 أحرف على الأقل)',
          controller: _passwordController,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: _obscurePassword
              ? Icons.visibility
              : Icons.visibility_off,
          onSuffixTap: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
            }
            if (value.length < 6) {
              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
            }
            return null;
          },
        ),
        const SizedBox(height: ModernSpacing.lg),
        ModernComponents.modernTextField(
          label: 'تأكيد كلمة المرور',
          hint: 'أعد إدخال كلمة المرور',
          controller: _confirmPasswordController,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: _obscureConfirmPassword
              ? Icons.visibility
              : Icons.visibility_off,
          onSuffixTap: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
          obscureText: _obscureConfirmPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى تأكيد كلمة المرور';
            }
            if (value != _passwordController.text) {
              return 'كلمات المرور غير متطابقة';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ModernComponents.modernButton(
        text: _currentTab == 0 ? 'تسجيل الدخول' : 'إنشاء الحساب',
        onPressed: _isLoading ? null : _handleSubmit,
        icon: _currentTab == 0 ? Icons.login : Icons.person_add,
        gradient: ModernDesignSystem.primaryGradient,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Container(
      padding: const EdgeInsets.all(ModernSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(ModernRadius.xl),
        boxShadow: ModernDesignSystem.mediumShadow,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'أو تسجيل الدخول باستخدام',
            style: ModernTextStyles.bodyLarge.copyWith(
              color: ModernColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ModernSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  text: 'Google',
                  color: const Color(0xFF4285F4),
                  onPressed: () => _handleSocialLogin(SocialPlatform.google),
                ),
              ),
              const SizedBox(width: ModernSpacing.md),
              Expanded(
                child: _buildSocialButton(
                  icon: Icons.apple,
                  text: 'Apple',
                  color: const Color(0xFF000000),
                  onPressed: () => _handleSocialLogin(SocialPlatform.apple),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ModernRadius.lg),
            side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ModernSpacing.md,
            vertical: ModernSpacing.sm,
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24, color: color),
                  const SizedBox(width: ModernSpacing.xs),
                  Text(
                    text,
                    style: ModernTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGuestOption() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ModernSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(ModernRadius.xl),
        boxShadow: ModernDesignSystem.mediumShadow,
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.flash_on, size: 32, color: ModernColors.secondary),
          const SizedBox(height: ModernSpacing.sm),
          Text(
            'دخول سريع',
            style: ModernTextStyles.titleLarge.copyWith(
              color: ModernColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernSpacing.xs),
          Text(
            'ادخل واستمتع باللعب مباشرة بدون تسجيل',
            style: ModernTextStyles.bodyMedium.copyWith(
              color: ModernColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ModernSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ModernComponents.modernButton(
              text: 'ابدأ اللعب الآن',
              onPressed: _isLoading ? null : _handleGuestLogin,
              backgroundColor: ModernColors.secondary,
              textColor: Colors.white,
              icon: Icons.play_arrow,
            ),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      if (_currentTab == 0) {
        // تسجيل الدخول
        final result = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (result != null) {
          _navigateToHome();
        } else {
          _showErrorMessage('بيانات تسجيل الدخول غير صحيحة');
        }
      } else {
        // إنشاء حساب جديد
        final result = await _authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (result != null) {
          _navigateToHome();
        } else {
          _showErrorMessage('فشل في إنشاء الحساب');
        }
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ غير متوقع');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGuestLogin() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final result = await _authService.signInAsGuest();
      if (result != null) {
        _navigateToHome();
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ في الدخول كضيف');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSocialLogin(SocialPlatform platform) async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final result = await _authService.signInWithSocial(platform);
      if (result != null) {
        _navigateToHome();
      } else {
        _showErrorMessage('فشل في تسجيل الدخول باستخدام $platform');
      }
    } catch (e) {
      _showErrorMessage(
        'حدث خطأ غير متوقع عند تسجيل الدخول باستخدام $platform',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _forgotPassword() {
    // TODO: تطبيق استرداد كلمة المرور
    _showInfoMessage(
      'سيتم إرسال رابط استرداد كلمة المرور إلى بريدك الإلكتروني',
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ModernHomeScreen()),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernRadius.md),
        ),
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernRadius.md),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // 🔄 الوظائف الجديدة المطلوبة
  // ------------------------------------------------------------------

  /// نسيت كلمة المرور
  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('يرجى إدخال البريد الإلكتروني أولاً');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());

      _showSuccessDialog(
        'تم الإرسال!',
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
      );
    } catch (e) {
      _showErrorMessage('خطأ في إرسال رابط إعادة التعيين');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// تسجيل دخول سريع (باستخدام بيانات تجريبية)
  Future<void> _handleQuickLogin() async {
    setState(() => _isLoading = true);

    try {
      // استخدام حساب تجريبي
      final result = await _authService.signInWithEmailAndPassword(
        'test@example.com',
        'test123',
      );

      if (result != null) {
        _navigateToHome();
      } else {
        _showErrorMessage('الحساب التجريبي غير متاح');
      }
    } catch (e) {
      _showErrorMessage('خطأ في الدخول السريع');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// اختيار صورة الملف الشخصي
  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorMessage('خطأ في اختيار الصورة');
    }
  }

  /// حذف الصورة المختارة
  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  /// إظهار رسالة نجاح مع حوار
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ModernRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: ModernColors.success),
            const SizedBox(width: ModernSpacing.sm),
            Text(
              title,
              style: ModernTextStyles.titleLarge.copyWith(
                color: ModernColors.success,
              ),
            ),
          ],
        ),
        content: Text(message, style: ModernTextStyles.bodyMedium),
        actions: [
          ModernComponents.modernButton(
            text: 'حسناً',
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: ModernColors.success,
            isSmall: true,
          ),
        ],
      ),
    );
  }
}
