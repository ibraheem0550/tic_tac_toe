import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme_new.dart';

class ResponsiveGameScreen extends StatefulWidget {
  const ResponsiveGameScreen({super.key});

  @override
  State<ResponsiveGameScreen> createState() => _ResponsiveGameScreenState();
}

class _ResponsiveGameScreenState extends State<ResponsiveGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  List<String> board = List.filled(9, '');
  bool isXTurn = true;
  String winner = '';
  bool _gameEnded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper functions للتجاوب
  double _getScreenWidth() => MediaQuery.of(context).size.width;
  double _getScreenHeight() => MediaQuery.of(context).size.height;
  bool _isSmallScreen() => _getScreenWidth() < 600;
  bool _isLandscape() => _getScreenWidth() > _getScreenHeight();

  double _getBoardSize() {
    final screenWidth = _getScreenWidth();
    final screenHeight = _getScreenHeight();
    final availableSpace = _isLandscape()
        ? screenHeight * 0.7
        : screenWidth * 0.8;

    // تأكد من أن الحجم مناسب ولا يتجاوز الشاشة
    return availableSpace.clamp(200.0, 400.0);
  }

  double _getCellSize() {
    return _getBoardSize() / 3;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.starfieldGradient,
          ),
          child: SafeArea(
            child: _isLandscape()
                ? _buildLandscapeLayout()
                : _buildPortraitLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_isSmallScreen() ? 16 : 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGameInfo(),
                const SizedBox(height: 32),
                _buildGameBoard(),
                const SizedBox(height: 32),
                _buildGameActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGameInfo(),
                      const SizedBox(height: 24),
                      _buildGameActions(),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 2, child: Center(child: _buildGameBoard())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isSmallScreen() ? 16 : 24,
        vertical: 12,
      ),
      decoration: const BoxDecoration(gradient: AppColors.nebularGradient),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSecondary.withValues(alpha: 0.3),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'X O الكوني',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: _isSmallScreen() ? 20 : 24,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Text(
              _gameEnded ? 'انتهت' : 'جارية',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: EdgeInsets.all(_isSmallScreen() ? 16 : 20),
      decoration: BoxDecoration(
        gradient: AppColors.stellarGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          Text(
            _getGameStatusText(),
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: _isSmallScreen() ? 18 : 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlayerInfo('X', isXTurn && !_gameEnded),
              Container(
                width: 2,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.dividerPrimary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildPlayerInfo('O', !isXTurn && !_gameEnded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String player, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primary
                : AppColors.surfaceSecondary.withValues(alpha: 0.5),
            border: Border.all(
              color: isActive ? AppColors.accent : AppColors.borderPrimary,
              width: 2,
            ),
          ),
          child: Text(
            player,
            style: AppTextStyles.headlineMedium.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
              fontWeight: FontWeight.bold,
              fontSize: _isSmallScreen() ? 20 : 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isActive ? 'دورك' : 'ينتظر',
          style: AppTextStyles.labelMedium.copyWith(
            color: isActive ? AppColors.primary : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    final boardSize = _getBoardSize();
    final cellSize = _getCellSize();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              gradient: AppColors.cosmicGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.stellar,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return _buildGameCell(index, cellSize);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameCell(int index, double cellSize) {
    final isWinningCell = _isWinningCell(index);

    return GestureDetector(
      onTap: () => _makeMove(index),
      child: Container(
        decoration: BoxDecoration(
          color: isWinningCell
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isWinningCell ? AppColors.success : AppColors.borderPrimary,
            width: isWinningCell ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            board[index],
            style: AppTextStyles.displayLarge.copyWith(
              color: board[index] == 'X' ? AppColors.primary : AppColors.accent,
              fontWeight: FontWeight.bold,
              fontSize: (cellSize * 0.6).clamp(20.0, 60.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: Text(
              'إعادة',
              style: TextStyle(fontSize: _isSmallScreen() ? 14 : 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: AppColors.textPrimary,
              padding: EdgeInsets.symmetric(
                vertical: _isSmallScreen() ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home),
            label: Text(
              'الرئيسية',
              style: TextStyle(fontSize: _isSmallScreen() ? 14 : 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              padding: EdgeInsets.symmetric(
                vertical: _isSmallScreen() ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getGameStatusText() {
    if (winner.isEmpty) {
      return 'دور اللاعب ${isXTurn ? 'X' : 'O'}';
    } else if (winner == 'Tie') {
      return '🤝 تعادل!';
    } else {
      return '🎉 الفائز: $winner';
    }
  }

  bool _isWinningCell(int index) {
    if (winner.isEmpty || winner == 'Tie') return false;

    // فحص الصفوف
    for (int i = 0; i < 9; i += 3) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2] &&
          board[i] == winner) {
        return index >= i && index <= i + 2;
      }
    }

    // فحص الأعمدة
    for (int i = 0; i < 3; i++) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6] &&
          board[i] == winner) {
        return index == i || index == i + 3 || index == i + 6;
      }
    }

    // فحص القطر الأول
    if (board[0].isNotEmpty &&
        board[0] == board[4] &&
        board[0] == board[8] &&
        board[0] == winner) {
      return index == 0 || index == 4 || index == 8;
    }

    // فحص القطر الثاني
    if (board[2].isNotEmpty &&
        board[2] == board[4] &&
        board[2] == board[6] &&
        board[2] == winner) {
      return index == 2 || index == 4 || index == 6;
    }

    return false;
  }

  void _makeMove(int index) {
    if (board[index].isEmpty && winner.isEmpty) {
      HapticFeedback.lightImpact();

      setState(() {
        board[index] = isXTurn ? 'X' : 'O';
        isXTurn = !isXTurn;
        winner = _checkWinner();
        _gameEnded = winner.isNotEmpty;
      });

      // تأثير انتصار
      if (_gameEnded) {
        HapticFeedback.heavyImpact();
        _animationController.reverse().then((_) {
          _animationController.forward();
        });
      }
    }
  }

  String _checkWinner() {
    // فحص الصفوف
    for (int i = 0; i < 9; i += 3) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2]) {
        return board[i];
      }
    }

    // فحص الأعمدة
    for (int i = 0; i < 3; i++) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        return board[i];
      }
    }

    // فحص الأقطار
    if (board[0].isNotEmpty && board[0] == board[4] && board[0] == board[8]) {
      return board[0];
    }
    if (board[2].isNotEmpty && board[2] == board[4] && board[2] == board[6]) {
      return board[2];
    }

    // فحص التعادل
    if (!board.contains('')) {
      return 'Tie';
    }

    return '';
  }

  void _resetGame() {
    HapticFeedback.selectionClick();

    setState(() {
      board = List.filled(9, '');
      isXTurn = true;
      winner = '';
      _gameEnded = false;
    });

    _animationController.reset();
    _animationController.forward();
  }
}
