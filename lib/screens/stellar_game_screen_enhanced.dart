import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
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
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
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

  // Timing
  DateTime? gameStartTime;
  Duration gameDuration = Duration.zero;
  Timer? _gameTimer;

  // Animations
  late AnimationController _boardController;
  late AnimationController _winController;
  late List<AnimationController> _cellAnimations;

  // Real game tracking
  bool _isDataLoaded = false;

  // Stats
  int player1Score = 0;
  int player2Score = 0;
  int drawCount = 0;

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

  void _initializeAnimations() {
    _boardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _winController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cellAnimations = List.generate(
      9,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );
  }

  void _initializeGame() {
    board = List.filled(9, '');
    currentPlayer = 'X';

    // Initialize Players
    final user = _authService.currentUser;

    player1 = GamePlayer(
      id: user?.id ?? 'player1',
      name: user?.displayName ?? 'اللاعب 1',
      symbol: 'X',
      isAI: false,
      avatar: user?.photoURL,
    );

    if (widget.gameMode == 'ai') {
      player2 = GamePlayer(
        id: 'ai_${widget.aiLevel ?? 3}',
        name: _getAIName(widget.aiLevel ?? 3),
        symbol: 'O',
        isAI: true,
      );
    } else if (widget.gameMode == 'local') {
      player2 = GamePlayer(
        id: 'player2',
        name: 'اللاعب 2',
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

  void _startGame() {
    gameStartTime = DateTime.now();
    gameDuration = Duration.zero;

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (gameStatus == 'playing') {
        setState(() {
          gameDuration = DateTime.now().difference(gameStartTime!);
        });
      } else {
        timer.cancel();
      }
    });

    _boardController.forward();
  }

  void _makeMove(int index) async {
    if (board[index].isNotEmpty || gameStatus != 'playing') return;

    // Play sound effect
    try {
      AudioHelper.playClickSound();
    } catch (e) {
      print('Error playing sound: $e');
    }

    setState(() {
      board[index] = currentPlayer;
      moveCount++;
    });

    // Animate cell
    _cellAnimations[index].forward();

    if (_checkWinner()) {
      _endGame();
      return;
    }

    if (_checkDraw()) {
      _endGame();
      return;
    }

    _switchPlayer();

    // AI move if needed
    if (widget.gameMode == 'ai' &&
        currentPlayer == 'O' &&
        gameStatus == 'playing') {
      await Future.delayed(const Duration(milliseconds: 500));
      _makeAIMove();
    }
  }

  void _makeAIMove() async {
    try {
      final availableMoves = <int>[];
      for (int i = 0; i < board.length; i++) {
        if (board[i].isEmpty) {
          availableMoves.add(i);
        }
      }

      if (availableMoves.isEmpty) return;

      // Simple AI logic - can be enhanced
      int aiMove;
      if (widget.aiLevel == 1) {
        // Random move
        aiMove =
            availableMoves[DateTime.now().millisecond % availableMoves.length];
      } else {
        // Basic strategy
        aiMove = _getBestAIMove(availableMoves);
      }

      _makeMove(aiMove);
    } catch (e) {
      print('Error in AI move: $e');
    }
  }

  int _getBestAIMove(List<int> availableMoves) {
    // Check for winning move
    for (int move in availableMoves) {
      board[move] = 'O';
      if (_checkWinnerForSymbol('O')) {
        board[move] = '';
        return move;
      }
      board[move] = '';
    }

    // Block player's winning move
    for (int move in availableMoves) {
      board[move] = 'X';
      if (_checkWinnerForSymbol('X')) {
        board[move] = '';
        return move;
      }
      board[move] = '';
    }

    // Take center if available
    if (availableMoves.contains(4)) {
      return 4;
    }

    // Take corners
    final corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (availableMoves.contains(corner)) {
        return corner;
      }
    }

    // Random move
    return availableMoves[0];
  }

  bool _checkWinner() {
    const winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var combination in winningCombinations) {
      if (board[combination[0]].isNotEmpty &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        winner = board[combination[0]];
        winningLine = combination;
        return true;
      }
    }
    return false;
  }

  bool _checkWinnerForSymbol(String symbol) {
    const winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (var combination in winningCombinations) {
      if (board[combination[0]] == symbol &&
          board[combination[1]] == symbol &&
          board[combination[2]] == symbol) {
        return true;
      }
    }
    return false;
  }

  bool _checkDraw() {
    return board.every((cell) => cell.isNotEmpty) && winner.isEmpty;
  }

  void _switchPlayer() {
    setState(() {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
      currentPlayerObj = currentPlayer == 'X' ? player1 : player2;
    });
  }

  void _endGame() async {
    setState(() {
      gameStatus = 'ended';
    });

    _gameTimer?.cancel();

    // Play sound effects
    try {
      if (winner.isNotEmpty) {
        if (winner == player1.symbol) {
          AudioHelper.playWinSound();
        } else {
          AudioHelper.playLoseSound();
        }
      } else {
        AudioHelper.playDrawSound();
      }
    } catch (e) {
      print('Error playing end game sound: $e');
    }

    // Animate winning line
    if (winningLine.isNotEmpty) {
      _winController.forward();
    }

    // Update scores
    if (winner == 'X') {
      player1Score++;
    } else if (winner == 'O') {
      player2Score++;
    } else {
      drawCount++;
    }

    // Save game result
    await _saveGameResult();

    // Show result
    await Future.delayed(const Duration(milliseconds: 1000));
    _showGameResult();
  }

  Future<void> _saveGameResult() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      String result;
      if (winner.isEmpty) {
        result = 'draw';
      } else if (winner == player1.symbol) {
        result = 'win';
      } else {
        result = 'loss';
      }
      await _gameStatsService.recordGameResult(
        gameResult: result,
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

  void _showGameResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildResultDialog(),
    );
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      currentPlayerObj = player1;
      gameStatus = 'playing';
      winner = '';
      winningLine = [];
      moveCount = 0;
      gameStartTime = DateTime.now();
      gameDuration = Duration.zero;
    });

    // Reset animations
    for (var controller in _cellAnimations) {
      controller.reset();
    }
    _winController.reset();

    _startGame();
  }

  String _getAIName(int level) {
    const names = {
      1: 'مبتدئ النجوم',
      2: 'حارس المجرة',
      3: 'قائد الكواكب',
      4: 'إمبراطور الفضاء',
      5: 'عبقري الكون',
    };
    return names[level] ?? 'الذكاء الاصطناعي';
  }

  @override
  Widget build(BuildContext context) {
    final responsiveSystem = ResponsiveSystem.instance;
    responsiveSystem.initialize(context);

    if (!_isDataLoaded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Players info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildPlayerCard(
                      player1,
                      currentPlayer == 'X',
                      responsiveSystem,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Text(
                        '${_formatTime(gameDuration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (userStats != null)
                        Text(
                          'معدل الفوز: ${userStats!.winRate.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPlayerCard(
                      player2,
                      currentPlayer == 'O',
                      responsiveSystem,
                    ),
                  ),
                ],
              ),
            ),

            // Score board
            if (player1Score > 0 || player2Score > 0 || drawCount > 0)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreItem('فوز', '$player1Score', Colors.green),
                    _buildScoreItem('تعادل', '$drawCount', Colors.orange),
                    _buildScoreItem('خسارة', '$player2Score', Colors.red),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Game board
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: AnimatedBuilder(
                      animation: _boardController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _boardController.value,
                          child: _buildGameBoard(responsiveSystem),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(
      GamePlayer player, bool isActive, ResponsiveSystem responsiveSystem) {
    return Container(
      padding: EdgeInsets.all(responsiveSystem.isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            isActive ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: responsiveSystem.isDesktop ? 30 : 25,
            backgroundColor: AppColors.primary.withValues(alpha: 0.3),
            backgroundImage:
                player.avatar != null ? NetworkImage(player.avatar!) : null,
            child: player.avatar == null
                ? Text(
                    player.symbol,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsiveSystem.isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            player.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsiveSystem.isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (player.isAI)
            Text(
              'AI Level ${widget.aiLevel ?? 3}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: responsiveSystem.isDesktop ? 12 : 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard(ResponsiveSystem responsiveSystem) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 9,
          itemBuilder: (context, index) => _buildCell(index, responsiveSystem),
        ),
      ),
    );
  }

  Widget _buildCell(int index, ResponsiveSystem responsiveSystem) {
    final isWinningCell = winningLine.contains(index);

    return GestureDetector(
      onTap: () => _makeMove(index),
      child: AnimatedBuilder(
        animation: _cellAnimations[index],
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_cellAnimations[index].value * 0.1),
            child: Container(
              decoration: BoxDecoration(
                color: isWinningCell
                    ? AppColors.primary.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  board[index],
                  style: TextStyle(
                    color: board[index] == 'X'
                        ? AppColors.primary
                        : AppColors.accent,
                    fontSize: responsiveSystem.isDesktop ? 48 : 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultDialog() {
    String title;
    String message;
    Color titleColor;

    if (winner.isEmpty) {
      title = 'تعادل!';
      message = 'لعبة رائعة! انتهت بالتعادل';
      titleColor = Colors.orange;
    } else if (winner == player1.symbol) {
      title = 'فوز رائع!';
      message = 'تهانينا، لقد فزت!';
      titleColor = Colors.green;
    } else {
      title = 'للأسف خسرت';
      message = 'حظ أفضل في المرة القادمة';
      titleColor = Colors.red;
    }
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              winner.isEmpty
                  ? Icons.handshake
                  : winner == player1.symbol
                      ? Icons.emoji_events
                      : Icons.sentiment_dissatisfied,
              size: 64,
              color: titleColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'وقت اللعب: ${_formatTime(gameDuration)}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            Text(
              'عدد الحركات: $moveCount',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('لعب مرة أخرى'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('العودة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
