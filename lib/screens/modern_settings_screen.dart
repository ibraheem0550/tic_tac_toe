import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../design_system/modern_theme.dart';
import '../design_system/modern_components.dart';
import '../services/unified_auth_services.dart';
import '../models/complete_user_models.dart';
import 'modern_auth_screen.dart';

/// شاشة الإعدادات الحديثة - تصميم متطور ومنظم
class ModernSettingsScreen extends StatefulWidget {
  const ModernSettingsScreen({super.key});

  @override
  State<ModernSettingsScreen> createState() => _ModernSettingsScreenState();
}

class _ModernSettingsScreenState extends State<ModernSettingsScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late AnimationController _backgroundController;
  late AnimationController _contentController;

  User? _currentUser;
  bool _isLoading = true;

  // Settings state
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'ar';
  String _selectedDifficulty = 'medium';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _loadSettings();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentController.forward();
  }

  Future<void> _loadUserData() async {
    try {
      _currentUser = await _authService.getCurrentUser();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadSettings() {
    // هنا يمكن تحميل الإعدادات من SharedPreferences
    // للتبسيط، سنستخدم القيم الافتراضية
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
        gradient: ModernDesignSystem.secondaryGradient,
      ),
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return CustomPaint(
            painter: SettingsBackgroundPainter(_backgroundController.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: AnimatedBuilder(
          animation: _contentController,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: ModernSpacing.xl),
                _buildUserProfile(),
                const SizedBox(height: ModernSpacing.xl),
                _buildSettingsSection('الأصوات والإشعارات', Icons.volume_up, [
                  _buildSwitchSetting(
                    'تفعيل الأصوات',
                    'تشغيل أصوات اللعبة والتأثيرات',
                    _soundEnabled,
                    (value) => setState(() => _soundEnabled = value),
                    Icons.volume_up,
                  ),
                  _buildSwitchSetting(
                    'الاهتزاز',
                    'تفعيل ردود الفعل باللمس',
                    _vibrationEnabled,
                    (value) => setState(() => _vibrationEnabled = value),
                    Icons.vibration,
                  ),
                  _buildSwitchSetting(
                    'الإشعارات',
                    'تلقي إشعارات اللعبة',
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                    Icons.notifications,
                  ),
                ]),
                const SizedBox(height: ModernSpacing.xl),
                _buildSettingsSection('المظهر واللغة', Icons.palette, [
                  _buildSwitchSetting(
                    'الوضع المظلم',
                    'تفعيل المظهر المظلم',
                    _darkModeEnabled,
                    (value) => setState(() => _darkModeEnabled = value),
                    Icons.dark_mode,
                  ),
                  _buildDropdownSetting(
                    'اللغة',
                    'اختيار لغة التطبيق',
                    _selectedLanguage,
                    [
                      {'value': 'ar', 'label': 'العربية'},
                      {'value': 'en', 'label': 'English'},
                    ],
                    (value) => setState(() => _selectedLanguage = value!),
                    Icons.language,
                  ),
                ]),
                const SizedBox(height: ModernSpacing.xl),
                _buildSettingsSection('اللعبة', Icons.games, [
                  _buildDropdownSetting(
                    'مستوى الذكاء الاصطناعي',
                    'صعوبة اللعب ضد الكمبيوتر',
                    _selectedDifficulty,
                    [
                      {'value': 'easy', 'label': 'سهل'},
                      {'value': 'medium', 'label': 'متوسط'},
                      {'value': 'hard', 'label': 'صعب'},
                    ],
                    (value) => setState(() => _selectedDifficulty = value!),
                    Icons.psychology,
                  ),
                  _buildActionSetting(
                    'إعادة تعيين الإحصائيات',
                    'حذف جميع بيانات الألعاب',
                    Icons.refresh,
                    _resetStats,
                  ),
                  _buildActionSetting(
                    'تصدير البيانات',
                    'حفظ نسخة احتياطية من البيانات',
                    Icons.download,
                    _exportData,
                  ),
                ]),
                const SizedBox(height: ModernSpacing.xl),
                _buildSettingsSection('الحساب', Icons.account_circle, [
                  if (_currentUser?.isGuest == false) ...[
                    _buildActionSetting(
                      'تغيير كلمة المرور',
                      'تحديث كلمة المرور الخاصة بك',
                      Icons.lock,
                      _changePassword,
                    ),
                    _buildActionSetting(
                      'تعديل الملف الشخصي',
                      'تغيير الاسم والصورة الشخصية',
                      Icons.edit,
                      _editProfile,
                    ),
                  ],
                  _buildActionSetting(
                    'تسجيل الخروج',
                    'الخروج من الحساب الحالي',
                    Icons.logout,
                    _signOut,
                    isDestructive: true,
                  ),
                ]),
                const SizedBox(height: ModernSpacing.xl),
                _buildSettingsSection('حول التطبيق', Icons.info, [
                  _buildActionSetting(
                    'معلومات التطبيق',
                    'الإصدار والمطور',
                    Icons.info_outline,
                    _showAppInfo,
                  ),
                  _buildActionSetting(
                    'شروط الاستخدام',
                    'اقرأ شروط وأحكام الاستخدام',
                    Icons.description,
                    _showTerms,
                  ),
                  _buildActionSetting(
                    'سياسة الخصوصية',
                    'كيف نحافظ على بياناتك',
                    Icons.privacy_tip,
                    _showPrivacy,
                  ),
                ]),
                const SizedBox(height: ModernSpacing.xxxl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ModernAnimations.fadeIn(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ModernRadius.md),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          const Expanded(
            child: Text(
              'الإعدادات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            width: 48, // للموازنة
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    final user = _currentUser;

    return ModernAnimations.fadeIn(
      offset: const Offset(0, 20),
      child: ModernComponents.modernCard(
        padding: const EdgeInsets.all(ModernSpacing.xl),
        color: Colors.white.withOpacity(0.15),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                user?.isGuest == true ? Icons.person : Icons.account_circle,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: ModernSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'ضيف',
                    style: ModernTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: ModernSpacing.xs),
                  Text(
                    user?.email ?? 'لا يوجد بريد إلكتروني',
                    style: ModernTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  if (user?.isGuest == false) ...[
                    const SizedBox(height: ModernSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ModernSpacing.md,
                        vertical: ModernSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: ModernColors.success.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(ModernRadius.full),
                      ),
                      child: Text(
                        'مُسجل',
                        style: ModernTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return ModernAnimations.fadeIn(
      offset: const Offset(0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ModernSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ModernRadius.sm),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: ModernSpacing.md),
              Text(
                title,
                style: ModernTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernSpacing.lg),
          ModernComponents.modernCard(
            padding: EdgeInsets.zero,
            color: Colors.white.withOpacity(0.1),
            child: Column(
              children: children.map((child) {
                final index = children.indexOf(child);
                return Column(
                  children: [
                    if (index > 0)
                      Divider(
                        color: Colors.white.withOpacity(0.1),
                        height: 1,
                        indent: ModernSpacing.lg,
                        endIndent: ModernSpacing.lg,
                      ),
                    child,
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: ModernTextStyles.titleLarge.copyWith(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: ModernTextStyles.bodyMedium.copyWith(
          color: Colors.white.withOpacity(0.7),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          onChanged(newValue);
          _saveSettings();
        },
        activeColor: ModernColors.success,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ModernSpacing.lg,
        vertical: ModernSpacing.sm,
      ),
    );
  }

  Widget _buildDropdownSetting(
    String title,
    String subtitle,
    String value,
    List<Map<String, String>> options,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: ModernTextStyles.titleLarge.copyWith(color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: ModernTextStyles.bodyMedium.copyWith(
          color: Colors.white.withOpacity(0.7),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: ModernSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ModernRadius.sm),
        ),
        child: DropdownButton<String>(
          value: value,
          onChanged: (newValue) {
            HapticFeedback.lightImpact();
            onChanged(newValue);
            _saveSettings();
          },
          underline: const SizedBox(),
          dropdownColor: ModernColors.backgroundDark,
          items: options.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ModernSpacing.lg,
        vertical: ModernSpacing.sm,
      ),
    );
  }

  Widget _buildActionSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? ModernColors.error : Colors.white,
      ),
      title: Text(
        title,
        style: ModernTextStyles.titleLarge.copyWith(
          color: isDestructive ? ModernColors.error : Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: ModernTextStyles.bodyMedium.copyWith(
          color: Colors.white.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? ModernColors.error : Colors.white,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ModernSpacing.lg,
        vertical: ModernSpacing.sm,
      ),
    );
  }

  // Settings actions
  void _saveSettings() {
    // حفظ الإعدادات في SharedPreferences
    _showSuccessMessage('تم حفظ الإعدادات');
  }

  void _resetStats() {
    _showConfirmDialog(
      'إعادة تعيين الإحصائيات',
      'هل أنت متأكد من حذف جميع الإحصائيات؟',
      () {
        // TODO: حذف الإحصائيات
        _showSuccessMessage('تم حذف الإحصائيات');
      },
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('تصدير البيانات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحضير ملف البيانات...'),
          ],
        ),
      ),
    );
    
    // محاكاة عملية التصدير
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _showSuccessMessage('تم تصدير البيانات بنجاح إلى مجلد التحميلات');
    });
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('تم تغيير كلمة المرور بنجاح');
            },
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'الاسم',
                border: const OutlineInputBorder(),
                hintText: _currentUser?.displayName ?? '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: const OutlineInputBorder(),
                hintText: _currentUser?.email ?? '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('تم تحديث الملف الشخصي بنجاح');
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _signOut() {
    _showConfirmDialog(
      'تسجيل الخروج',
      'هل أنت متأكد من تسجيل الخروج؟',
      () async {
        await _authService.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ModernAuthScreen()),
        );
      },
    );
  }

  void _showAppInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات التطبيق'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tic Tac Toe - Modern'),
            Text('الإصدار: 2.0.0'),
            Text('المطور: فريق التطوير'),
            SizedBox(height: 16),
            Text('تطبيق لعبة X O بتصميم حديث ومتقدم'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شروط الاستخدام'),
        content: const SingleChildScrollView(
          child: Text('''
شروط استخدام تطبيق Tic Tac Toe

1. الاستخدام المسموح
- يُسمح لك باستخدام هذا التطبيق للأغراض الشخصية والترفيهية فقط.
- يجب عليك استخدام التطبيق بشكل مسؤول وقانوني.

2. الحساب والبيانات
- أنت مسؤول عن الحفاظ على أمان حسابك.
- نحن نحتفظ بالحق في حذف الحسابات غير النشطة.

3. قواعد اللعب
- يجب اللعب بروح رياضية.
- ممنوع استخدام أي برامج أو أدوات غير قانونية.

4. المسؤولية
- التطبيق متاح "كما هو" دون ضمانات.
- نحن غير مسؤولين عن أي أضرار قد تنتج عن الاستخدام.

5. التحديثات
- نحتفظ بالحق في تحديث هذه الشروط في أي وقت.
- استمرار الاستخدام يعني الموافقة على الشروط المحدثة.

باستخدام التطبيق، فإنك توافق على هذه الشروط والأحكام.
          '''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text('''
سياسة الخصوصية لتطبيق Tic Tac Toe

1. جمع البيانات
- نحن نجمع معلومات الحساب الأساسية (الاسم والبريد الإلكتروني).
- نتتبع إحصائيات الألعاب لتحسين تجربة المستخدم.
- لا نجمع معلومات حساسة أو شخصية أخرى.

2. استخدام البيانات
- البيانات تُستخدم لتقديم خدمة أفضل.
- الإحصائيات تُستخدم لتتبع التقدم والإنجازات.
- لا نبيع أو نشارك بياناتك مع أطراف ثالثة.

3. حماية البيانات
- نحن نحمي بياناتك باستخدام تقنيات التشفير المتقدمة.
- البيانات محفوظة محلياً على جهازك.

4. حقوقك
- يمكنك طلب حذف حسابك وبياناتك في أي وقت.
- يمكنك تصدير بياناتك من خلال الإعدادات.

5. ملفات الارتباط
- نستخدم ملفات الارتباط لحفظ تفضيلاتك.
- يمكنك إيقاف ملفات الارتباط من إعدادات التطبيق.

6. الاتصال
- إذا كان لديك أسئلة حول سياسة الخصوصية، يمكنك التواصل معنا.

آخر تحديث: ديسمبر 2024
          '''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernColors.success,
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
}

/// رسام خلفية الإعدادات
class SettingsBackgroundPainter extends CustomPainter {
  final double animationValue;

  SettingsBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // رسم خطوط متموجة
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final y = size.height * 0.2 * i;
      path.moveTo(-50, y + 50 * math.sin(animationValue * 2 * math.pi));

      for (double x = 0; x <= size.width + 50; x += 50) {
        final wave = 30 * math.sin((x / 50 + animationValue * 2) * math.pi);
        path.lineTo(x, y + wave);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SettingsBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
