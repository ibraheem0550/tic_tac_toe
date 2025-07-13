import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // TODO: Add when needed
import '../services/online_game_service.dart';
import '../services/unified_auth_services.dart';
import '../models/complete_user_models.dart';
import '../audio_helper.dart';
import '../utils/app_theme_new.dart';

/// شاشة اللعب أونلاين النجمية
class StellarOnlineGameScreen extends StatefulWidget {
  const StellarOnlineGameScreen({super.key});

  @override
  State<StellarOnlineGameScreen> createState() =>
      _StellarOnlineGameScreenState();
}

class _StellarOnlineGameScreenState extends State<StellarOnlineGameScreen>
    with TickerProviderStateMixin {
  final OnlineGameService _gameService = OnlineGameService();
  late AnimationController _pulseController;
  late AnimationController _boardController;
  late AnimationController _starfieldController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _boardAnimation;
  late Animation<double> _starfieldAnimation;
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
    )..repeat(reverse: true);

    _boardController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _starfieldController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _boardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _boardController, curve: Curves.elasticOut),
    );

    _starfieldAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_starfieldController);
  }

  void _loadCurrentUser() async {
    try {
      final user = FirebaseAuthService().currentUserModel;
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _onGameStateChanged() {
    setState(() {});
    if (_gameService.gameStatus == 'playing') {
      _boardController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _boardController.dispose();
    _starfieldController.dispose();
    _gameService.removeListener(_onGameStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.starfieldGradient),
        child: Stack(
          children: [
            _buildAnimatedStarfield(),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(isTablet),
                  Expanded(child: _buildGameContent(isTablet)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStarfield() {
    return AnimatedBuilder(
      animation: _starfieldAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.5 + (0.3 * (_starfieldAnimation.value - 0.5)),
                0.5 + (0.2 * (_starfieldAnimation.value - 0.5)),
              ),
              radius: 1.5,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.backgroundPrimary.withValues(alpha: 0.3),
                AppColors.backgroundPrimary,
              ],
            ),
          ),
          child: CustomPaint(
            painter: StarfieldPainter(_starfieldAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isTablet) {
    final padding = isTablet ? 24.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.cosmicButtonGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معركة نجمية',
                  style: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: isTablet ? 28 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'تحدى لاعبين من حول العالم',
                  style: TextStyle(
                    color: AppColors.secondaryLight,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isTablet ? 60 : 48,
                  height: isTablet ? 60 : 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.starGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.public,
                    color: Colors.white,
                    size: isTablet ? 32 : 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(bool isTablet) {
    switch (_gameService.gameStatus) {
      case 'waiting':
        return _buildWaitingRoom(isTablet);
      case 'searching':
        return _buildSearchingScreen(isTablet);
      case 'playing':
        return _buildGameBoard(isTablet);
      case 'finished':
        return _buildGameOverScreen(isTablet);
      default:
        return _buildWaitingRoom(isTablet);
    }
  }

  Widget _buildWaitingRoom(bool isTablet) {
    final padding = isTablet ? 32.0 : 24.0;

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.stellarGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.starGold.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: isTablet ? 60 : 50,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: padding),
          Text(
            'أهلاً بك في الساحة الكونية',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: isTablet ? 26 : 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: padding / 2),
          Text(
            'ابحث عن منافسين واخوض معارك استراتيجية',
            style: TextStyle(
              color: AppColors.secondaryLight,
              fontSize: isTablet ? 18 : 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: padding),
          _buildUserInfo(isTablet),
          SizedBox(height: padding),
          _buildActionButton(
            text: 'ابحث عن منافس',
            icon: Icons.search,
            gradient: AppColors.cosmicButtonGradient,
            onPressed: _isConnecting ? null : _startSearching,
            isTablet: isTablet,
          ),
          SizedBox(height: padding / 2),
          _buildActionButton(
            text: 'غرفة خاصة',
            icon: Icons.lock,
            gradient: const LinearGradient(
              colors: [AppColors.nebulaPurple, AppColors.galaxyBlue],
            ),
            onPressed: _createPrivateRoom,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(bool isTablet) {
    if (_currentUser == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfacePrimary, AppColors.surfaceSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 60 : 50,
            height: isTablet ? 60 : 50,
            decoration: BoxDecoration(
              gradient: AppColors.stellarGradient,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.starGold, width: 2),
            ),
            child: ClipOval(
              child: _currentUser!.photoURL != null
                  ? Image.network(
                      _currentUser!.photoURL!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Icon(
                          Icons.person,
                          color: Colors.white,
                          size: isTablet ? 30 : 25,
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isTablet ? 30 : 25,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: Colors.white,
                      size: isTablet ? 30 : 25,
                    ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.displayName ?? 'لاعب مجهول',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.starGold,
                      size: isTablet ? 18 : 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'المستوى ${(() {
                        final wins = _currentUser?.profile?.gameStats.wins ?? 0;
                        return (wins ~/ 10 + 1);
                      })()}',
                      style: TextStyle(
                        color: AppColors.secondaryLight,
                        fontSize: isTablet ? 14 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 8,
              vertical: isTablet ? 6 : 4,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.success, AppColors.successLight],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'متصل',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 12 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback? onPressed,
    required bool isTablet,
  }) {
    return Container(
      width: double.infinity,
      height: isTablet ? 60 : 50,
      decoration: BoxDecoration(
        gradient: onPressed != null ? gradient : null,
        color: onPressed == null ? AppColors.textMuted : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isTablet ? 24 : 20),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchingScreen(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _starfieldAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _starfieldAnimation.value * 2 * 3.14159,
                child: Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.stellarGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: isTablet ? 60 : 50,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: isTablet ? 32 : 24),
          Text(
            'البحث عن منافس...',
            style: TextStyle(
              color: AppColors.primaryLight,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'يتم البحث في الكون عن منافس مناسب',
            style: TextStyle(
              color: AppColors.secondaryLight,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          SizedBox(height: isTablet ? 32 : 24),
          _buildActionButton(
            text: 'إلغاء البحث',
            icon: Icons.close,
            gradient: const LinearGradient(
              colors: [AppColors.error, AppColors.errorLight],
            ),
            onPressed: _cancelSearch,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(bool isTablet) {
    return AnimatedBuilder(
      animation: _boardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _boardAnimation.value,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              children: [
                _buildPlayersInfo(isTablet),
                SizedBox(height: isTablet ? 24 : 16),
                Expanded(child: _buildBoard(isTablet)),
                SizedBox(height: isTablet ? 24 : 16),
                _buildGameActions(isTablet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayersInfo(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfacePrimary, AppColors.surfaceSecondary],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _buildPlayerInfo(_currentUser, true, isTablet),
          Expanded(
            child: Column(
              children: [
                Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.flash_on,
                  color: AppColors.starGold,
                  size: isTablet ? 24 : 20,
                ),
              ],
            ),
          ),
          _buildPlayerInfo(_gameService.opponent, false, isTablet),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(User? user, bool isCurrentPlayer, bool isTablet) {
    return Column(
      children: [
        Container(
          width: isTablet ? 50 : 40,
          height: isTablet ? 50 : 40,
          decoration: BoxDecoration(
            gradient: isCurrentPlayer
                ? AppColors.stellarGradient
                : AppColors.nebularGradient,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentPlayer ? AppColors.starGold : AppColors.secondary,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: isTablet ? 25 : 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          user?.displayName ?? 'منافس',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBoard(bool isTablet) {
    final boardSize = isTablet ? 300.0 : 250.0;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.surfacePrimary, AppColors.surfaceElevated],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return _buildBoardCell(index, isTablet);
        },
      ),
    );
  }

  Widget _buildBoardCell(int index, bool isTablet) {
    final cellValue = _gameService.board[index];

    return Container(
      decoration: BoxDecoration(
        gradient: cellValue.isEmpty
            ? const LinearGradient(
                colors: [
                  AppColors.backgroundSecondary,
                  AppColors.backgroundTertiary,
                ],
              )
            : (cellValue == 'X'
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    )
                  : const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                    )),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: cellValue.isEmpty ? () => _makeMove(index) : null,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: cellValue.isNotEmpty
                ? Text(
                    cellValue,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 36 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildGameActions(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: 'استسلام',
            icon: Icons.flag,
            gradient: const LinearGradient(
              colors: [AppColors.error, AppColors.errorLight],
            ),
            onPressed: _surrender,
            isTablet: isTablet,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Expanded(
          child: _buildActionButton(
            text: 'إعادة اللعب',
            icon: Icons.refresh,
            gradient: const LinearGradient(
              colors: [AppColors.info, AppColors.infoLight],
            ),
            onPressed: _requestRematch,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen(bool isTablet) {
    final winner = _gameService.winner;
    final isWinner = winner == _currentUser?.id;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: isTablet ? 120 : 100,
                  height: isTablet ? 120 : 100,
                  decoration: BoxDecoration(
                    gradient: isWinner
                        ? AppColors.stellarGradient
                        : const LinearGradient(
                            colors: [AppColors.error, AppColors.errorLight],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isWinner ? AppColors.starGold : AppColors.error)
                            .withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    isWinner
                        ? Icons.emoji_events
                        : Icons.sentiment_dissatisfied,
                    color: Colors.white,
                    size: isTablet ? 60 : 50,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: isTablet ? 32 : 24),
          Text(
            isWinner ? 'نصر عظيم!' : 'حاول مرة أخرى',
            style: TextStyle(
              color: isWinner ? AppColors.success : AppColors.error,
              fontSize: isTablet ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            isWinner
                ? 'لقد هزمت منافسك في معركة نجمية رائعة!'
                : 'لا تيأس، النجوم تنتظر انتصارك القادم',
            style: TextStyle(
              color: AppColors.secondaryLight,
              fontSize: isTablet ? 16 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 32 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                text: 'لعبة جديدة',
                icon: Icons.refresh,
                gradient: AppColors.cosmicButtonGradient,
                onPressed: _startNewGame,
                isTablet: isTablet,
              ),
              _buildActionButton(
                text: 'العودة',
                icon: Icons.home,
                gradient: const LinearGradient(
                  colors: [AppColors.info, AppColors.infoLight],
                ),
                onPressed: () => Navigator.pop(context),
                isTablet: isTablet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Game action methods
  void _startSearching() {
    setState(() {
      _isConnecting = true;
    });
    _gameService.findMatch();
    AudioHelper.playClickSound();
  }

  void _cancelSearch() {
    _gameService.leaveGame();
    setState(() {
      _isConnecting = false;
    });
    AudioHelper.playClickSound();
  }

  void _createPrivateRoom() {
    // Implementation for private room
    AudioHelper.playClickSound();
  }

  void _makeMove(int index) {
    _gameService.makeMove(index);
    AudioHelper.playClickSound();
  }

  void _surrender() {
    _gameService.leaveGame();
    AudioHelper.playClickSound();
  }

  void _requestRematch() {
    _gameService.findMatch();
    AudioHelper.playClickSound();
  }

  void _startNewGame() {
    _gameService.leaveGame();
    setState(() {
      _isConnecting = false;
    });
    AudioHelper.playClickSound();
  }
}

// Custom painter for animated starfield
class StarfieldPainter extends CustomPainter {
  final double animationValue;

  StarfieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.starGold.withValues(alpha: 0.6);

    // Draw animated stars
    for (int i = 0; i < 50; i++) {
      final x = (i * 37.5) % size.width;
      final y = (i * 23.7 + animationValue * 100) % size.height;
      final starSize = (i % 3) + 1.0;

      canvas.drawCircle(
        Offset(x, y),
        starSize,
        paint
          ..color = AppColors.starGold.withValues(alpha: 0.3 + (i % 3) * 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
