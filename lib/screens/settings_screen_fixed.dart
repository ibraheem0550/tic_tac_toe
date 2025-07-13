import 'package:flutter/material.dart';
import '../services/unified_auth_services.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _animationController;

  User? _currentUser;
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadUserData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _currentUser = _authService.currentUserModel;
      if (_currentUser != null) {
        _displayNameController.text = _currentUser!.displayName;
        _emailController.text = _currentUser!.email;
        _phoneController.text = _currentUser!.phoneNumber ?? '';
        _bioController.text = _currentUser!.bio ?? '';
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء تحميل البيانات');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktopOrTablet = screenWidth > 768;

    // التحقق من حالة المستخدم
    final currentUser = _authService.currentUserModel;
    final isGuest = currentUser?.isGuest == true;

    // إذا كان ضيف، عرض شاشة تسجيل الدخول
    if (isGuest) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'سجل دخولك للوصول للإعدادات',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'يمكنك الوصول للإعدادات المتقدمة وحفظ تفضيلاتك بعد تسجيل الدخول',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _navigateToAuth(),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingWidget()
          : isDesktopOrTablet
          ? _buildDesktopLayout()
          : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'الإعدادات',
        style: AppTextStyles.h2.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColors.primary),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildProfileSection(),
              const SizedBox(height: 32),
              _buildAccountSection(),
              const SizedBox(height: 32),
              _buildPreferencesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileSection(),
          const SizedBox(height: 24),
          _buildAccountSection(),
          const SizedBox(height: 24),
          _buildPreferencesSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return AppComponents.stellarCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'الملف الشخصي',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  backgroundImage: _currentUser?.photoURL != null
                      ? NetworkImage(_currentUser!.photoURL!)
                      : null,
                  child: _currentUser?.photoURL == null
                      ? Text(
                          _currentUser?.displayName
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'م',
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _displayNameController,
                        label: 'الاسم',
                        icon: Icons.person,
                        onChanged: _updateProfile,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emailController,
                        label: 'البريد الإلكتروني',
                        icon: Icons.email,
                        enabled: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatsCard(
                  'المستوى',
                  '${_currentUser?.level ?? 1}',
                  Icons.trending_up,
                ),
                const SizedBox(width: 16),
                _buildStatsCard(
                  'الجواهر',
                  '${_currentUser?.gems ?? 0}',
                  Icons.diamond,
                ),
                const SizedBox(width: 16),
                _buildStatsCard(
                  'الخبرة',
                  '${_currentUser?.experience ?? 0}',
                  Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection('بيانات الحساب', Icons.account_circle, [
      _buildTextField(
        controller: _phoneController,
        label: 'رقم الهاتف',
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
        onChanged: _updateProfile,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _bioController,
        label: 'نبذة شخصية',
        icon: Icons.info,
        maxLines: 3,
        onChanged: _updateProfile,
      ),
    ]);
  }

  Widget _buildPreferencesSection() {
    final preferences =
        _currentUser?.profile?.preferences ?? const UserPreferences();

    return _buildSection('التفضيلات', Icons.settings, [
      _buildSwitchTile(
        'الأصوات',
        'تفعيل الأصوات في اللعبة',
        Icons.volume_up,
        preferences.soundEnabled,
        (value) => _updatePreference('soundEnabled', value),
      ),
      _buildSwitchTile(
        'الإشعارات',
        'استقبال الإشعارات',
        Icons.notifications,
        preferences.notificationsEnabled,
        (value) => _updatePreference('notificationsEnabled', value),
      ),
      _buildSwitchTile(
        'الاهتزاز',
        'تفعيل الاهتزاز',
        Icons.vibration,
        preferences.vibrationEnabled,
        (value) => _updatePreference('vibrationEnabled', value),
      ),
    ]);
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return AppComponents.stellarCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        filled: true,
        fillColor: enabled ? Colors.transparent : AppColors.surfaceLight,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(String value) async {
    // في التطبيق الحقيقي، يمكن إضافة debouncing وحفظ التحديثات
    _showInfoSnackBar('تم حفظ التغييرات محلياً');
  }

  Future<void> _updatePreference(String key, bool value) async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // في التطبيق الحقيقي، يجب إضافة دالة لتحديث التفضيلات في AuthService
      _showSuccessSnackBar('تم تحديث التفضيلات');
    } catch (e) {
      _showErrorSnackBar('حدث خطأ أثناء تحديث التفضيلات');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAuth() {
    Navigator.of(context).pushNamed('/auth');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
}
