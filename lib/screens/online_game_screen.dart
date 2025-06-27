import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/online_game_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/complete_user_models.dart';
import '../audio_helper.dart';
import '../utils/app_theme_new.dart';

/// شاشة اللعب أونلاين
class OnlineGameScreen extends StatefulWidget {
  const OnlineGameScreen({super.key});

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen>
    with TickerProviderStateMixin {
  final OnlineGameService _gameService = OnlineGameService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  late AnimationController _pulseController;
  late AnimationController _boardController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _boardAnimation;
  bool _isConnecting = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCurrentUser();
    _gameService.addListener(_onGameStateChanged);
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _boardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _boardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _boardController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadCurrentUser() async {
    _currentUser = _authService.currentUser;
    setState(() {});
  }

  void _onGameStateChanged() {
    setState(() {});

    // تشغيل الصوت المناسب
    if (_gameService.gameStatus == 'playing' && mounted) {
      AudioHelper.playClickSound();
      _boardController.forward();
    }
  }

  @override
  void dispose() {
    _gameService.removeListener(_onGameStateChanged);
    _pulseController.dispose();
    _boardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'اللعب أونلاين',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _gameService.isConnected ? Icons.wifi : Icons.wifi_off,
              color: _gameService.isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _showConnectionStatus,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_gameService.isConnected && !_isConnecting) {
      return _buildConnectionScreen();
    }

    switch (_gameService.gameStatus) {
      case 'idle':
        return _buildMenuScreen();
      case 'searching':
        return _buildSearchingScreen();
      case 'playing':
        return _buildGameScreen();
      case 'finished':
      case 'opponent_left':
        return _buildGameOverScreen();
      default:
        return _buildMenuScreen();
    }
  }

  Widget _buildConnectionScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'الاتصال بالخادم',
              style: AppTextStyles.h2.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            Text(
              'يجب الاتصال بالخادم للعب أونلاين',
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_isConnecting)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _connectToServer,
                icon: const Icon(Icons.wifi),
                label: const Text('الاتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // معلومات اللاعب
          _buildPlayerCard(_currentUser, isCurrentUser: true),
          const SizedBox(height: 32),

          // أزرار اللعب
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMenuButton(
                  icon: Icons.search,
                  title: 'البحث عن مباراة',
                  subtitle: 'العثور على لاعب عشوائي',
                  onTap: _findRandomMatch,
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  icon: Icons.people,
                  title: 'دعوة صديق',
                  subtitle: 'العب مع أصدقائك',
                  onTap: _showFriendsList,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.search,
                    size: 80,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'البحث عن لاعب...',
              style: AppTextStyles.h2.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            Text(
              'يرجى الانتظار حتى العثور على مباراة',
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _cancelSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('إلغاء البحث'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // معلومات اللاعبين
          Row(
            children: [
              Expanded(
                child: _buildPlayerCard(
                  _gameService.opponent,
                  isCurrentUser: false,
                  symbol: _gameService.mySymbol == 'X' ? 'O' : 'X',
                  isActive: !_gameService.isMyTurn,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Expanded(
                child: _buildPlayerCard(
                  _currentUser,
                  isCurrentUser: true,
                  symbol: _gameService.mySymbol,
                  isActive: _gameService.isMyTurn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // حالة اللعبة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _gameService.isMyTurn ? 'دورك للعب!' : 'انتظار الخصم...',
              style: AppTextStyles.h3.copyWith(
                color: _gameService.isMyTurn
                    ? AppColors.primary
                    : AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // لوحة اللعبة
          Expanded(
            child: AnimatedBuilder(
              animation: _boardAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _boardAnimation.value,
                  child: _buildGameBoard(),
                );
              },
            ),
          ),

          // زر المغادرة
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              onPressed: _leaveGame,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('مغادرة اللعبة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final isWinner = _gameService.winner == _gameService.mySymbol;
    final isDraw = _gameService.winner == 'draw';
    final opponentLeft = _gameService.gameStatus == 'opponent_left';

    String title;
    String message;
    Color color;
    IconData icon;

    if (opponentLeft) {
      title = 'فوز!';
      message = 'غادر الخصم - لقد فزت!';
      color = Colors.green;
      icon = Icons.emoji_events;
    } else if (isDraw) {
      title = 'تعادل!';
      message = 'لعبة رائعة!';
      color = Colors.blue;
      icon = Icons.handshake;
    } else if (isWinner) {
      title = 'فوز!';
      message = 'أحسنت! حصلت على 15 جوهرة';
      color = Colors.green;
      icon = Icons.emoji_events;
    } else {
      title = 'خسارة';
      message = 'حظ أفضل في المرة القادمة';
      color = Colors.red;
      icon = Icons.sentiment_dissatisfied;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: color,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h1.copyWith(color: color),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // نتيجة اللعبة النهائية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildFinalBoard(),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _playAgain,
                  icon: const Icon(Icons.refresh),
                  label: const Text('العب مرة أخرى'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _backToMenu,
                  icon: const Icon(Icons.home),
                  label: const Text('القائمة الرئيسية'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
    User? user, {
    required bool isCurrentUser,
    String? symbol,
    bool isActive = false,
  }) {
    if (user == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border:
              isActive ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'انتظار...',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border:
            isActive ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: user.photoURL?.isNotEmpty == true
                    ? CachedNetworkImageProvider(user.photoURL!)
                    : null,
                backgroundColor: AppColors.primary,
                child: user.photoURL?.isEmpty != false
                    ? Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              if (symbol != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: symbol == 'X'
                          ? AppColors.primary
                          : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.displayName,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isCurrentUser)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user.gems}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppColors.surfaceLight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: AppColors.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.textLight),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameBoard() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) => _buildBoardCell(index),
        ),
      ),
    );
  }

  Widget _buildBoardCell(int index) {
    final cellValue = _gameService.board[index];
    final isEmpty = cellValue.isEmpty;
    final isX = cellValue == 'X';

    return GestureDetector(
      onTap: () => _makeMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: isEmpty
              ? AppColors.backgroundDark.withOpacity(0.3)
              : isX
                  ? AppColors.primary
                  : AppColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            cellValue,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isEmpty ? Colors.transparent : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinalBoard() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final cellValue = _gameService.board[index];
          final isEmpty = cellValue.isEmpty;
          final isX = cellValue == 'X';

          return Container(
            decoration: BoxDecoration(
              color: isEmpty
                  ? Colors.grey[300]
                  : isX
                      ? AppColors.primary
                      : AppColors.secondary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                cellValue,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isEmpty ? Colors.transparent : Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Event handlers
  Future<void> _connectToServer() async {
    setState(() => _isConnecting = true);

    try {
      await _gameService.connect();

      if (_gameService.isConnected) {
        setState(() => _isConnecting = false);

        // تسجيل اللاعب في الخادم
        if (_currentUser != null) {
          _gameService.registerPlayer(_currentUser!);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم الاتصال بالخادم بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('فشل في الاتصال');
      }
    } catch (e) {
      setState(() => _isConnecting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل في الاتصال بالخادم: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              onPressed: _connectToServer,
            ),
          ),
        );
      }
    }
  }

  void _findRandomMatch() {
    _gameService.findMatch();
  }

  void _showFriendsList() {
    // TODO: تنفيذ قائمة الأصدقاء للدعوة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('دعوة الأصدقاء ستكون متاحة قريباً'),
      ),
    );
  }

  void _cancelSearch() {
    _gameService.leaveGame();
  }

  void _makeMove(int index) {
    if (_gameService.isMyTurn && _gameService.board[index].isEmpty) {
      _gameService.makeMove(index);
      AudioHelper.playClickSound();
    }
  }

  void _leaveGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد المغادرة'),
        content: const Text('هل تريد مغادرة اللعبة؟ ستخسر النقاط.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _gameService.leaveGame();
            },
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
  }

  void _playAgain() {
    _gameService.findMatch();
  }

  void _backToMenu() {
    _gameService.leaveGame();
  }

  void _showConnectionStatus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_gameService.isConnected ? 'متصل' : 'غير متصل'),
        content: Text(
          _gameService.isConnected
              ? 'متصل بالخادم بنجاح\nمعرف اللاعب: ${_gameService.playerId}'
              : 'غير متصل بالخادم\nتحقق من الاتصال بالإنترنت',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
