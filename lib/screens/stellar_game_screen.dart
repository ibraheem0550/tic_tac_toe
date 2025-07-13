import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../AI/ai.dart';
import '../audio_helper.dart';
import '../utils/app_theme_new.dart';

class StellarGameScreen extends StatefulWidget {
  final int aiLevel;
  final bool isAI;
  final bool isPvP;

  const StellarGameScreen({
    super.key,
    required this.aiLevel,
    this.isAI = false,
    this.isPvP = false,
  });

  @override
  State<StellarGameScreen> createState() => _StellarGameScreenState();
}

class _StellarGameScreenState extends State<StellarGameScreen>
    with TickerProviderStateMixin {
  late List<String> board;
  bool isPlayerTurn = true;
  String winner = '';
  List<int> xMoves = [];
  List<int> oMoves = [];

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  final List<AnimationController> _cellAnimations = [];
  bool _gameStarted = false;
  int _playerScore = 0;
  int _aiScore = 0;
  int _drawCount = 0;

  @override
  void initState() {
    super.initState();
    board = List.filled(9, '');
    _setupAnimations();
    loadProgress();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    // إنشاء أنيميشن لكل خلية
    for (int i = 0; i < 9; i++) {
      _cellAnimations.add(
        AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: this,
        ),
      );
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    for (var controller in _cellAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  void resetGame() async {
    setState(() {
      board = List.filled(9, '');
      isPlayerTurn = true;
      winner = '';
      xMoves.clear();
      oMoves.clear();
      _gameStarted = false;
    });

    // إعادة تعيين الأنيميشن
    for (var controller in _cellAnimations) {
      controller.reset();
    }

    await AudioHelper.playClickSound();
    HapticFeedback.lightImpact();
  }

  Future<void> loadProgress() async {
    try {
      // تحميل البيانات المحفوظة (يمكن استبدالها بنظام تخزين آخر)
      setState(() {
        _playerScore = 0;
        _aiScore = 0;
        _drawCount = 0;
      });
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
    }
  }

  Future<void> saveProgress() async {
    try {
      // حفظ البيانات (يمكن استبدالها بنظام تخزين آخر)
      debugPrint(
        'تم حفظ النتائج: اللاعب $_playerScore - الذكاء الاصطناعي $_aiScore - التعادل $_drawCount',
      );
    } catch (e) {
      debugPrint('خطأ في حفظ البيانات: $e');
    }
  }

  void makeMove(int index) async {
    if (board[index] != '' || winner != '') return;

    HapticFeedback.selectionClick();
    await AudioHelper.playClickSound();

    setState(() {
      board[index] = 'X';
      xMoves.add(index);
      isPlayerTurn = false;
      _gameStarted = true;
    });

    // تشغيل أنيميشن الخلية
    _cellAnimations[index].forward();

    await _checkGameStatus();

    if (widget.isAI && winner == '' && !isPlayerTurn) {
      await Future.delayed(const Duration(milliseconds: 800));
      await _makeAIMove();
    }
  }

  Future<void> _makeAIMove() async {
    if (winner != '') return;

    final aiMove = AI.getBestMove(board, 'O', 'X', widget.aiLevel);
    if (aiMove != -1) {
      setState(() {
        board[aiMove] = 'O';
        oMoves.add(aiMove);
        isPlayerTurn = true;
      });

      _cellAnimations[aiMove].forward();
      await AudioHelper.playClickSound();
      HapticFeedback.lightImpact();

      await _checkGameStatus();
    }
  }

  Future<void> _checkGameStatus() async {
    final gameResult = _checkWinner();

    if (gameResult != '') {
      setState(() {
        winner = gameResult;
      });

      // تحديث النتائج
      if (gameResult == 'X') {
        _playerScore++;
        await AudioHelper.playWinSound();
        HapticFeedback.heavyImpact();
      } else if (gameResult == 'O') {
        _aiScore++;
        await AudioHelper.playLoseSound();
        HapticFeedback.mediumImpact();
      } else {
        _drawCount++;
        await AudioHelper.playDrawSound();
        HapticFeedback.lightImpact();
      }

      await saveProgress();

      // إظهار نتيجة اللعبة بعد تأخير قصير
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _showGameResultDialog();
        }
      });
    }
  }

  String _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // صفوف
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // أعمدة
      [0, 4, 8], [2, 4, 6], // أقطار
    ];

    for (var pattern in winPatterns) {
      if (board[pattern[0]] != '' &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return board[pattern[0]];
      }
    }

    if (!board.contains('')) {
      return 'تعادل';
    }

    return '';
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
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildAppBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingLG,
                            ),
                            child: Column(
                              children: [
                                _buildScoreBoard(),
                                const SizedBox(height: AppDimensions.paddingXL),
                                _buildGameBoard(),
                                const SizedBox(height: AppDimensions.paddingXL),
                                _buildGameControls(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLG,
        vertical: AppDimensions.paddingMD,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.nebularGradient,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.stellarGradient,
                boxShadow: AppShadows.card,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppDimensions.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'معركة النجوم',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget.isAI
                      ? 'ضد الذكاء الاصطناعي - المستوى ${widget.aiLevel}'
                      : 'لاعب ضد لاعب',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.stellarGradient,
                    boxShadow: AppShadows.stellar,
                  ),
                  child: const Icon(
                    Icons.stars,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoard() {
    return AppComponents.stellarCard(
      gradient: AppColors.galaxyGradient,
      child: Row(
        children: [
          Expanded(
            child: _buildPlayerScore(
              'أنت',
              'X',
              _playerScore,
              AppColors.primary,
              Icons.person,
            ),
          ),
          Container(
            width: 2,
            height: 60,
            decoration: BoxDecoration(gradient: AppColors.stellarGradient),
          ),
          Expanded(
            child: _buildPlayerScore(
              'التعادل',
              '=',
              _drawCount,
              AppColors.warning,
              Icons.handshake,
            ),
          ),
          Container(
            width: 2,
            height: 60,
            decoration: BoxDecoration(gradient: AppColors.stellarGradient),
          ),
          Expanded(
            child: _buildPlayerScore(
              widget.isAI ? 'الذكاء الاصطناعي' : 'الخصم',
              'O',
              _aiScore,
              AppColors.error,
              widget.isAI ? Icons.smart_toy : Icons.person_outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerScore(
    String label,
    String symbol,
    int score,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppDimensions.paddingSM),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: AppColors.nebularGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.elevated,
        border: Border.all(
          color: AppColors.starGold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (winner == '' && _gameStarted)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isPlayerTurn
                          ? AppColors.cosmicButtonGradient
                          : const LinearGradient(
                              colors: [AppColors.error, AppColors.errorDark],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.card,
                    ),
                    child: Text(
                      isPlayerTurn ? 'دورك' : 'دور الخصم',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          if (winner == '' && _gameStarted)
            const SizedBox(height: AppDimensions.paddingLG),
          AspectRatio(
            aspectRatio: 1.0,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 9,
              itemBuilder: (context, index) => _buildGameCell(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCell(int index) {
    return AnimatedBuilder(
      animation: _cellAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_cellAnimations[index].value * 0.2),
          child: GestureDetector(
            onTap: () => makeMove(index),
            child: Container(
              decoration: BoxDecoration(
                gradient: board[index] == ''
                    ? AppColors.stellarGradient
                    : (board[index] == 'X'
                          ? AppColors.cosmicButtonGradient
                          : const LinearGradient(
                              colors: [AppColors.error, AppColors.errorDark],
                            )),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                boxShadow: AppShadows.card,
                border: Border.all(
                  color: board[index] == ''
                      ? AppColors.borderPrimary
                      : (board[index] == 'X'
                            ? AppColors.primary
                            : AppColors.error),
                  width: 2,
                ),
              ),
              child: Center(
                child: board[index] == ''
                    ? Icon(
                        Icons.add,
                        size: 32,
                        color: AppColors.textPrimary.withValues(alpha: 0.3),
                      )
                    : Text(
                        board[index],
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 48,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameControls() {
    return Column(
      children: [
        if (winner != '')
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: winner == 'X'
                  ? AppColors.cosmicButtonGradient
                  : winner == 'O'
                  ? const LinearGradient(
                      colors: [AppColors.error, AppColors.errorDark],
                    )
                  : const LinearGradient(
                      colors: [AppColors.warning, AppColors.warningDark],
                    ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: AppShadows.elevated,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  winner == 'X'
                      ? Icons.emoji_events
                      : winner == 'O'
                      ? Icons.sentiment_dissatisfied
                      : Icons.handshake,
                  color: AppColors.textPrimary,
                  size: 32,
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                Text(
                  winner == 'X'
                      ? 'فزت! 🎉'
                      : winner == 'O'
                      ? 'خسرت! 😞'
                      : 'تعادل! 🤝',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppDimensions.paddingLG),
        Row(
          children: [
            Expanded(
              child: AppComponents.stellarButton(
                text: 'لعبة جديدة',
                onPressed: resetGame,
                icon: Icons.refresh,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: AppComponents.stellarButton(
                text: 'الرئيسية',
                onPressed: () => Navigator.pop(context),
                icon: Icons.home,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showGameResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.starfieldGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
            boxShadow: AppShadows.modal,
            border: Border.all(color: AppColors.borderPrimary, width: 1),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: winner == 'X'
                      ? AppColors.cosmicButtonGradient
                      : winner == 'O'
                      ? const LinearGradient(
                          colors: [AppColors.error, AppColors.errorDark],
                        )
                      : const LinearGradient(
                          colors: [AppColors.warning, AppColors.warningDark],
                        ),
                  boxShadow: AppShadows.stellar,
                ),
                child: Icon(
                  winner == 'X'
                      ? Icons.emoji_events
                      : winner == 'O'
                      ? Icons.sentiment_dissatisfied
                      : Icons.handshake,
                  size: 40,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                winner == 'X'
                    ? 'مبروك! لقد فزت!'
                    : winner == 'O'
                    ? 'للأسف! لقد خسرت!'
                    : 'تعادل!',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingMD),
              Text(
                winner == 'X'
                    ? 'أداء رائع! استمر في التقدم!'
                    : winner == 'O'
                    ? 'لا تستسلم! جرب مرة أخرى!'
                    : 'لعبة جيدة! كان أداؤكما متساوياً!',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Row(
                children: [
                  Expanded(
                    child: AppComponents.stellarButton(
                      text: 'لعبة جديدة',
                      onPressed: () {
                        Navigator.pop(context);
                        resetGame();
                      },
                      icon: Icons.refresh,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMD),
                  Expanded(
                    child: AppComponents.stellarButton(
                      text: 'الرئيسية',
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: Icons.home,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
