import 'package:flutter/material.dart';
import '../AI/ai_level_manager.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_helper.dart';
import '../screens/game_screen.dart';

class AILevelSelectionScreen extends StatefulWidget {
  const AILevelSelectionScreen({super.key});

  @override
  _AILevelSelectionScreenState createState() => _AILevelSelectionScreenState();
}

class _AILevelSelectionScreenState extends State<AILevelSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<int> unlockedLevels = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    loadUnlockedLevels();
  }

  Future<void> loadUnlockedLevels() async {
    unlockedLevels = await AILevelManager.getUnlockedLevels();
    setState(() {});
  }

  // تابع عند اختيار مستوى
  void onLevelSelected(int level) async {
    if (unlockedLevels.contains(level)) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(isAI: true, aiLevel: level),
        ),
      );
      // ✅ بعد العودة من GameScreen نعيد تحميل المستويات
      loadUnlockedLevels();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('هذا المستوى مقفل 🔒')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            'اختر مستوى الذكاء الاصطناعي',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 8,
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
          child: ResponsiveWidget(
            mobile: _buildMobileLayout(),
            tablet: _buildTabletLayout(),
            desktop: _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _buildLevelGrid(2);
  }

  Widget _buildTabletLayout() {
    return _buildLevelGrid(3);
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: _buildLevelGrid(4),
      ),
    );
  }

  Widget _buildLevelGrid(int crossAxisCount) {
    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: ResponsiveHelper.getPadding(context) * 0.5,
        mainAxisSpacing: ResponsiveHelper.getPadding(context) * 0.5,
        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        int level = index + 1;
        bool isUnlocked = unlockedLevels.contains(level);

        return ScaleTransition(
          scale: Tween(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(0.1 * index, 1.0, curve: Curves.easeOutBack),
            ),
          ),
          child: _buildLevelCard(level, isUnlocked),
        );
      },
    );
  }

  Widget _buildLevelCard(int level, bool isUnlocked) {
    return GestureDetector(
      onTap: () => onLevelSelected(level),
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    AppColors.surfaceLight.withValues(alpha: 0.3),
                    AppColors.surfaceLight.withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.surfaceLight.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUnlocked ? Icons.smart_toy : Icons.lock,
                    size: ResponsiveHelper.getIconSize(context) * 1.5,
                    color: isUnlocked
                        ? AppColors.textLight
                        : AppColors.textLight.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: ResponsiveHelper.getPadding(context) * 0.25),
                  Text(
                    'المستوى $level',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      color: isUnlocked
                          ? AppColors.textLight
                          : AppColors.textLight.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getPadding(context) * 0.125,
                  ),
                  Text(
                    _getLevelDescription(level),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isUnlocked
                          ? AppColors.textLight.withValues(alpha: 0.9)
                          : AppColors.textLight.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (!isUnlocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.lock,
                    color: Colors.red,
                    size: ResponsiveHelper.getIconSize(context),
                  ),
                ),
              ),
            if (isUnlocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.accent,
                    size: ResponsiveHelper.getIconSize(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'مبتدئ';
      case 2:
        return 'سهل';
      case 3:
        return 'متوسط';
      case 4:
        return 'صعب';
      case 5:
        return 'خبير';
      case 6:
        return 'محترف';
      case 7:
        return 'أسطورة';
      case 8:
        return 'نينجا';
      case 9:
        return 'سيد';
      case 10:
        return 'مستحيل';
      default:
        return 'غير محدد';
    }
  }
}
