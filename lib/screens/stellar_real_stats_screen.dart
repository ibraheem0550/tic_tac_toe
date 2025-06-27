import 'package:flutter/material.dart';
import '../services/game_stats_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_system.dart';

/// شاشة الإحصائيات الحقيقية - تعرض البيانات الفعلية للمستخدم
class StellarRealStatsScreen extends StatefulWidget {
  const StellarRealStatsScreen({super.key});

  @override
  State<StellarRealStatsScreen> createState() => _StellarRealStatsScreenState();
}

class _StellarRealStatsScreenState extends State<StellarRealStatsScreen>
    with TickerProviderStateMixin {
  final GameStatsService _gameStatsService = GameStatsService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  GameStats? _stats;
  User? _currentUser;
  bool _isLoading = true;
  List<Map<String, dynamic>> _gameHistory = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadRealData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  /// تحميل البيانات الحقيقية
  Future<void> _loadRealData() async {
    try {
      setState(() => _isLoading = true);

      // تحميل المستخدم الحالي
      _currentUser = _authService.currentUser;

      // تحميل الإحصائيات الحقيقية
      _stats = await _gameStatsService.loadGameStats();

      // تحميل تاريخ الألعاب الحقيقي
      _gameHistory = await _gameStatsService.getGameHistory(limit: 10);

      setState(() => _isLoading = false);
      _animationController.forward();
    } catch (e) {
      print('خطأ في تحميل البيانات: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.starfieldGradient,
        ),
        child: SafeArea(
          child: ResponsiveBuilder(
            builder: (context, sizingInfo) {
              if (_isLoading) {
                return _buildLoadingScreen();
              }

              if (_stats == null) {
                return _buildErrorScreen();
              }

              return _buildStatsScreen(sizingInfo);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.starGold),
          ),
          SizedBox(height: 16),
          Text(
            'تحميل إحصائياتك الحقيقية...',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل الإحصائيات',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRealData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsScreen(SizingInformation sizingInfo) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeader(sizingInfo),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(sizingInfo.isDesktop ? 24 : 16),
              child: Column(
                children: [
                  _buildUserInfo(sizingInfo),
                  SizedBox(height: 24),
                  _buildMainStats(sizingInfo),
                  SizedBox(height: 24),
                  _buildDifficultyStats(sizingInfo),
                  SizedBox(height: 24),
                  _buildGameHistory(sizingInfo),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SizingInformation sizingInfo) {
    return Container(
      padding: EdgeInsets.all(sizingInfo.isDesktop ? 24 : 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'إحصائياتك الحقيقية',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.starGold,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: _loadRealData,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(SizingInformation sizingInfo) {
    return Container(
      padding: EdgeInsets.all(sizingInfo.isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        gradient: AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Row(
        children: [
          // صورة المستخدم
          Container(
            width: sizingInfo.isDesktop ? 80 : 64,
            height: sizingInfo.isDesktop ? 80 : 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.starGold, width: 2),
            ),
            child: _currentUser?.photoURL != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Image.network(
                      _currentUser!.photoURL!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          SizedBox(width: 16),

          // معلومات المستخدم
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.displayName ?? 'مستخدم',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentUser?.email != null)
                  Text(
                    _currentUser!.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _currentUser?.isGuest == true
                        ? AppColors.warning
                        : AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _currentUser?.isGuest == true ? 'ضيف' : 'مستخدم مسجل',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.stellarGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Icon(
        _currentUser?.isGuest == true ? Icons.person_outline : Icons.person,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildMainStats(SizingInformation sizingInfo) {
    final stats = _stats!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات الرئيسية',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.starGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: sizingInfo.isDesktop ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('إجمالي الألعاب', '${stats.totalGames}', Icons.games,
                AppColors.primary),
            _buildStatCard('الانتصارات', '${stats.wins}', Icons.emoji_events,
                AppColors.success),
            _buildStatCard('الخسارات', '${stats.losses}',
                Icons.sentiment_dissatisfied, AppColors.error),
            _buildStatCard('التعادل', '${stats.draws}', Icons.handshake,
                AppColors.warning),
          ],
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: sizingInfo.isDesktop ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('معدل الفوز', '${stats.winRate.toStringAsFixed(1)}%',
                Icons.trending_up, AppColors.starGold),
            _buildStatCard('أفضل سلسلة', '${stats.bestWinStreak}',
                Icons.local_fire_department, AppColors.secondary),
            _buildStatCard(
                'وقت اللعب',
                '${(stats.totalPlayTime / 3600).toStringAsFixed(1)}س',
                Icons.schedule,
                AppColors.info),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyStats(SizingInformation sizingInfo) {
    final stats = _stats!;

    if (stats.difficultyGames.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات المستويات',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.starGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ...stats.difficultyGames.entries.map((entry) {
          final difficulty = entry.key;
          final totalGames = entry.value;
          final wins = stats.difficultyStats[difficulty] ?? 0;
          final winRate = totalGames > 0 ? (wins / totalGames) * 100 : 0.0;

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfacePrimary.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    difficulty,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$wins/$totalGames',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${winRate.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.starGold,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGameHistory(SizingInformation sizingInfo) {
    if (_gameHistory.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfacePrimary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'لا يوجد تاريخ ألعاب بعد',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'ابدأ بلعب بعض الألعاب لرؤية التاريخ هنا',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'آخر الألعاب',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.starGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ...(_gameHistory
            .take(5)
            .map((game) => _buildGameHistoryItem(game))
            .toList()),
        if (_gameHistory.length > 5)
          TextButton(
            onPressed: () {
              // عرض جميع الألعاب
            },
            child: Text(
              'عرض المزيد...',
              style: TextStyle(color: AppColors.starGold),
            ),
          ),
      ],
    );
  }

  Widget _buildGameHistoryItem(Map<String, dynamic> game) {
    final result = game['game_result'] as String;
    final mode = game['game_mode'] as String;
    final duration = game['game_duration'] as int;
    final playedAt = DateTime.parse(game['played_at']);

    Color resultColor;
    IconData resultIcon;
    String resultText;

    switch (result) {
      case 'win':
        resultColor = AppColors.success;
        resultIcon = Icons.emoji_events;
        resultText = 'فوز';
        break;
      case 'loss':
        resultColor = AppColors.error;
        resultIcon = Icons.sentiment_dissatisfied;
        resultText = 'خسارة';
        break;
      default:
        resultColor = AppColors.warning;
        resultIcon = Icons.handshake;
        resultText = 'تعادل';
    }

    String modeText;
    switch (mode) {
      case 'ai':
        modeText = 'ذكاء اصطناعي';
        break;
      case 'local':
        modeText = 'لعب محلي';
        break;
      case 'online':
        modeText = 'أونلاين';
        break;
      default:
        modeText = mode;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Row(
        children: [
          Icon(resultIcon, color: resultColor, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$resultText - $modeText',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_formatDuration(duration)} - ${_formatDateTime(playedAt)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
