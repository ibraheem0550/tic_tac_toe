import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../AI/ai_engine.dart';
import '../audio_helper.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_system.dart';
import '../services/firebase_auth_service.dart';
import '../services/game_stats_service.dart';
import '../models/complete_user_models.dart';

/// نموذج اللاعب في اللعبة
class GamePlayer {
  final String id;
  final String name;
  final String symbol;
  final bool isAI;
  final String? avatar;

  GamePlayer({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isAI,
    this.avatar,
  });
}

/// شاشة اللعب المحسنة - تصميم نجمي احترافي مع بيانات حقيقية
class StellarGameScreenEnhanced extends StatefulWidget {
  final String gameMode; // 'ai', 'local', 'online'
  final int? aiLevel; // 1-5 للذكاء الاصطناعي
  final String? opponentId; // للعب الأونلاين
  final Map<String, dynamic>? gameData;

  const StellarGameScreenEnhanced({
    super.key,
    required this.gameMode,
    this.aiLevel,
    this.opponentId,
    this.gameData,
  });

  @override
  State<StellarGameScreenEnhanced> createState() =>
      _StellarGameScreenEnhancedState();
}

class _StellarGameScreenEnhancedState extends State<StellarGameScreenEnhanced>
    with TickerProviderStateMixin {
  // Services
  final FirebaseAuthService _authService = FirebaseAuthService();
  final GameStatsService _gameStatsService = GameStatsService();

  // Game State
  late List<String> board;
  late String currentPlayer;
  String gameStatus = 'playing'; // playing, ended, paused
  String winner = '';
  List<int> winningLine = [];
  int moveCount = 0;
  // Players
  late GamePlayer player1;
  late GamePlayer player2;
  GamePlayer? currentPlayerObj;

  // Real User Data
  User? currentUser;
  GameStats? userStats;
  bool _isDataLoaded = false;

  // Timing
  DateTime? gameStartTime;
  Duration gameDuration = Duration.zero;
  Timer? _gameTimer;

  // Animations
  late AnimationController _boardController;
  late AnimationController _cellController;
  late AnimationController _winController;
  late List<AnimationController> _cellAnimations;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
    _loadUserData();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _boardController.dispose();
    _cellController.dispose();
    _winController.dispose();
    for (var controller in _cellAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  /// تحميل بيانات المستخدم الحقيقية
  Future<void> _loadUserData() async {
    try {
      currentUser = _authService.currentUser;
      userStats = await _gameStatsService.loadGameStats();

      setState(() {
        _isDataLoaded = true;
      });
    } catch (e) {
      print('خطأ في تحميل بيانات المستخدم: $e');
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  void _initializeGame() {
    board = List.filled(9, '');
    currentPlayer = 'X';
    gameStatus = 'playing';
    winner = '';
    winningLine = [];
    moveCount = 0;

    // إعداد اللاعبين بناءً على البيانات الحقيقية
    _setupPlayers();
  }

  void _setupPlayers() {
    // اللاعب الأول (المستخدم الحالي)
    final user = _authService.currentUser;
    player1 = GamePlayer(
      id: user?.id ?? 'player1',
      name:
          user?.displayName ?? (user?.isGuest == true ? 'ضيف' : 'اللاعب الأول'),
      symbol: 'X',
      isAI: false,
      avatar: user?.photoURL,
    );

    // اللاعب الثاني حسب نوع اللعبة
    if (widget.gameMode == 'ai') {
      player2 = GamePlayer(
        id: 'ai',
        name: _getAIName(widget.aiLevel ?? 3),
        symbol: 'O',
        isAI: true,
      );
    } else if (widget.gameMode == 'local') {
      player2 = GamePlayer(
        id: 'player2',
        name: 'اللاعب الثاني',
        symbol: 'O',
        isAI: false,
      );
    } else {
      // Online mode
      player2 = GamePlayer(
        id: widget.opponentId ?? 'opponent',
        name: 'الخصم',
        symbol: 'O',
        isAI: false,
      );
    }

    currentPlayerObj = player1;
  }

  void _initializeAnimations() {
    _boardController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _cellController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _winController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _cellAnimations = List.generate(
      9,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );
  }

  void _startGame() {
    gameStartTime = DateTime.now();
    _boardController.forward();

    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (gameStartTime != null && gameStatus == 'playing') {
        setState(() {
          gameDuration = DateTime.now().difference(gameStartTime!);
        });
      }
    });
  }

  void _makeMove(int index) async {
    if (board[index].isNotEmpty || gameStatus != 'playing') return;

    // Haptic feedback
    HapticFeedback.selectionClick();

    setState(() {
      board[index] = currentPlayer;
      moveCount++;
    });

    // Animate cell
    _cellAnimations[index].forward();
    // Play sound
    await AudioHelper.playClickSound();

    // Check for win
    if (_checkWin()) {
      _endGame(currentPlayer);
      return;
    }

    // Check for draw
    if (moveCount == 9) {
      _endGame('draw');
      return;
    }

    // Switch player
    _switchPlayer();

    // AI move if needed
    if (widget.gameMode == 'ai' &&
        currentPlayer == 'O' &&
        gameStatus == 'playing') {
      await Future.delayed(Duration(milliseconds: 500));
      _makeAIMove();
    }
  }

  void _makeAIMove() async {
    final aiMove = AIEngine.getBestMove(board, widget.aiLevel ?? 3);
    if (aiMove != -1) {
      _makeMove(aiMove);
    }
  }

  void _switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      currentPlayerObj = currentPlayer == 'X' ? player1 : player2;
    });
  }

  bool _checkWin() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]] &&
          board[pattern[0]].isNotEmpty) {
        winningLine = pattern;
        return true;
      }
    }
    return false;
  }

  void _endGame(String result) async {
    setState(() {
      gameStatus = 'ended';
      winner = result;
    });

    _gameTimer?.cancel();
    _winController.forward();
    // تحديد نتيجة اللعبة للاعب الأول (المستخدم الحالي)
    String gameResult;
    if (result == 'X') {
      gameResult = 'win';
      await AudioHelper.playWinSound();
    } else if (result == 'O') {
      if (widget.gameMode == 'ai') {
        gameResult = 'loss';
        await AudioHelper.playLoseSound();
      } else {
        gameResult = 'loss';
        await AudioHelper.playWinSound();
      }
    } else {
      gameResult = 'draw';
      await AudioHelper.playDrawSound();
    }

    // حفظ نتيجة اللعبة في الإحصائيات الحقيقية
    await _saveGameResult(gameResult);

    // عرض نتيجة اللعبة
    _showGameResult();
  }

  /// حفظ نتيجة اللعبة في الإحصائيات الحقيقية
  Future<void> _saveGameResult(String gameResult) async {
    try {
      await _gameStatsService.recordGameResult(
        gameResult: gameResult,
        gameDuration: gameDuration,
        gameMode: widget.gameMode,
        aiLevel: widget.aiLevel,
        opponentId: widget.opponentId,
      );

      // تحديث الإحصائيات المحلية
      userStats = await _gameStatsService.loadGameStats();
      setState(() {});
    } catch (e) {
      print('خطأ في حفظ نتيجة اللعبة: $e');
    }
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      gameStatus = 'playing';
      winner = '';
      winningLine = [];
      moveCount = 0;
      currentPlayerObj = player1;
    });

    // Reset animations
    for (var controller in _cellAnimations) {
      controller.reset();
    }
    _winController.reset();

    _startGame();
  }

  String _getAIName(int level) {
    return AIEngine.getDifficultyName(level);
  }

  String _getGameModeTitle() {
    switch (widget.gameMode) {
      case 'ai':
        return 'ضد الذكاء الاصطناعي';
      case 'local':
        return 'لعب محلي';
      case 'online':
        return 'لعب أونلاين';
      default:
        return 'تيك تاك تو نجمي';
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
              return Column(
                children: [
                  _buildHeader(sizingInfo),
                  _buildPlayersInfo(sizingInfo),
                  Expanded(
                    child: _buildGameBoard(sizingInfo),
                  ),
                  _buildBottomControls(sizingInfo),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SizingInformation sizingInfo) {
    return Container(
      padding: EdgeInsets.all(sizingInfo.isDesktop ? 24 : 16),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfacePrimary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    _getGameModeTitle(),
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.starGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (gameStatus == 'playing')
                    Text(
                      _formatTime(gameDuration),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Settings button
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfacePrimary.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: IconButton(
              icon: Icon(Icons.settings, color: AppColors.textPrimary),
              onPressed: _showGameSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersInfo(SizingInformation sizingInfo) {
    if (!_isDataLoaded) {
      return Container(
        margin:
            EdgeInsets.symmetric(horizontal: sizingInfo.isDesktop ? 24 : 16),
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.starGold),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sizingInfo.isDesktop ? 24 : 16),
      child: Row(
        children: [
          Expanded(
              child:
                  _buildPlayerCard(player1, currentPlayer == 'X', sizingInfo)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  'VS',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.starGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (userStats != null)
                  Text(
                    'معدل الفوز: ${userStats!.winRate.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
              child:
                  _buildPlayerCard(player2, currentPlayer == 'O', sizingInfo)),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
      GamePlayer player, bool isActive, SizingInformation sizingInfo) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(sizingInfo.isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.nebularGradient : null,
        color:
            isActive ? null : AppColors.surfacePrimary.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.starGold : AppColors.borderPrimary,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.starGold.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: sizingInfo.isDesktop ? 60 : 48,
            height: sizingInfo.isDesktop ? 60 : 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.borderSecondary),
            ),
            child: player.avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      player.avatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(player),
                    ),
                  )
                : _buildDefaultAvatar(player),
          ),
          SizedBox(height: 8),

          // Name
          Text(
            player.name,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Symbol
          Container(
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: player.symbol == 'X'
                  ? AppColors.primary
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              player.symbol,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Player Stats
          if (player == player1 && userStats != null) ...[
            SizedBox(height: 4),
            Text(
              'الانتصارات: ${userStats!.wins}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(GamePlayer player) {
    return Container(
      decoration: BoxDecoration(
        gradient: player.isAI
            ? AppColors.stellarGradient
            : AppColors.cosmicButtonGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(
        player.isAI ? Icons.smart_toy : Icons.person,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildGameBoard(SizingInformation sizingInfo) {
    final boardSize = sizingInfo.isDesktop
        ? 360.0
        : sizingInfo.isTablet
            ? 320.0
            : 280.0;

    return Center(
      child: AnimatedBuilder(
        animation: _boardController,
        builder: (context, child) {
          return Transform.scale(
            scale: _boardController.value,
            child: Container(
              width: boardSize,
              height: boardSize,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.nebularGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.starGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) =>
                      _buildGameCell(index, sizingInfo),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameCell(int index, SizingInformation sizingInfo) {
    final isWinningCell = winningLine.contains(index);

    return AnimatedBuilder(
      animation: _cellAnimations[index],
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _makeMove(index),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isWinningCell
                  ? AppColors.starGold.withValues(alpha: 0.3)
                  : AppColors.surfacePrimary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isWinningCell
                    ? AppColors.starGold
                    : AppColors.borderPrimary,
                width: isWinningCell ? 2 : 1,
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: _cellAnimations[index].value,
                child: Text(
                  board[index],
                  style: AppTextStyles.displayLarge.copyWith(
                    color: board[index] == 'X'
                        ? AppColors.primary
                        : AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: sizingInfo.isDesktop
                        ? 48
                        : sizingInfo.isTablet
                            ? 40
                            : 32,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(SizingInformation sizingInfo) {
    return Container(
      padding: EdgeInsets.all(sizingInfo.isDesktop ? 24 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Restart button
          _buildControlButton(
            icon: Icons.refresh,
            label: 'إعادة تشغيل',
            onPressed: _resetGame,
            sizingInfo: sizingInfo,
          ),

          // Pause button
          if (gameStatus == 'playing')
            _buildControlButton(
              icon: Icons.pause,
              label: 'إيقاف مؤقت',
              onPressed: _pauseGame,
              sizingInfo: sizingInfo,
            ),

          // Stats button
          _buildControlButton(
            icon: Icons.analytics,
            label: 'الإحصائيات',
            onPressed: _showStatsDialog,
            sizingInfo: sizingInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required SizingInformation sizingInfo,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: sizingInfo.isDesktop ? 24 : 16,
            vertical: sizingInfo.isDesktop ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _pauseGame() {
    setState(() {
      gameStatus = gameStatus == 'playing' ? 'paused' : 'playing';
    });

    if (gameStatus == 'paused') {
      _gameTimer?.cancel();
    } else {
      _startGame();
    }
  }

  void _showGameSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: Text(
          'إعدادات اللعبة',
          style: AppTextStyles.headlineSmall
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.volume_up, color: AppColors.textPrimary),
              title: Text('الصوت',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textPrimary)),
              trailing: Switch(
                value: true, // TODO: implement audio settings
                onChanged: (value) {},
                activeColor: AppColors.starGold,
              ),
            ),
            ListTile(
              leading: Icon(Icons.vibration, color: AppColors.textPrimary),
              title: Text('الاهتزاز',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.textPrimary)),
              trailing: Switch(
                value: true, // TODO: implement haptic settings
                onChanged: (value) {},
                activeColor: AppColors.starGold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: TextStyle(color: AppColors.starGold)),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    if (userStats == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: Text(
          'إحصائياتك',
          style: AppTextStyles.headlineSmall
              .copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('إجمالي الألعاب', '${userStats!.totalGames}'),
            _buildStatRow('الانتصارات', '${userStats!.wins}'),
            _buildStatRow('الخسارات', '${userStats!.losses}'),
            _buildStatRow('التعادل', '${userStats!.draws}'),
            _buildStatRow(
                'معدل الفوز', '${userStats!.winRate.toStringAsFixed(1)}%'),
            _buildStatRow('أفضل سلسلة انتصارات', '${userStats!.bestWinStreak}'),
            _buildStatRow('متوسط وقت اللعبة',
                '${(userStats!.averageGameTime / 60).toStringAsFixed(1)} دقيقة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: TextStyle(color: AppColors.starGold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.starGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showGameResult() {
    String title;
    String message;
    Color titleColor;

    if (winner == 'X') {
      title = '🎉 تهانينا!';
      message = 'لقد فزت في هذه الجولة!';
      titleColor = AppColors.primary;
    } else if (winner == 'O') {
      if (widget.gameMode == 'ai') {
        title = '😔 الذكاء الاصطناعي فاز';
        message = 'حاول مرة أخرى، يمكنك الفوز!';
      } else {
        title = '🎉 اللاعب الثاني فاز!';
        message = 'تهانينا للفائز!';
      }
      titleColor = AppColors.secondary;
    } else {
      title = '🤝 تعادل!';
      message = 'لعبة متوازنة ومثيرة!';
      titleColor = AppColors.starGold;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: Text(
          title,
          style: AppTextStyles.headlineSmall.copyWith(color: titleColor),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTextStyles.bodyLarge
                  .copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'وقت اللعبة: ${_formatTime(gameDuration)}',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            if (userStats != null) ...[
              SizedBox(height: 8),
              Text(
                'إجمالي انتصاراتك: ${userStats!.wins}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.starGold),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _resetGame,
            child: Text('لعب مرة أخرى',
                style: TextStyle(color: AppColors.starGold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('العودة للقائمة',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
