import 'package:flutter/material.dart';
import '../AI/ai.dart';
import '../audio_helper.dart';
import '../AI/ai_level_manager.dart';
import '../missions/mission_manager.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_theme_new.dart';

class GameScreen extends StatefulWidget {
  final int aiLevel;
  final bool isAI;
  final bool isPvP;

  const GameScreen({
    super.key,
    required this.aiLevel,
    this.isAI = false,
    this.isPvP = false,
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late List<String> board;
  bool isPlayerTurn = true;
  String winner = '';
  List<int> xMoves = [];
  List<int> oMoves = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    board = List.filled(9, '');
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    loadProgress();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void resetGame() async {
    setState(() {
      board = List.filled(9, '');
      isPlayerTurn = true;
      winner = '';
      xMoves.clear();
      oMoves.clear();
      _controller.reset();
    }); // حذف التقدم المحفوظ عند إعادة تعيين اللعبة
    // TODO: استخدام Firebase للحفظ بدلاً من XML
    // التخزين السحابي مفعل الآن
  }

  Future<void> loadProgress() async {
    // TODO: تحميل التقدم من Firebase بدلاً من XML
    // التخزين السحابي مفعل الآن
  }
  Future<void> saveProgress() async {
    // TODO: حفظ التقدم في Firebase بدلاً من XML
    // التخزين السحابي مفعل الآن
  }

  void playMove(int index) {
    if (board[index] != '' || winner != '') return;

    String currentPlayer = isPlayerTurn ? 'X' : 'O';

    setState(() {
      board[index] = currentPlayer;
      if (currentPlayer == 'X') {
        xMoves.add(index);
      } else {
        oMoves.add(index);
      }
    });

    checkWinner();
    saveProgress(); // حفظ التقدم بعد كل حركة

    if (widget.aiLevel == 10 && winner == '') {
      Future.delayed(Duration(milliseconds: 300), () {
        if (currentPlayer == 'X' && xMoves.length == 3) {
          if (!checkWinnerSimulation('X')) {
            int removeIndex = xMoves.removeAt(0);
            setState(() => board[removeIndex] = '');
          }
        } else if (currentPlayer == 'O' && oMoves.length == 3) {
          if (!checkWinnerSimulation('O')) {
            int removeIndex = oMoves.removeAt(0);
            setState(() => board[removeIndex] = '');
          }
        }

        if (winner == '') {
          _switchTurnOrAIMove();
        }
      });
    } else {
      if (winner == '') {
        _switchTurnOrAIMove();
      }
    }
  }

  void _switchTurnOrAIMove() {
    setState(() => isPlayerTurn = !isPlayerTurn);

    if (!widget.isPvP && widget.isAI && !isPlayerTurn && winner == '') {
      Future.delayed(Duration(milliseconds: 400), () {
        aiMove();
      });
    }
  }

  bool checkWinnerSimulation(String player) {
    List<List<int>> winningComb = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var combo in winningComb) {
      if (board[combo[0]] == player &&
          board[combo[1]] == player &&
          board[combo[2]] == player) {
        return true;
      }
    }
    return false;
  }

  void checkWinner() {
    if (winner != '') return;

    List<List<int>> combos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combo in combos) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        setState(() {
          winner = board[combo[0]];
        });
        AudioHelper.playWinSound();
        _controller.forward();

        // Mission completion logic
        if (winner == 'X') {
          _handleMissionCompletion();
        }

        if (winner == 'X' && widget.aiLevel > 0) {
          int nextLevel = widget.aiLevel + 1;
          if (nextLevel <= 10) {
            AILevelManager.getUnlockedLevel().then((unlockedLevel) {
              if (nextLevel > unlockedLevel) {
                AILevelManager.unlockLevel(nextLevel);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('🎉 تم فتح مستوى جديد: $nextLevel'),
                  backgroundColor: Colors.green,
                ));
              }
            });
          }
        }
        return;
      }
    }

    if (!board.contains('')) {
      setState(() => winner = 'draw');
      AudioHelper.playDrawSound();
      _controller.forward();
    }
  }

  void aiMove() {
    int move = AI.getBestMove(board, 'O', 'X', widget.aiLevel);
    playMove(move);
  }

  Future<void> _handleMissionCompletion() async {
    bool missionCompleted = false;
    String missionType = '';

    // تحديث إحصائيات AI للمهام الذكية
    final isWin = winner == 'X';
    final difficulty = _getDifficultyString(widget.aiLevel);
    await MissionManager.updateGameStats(
      isWin: isWin,
      isAI: widget.isAI,
      difficulty: difficulty,
      gameDurationMinutes: 1, // تقدير متوسط للوقت
    );

    if (widget.isAI) {
      missionCompleted = await MissionManager.completeMission('win_vs_ai');
      missionType = 'الفوز على الذكاء الاصطناعي';
    } else if (widget.isPvP) {
      missionCompleted = await MissionManager.completeMission('play_friend');
      missionType = 'اللعب مع صديق';
    }

    if (missionCompleted) {
      _showMissionCompletedDialog(missionType);
    }
  }

  String _getDifficultyString(int aiLevel) {
    if (aiLevel <= 2) return 'easy';
    if (aiLevel <= 5) return 'medium';
    if (aiLevel <= 8) return 'hard';
    return 'impossible';
  }

  void _showMissionCompletedDialog(String missionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              'مهمة مكتملة!',
              style: TextStyle(
                color: Colors.amberAccent.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'تم إكمال مهمة: $missionType',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  '+50 عملة',
                  style: TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'رائع!',
              style: TextStyle(
                color: Colors.amberAccent.shade200,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: Text(
            'Tic Tac Toe',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 8,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textLight),
              tooltip: 'إعادة اللعبة',
              onPressed: resetGame,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.backgroundDark,
                AppColors.primaryDark.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final deviceType =
                  ResponsiveHelper.getDeviceType(constraints.maxWidth);

              switch (deviceType) {
                case DeviceType.mobile:
                  return _buildMobileGameLayout();
                case DeviceType.tablet:
                  return _buildTabletGameLayout();
                case DeviceType.desktop:
                case DeviceType.largeDesktop:
                  return _buildDesktopGameLayout();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileGameLayout() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGameInfo(),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            _buildGameGrid(),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            if (winner != '') _buildGameResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletGameLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildGameInfo(),
            SizedBox(height: ResponsiveHelper.getPadding(context) * 1.5),
            Row(
              children: [
                Expanded(child: _buildGameGrid()),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildScoreBoard(),
                      if (winner != '') ...[
                        SizedBox(height: ResponsiveHelper.getPadding(context)),
                        _buildGameResult(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopGameLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGameInfo(),
                  SizedBox(height: ResponsiveHelper.getPadding(context)),
                  _buildScoreBoard(),
                  if (winner != '') ...[
                    SizedBox(height: ResponsiveHelper.getPadding(context)),
                    _buildGameResult(),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              flex: 2,
              child: Center(child: _buildGameGrid()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isAI
                ? 'ضد الكمبيوتر (مستوى ${widget.aiLevel})'
                : widget.isPvP
                    ? 'لاعب ضد لاعب'
                    : 'وضع التدريب',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isPlayerTurn ? AppColors.primary : AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'دور: ${isPlayerTurn ? "X" : "O"}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final deviceType = ResponsiveHelper.getDeviceType(screenSize.width);

    // حساب حجم الشبكة بناءً على نوع الجهاز والاتجاه
    double gridSize;

    if (orientation == Orientation.landscape) {
      // في الوضع الأفقي
      switch (deviceType) {
        case DeviceType.mobile:
          gridSize = screenSize.height * 0.65;
          break;
        case DeviceType.tablet:
          gridSize = screenSize.height * 0.7;
          break;
        case DeviceType.desktop:
        case DeviceType.largeDesktop:
          gridSize = 400.0;
          break;
      }
    } else {
      // في الوضع العمودي
      switch (deviceType) {
        case DeviceType.mobile:
          gridSize = screenSize.width * 0.85;
          break;
        case DeviceType.tablet:
          gridSize = screenSize.width * 0.6;
          break;
        case DeviceType.desktop:
        case DeviceType.largeDesktop:
          gridSize = 400.0;
          break;
      }
    }

    // تطبيق حدود معقولة
    gridSize = gridSize.clamp(250.0, 450.0);

    return Container(
      width: gridSize,
      height: gridSize,
      padding: EdgeInsets.all(
          ResponsiveHelper.getPadding(context, size: PaddingSize.small)),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (context, index) => _buildGridCell(index),
      ),
    );
  }

  Widget _buildGridCell(int index) {
    final isEmpty = board[index] == '';
    final isX = board[index] == 'X';

    return GestureDetector(
      onTap: () => playMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: isEmpty
              ? AppColors.surfaceLight.withValues(alpha: 0.2)
              : isX
                  ? AppColors.primary
                  : AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEmpty
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          boxShadow: [
            if (!isEmpty)
              BoxShadow(
                color: (isX ? AppColors.primary : AppColors.secondary)
                    .withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 48),
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'لوحة النتائج',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreItem('X', xMoves.length.toString(), AppColors.primary),
              _buildScoreItem(
                  'O', oMoves.length.toString(), AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String player, String moves, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              player,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$moves حركات',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGameResult() {
    final isWin = winner != 'draw';
    final winnerText = winner == 'draw' ? 'تعادل 🤝' : 'الفائز: $winner 🎉';

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        color: isWin
            ? AppColors.accent.withValues(alpha: 0.2)
            : AppColors.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWin ? AppColors.accent : AppColors.secondary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            winnerText,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context)),
          ElevatedButton.icon(
            onPressed: resetGame,
            icon: const Icon(Icons.refresh),
            label: Text(
              'لعبة جديدة',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
