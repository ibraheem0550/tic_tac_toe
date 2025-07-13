import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme_new.dart';
import '../AI/ai_engine.dart';

class GameScreenSimple extends StatefulWidget {
  final String gameMode;

  const GameScreenSimple({super.key, required this.gameMode});

  @override
  State<GameScreenSimple> createState() => _GameScreenSimpleState();
}

class _GameScreenSimpleState extends State<GameScreenSimple> {
  List<String> board = List.filled(9, '');
  String currentPlayer = 'X';
  String gameStatus = 'playing';
  String winner = '';
  List<int> winningLine = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.starfieldGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.gameMode == 'ai' ? 'ضد الكمبيوتر' : 'مع صديق',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starGold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: AppColors.textPrimary),
                      onPressed: _resetGame,
                    ),
                  ],
                ),
              ),

              // Current Player
              if (gameStatus == 'playing')
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'دور: $currentPlayer',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Game Board
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    margin: EdgeInsets.all(20),
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
                        itemBuilder: (context, index) => _buildCell(index),
                      ),
                    ),
                  ),
                ),
              ),

              // Game Status
              if (gameStatus == 'ended')
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _getGameResult(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.starGold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'لعب مرة أخرى',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    final isWinningCell = winningLine.contains(index);

    return GestureDetector(
      onTap: () => _makeMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: isWinningCell
              ? AppColors.starGold.withValues(alpha: 0.3)
              : AppColors.surfacePrimary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWinningCell ? AppColors.starGold : AppColors.borderPrimary,
            width: isWinningCell ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            board[index],
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: board[index] == 'X'
                  ? AppColors.primary
                  : AppColors.secondary,
            ),
          ),
        ),
      ),
    );
  }

  void _makeMove(int index) {
    if (board[index].isNotEmpty || gameStatus != 'playing') return;

    HapticFeedback.selectionClick();

    setState(() {
      board[index] = currentPlayer;
    });

    if (_checkWin()) {
      setState(() {
        gameStatus = 'ended';
        winner = currentPlayer;
      });
      return;
    }

    if (board.every((cell) => cell.isNotEmpty)) {
      setState(() {
        gameStatus = 'ended';
        winner = 'draw';
      });
      return;
    }

    setState(() {
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });

    // AI Move
    if (widget.gameMode == 'ai' &&
        currentPlayer == 'O' &&
        gameStatus == 'playing') {
      Future.delayed(Duration(milliseconds: 500), _makeAIMove);
    }
  }

  void _makeAIMove() {
    final aiMove = AIEngine.getBestMove(board, 3);
    if (aiMove != -1) {
      _makeMove(aiMove);
    }
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

  String _getGameResult() {
    if (winner == 'X') {
      return 'فاز X!';
    } else if (winner == 'O') {
      return widget.gameMode == 'ai' ? 'فاز الكمبيوتر!' : 'فاز O!';
    } else {
      return 'تعادل!';
    }
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      currentPlayer = 'X';
      gameStatus = 'playing';
      winner = '';
      winningLine = [];
    });
  }
}
