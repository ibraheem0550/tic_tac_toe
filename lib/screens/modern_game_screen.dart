import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../design_system/modern_theme.dart';
import '../design_system/modern_components.dart';
import '../AI/ai_engine.dart';

/// شاشة اللعب الحديثة - تصميم مبتكر وتفاعلي
class ModernGameScreen extends StatefulWidget {
  final String gameMode; // 'ai', 'local', 'online'

  const ModernGameScreen({super.key, required this.gameMode});

  @override
  State<ModernGameScreen> createState() => _ModernGameScreenState();
}

class _ModernGameScreenState extends State<ModernGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _boardController;
  late AnimationController _particlesController;
  late AnimationController _celebrationController;

  // Game state
  List<String> _board = List.filled(9, '');
  String _currentPlayer = 'X';
  String _gameStatus = 'playing'; // playing, ended
  String _winner = '';
  List<int> _winningLine = [];
  int _moveCount = 0;

  // Players info
  String _player1Name = 'اللاعب الأول';
  String _player2Name = 'اللاعب الثاني';

  // AI
  final AIEngine _aiEngine = AIEngine();

  // Scores
  int _player1Score = 0;
  int _player2Score = 0;
  int _drawCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _boardController.dispose();
    _particlesController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _setupPlayerNames();
  }

  void _setupPlayerNames() {
    switch (widget.gameMode) {
      case 'ai':
        _player1Name = 'أنت';
        _player2Name = 'الذكاء الاصطناعي';
        break;
      case 'local':
        _player1Name = 'اللاعب الأول';
        _player2Name = 'اللاعب الثاني';
        break;
      case 'online':
        _player1Name = 'أنت';
        _player2Name = 'الخصم';
        break;
    }
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _boardController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _boardController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          _buildContent(),
          if (_gameStatus == 'ended') _buildCelebrationOverlay(),
        ],
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
          return CustomPaint(
            painter: GameBackgroundPainter(_backgroundController.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: ModernSpacing.lg),
            _buildScoreBoard(),
            const Expanded(child: SizedBox(height: ModernSpacing.xl)),
            _buildGameBoard(),
            const Expanded(child: SizedBox(height: ModernSpacing.xl)),
            _buildGameControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return ModernAnimations.fadeIn(
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ModernRadius.md),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
          ),
          Expanded(
            child: Text(
              _getGameModeTitle(),
              style: ModernTextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ModernRadius.md),
            ),
            child: IconButton(
              onPressed: _showGameMenu,
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return ModernAnimations.fadeIn(
      offset: const Offset(0, -20),
      child: Container(
        padding: const EdgeInsets.all(ModernSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(ModernRadius.xl),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildPlayerScore(
                _player1Name,
                'X',
                _player1Score,
                _currentPlayer == 'X' && _gameStatus == 'playing',
                ModernColors.error,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(width: ModernSpacing.md),
            Column(
              children: [
                Text(
                  'تعادل',
                  style: ModernTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  '$_drawCount',
                  style: ModernTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: ModernSpacing.md),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildPlayerScore(
                _player2Name,
                'O',
                _player2Score,
                _currentPlayer == 'O' && _gameStatus == 'playing',
                ModernColors.info,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerScore(
    String name,
    String symbol,
    int score,
    bool isActive,
    Color symbolColor,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: symbolColor.withOpacity(isActive ? 1.0 : 0.5),
                borderRadius: BorderRadius.circular(ModernRadius.xs),
              ),
              child: Center(
                child: Text(
                  symbol,
                  style: ModernTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: ModernSpacing.xs),
            Text(
              name,
              style: ModernTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(isActive ? 1.0 : 0.7),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: ModernSpacing.xs),
        Text(
          '$score',
          style: ModernTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return ModernAnimations.scaleIn(
      child: AnimatedBuilder(
        animation: _boardController,
        builder: (context, child) {
          return Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ModernRadius.xl),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(ModernSpacing.md),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: ModernSpacing.sm,
                  mainAxisSpacing: ModernSpacing.sm,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return _buildGameCell(index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameCell(int index) {
    final isWinningCell = _winningLine.contains(index);
    final isEmpty = _board[index].isEmpty;
    final symbol = _board[index];

    return GestureDetector(
      onTap: isEmpty && _gameStatus == 'playing'
          ? () => _makeMove(index)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isWinningCell
              ? Colors.yellow.withOpacity(0.3)
              : Colors.white.withOpacity(isEmpty ? 0.1 : 0.2),
          borderRadius: BorderRadius.circular(ModernRadius.md),
          border: Border.all(
            color: isWinningCell
                ? Colors.yellow
                : Colors.white.withOpacity(0.4),
            width: isWinningCell ? 2 : 1,
          ),
          boxShadow: isEmpty
              ? null
              : [
                  BoxShadow(
                    color:
                        (symbol == 'X' ? ModernColors.error : ModernColors.info)
                            .withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: Center(
          child: symbol.isNotEmpty
              ? TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Text(
                        symbol,
                        style: ModernTextStyles.displayLarge.copyWith(
                          color: symbol == 'X'
                              ? ModernColors.error
                              : ModernColors.info,
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                        ),
                      ),
                    );
                  },
                )
              : Container(),
        ),
      ),
    );
  }

  Widget _buildGameControls() {
    return ModernAnimations.fadeIn(
      offset: const Offset(0, 20),
      child: Row(
        children: [
          Expanded(
            child: ModernComponents.modernButton(
              text: 'لعبة جديدة',
              onPressed: _resetGame,
              icon: Icons.refresh,
              gradient: ModernDesignSystem.secondaryGradient,
            ),
          ),
          const SizedBox(width: ModernSpacing.md),
          Expanded(
            child: ModernComponents.modernButton(
              text: 'إعادة تشغيل',
              onPressed: _restartMatch,
              icon: Icons.replay,
              isOutlined: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.7 * _celebrationController.value),
          child: Center(
            child: Transform.scale(
              scale: _celebrationController.value,
              child: Container(
                margin: const EdgeInsets.all(ModernSpacing.xl),
                padding: const EdgeInsets.all(ModernSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ModernRadius.xxl),
                  boxShadow: ModernDesignSystem.largeShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _winner.isEmpty ? Icons.handshake : Icons.emoji_events,
                      size: 80,
                      color: _winner.isEmpty
                          ? ModernColors.warning
                          : ModernColors.success,
                    ),
                    const SizedBox(height: ModernSpacing.lg),
                    Text(
                      _winner.isEmpty ? 'تعادل!' : 'مبروك!',
                      style: ModernTextStyles.displayMedium.copyWith(
                        color: ModernColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: ModernSpacing.sm),
                    Text(
                      _winner.isEmpty
                          ? 'انتهت اللعبة بالتعادل'
                          : 'فاز ${_winner == 'X' ? _player1Name : _player2Name}!',
                      style: ModernTextStyles.bodyLarge.copyWith(
                        color: ModernColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: ModernSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: ModernComponents.modernButton(
                            text: 'لعبة أخرى',
                            onPressed: () {
                              _celebrationController.reverse();
                              _resetGame();
                            },
                            gradient: ModernDesignSystem.primaryGradient,
                          ),
                        ),
                        const SizedBox(width: ModernSpacing.md),
                        Expanded(
                          child: ModernComponents.modernButton(
                            text: 'الرئيسية',
                            onPressed: () => Navigator.pop(context),
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Game Logic
  void _makeMove(int index) {
    if (_gameStatus != 'playing' || _board[index].isNotEmpty) return;

    setState(() {
      _board[index] = _currentPlayer;
      _moveCount++;
    });

    HapticFeedback.lightImpact();
    _checkGameEnd();

    if (_gameStatus == 'playing') {
      setState(() {
        _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
      });

      // AI move
      if (widget.gameMode == 'ai' && _currentPlayer == 'O') {
        _makeAIMove();
      }
    }
  }

  void _makeAIMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_gameStatus != 'playing') return;

      final aiMove = AIEngine.getBestMoveForPlayer(_board, 'O');
      if (aiMove != -1) {
        _makeMove(aiMove);
      }
    });
  }

  void _checkGameEnd() {
    // Check winning patterns
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (final pattern in winPatterns) {
      final a = _board[pattern[0]];
      final b = _board[pattern[1]];
      final c = _board[pattern[2]];

      if (a.isNotEmpty && a == b && b == c) {
        setState(() {
          _gameStatus = 'ended';
          _winner = a;
          _winningLine = pattern;
        });

        if (_winner == 'X') {
          _player1Score++;
        } else {
          _player2Score++;
        }

        _celebrationController.forward();
        HapticFeedback.heavyImpact();
        return;
      }
    }

    // Check draw
    if (_moveCount == 9) {
      setState(() {
        _gameStatus = 'ended';
        _winner = '';
        _drawCount++;
      });
      _celebrationController.forward();
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = 'X';
      _gameStatus = 'playing';
      _winner = '';
      _winningLine = [];
      _moveCount = 0;
    });
  }

  void _restartMatch() {
    _resetGame();
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
      _drawCount = 0;
    });
  }

  void _showGameMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(ModernSpacing.lg),
        padding: const EdgeInsets.all(ModernSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ModernRadius.xl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.pause),
              title: const Text('إيقاف مؤقت'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('الأصوات'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.vibration),
              title: const Text('الاهتزاز'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('الرئيسية'),
              onTap: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  String _getGameModeTitle() {
    switch (widget.gameMode) {
      case 'ai':
        return 'ضد الذكاء الاصطناعي';
      case 'local':
        return 'اللعب المحلي';
      case 'online':
        return 'اللعب الجماعي';
      case 'speed_challenge':
        return 'تحدي السرعة ⚡';
      case 'ai_challenge':
        return 'تحدي الذكاء 🧠';
      case 'win_streak':
        return 'تحدي الانتصارات 🏆';
      default:
        return 'لعبة X O';
    }
  }
}

/// رسام الخلفية المتحركة
class GameBackgroundPainter extends CustomPainter {
  final double animationValue;

  GameBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // رسم شبكة متحركة
    final spacing = 50.0;
    final offsetX = (animationValue * spacing) % spacing;
    final offsetY = (animationValue * spacing * 0.7) % spacing;

    for (
      double x = -spacing + offsetX;
      x < size.width + spacing;
      x += spacing
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (
      double y = -spacing + offsetY;
      y < size.height + spacing;
      y += spacing
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // رسم دوائر متحركة
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final radius = 50.0 + i * 20;
      final centerX =
          size.width * 0.5 +
          100 * math.sin(animationValue * 2 * math.pi + i * math.pi / 3);
      final centerY =
          size.height * 0.5 +
          50 * math.cos(animationValue * 2 * math.pi + i * math.pi / 3);

      canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(GameBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
