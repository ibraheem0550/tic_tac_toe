import 'package:flutter/material.dart';
import '../missions/mission_manager.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_theme_new.dart';
import 'dart:async';

class SmartMissionsScreen extends StatefulWidget {
  const SmartMissionsScreen({super.key});

  @override
  State<SmartMissionsScreen> createState() => _SmartMissionsScreenState();
}

class _SmartMissionsScreenState extends State<SmartMissionsScreen>
    with TickerProviderStateMixin {
  List<Mission> _allMissions = [];
  List<String> _aiRecommendations = [];
  bool _isLoading = true;
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAllData();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final missions = await MissionManager.getAllMissions();
      final recommendations = await MissionManager.getAIRecommendations();

      setState(() {
        _allMissions = missions;
        _aiRecommendations = recommendations;
        _isLoading = false;
      });

      _controller.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = ResponsiveHelper.getDeviceType(screenSize.width);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
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
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    if (_isLoading) _buildLoadingSliver(),
                    if (!_isLoading) ...[
                      _buildAIStatusSection(),
                      _buildRecommendationsSection(),
                      _buildMissionsSection(),
                      _buildAIControlsSection(),
                      // إضافة مساحة أسفل للشاشات الصغيرة
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: ResponsiveHelper.getPadding(
                            context,
                            size: deviceType == DeviceType.mobile
                                ? PaddingSize.large
                                : PaddingSize.medium,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accent, strokeWidth: 3),
            const SizedBox(height: 20),
            Text(
              'جاري تحميل المهام الذكية...',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textLight.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveHelper.getDeviceType(screenWidth);
    final isMobile = deviceType == DeviceType.mobile;

    return SliverAppBar(
      expandedHeight: isMobile ? 100 : 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.psychology,
                    color: AppColors.textLight,
                    size: ResponsiveHelper.getIconSize(
                      context,
                      size: isMobile ? IconSize.medium : IconSize.large,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: ResponsiveHelper.getPadding(context) * 0.25),
            Flexible(
              child: Text(
                'المهام الذكية',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIStatusSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveHelper.getDeviceType(screenWidth);
    final isMobile = deviceType == DeviceType.mobile;

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.all(
            ResponsiveHelper.getPadding(
              context,
              size: isMobile ? PaddingSize.medium : PaddingSize.large,
            ),
          ),
          padding: EdgeInsets.all(
            ResponsiveHelper.getPadding(
              context,
              size: isMobile ? PaddingSize.medium : PaddingSize.large,
            ),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.1),
                AppColors.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(isMobile ? 8 : 12),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.smart_toy,
                            color: AppColors.accent,
                            size: ResponsiveHelper.getIconSize(
                              context,
                              size: isMobile ? IconSize.medium : IconSize.large,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: ResponsiveHelper.getPadding(context) * 0.5),
                  Expanded(
                    child: Text(
                      'نظام الذكاء الاصطناعي نشط',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ResponsiveHelper.getPadding(context) * 0.5),
              Text(
                'يقوم الذكاء الاصطناعي بتحليل أدائك وتوليد مهام مخصصة لك كل 6 ساعات',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight.withValues(alpha: 0.9),
                  fontSize: isMobile ? 13 : 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    if (_aiRecommendations.isEmpty) return const SliverToBoxAdapter();

    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveHelper.getDeviceType(screenWidth);
    final orientation = MediaQuery.of(context).orientation;
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getPadding(
              context,
              size: isMobile ? PaddingSize.medium : PaddingSize.large,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                  ResponsiveHelper.getPadding(
                    context,
                    size: isMobile ? PaddingSize.medium : PaddingSize.large,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: AppColors.accent,
                      size: ResponsiveHelper.getIconSize(
                        context,
                        size: isMobile ? IconSize.medium : IconSize.large,
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getPadding(context) * 0.25,
                    ),
                    Flexible(
                      child: Text(
                        'توصيات ذكية لك',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                          fontSize: isMobile ? 16 : (isTablet ? 18 : 20),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMobile || (isTablet && orientation == Orientation.portrait))
                // شريط أفقي قابل للسحب للشاشات الصغيرة والمتوسطة العمودية
                SizedBox(
                  height: isMobile ? 130 : 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getPadding(context),
                    ),
                    itemCount: _aiRecommendations.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: isMobile
                            ? screenWidth * 0.85
                            : screenWidth * 0.75,
                        margin: EdgeInsets.only(
                          right: ResponsiveHelper.getPadding(context) * 0.5,
                        ),
                        padding: EdgeInsets.all(
                          ResponsiveHelper.getPadding(
                            context,
                            size: isMobile
                                ? PaddingSize.medium
                                : PaddingSize.large,
                          ),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.surfaceLight.withValues(alpha: 0.15),
                              AppColors.surfaceLight.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.tips_and_updates,
                                    color: AppColors.accent,
                                    size: ResponsiveHelper.getIconSize(
                                      context,
                                      size: isMobile
                                          ? IconSize.small
                                          : IconSize.medium,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      ResponsiveHelper.getPadding(context) *
                                      0.5,
                                ),
                                Expanded(
                                  child: Text(
                                    'توصية ${index + 1}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 12 : 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height:
                                  ResponsiveHelper.getPadding(context) * 0.5,
                            ),
                            Expanded(
                              child: Text(
                                _aiRecommendations[index],
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textLight.withValues(
                                    alpha: 0.9,
                                  ),
                                  height: 1.4,
                                  fontSize: isMobile ? 13 : 14,
                                ),
                                maxLines: isMobile ? 2 : 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                // عرض شبكي للشاشات الكبيرة والتابلت الأفقي
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getPadding(context),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.getColumnsCount(
                      context,
                      maxColumns: deviceType == DeviceType.largeDesktop ? 4 : 3,
                      minColumns: isTablet ? 2 : 2,
                    ),
                    crossAxisSpacing: ResponsiveHelper.getPadding(context),
                    mainAxisSpacing: ResponsiveHelper.getPadding(context),
                    childAspectRatio: deviceType == DeviceType.largeDesktop
                        ? 1.8
                        : 1.5,
                  ),
                  itemCount: _aiRecommendations.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(
                        ResponsiveHelper.getPadding(
                          context,
                          size: deviceType == DeviceType.largeDesktop
                              ? PaddingSize.large
                              : PaddingSize.medium,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceLight.withValues(alpha: 0.15),
                            AppColors.surfaceLight.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.tips_and_updates,
                                color: AppColors.accent,
                                size: ResponsiveHelper.getIconSize(
                                  context,
                                  size: deviceType == DeviceType.largeDesktop
                                      ? IconSize.large
                                      : IconSize.medium,
                                ),
                              ),
                              SizedBox(
                                width:
                                    ResponsiveHelper.getPadding(context) * 0.5,
                              ),
                              Expanded(
                                child: Text(
                                  'توصية ${index + 1}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        deviceType == DeviceType.largeDesktop
                                        ? 14
                                        : 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ResponsiveHelper.getPadding(context) * 0.25,
                          ),
                          Expanded(
                            child: Text(
                              _aiRecommendations[index],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textLight.withValues(
                                  alpha: 0.9,
                                ),
                                height: 1.4,
                                fontSize: deviceType == DeviceType.largeDesktop
                                    ? 15
                                    : 14,
                              ),
                              maxLines: deviceType == DeviceType.largeDesktop
                                  ? 5
                                  : 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionsSection() {
    final dailyMissions = _allMissions
        .where((m) => m.id.startsWith('win_') || m.id.startsWith('play_'))
        .toList();
    final aiMissions = _allMissions
        .where((m) => m.id.startsWith('ai_'))
        .toList();

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            if (dailyMissions.isNotEmpty) ...[
              _buildMissionGroup('المهام اليومية', dailyMissions, Icons.today),
              const SizedBox(height: 16),
            ],
            if (aiMissions.isNotEmpty) ...[
              _buildMissionGroup('المهام الذكية', aiMissions, Icons.psychology),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMissionGroup(
    String title,
    List<Mission> missions,
    IconData icon,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveHelper.getDeviceType(screenWidth);
    final isMobile = deviceType == DeviceType.mobile;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getPadding(
          context,
          size: isMobile ? PaddingSize.medium : PaddingSize.large,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(
              ResponsiveHelper.getPadding(
                context,
                size: isMobile ? PaddingSize.medium : PaddingSize.large,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: ResponsiveHelper.getIconSize(
                    context,
                    size: isMobile ? IconSize.medium : IconSize.large,
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getPadding(context) * 0.25),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                      fontSize: isMobile ? 16 : 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...missions.map((mission) => _buildMissionCard(mission)).toList(),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final isCompleted = mission.isCompleted;
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveHelper.getDeviceType(screenWidth);
    final isMobile = deviceType == DeviceType.mobile;

    return GestureDetector(
      onTap: isCompleted ? null : () => _attemptMissionCompletion(mission),
      child: Container(
        margin: EdgeInsets.only(
          bottom:
              ResponsiveHelper.getPadding(
                context,
                size: isMobile ? PaddingSize.medium : PaddingSize.large,
              ) *
              0.5,
          left: ResponsiveHelper.getPadding(
            context,
            size: isMobile ? PaddingSize.medium : PaddingSize.large,
          ),
          right: ResponsiveHelper.getPadding(
            context,
            size: isMobile ? PaddingSize.medium : PaddingSize.large,
          ),
        ),
        child: Material(
          elevation: isCompleted ? 2 : 4,
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(
              ResponsiveHelper.getPadding(
                context,
                size: isMobile ? PaddingSize.medium : PaddingSize.large,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              gradient: isCompleted
                  ? LinearGradient(
                      colors: [AppColors.accent, AppColors.secondary],
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.surfaceLight.withValues(alpha: 0.1),
                        AppColors.surfaceLight.withValues(alpha: 0.05),
                      ],
                    ),
              border: Border.all(
                color: isCompleted
                    ? AppColors.accent.withValues(alpha: 0.5)
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.textLight.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    mission.icon,
                    color: isCompleted
                        ? AppColors.textLight
                        : AppColors.primary,
                    size: ResponsiveHelper.getIconSize(
                      context,
                      size: isMobile ? IconSize.medium : IconSize.large,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getPadding(
                    context,
                    size: isMobile ? PaddingSize.medium : PaddingSize.large,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? AppColors.textLight
                              : AppColors.textLight,
                          fontSize: isMobile ? 16 : 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height:
                            ResponsiveHelper.getPadding(
                              context,
                              size: isMobile
                                  ? PaddingSize.small
                                  : PaddingSize.medium,
                            ) *
                            0.25,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: isMobile ? 14 : 16,
                            color: isCompleted
                                ? AppColors.textLight.withValues(alpha: 0.7)
                                : AppColors.accent,
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getPadding(context) * 0.25,
                          ),
                          Flexible(
                            child: Text(
                              '${mission.coinsReward} نقطة',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isCompleted
                                    ? AppColors.textLight.withValues(alpha: 0.7)
                                    : AppColors.accent,
                                fontWeight: FontWeight.w500,
                                fontSize: isMobile ? 13 : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: EdgeInsets.all(isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.textLight,
                        size: ResponsiveHelper.getIconSize(
                          context,
                          size: isMobile ? IconSize.small : IconSize.medium,
                        ),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    size: ResponsiveHelper.getIconSize(
                      context,
                      size: isMobile ? IconSize.small : IconSize.medium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIControlsSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = ResponsiveHelper.getDeviceType(screenWidth);
    final isMobile = deviceType == DeviceType.mobile;

    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.all(
            ResponsiveHelper.getPadding(
              context,
              size: isMobile ? PaddingSize.medium : PaddingSize.large,
            ),
          ),
          padding: EdgeInsets.all(
            ResponsiveHelper.getPadding(
              context,
              size: isMobile ? PaddingSize.medium : PaddingSize.large,
            ),
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تحكم في الذكاء الاصطناعي',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.getPadding(
                  context,
                  size: isMobile ? PaddingSize.medium : PaddingSize.large,
                ),
              ),
              if (isMobile)
                // عرض عمودي للأزرار في الموبايل
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await MissionManager.forceAIRenewal();
                          _loadAllData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'تم إعادة تعيين نظام AI وتوليد مهام جديدة',
                              ),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                          size: ResponsiveHelper.getIconSize(
                            context,
                            size: IconSize.medium,
                          ),
                        ),
                        label: const Text('إعادة تولید المهام'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          padding: EdgeInsets.symmetric(
                            vertical:
                                ResponsiveHelper.getPadding(context) * 0.75,
                            horizontal: ResponsiveHelper.getPadding(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getPadding(context) * 0.5,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('نظام AI يعمل بشكل طبيعي'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.psychology,
                          size: ResponsiveHelper.getIconSize(
                            context,
                            size: IconSize.medium,
                          ),
                        ),
                        label: const Text('فحص حالة النظام'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textLight,
                          padding: EdgeInsets.symmetric(
                            vertical:
                                ResponsiveHelper.getPadding(context) * 0.75,
                            horizontal: ResponsiveHelper.getPadding(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                // عرض أفقي للأزرار في الشاشات الكبيرة
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await MissionManager.forceAIRenewal();
                          _loadAllData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'تم إعادة تعيين نظام AI وتوليد مهام جديدة',
                              ),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                          size: ResponsiveHelper.getIconSize(
                            context,
                            size: IconSize.large,
                          ),
                        ),
                        label: const Text('إعادة تولید المهام'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getPadding(context),
                            horizontal: ResponsiveHelper.getPadding(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getPadding(context)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('نظام AI يعمل بشكل طبيعي'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.psychology,
                          size: ResponsiveHelper.getIconSize(
                            context,
                            size: IconSize.large,
                          ),
                        ),
                        label: const Text('فحص حالة النظام'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textLight,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.getPadding(context),
                            horizontal: ResponsiveHelper.getPadding(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: ResponsiveHelper.getPadding(context) * 0.5),
              Text(
                'يمكنك إعادة تولید المهام الذكية أو فحص حالة النظام في أي وقت',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textLight.withValues(alpha: 0.7),
                  fontSize: isMobile ? 12 : 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _attemptMissionCompletion(Mission mission) async {
    try {
      bool success = false;

      if (mission.id.startsWith('ai_')) {
        // للمهام الذكية
        success = await MissionManager.completeAIMission(
          mission.id,
          mission.coinsReward,
        );
      } else {
        // للمهام التقليدية
        await MissionManager.completeMission(mission.id);
        success = true;
      }

      if (success) {
        setState(() {
          // المهمة تمت بنجاح - سيتم تحديث البيانات عبر _loadAllData()
        });

        // إظهار نافذة حوارية جميلة
        _showMissionCompletedDialog(mission);

        // تحديث البيانات
        _loadAllData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إكمال المهمة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMissionCompletedDialog(Mission mission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: 60,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تم إكمال المهمة!',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                mission.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLight.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${mission.coinsReward} نقطة',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text('رائع!'),
              ),
            ],
          ),
        );
      },
    );
  }
}
