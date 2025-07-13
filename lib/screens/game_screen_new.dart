import 'package:flutter/material.dart';
import '../AI/ai.dart';
import '../audio_helper.dart';
import '../missions/mission_manager.dart';
import '../store/coins_notifier.dart';
import '../store/store_manager.dart';

/// شاشة اللعبة المحسنة مع تأثيرات بصرية وصوتية متقدمة
class GameScreenNew extends StatefulWidget {
  final int aiLevel;
  final bool isAI;
  final bool isPvP;

  const GameScreenNew({
    super.key,
    required this.aiLevel,
    required this.isAI,
    required this.isPvP,
  });

  @override
  State<GameScreenNew> createState() => _GameScreenNewState();
}

class _GameScreenNewState extends State<GameScreenNew>
    with TickerProviderStateMixin {
  List<String> _board = List.filled(9, '');
  bool _isXTurn = true;
  String _winner = '';
  bool _gameOver = false;

  // الأنيميشن
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _backgroundController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _setupAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _backgroundAnimation = ColorTween(
      begin: Colors.grey.shade900,
      end: Colors.deepPurple.shade900,
    ).animate(_backgroundController);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _makeMove(int index) {
    if (_board[index] != '' || _gameOver) return;

    setState(() {
      _board[index] = _isXTurn ? 'X' : 'O';
    });

    // تشغيل صوت النقر
    AudioHelper.playClickSound();

    // تأثير بصري
    _animateMove();

    _checkWinner();

    if (!_gameOver) {
      setState(() {
        _isXTurn = !_isXTurn;
      });

      // حركة الذكاء الاصطناعي
      if (widget.isAI && !_isXTurn && !_gameOver) {
        _makeAIMove();
      }
    }
  }

  void _animateMove() {
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
  }

  void _makeAIMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_gameOver) return;
      final aiMove = AI.getBestMove(_board, 'O', 'X', widget.aiLevel);
      if (aiMove != -1) {
        setState(() {
          _board[aiMove] = 'O';
        });

        AudioHelper.playClickSound();
        _animateMove();
        _checkWinner();

        if (!_gameOver) {
          setState(() {
            _isXTurn = true;
          });
        }
      }
    });
  }

  void _checkWinner() {
    const winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // صفوف
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // أعمدة
      [0, 4, 8], [2, 4, 6], // أقطار
    ];

    for (final combination in winningCombinations) {
      final a = combination[0];
      final b = combination[1];
      final c = combination[2];

      if (_board[a] != '' && _board[a] == _board[b] && _board[b] == _board[c]) {
        setState(() {
          _winner = _board[a];
          _gameOver = true;
        });

        _handleGameEnd();
        return;
      }
    }

    // التحقق من التعادل
    if (!_board.contains('')) {
      setState(() {
        _winner = 'تعادل';
        _gameOver = true;
      });

      _handleGameEnd();
    }
  }

  void _handleGameEnd() {
    // تشغيل الصوت المناسب
    if (_winner == 'X') {
      AudioHelper.playWinSound();
    } else if (_winner == 'O') {
      AudioHelper.playLoseSound();
    } else {
      AudioHelper.playDrawSound();
    }

    // تأثير بصري للخلفية
    _backgroundController.forward();

    // تحديث المهام والعملات
    _updateMissionsAndCoins();

    // إظهار حوار النتيجة
    _showGameEndDialog();
  }

  void _updateMissionsAndCoins() async {
    if (_winner == 'X') {
      // المهمة: الفوز في اللعبة
      await MissionManager.completeMission('win_games');

      // إضافة عملات للفوز
      await StoreManager.addCoins(10);
      coinsChangeNotifier.notifyCoinsChanged();
    }

    // المهمة: لعب عدد من الألعاب
    await MissionManager.completeMission('play_friend');
  }

  void _showGameEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          _getGameEndTitle(),
          style: TextStyle(
            color: _getGameEndColor(),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getGameEndIcon(),
              size: 64,
              color: _getGameEndColor(),
            ),
            const SizedBox(height: 16),
            Text(
              _getGameEndMessage(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'العودة للقائمة',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('لعب مرة أخرى'),
          ),
        ],
      ),
    );
  }

  String _getGameEndTitle() {
    if (_winner == 'X') {
      return '🎉 مبروك! فزت! 🎉';
    } else if (_winner == 'O') {
      return '😔 للأسف، خسرت';
    } else {
      return '🤝 تعادل!';
    }
  }

  String _getGameEndMessage() {
    if (_winner == 'X') {
      return 'أحسنت! حصلت على 10 عملات ذهبية';
    } else if (_winner == 'O') {
      return 'لا تيأس، حاول مرة أخرى';
    } else {
      return 'لعبة رائعة! كلاكما لعب بشكل ممتاز';
    }
  }

  IconData _getGameEndIcon() {
    if (_winner == 'X') {
      return Icons.emoji_events;
    } else if (_winner == 'O') {
      return Icons.sentiment_dissatisfied;
    } else {
      return Icons.handshake;
    }
  }

  Color _getGameEndColor() {
    if (_winner == 'X') {
      return Colors.amber;
    } else if (_winner == 'O') {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  void _resetGame() {
    setState(() {
      _board = List.filled(9, '');
      _isXTurn = true;
      _winner = '';
      _gameOver = false;
    });

    _backgroundController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) => Scaffold(
        backgroundColor: _backgroundAnimation.value,
        appBar: AppBar(
          title: Text(
            widget.isPvP ? 'لاعب ضد لاعب' : 'ضد الذكاء الاصطناعي',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurple.shade700,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _resetGame,
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة تشغيل',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildGameStatus(),
            Expanded(child: _buildGameBoard()),
            _buildControlsPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade700,
            Colors.deepPurple.shade500,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _gameOver ? 'انتهت اللعبة' : 'دور ${_isXTurn ? 'X' : 'O'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_gameOver)
            Text(
              'النتيجة: $_winner',
              style: TextStyle(
                color: _getGameEndColor(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) => Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) => _buildGameCell(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameCell(int index) {
    return GestureDetector(
      onTap: () => _makeMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: Colors.deepPurple.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _board[index],
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _board[index] == 'X'
                  ? Colors.blue.shade700
                  : Colors.red.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة تشغيل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home),
            label: const Text('الرئيسية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
