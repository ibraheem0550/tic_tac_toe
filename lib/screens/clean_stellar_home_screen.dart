import 'package:flutter/material.dart';
import '../AI/ai_level_selection.dart';
import '../screens/stellar_game_screen_enhanced_real.dart';
import '../screens/gems_store_screen.dart';
import '../screens/stellar_settings_screen.dart';
import '../screens/stellar_missions_screen.dart';
import '../screens/stellar_real_stats_screen.dart';
import '../themes/app_theme_new.dart';

class CleanStellarHomeScreen extends StatefulWidget {
  const CleanStellarHomeScreen({super.key});

  @override
  State<CleanStellarHomeScreen> createState() => _CleanStellarHomeScreenState();
}

class _CleanStellarHomeScreenState extends State<CleanStellarHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildGameMenu()),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك',
                style: AppThemeNew.headingMedium.copyWith(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              Text(
                'لاعب محلي',
                style: AppThemeNew.headingLarge.copyWith(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 5),
                Text(
                  '1000',
                  style: AppThemeNew.bodyMedium.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameMenu() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuGrid(),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    final menuItems = [
      {
        'title': 'لعب ضد الذكاء الاصطناعي',
        'subtitle': 'اختر المستوى المناسب',
        'icon': Icons.smart_toy,
        'color': const Color(0xFF4CAF50),
        'onTap': () => _navigateToAI(),
      },
      {
        'title': 'لعب محلي',
        'subtitle': 'لاعبين على نفس الجهاز',
        'icon': Icons.people,
        'color': const Color(0xFF2196F3),
        'onTap': () => _navigateToLocalGame(),
      },
      {
        'title': 'الإحصائيات',
        'subtitle': 'تتبع تقدمك',
        'icon': Icons.analytics,
        'color': const Color(0xFF9C27B0),
        'onTap': () => _navigateToStats(),
      },
      {
        'title': 'المتجر',
        'subtitle': 'اشتري الثيمات والمكافآت',
        'icon': Icons.store,
        'color': const Color(0xFFFF9800),
        'onTap': () => _navigateToStore(),
      },
      {
        'title': 'الإعدادات',
        'subtitle': 'خصص تجربتك',
        'icon': Icons.settings,
        'color': const Color(0xFF607D8B),
        'onTap': () => _navigateToSettings(),
      },
      {
        'title': 'المهام',
        'subtitle': 'أكمل التحديات',
        'icon': Icons.assignment,
        'color': const Color(0xFFE91E63),
        'onTap': () => _navigateToMissions(),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return _buildMenuItem(
          title: item['title'] as String,
          subtitle: item['subtitle'] as String,
          icon: item['icon'] as IconData,
          color: item['color'] as Color,
          onTap: item['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppThemeNew.bodyTextStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppThemeNew.bodyTextStyle.copyWith(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickAction(
            icon: Icons.play_arrow,
            label: 'لعبة سريعة',
            onTap: () => _navigateToLocalGame(),
          ),
          _buildQuickAction(
            icon: Icons.leaderboard,
            label: 'الترتيب',
            onTap: () => _navigateToStats(),
          ),
          _buildQuickAction(
            icon: Icons.help_outline,
            label: 'المساعدة',
            onTap: () => _showHelp(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppThemeNew.bodyTextStyle.copyWith(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAI() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AILevelSelectionScreen()),
    );
  }

  void _navigateToLocalGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StellarGameScreenEnhanced(gameMode: 'local'),
      ),
    );
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarRealStatsScreen()),
    );
  }

  void _navigateToStore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GemsStoreScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarSettingsScreen()),
    );
  }

  void _navigateToMissions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StellarMissionsScreen()),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('كيفية اللعب'),
        content: const Text(
          'لعبة X-O الكلاسيكية!\n\n'
          '• اختر وضع اللعب المناسب\n'
          '• ضع رمزك في المربعات\n'
          '• اربط ثلاثة رموز في خط واحد للفوز\n'
          '• اجمع النقاط واشتري الثيمات الجديدة',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
