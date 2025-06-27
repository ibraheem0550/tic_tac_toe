import 'dart:math';

class AI {
  /// دالة لاختيار أفضل حركة بناءً على المستوى
  static int getBestMove(
      List<String> board, String aiPlayer, String humanPlayer, int level) {
    if (level == 1) {
      return getRandomMove(board);
    } else {
      return minimax(board, aiPlayer, humanPlayer, aiPlayer).index;
    }
  }

  /// دالة لاختيار خطوة عشوائية
  static int getRandomMove(List<String> board) {
    List<int> emptyIndices = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        emptyIndices.add(i);
      }
    }
    return emptyIndices[Random().nextInt(emptyIndices.length)];
  }

  /// خوارزمية Minimax
  static Move minimax(List<String> board, String aiPlayer, String humanPlayer,
      String currentPlayer) {
    List<List<int>> winningCombination = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    String winner = checkWinner(board, winningCombination);

    if (winner == aiPlayer) return Move(score: 10);
    if (winner == humanPlayer) return Move(score: -10);
    if (!board.contains('')) return Move(score: 0);

    List<Move> moves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        board[i] = currentPlayer;
        Move move = minimax(
          board,
          aiPlayer,
          humanPlayer,
          currentPlayer == aiPlayer ? humanPlayer : aiPlayer,
        );
        moves.add(Move(index: i, score: move.score));
        board[i] = '';
      }
    }

    if (currentPlayer == aiPlayer) {
      return moves.reduce((a, b) => a.score > b.score ? a : b);
    } else {
      return moves.reduce((a, b) => a.score < b.score ? a : b);
    }
  }

  /// التحقق من الفائز
  static String checkWinner(
      List<String> board, List<List<int>> winningCombination) {
    for (var combo in winningCombination) {
      if (board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]] &&
          board[combo[0]] != '') {
        return board[combo[0]];
      }
    }
    return '';
  }
}

/// هيكل لتخزين البيانات الخاصة بكل خطوة
class Move {
  final int index;
  final int score;

  Move({this.index = -1, required this.score});
}
