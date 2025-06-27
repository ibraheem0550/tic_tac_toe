import 'package:flutter/material.dart';
import '../AI/ai_level_selection.dart';
import '../screens/game_screen.dart';
import '../screens/admin_screen.dart';
import '../screens/gems_store_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/friends_screen.dart';
import '../screens/online_game_screen.dart';
import '../screens/missions_screen.dart';
import '../services/firebase_auth_service.dart';
import '../utils/app_theme_new.dart';
import '../screens/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _authService.addAuthListener(_onUserDataChanged);
  }

  @override
  void dispose() {
    _authService.removeAuthListener(_onUserDataChanged);
    super.dispose();
  }

  void _onUserDataChanged(user) {
    if (mounted) {
      setState(() {});
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
          child: CustomScrollView(
            slivers: [
              // شريط التطبيق النجمي
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.nebularGradient,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        // أيقونة نجمية متوهجة
                        Container(
                          padding:
                              const EdgeInsets.all(AppDimensions.paddingLG),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.stellarGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.starGold.withOpacity(0.6),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.stars,
                            size: 60,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingMD),
                        Text(
                          'TIC TAC TOE',
                          style: AppTextStyles.stellarTitle,
                        ),
                        Text(
                          'مغامرة نجمية ملحمية',
                          style: AppTextStyles.nebularSubtitle,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: _buildAppBarActions(),
              ),

              // المحتوى الرئيسي
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLG),
                  child: Column(
                    children: [
                      // معلومات المستخدم النجمية
                      _buildUserInfo(),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // أزرار اللعب النجمية
                      _buildGameButtons(),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // ميزات إضافية
                      _buildFeatures(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      // الجواهر
      IconButton(
        icon: const Icon(Icons.diamond, color: Colors.amber),
        onPressed: () => _navigateToGemsStore(),
        tooltip: 'الجواهر',
      ),
      // الإعدادات
      IconButton(
        icon: const Icon(Icons.settings, color: AppColors.textSecondary),
        onPressed: () => _navigateToSettings(),
        tooltip: 'الإعدادات',
      ),
      // تسجيل الخروج
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.red),
        onPressed: _handleLogout,
        tooltip: 'تسجيل الخروج',
      ),
    ];
  }

  Widget _buildUserInfo() {
    final user = _authService.currentUser;
    if (user == null) return const SizedBox.shrink();

    return AppComponents.stellarCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            backgroundColor: AppColors.primary,
            child: user.photoURL == null
                ? Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? '؟',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppDimensions.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? 'مستخدم',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  user.email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.diamond, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            '${user.gems}',
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameButtons() {
    return Column(
      children: [
        // اللعب ضد الذكاء الاصطناعي
        AppComponents.stellarButton(
          text: 'ضد الذكاء الاصطناعي',
          onPressed: () => _navigateToAIGame(),
          icon: Icons.smart_toy,
        ),
        const SizedBox(height: AppDimensions.paddingMD),

        // اللعب مع لاعبين محليين
        AppComponents.stellarButton(
          text: 'لاعبان محليان',
          onPressed: () => _navigateToLocalGame(),
          icon: Icons.people,
          isPrimary: false,
        ),
        const SizedBox(height: AppDimensions.paddingMD),

        // اللعب أونلاين
        AppComponents.stellarButton(
          text: 'لعب أونلاين',
          onPressed: () => _navigateToOnlineGame(),
          icon: Icons.public,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Wrap(
      spacing: AppDimensions.paddingMD,
      runSpacing: AppDimensions.paddingMD,
      children: [
        _buildFeatureButton(
          'الأصدقاء',
          Icons.group,
          () => _navigateToFriends(),
        ),
        _buildFeatureButton(
          'المهام',
          Icons.assignment,
          () => _navigateToMissions(),
        ),
        _buildFeatureButton(
          'المتجر',
          Icons.store,
          () => _navigateToGemsStore(),
        ),
        _buildFeatureButton(
          'الإدارة',
          Icons.admin_panel_settings,
          () => _navigateToAdmin(),
        ),
      ],
    );
  }

  Widget _buildFeatureButton(
      String title, IconData icon, VoidCallback onPressed) {
    return AppComponents.stellarCard(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToAIGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AILevelSelectionScreen(),
      ),
    );
  }

  void _navigateToLocalGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(aiLevel: 1, isPvP: true),
      ),
    );
  }

  void _navigateToOnlineGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OnlineGameScreen(),
      ),
    );
  }

  void _navigateToFriends() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FriendsScreen(),
      ),
    );
  }

  void _navigateToMissions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MissionsScreen(),
      ),
    );
  }

  void _navigateToGemsStore() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GemsStoreScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToAdmin() {
    _showAdminPasswordDialog();
  }

  void _showAdminPasswordDialog() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('كلمة مرور الإدارة'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'أدخل كلمة مرور الإدارة',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text == 'admin123') {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('كلمة مرور خاطئة')),
                );
              }
            },
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
