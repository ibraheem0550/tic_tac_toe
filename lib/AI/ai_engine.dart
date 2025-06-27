import 'dart:math';

/// نظام الذكاء الاصطناعي المحدث للعبة تيك تاك تو
class AIEngine {
  /// الحصول على أفضل خطوة حسب مستوى الصعوبة
  static int getBestMove(List<String> board, int difficulty) {
    switch (difficulty) {
      case 1:
        return _getRandomMove(board);
      case 2:
        return _getEasyMove(board);
      case 3:
        return _getMediumMove(board);
      case 4:
        return _getHardMove(board);
      case 5:
        return _getExpertMove(board);
      default:
        return _getMediumMove(board);
    }
  }

  /// حركة عشوائية (مستوى 1)
  static int _getRandomMove(List<String> board) {
    List<int> availableMoves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        availableMoves.add(i);
      }
    }
    if (availableMoves.isEmpty) return -1;
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  /// حركة سهلة (مستوى 2) - عشوائية مع بعض الدفاع
  static int _getEasyMove(List<String> board) {
    // 30% فرصة للدفاع، 70% عشوائية
    if (Random().nextInt(100) < 30) {
      int blockMove = _findBlockingMove(board);
      if (blockMove != -1) return blockMove;
    }
    return _getRandomMove(board);
  }

  /// حركة متوسطة (مستوى 3) - دفاع وهجوم بسيط
  static int _getMediumMove(List<String> board) {
    // الفوز أولاً إن أمكن
    int winMove = _findWinningMove(board, 'O');
    if (winMove != -1) return winMove;

    // منع الخصم من الفوز
    int blockMove = _findBlockingMove(board);
    if (blockMove != -1) return blockMove;

    // اختيار المركز إن كان فارغاً
    if (board[4].isEmpty) return 4;

    // اختيار الزوايا
    List<int> corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (board[corner].isEmpty) return corner;
    }

    return _getRandomMove(board);
  }

  /// حركة صعبة (مستوى 4) - استراتيجية متقدمة
  static int _getHardMove(List<String> board) {
    // الفوز أولاً
    int winMove = _findWinningMove(board, 'O');
    if (winMove != -1) return winMove;

    // منع الفوز
    int blockMove = _findBlockingMove(board);
    if (blockMove != -1) return blockMove;

    // إنشاء تهديدات متعددة
    int forkMove = _findForkMove(board, 'O');
    if (forkMove != -1) return forkMove;

    // منع التهديدات المتعددة للخصم
    int blockForkMove = _findBlockForkMove(board);
    if (blockForkMove != -1) return blockForkMove;

    // المركز
    if (board[4].isEmpty) return 4;

    // الزاوية المقابلة للخصم
    if (board[0] == 'X' && board[8].isEmpty) return 8;
    if (board[2] == 'X' && board[6].isEmpty) return 6;
    if (board[6] == 'X' && board[2].isEmpty) return 2;
    if (board[8] == 'X' && board[0].isEmpty) return 0;

    // أي زاوية فارغة
    List<int> corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (board[corner].isEmpty) return corner;
    }

    return _getRandomMove(board);
  }

  /// حركة خبير (مستوى 5) - minimax كامل
  static int _getExpertMove(List<String> board) {
    return _minimax(board, 'O', true).position;
  }

  /// العثور على حركة الفوز
  static int _findWinningMove(List<String> board, String player) {
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        board[i] = player;
        if (_checkWin(board, player)) {
          board[i] = ''; // التراجع
          return i;
        }
        board[i] = ''; // التراجع
      }
    }
    return -1;
  }

  /// العثور على حركة الحظر
  static int _findBlockingMove(List<String> board) {
    return _findWinningMove(board, 'X');
  }

  /// العثور على حركة Fork (إنشاء تهديدين)
  static int _findForkMove(List<String> board, String player) {
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        board[i] = player;
        int threats = 0;

        // عد التهديدات المحتملة
        for (int j = 0; j < board.length; j++) {
          if (board[j].isEmpty) {
            board[j] = player;
            if (_checkWin(board, player)) {
              threats++;
            }
            board[j] = '';
          }
        }

        board[i] = '';
        if (threats >= 2) return i;
      }
    }
    return -1;
  }

  /// منع Fork للخصم
  static int _findBlockForkMove(List<String> board) {
    int forkMove = _findForkMove(board, 'X');
    if (forkMove != -1) return forkMove;
    return -1;
  }

  /// فحص الفوز
  static bool _checkWin(List<String> board, String player) {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // صفوف
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // أعمدة
      [0, 4, 8], [2, 4, 6], // قطران
    ];

    for (List<int> pattern in winPatterns) {
      if (board[pattern[0]] == player &&
          board[pattern[1]] == player &&
          board[pattern[2]] == player) {
        return true;
      }
    }
    return false;
  }

  /// خوارزمية Minimax للمستوى الخبير
  static MoveResult _minimax(
      List<String> board, String player, bool isMaximizing) {
    String winner = _getWinner(board);

    if (winner == 'O') return MoveResult(score: 1, position: -1);
    if (winner == 'X') return MoveResult(score: -1, position: -1);
    if (!board.contains('')) return MoveResult(score: 0, position: -1);

    int bestScore = isMaximizing ? -1000 : 1000;
    int bestMove = -1;

    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        board[i] = player;

        MoveResult result =
            _minimax(board, player == 'O' ? 'X' : 'O', !isMaximizing);

        board[i] = '';

        if (isMaximizing && result.score > bestScore) {
          bestScore = result.score;
          bestMove = i;
        } else if (!isMaximizing && result.score < bestScore) {
          bestScore = result.score;
          bestMove = i;
        }
      }
    }

    return MoveResult(score: bestScore, position: bestMove);
  }

  /// الحصول على الفائز
  static String _getWinner(List<String> board) {
    if (_checkWin(board, 'O')) return 'O';
    if (_checkWin(board, 'X')) return 'X';
    return '';
  }

  /// الحصول على اسم مستوى الصعوبة
  static String getDifficultyName(int level) {
    switch (level) {
      case 1:
        return 'مبتدئ النجوم';
      case 2:
        return 'حارس المجرة';
      case 3:
        return 'ملك الكواكب';
      case 4:
        return 'سيد الأكوان';
      case 5:
        return 'إمبراطور النجوم';
      default:
        return 'ذكي نجمي';
    }
  }

  /// الحصول على وصف المستوى
  static String getDifficultyDescription(int level) {
    switch (level) {
      case 1:
        return 'مثالي للمبتدئين\nسهل الفوز';
      case 2:
        return 'تحدي بسيط\nحركات عشوائية مع دفاع خفيف';
      case 3:
        return 'تحدي متوازن\nيتطلب تفكير واستراتيجية';
      case 4:
        return 'للخبراء فقط\nذكاء متقدم وتخطيط';
      case 5:
        return 'مستحيل تقريباً\nذكاء خارق ومثالي';
      default:
        return 'تحدي نجمي';
    }
  }
}

/// نتيجة حركة المحرك
class MoveResult {
  final int score;
  final int position;

  MoveResult({required this.score, required this.position});
}

/// فئة الذكاء الاصطناعي القديمة للتوافق مع الكود القديم
class AI {
  static int getBestMove(
      List<String> board, String aiPlayer, String humanPlayer, int level) {
    return AIEngine.getBestMove(board, level);
  }
}
