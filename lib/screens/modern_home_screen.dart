import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/modern_theme.dart';
import '../design_system/modern_components.dart';
import '../services/unified_auth_services.dart';
import '../models/complete_user_models.dart';
import 'modern_auth_screen.dart';
import 'modern_game_screen.dart';
import 'modern_settings_screen.dart';

/// الشاشة الرئيسية الحديثة - إعادة تصميم شاملة
class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();
  late AnimationController _backgroundController;
  late AnimationController _cardsController;
  late AnimationController _heroController;

  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _authService.addAuthListener(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardsController.dispose();
    _heroController.dispose();
    _authService.removeAuthListener(_onAuthStateChanged);
    super.dispose();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // بدء التحريكات
    _heroController.forward();
    _cardsController.forward();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // محاكاة التحميل
      _currentUser = await _authService.getCurrentUser();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onAuthStateChanged() {
    if (mounted) {
      setState(() {
        _currentUser = _authService.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingView()
          : Stack(children: [_buildAnimatedBackground(), _buildContent()]),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: ModernDesignSystem.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ModernAnimations.scaleIn(
              child: Container(
                padding: const EdgeInsets.all(ModernSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ModernRadius.xl),
                ),
                child: const Icon(Icons.games, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: ModernSpacing.xl),
            ModernComponents.modernLoader(
              size: 32,
              color: Colors.white,
              text: 'جاري التحميل...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: ModernDesignSystem.primaryGradient,
      ),
      child: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Stack(
            children: [
              // كرات متحركة في الخلفية
              ...List.generate(5, (index) {
                final offset = Offset(
                  (index * 100.0 + _backgroundController.value * 200) %
                      MediaQuery.of(context).size.width,
                  (index * 80.0 + _backgroundController.value * 100) %
                      MediaQuery.of(context).size.height,
                );

                return Positioned(
                  left: offset.dx,
                  top: offset.dy,
                  child: Container(
                    width: 20 + (index * 10),
                    height: 20 + (index * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: ModernSpacing.xxl),
            _buildHeroSection(),
            const SizedBox(height: ModernSpacing.xxl),
            _buildGameModes(),
            const SizedBox(height: ModernSpacing.xxl),
            _buildQuickActions(),
            const SizedBox(height: ModernSpacing.xxl),
            if (!(_currentUser?.isGuest ?? true)) _buildUserStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = _currentUser;
    final isGuest = user?.isGuest ?? true;

    return ModernAnimations.fadeIn(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? 'مرحباً بك' : 'مرحباً ${user?.displayName ?? ''}',
                  style: ModernTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: ModernSpacing.xs),
                Text(
                  'استعد للعبة مثيرة!',
                  style: ModernTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (isGuest)
                ModernComponents.modernButton(
                  text: 'تسجيل الدخول',
                  onPressed: _navigateToAuth,
                  backgroundColor: Colors.white,
                  textColor: ModernColors.primary,
                  isSmall: true,
                )
              else ...[
                _buildNotificationButton(),
                const SizedBox(width: ModernSpacing.sm),
                _buildProfileButton(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(ModernRadius.md),
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          // TODO: فتح الإشعارات
        },
        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(ModernRadius.md),
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ModernSettingsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.settings_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildHeroSection() {
    return ModernAnimations.fadeIn(
      offset: const Offset(0, 50),
      child: AnimatedBuilder(
        animation: _heroController,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.9 + (_heroController.value * 0.1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ModernSpacing.xxl),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(ModernRadius.xxl),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(ModernSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.games,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: ModernSpacing.lg),
                  Text(
                    'X O لعبة',
                    style: ModernTextStyles.displayLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: ModernSpacing.sm),
                  Text(
                    'التحدي الكلاسيكي بتصميم حديث',
                    style: ModernTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameModes() {
    return ModernAnimations.fadeIn(
      offset: const Offset(0, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر طريقة اللعب',
            style: ModernTextStyles.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: ModernSpacing.lg),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: ModernSpacing.md,
            mainAxisSpacing: ModernSpacing.md,
            childAspectRatio: 1.1,
            children: [
              _buildGameModeCard(
                title: 'ضد الذكاء الاصطناعي',
                subtitle: 'تحدى الكمبيوتر',
                icon: Icons.smart_toy,
                gradient: ModernDesignSystem.secondaryGradient,
                onTap: () => _navigateToAIGame(),
              ),
              _buildGameModeCard(
                title: 'اللعب المحلي',
                subtitle: 'مع صديق',
                icon: Icons.people,
                gradient: ModernDesignSystem.sunsetGradient,
                onTap: () => _navigateToLocalGame(),
              ),
              _buildGameModeCard(
                title: 'اللعب الجماعي',
                subtitle: 'عبر الإنترنت',
                icon: Icons.public,
                gradient: ModernDesignSystem.oceanGradient,
                onTap: () => _navigateToOnlineGame(),
              ),
              _buildGameModeCard(
                title: 'التحديات',
                subtitle: 'مهام خاصة',
                icon: Icons.emoji_events,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                ),
                onTap: () => _navigateToChallenges(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(ModernRadius.xl),
          boxShadow: ModernDesignSystem.mediumShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ModernRadius.xl),
            child: Padding(
              padding: const EdgeInsets.all(ModernSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 48, color: Colors.white),
                  const SizedBox(height: ModernSpacing.md),
                  Text(
                    title,
                    style: ModernTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ModernSpacing.xs),
                  Text(
                    subtitle,
                    style: ModernTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return ModernAnimations.fadeIn(
      offset: const Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ModernRadius.xl),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات سريعة',
              style: ModernTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ModernSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'المتجر',
                    Icons.store,
                    () => _navigateToStore(),
                  ),
                ),
                const SizedBox(width: ModernSpacing.md),
                Expanded(
                  child: _buildQuickActionButton(
                    'الأصدقاء',
                    Icons.group,
                    () => _navigateToFriends(),
                  ),
                ),
                const SizedBox(width: ModernSpacing.md),
                Expanded(
                  child: _buildQuickActionButton(
                    'الإحصائيات',
                    Icons.analytics,
                    () => _navigateToStats(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: ModernSpacing.lg,
          horizontal: ModernSpacing.md,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ModernRadius.md),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: ModernSpacing.xs),
            Text(
              label,
              style: ModernTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats() {
    return ModernAnimations.fadeIn(
      offset: const Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ModernRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائياتك',
              style: ModernTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: ModernSpacing.lg),
            Row(
              children: [
                Expanded(child: _buildStatItem('الألعاب', '127', Icons.games)),
                Expanded(
                  child: _buildStatItem('الانتصارات', '89', Icons.emoji_events),
                ),
                Expanded(child: _buildStatItem('النقاط', '2,340', Icons.star)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: ModernSpacing.xs),
        Text(
          value,
          style: ModernTextStyles.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: ModernTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Navigation methods
  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ModernAuthScreen()),
    );
  }

  void _navigateToAIGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernGameScreen(gameMode: 'ai'),
      ),
    );
  }

  void _navigateToLocalGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernGameScreen(gameMode: 'local'),
      ),
    );
  }

  void _navigateToOnlineGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernGameScreen(gameMode: 'online'),
      ),
    );
  }

  void _navigateToChallenges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('التحديات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.speed, color: Colors.orange),
              title: const Text('تحدي السرعة'),
              subtitle: const Text('اكمل 5 ألعاب في أقل من دقيقة'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                _startSpeedChallenge();
              },
            ),
            ListTile(
                             leading: const Icon(Icons.emoji_events, color: Colors.amber),
              title: const Text('تحدي الذكاء'),
              subtitle: const Text('اهزم الذكاء الاصطناعي 10 مرات'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                _startAIChallenge();
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('تحدي الفوز المتتالي'),
              subtitle: const Text('احصل على 7 انتصارات متتالية'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                _startWinStreakChallenge();
              },
            ),
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

  void _navigateToStore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المتجر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.palette, color: Colors.blue),
              title: const Text('ثيمات جديدة'),
              subtitle: const Text('10 ثيمات ملونة'),
              trailing: const Text('مجاني', style: TextStyle(color: Colors.green)),
            ),
            ListTile(
              leading: const Icon(Icons.music_note, color: Colors.purple),
              title: const Text('أصوات مختلفة'),
              subtitle: const Text('أصوات تفاعلية'),
              trailing: const Text('مجاني', style: TextStyle(color: Colors.green)),
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.orange),
              title: const Text('ألقاب خاصة'),
              subtitle: const Text('ألقاب للإنجازات'),
              trailing: const Text('مجاني', style: TextStyle(color: Colors.green)),
            ),
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

  void _navigateToFriends() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الأصدقاء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('قائمة الأصدقاء فارغة حالياً'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAddFriendDialog();
              },
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة صديق'),
            ),
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

  void _navigateToStats() {
    final user = _currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إحصائياتك'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('إجمالي الألعاب', '127'),
            _buildStatRow('الانتصارات', '89'),
            _buildStatRow('الهزائم', '31'),
            _buildStatRow('التعادل', '7'),
            _buildStatRow('نسبة الفوز', '70.1%'),
            _buildStatRow('أطول سلسلة انتصارات', '12'),
            _buildStatRow('النقاط الإجمالية', '2,340'),
            _buildStatRow('المستوى', 'متقدم'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetStats();
            },
            child: const Text('إعادة تعيين'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  // تحديد الدوال الجديدة
  void _startSpeedChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernGameScreen(gameMode: 'speed_challenge'),
      ),
    );
  }

  void _startAIChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernGameScreen(gameMode: 'ai_challenge'),
      ),
    );
  }

  void _startWinStreakChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModernGameScreen(gameMode: 'win_streak'),
      ),
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة صديق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم أو البريد الإلكتروني',
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال طلب الصداقة!')),
              );
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _resetStats() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إعادة تعيين الإحصائيات')),
    );
  }
}
