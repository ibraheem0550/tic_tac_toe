import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/unified_auth_services.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';
import '../utils/logger.dart';

class StellarSettingsScreen extends StatefulWidget {
  const StellarSettingsScreen({super.key});

  @override
  State<StellarSettingsScreen> createState() => _StellarSettingsScreenState();
}

class _StellarSettingsScreenState extends State<StellarSettingsScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;

  User? _currentUser;
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  double _masterVolume = 0.8;
  String _selectedLanguage = 'ar';
  String _selectedTheme = 'stellar';

  // Form controllers
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      _currentUser = _authService.currentUserModel;
      if (_currentUser != null) {
        _displayNameController.text = _currentUser!.displayName;
        _emailController.text = _currentUser!.email;
        _phoneController.text = '';
        _bioController.text = '';
      }
    } catch (e) {
      Logger.logError('??? ?? ????? ?????? ????????', e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.starfieldGradient,
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                )
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: CustomScrollView(
                          slivers: [
                            _buildStellarAppBar(),
                            SliverPadding(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingLG,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  _buildUserProfileSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildGameSettingsSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildNotificationSettingsSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildAppearanceSettingsSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXL,
                                  ),
                                  _buildAccountSettingsSection(),
                                  const SizedBox(
                                    height: AppDimensions.paddingXXL,
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildStellarAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.nebularGradient,
            boxShadow: AppShadows.card,
          ),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.nebularGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.stellarGradient,
                        boxShadow: AppShadows.stellar,
                      ),
                      child: const Icon(
                        Icons.settings,
                        size: 50,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                '????????? ???????',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                '??? ?????? ?? ??????',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('????? ??????', Icons.person),
        const SizedBox(height: AppDimensions.paddingLG),
        AppComponents.stellarCard(
          child: Column(
            children: [
              // ???? ????? ??????
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.stellarGradient,
                        border: Border.all(color: AppColors.starGold, width: 3),
                        boxShadow: AppShadows.stellar,
                      ),
                      child: ClipOval(
                        child: _currentUser?.photoURL != null
                            ? Image.network(
                                _currentUser!.photoURL!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.textPrimary,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.cosmicButtonGradient,
                          border: Border.all(
                            color: AppColors.textPrimary,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              // ???? ???????
              AppComponents.stellarTextField(
                controller: _displayNameController,
                hintText: '??? ?????',
                prefixIcon: Icons.badge,
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              AppComponents.stellarTextField(
                controller: _emailController,
                hintText: '?????? ??????????',
                prefixIcon: Icons.email,
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              AppComponents.stellarTextField(
                controller: _phoneController,
                hintText: '??? ??????',
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              AppComponents.stellarTextField(
                controller: _bioController,
                hintText: '???? ???',
                prefixIcon: Icons.info,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              AppComponents.stellarButton(
                text: '??? ?????????',
                onPressed: _saveUserData,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('??????? ??????', Icons.games),
        const SizedBox(height: AppDimensions.paddingLG),
        AppComponents.stellarCard(
          child: Column(
            children: [
              _buildSwitchSetting(
                '???????',
                '????? ??????? ?????????',
                Icons.volume_up,
                _soundEnabled,
                (value) => setState(() => _soundEnabled = value),
              ),
              _buildDivider(),
              _buildSwitchSetting(
                '????????',
                '?????? ?????? ??? ?????',
                Icons.vibration,
                _vibrationEnabled,
                (value) => setState(() => _vibrationEnabled = value),
              ),
              _buildDivider(),
              _buildSliderSetting(
                '????? ????? ???????',
                '?????? ?? ????? ??? ??????',
                Icons.volume_down,
                _masterVolume,
                (value) => setState(() => _masterVolume = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('?????????', Icons.notifications),
        const SizedBox(height: AppDimensions.paddingLG),
        AppComponents.stellarCard(
          child: Column(
            children: [
              _buildSwitchSetting(
                '?????????',
                '???? ??????? ?? ???????',
                Icons.notifications_active,
                _notificationsEnabled,
                (value) => setState(() => _notificationsEnabled = value),
              ),
              _buildDivider(),
              _buildOptionSetting(
                '??????? ????????',
                '??????? ??? ?????? ??????',
                Icons.people,
                () => _showNotificationOptions('friends'),
              ),
              _buildDivider(),
              _buildOptionSetting(
                '????????',
                '??????? ???????? ??????????',
                Icons.emoji_events,
                () => _showNotificationOptions('challenges'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('??????', Icons.palette),
        const SizedBox(height: AppDimensions.paddingLG),
        AppComponents.stellarCard(
          child: Column(
            children: [
              _buildOptionSetting(
                '?????',
                _getLanguageName(_selectedLanguage),
                Icons.language,
                _showLanguageOptions,
              ),
              _buildDivider(),
              _buildOptionSetting(
                '?????',
                _getThemeName(_selectedTheme),
                Icons.color_lens,
                _showThemeOptions,
              ),
              _buildDivider(),
              _buildSwitchSetting(
                '????? ??????',
                '??????? ????? ??????',
                Icons.dark_mode,
                true,
                (value) => {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('??????', Icons.account_circle),
        const SizedBox(height: AppDimensions.paddingLG),
        AppComponents.stellarCard(
          child: Column(
            children: [
              _buildOptionSetting(
                '????? ???? ??????',
                '??? ???? ???? ?????',
                Icons.lock,
                _changePassword,
              ),
              _buildDivider(),
              _buildOptionSetting(
                '???????? ???????',
                '??????? ???????? ????????',
                Icons.security,
                _showPrivacySettings,
              ),
              _buildDivider(),
              _buildOptionSetting(
                '????? ?????????',
                '??? ??????? ???????? ???????',
                Icons.backup,
                _showBackupOptions,
              ),
              _buildDivider(),
              _buildOptionSetting(
                '??? ??????',
                '??? ?????? ???????',
                Icons.delete_forever,
                _deleteAccount,
                isDangerous: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.stellarGradient,
            boxShadow: AppShadows.card,
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
        const SizedBox(width: AppDimensions.paddingMD),
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceSecondary,
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(width: AppDimensions.paddingMD),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
          inactiveThumbColor: AppColors.textTertiary,
          inactiveTrackColor: AppColors.surfaceSecondary,
        ),
      ],
    );
  }

  Widget _buildSliderSetting(
    String title,
    String subtitle,
    IconData icon,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSecondary,
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceSecondary,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 4.0,
          ),
          child: Slider(value: value, onChanged: onChanged, min: 0.0, max: 1.0),
        ),
      ],
    );
  }

  Widget _buildOptionSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDangerous = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDangerous
                    ? AppColors.error.withValues(alpha: 0.2)
                    : AppColors.surfaceSecondary,
              ),
              child: Icon(
                icon,
                color: isDangerous ? AppColors.error : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDangerous
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMD),
      height: 1,
      color: AppColors.dividerPrimary,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return '???????';
      case 'en':
        return 'English';
      default:
        return '???????';
    }
  }

  String _getThemeName(String theme) {
    switch (theme) {
      case 'stellar':
        return '??????';
      case 'dark':
        return '??????';
      case 'light':
        return '??????';
      default:
        return '??????';
    }
  }

  Future<void> _saveUserData() async {
    setState(() => _isLoading = true);
    try {
      HapticFeedback.lightImpact();

      // TODO: Implement save user data
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('?? ??? ???????? ?????'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('??? ?? ??? ????????: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showLanguageOptions() {
    showDialog(context: context, builder: (context) => _buildLanguageDialog());
  }

  void _showThemeOptions() {
    showDialog(context: context, builder: (context) => _buildThemeDialog());
  }

  void _showNotificationOptions(String type) {
    // TODO: Implement notification options
  }

  void _changePassword() {
    // TODO: Implement change password
  }

  void _showPrivacySettings() {
    // TODO: Implement privacy settings
  }

  void _showBackupOptions() {
    // TODO: Implement backup options
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => _buildDeleteAccountDialog(),
    );
  }

  Widget _buildLanguageDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.starfieldGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: AppShadows.modal,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '?????? ?????',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            ...['ar', 'en'].map(
              (lang) => ListTile(
                title: Text(
                  _getLanguageName(lang),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                leading: Radio<String>(
                  value: lang,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    setState(() => _selectedLanguage = value!);
                    Navigator.pop(context);
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.starfieldGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: AppShadows.modal,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '?????? ?????',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            ...['stellar', 'dark', 'light'].map(
              (theme) => ListTile(
                title: Text(
                  _getThemeName(theme),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                leading: Radio<String>(
                  value: theme,
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                    Navigator.pop(context);
                  },
                  activeColor: AppColors.primary,
                ),
                onTap: () {
                  setState(() => _selectedTheme = theme);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteAccountDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.starfieldGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: AppShadows.modal,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.error, width: 2),
              ),
              child: const Icon(
                Icons.warning,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text(
              '?????',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              '?? ??? ????? ?? ??? ?????? ??? ??????? ?? ???? ??????? ???.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),
            Row(
              children: [
                Expanded(
                  child: AppComponents.stellarButton(
                    text: '?????',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                Expanded(
                  child: AppComponents.stellarButton(
                    text: '???',
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implement account deletion
                    },
                    icon: Icons.delete_forever,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
