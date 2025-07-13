import 'package:flutter/material.dart';
import '../themes/app_theme_new.dart';
import '../models/game_mode_models.dart';
import 'stellar_game_screen_enhanced_real.dart';

class StellarAILevelSelection extends StatefulWidget {
  final GameMode gameMode;

  const StellarAILevelSelection({super.key, this.gameMode = GameMode.ai});

  @override
  State<StellarAILevelSelection> createState() =>
      _StellarAILevelSelectionState();
}

class _StellarAILevelSelectionState extends State<StellarAILevelSelection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DifficultyLevel? _selectedLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectLevel(DifficultyLevel level) {
    setState(() {
      _selectedLevel = level;
    });
  }

  Future<void> _startGame() async {
    if (_selectedLevel == null) return;

    setState(() {
      _isLoading = true;
    });

    // تأخير بسيط للتأثيرات البصرية
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final gameSettings = GameSettings(
      mode: widget.gameMode,
      difficulty: _selectedLevel!,
      opponentType: OpponentType.ai,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => StellarGameScreenEnhanced(
          gameMode: 'ai',
          aiLevel: _selectedLevel != null
              ? DifficultyManager.getLevelStars(_selectedLevel!)
              : 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppThemeNew.backgroundGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildLevelGrid()),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppThemeNew.spaceLG),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppThemeNew.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Text(
                'اختر مستوى الذكاء الاصطناعي',
                style: AppThemeNew.headingMedium,
              ),
              const Spacer(),
              const SizedBox(width: 48), // للتوازن
            ],
          ),
          const SizedBox(height: AppThemeNew.spaceMD),
          Container(
            padding: const EdgeInsets.all(AppThemeNew.spaceMD),
            decoration: AppThemeNew.glassDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.smart_toy,
                  color: AppThemeNew.accentColor,
                  size: AppThemeNew.iconMD,
                ),
                const SizedBox(width: AppThemeNew.spaceSM),
                Text(
                  'اختبر مهاراتك ضد الذكاء الاصطناعي',
                  style: AppThemeNew.bodyMedium.copyWith(
                    color: AppThemeNew.textAccentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppThemeNew.spaceLG),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppThemeNew.spaceMD,
          mainAxisSpacing: AppThemeNew.spaceMD,
          childAspectRatio: 0.8,
        ),
        itemCount: DifficultyLevel.values.length,
        itemBuilder: (context, index) {
          final level = DifficultyLevel.values[index];
          return _buildLevelCard(level);
        },
      ),
    );
  }

  Widget _buildLevelCard(DifficultyLevel level) {
    final isSelected = _selectedLevel == level;
    final levelColor = DifficultyManager.getLevelColor(level);

    return GestureDetector(
      onTap: () => _selectLevel(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    levelColor.withValues(alpha: 0.3),
                    levelColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppThemeNew.cardColor,
          borderRadius: BorderRadius.circular(AppThemeNew.radiusLG),
          border: Border.all(
            color: isSelected
                ? levelColor
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: levelColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [AppThemeNew.createShadow()],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppThemeNew.spaceMD),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة المستوى
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppThemeNew.radiusCircle),
                ),
                child: Icon(
                  Icons.psychology,
                  color: levelColor,
                  size: AppThemeNew.iconLG,
                ),
              ),

              const SizedBox(height: AppThemeNew.spaceMD),

              // اسم المستوى
              Text(
                DifficultyManager.getLevelName(level),
                style: AppThemeNew.headingSmall.copyWith(
                  color: isSelected
                      ? AppThemeNew.textPrimaryColor
                      : AppThemeNew.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppThemeNew.spaceSM),

              // وصف المستوى
              Text(
                DifficultyManager.getLevelDescription(level),
                style: AppThemeNew.bodySmall.copyWith(
                  color: isSelected
                      ? AppThemeNew.textSecondaryColor
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppThemeNew.spaceMD),

              // تقييم بالنجوم
              _buildStarRating(level),

              const SizedBox(height: AppThemeNew.spaceSM),

              // مضاعف النقاط
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppThemeNew.spaceSM,
                  vertical: AppThemeNew.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppThemeNew.radiusSM),
                ),
                child: Text(
                  '×${DifficultyManager.getLevelMultiplier(level).toStringAsFixed(1)}',
                  style: AppThemeNew.bodySmall.copyWith(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarRating(DifficultyLevel level) {
    final stars = DifficultyManager.getLevelStars(level);
    final levelColor = DifficultyManager.getLevelColor(level);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: index < stars
              ? levelColor
              : Colors.grey.withValues(alpha: 0.5),
          size: 16,
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppThemeNew.spaceLG),
      child: Column(
        children: [
          // معلومات إضافية
          if (_selectedLevel != null) ...[
            Container(
              padding: const EdgeInsets.all(AppThemeNew.spaceMD),
              decoration: AppThemeNew.surfaceDecoration,
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppThemeNew.infoColor,
                    size: AppThemeNew.iconMD,
                  ),
                  const SizedBox(width: AppThemeNew.spaceSM),
                  Expanded(
                    child: Text(
                      'ستحصل على ${(DifficultyManager.getLevelMultiplier(_selectedLevel!) * 100).toInt()} نقطة إضافية للفوز في هذا المستوى',
                      style: AppThemeNew.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppThemeNew.spaceMD),
          ],

          // زر البدء
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedLevel != null && !_isLoading
                  ? _startGame
                  : null,
              style: AppThemeNew.primaryButtonStyle.copyWith(
                backgroundColor: WidgetStateProperty.all(
                  _selectedLevel != null
                      ? DifficultyManager.getLevelColor(_selectedLevel!)
                      : Colors.grey,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow),
                        const SizedBox(width: AppThemeNew.spaceSM),
                        Text(
                          _selectedLevel != null
                              ? 'ابدأ اللعب'
                              : 'اختر مستوى أولاً',
                          style: AppThemeNew.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
