import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme_new.dart';

// إضافة Helper للتجاوب مع الشاشات
class ResponsiveHelper {
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isSmallScreen(BuildContext context) =>
      getScreenWidth(context) < 600;

  static bool isMediumScreen(BuildContext context) =>
      getScreenWidth(context) >= 600 && getScreenWidth(context) < 1200;

  static bool isLargeScreen(BuildContext context) =>
      getScreenWidth(context) >= 1200;

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    if (screenWidth < 600) return baseSize * 0.8;
    if (screenWidth < 1200) return baseSize * 0.9;
    return baseSize;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (screenWidth < 600) return const EdgeInsets.all(8.0);
    if (screenWidth < 1200) return const EdgeInsets.all(12.0);
    return const EdgeInsets.all(16.0);
  }

  static double getResponsiveAppBarHeight(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    if (screenHeight < 700) return 120.0;
    if (screenHeight < 900) return 150.0;
    return 200.0;
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    if (screenWidth < 600) return baseSize * 0.8;
    if (screenWidth < 1200) return baseSize * 0.9;
    return baseSize;
  }

  static int getResponsiveMaxLines(BuildContext context) {
    return isSmallScreen(context) ? 1 : 2;
  }

  static double getResponsiveCardHeight(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    if (screenHeight < 700) return 60.0;
    if (screenHeight < 900) return 70.0;
    return 80.0;
  }
}

class StellarFriendsScreen extends StatefulWidget {
  const StellarFriendsScreen({super.key});

  @override
  State<StellarFriendsScreen> createState() => _StellarFriendsScreenState();
}

class _StellarFriendsScreenState extends State<StellarFriendsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friendRequests = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _selectedTab = 'friends';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadFriendsData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      _friends = [
        {
          'id': '1',
          'name': 'أحمد محمد',
          'email': 'ahmed@example.com',
          'isOnline': true,
          'lastSeen': DateTime.now(),
          'avatar': null,
        },
        {
          'id': '2',
          'name': 'سارة أحمد',
          'email': 'sara@example.com',
          'isOnline': false,
          'lastSeen': DateTime.now().subtract(const Duration(minutes: 30)),
          'avatar': null,
        },
        {
          'id': '3',
          'name': 'عمر حسن',
          'email': 'omar@example.com',
          'isOnline': true,
          'lastSeen': DateTime.now(),
          'avatar': null,
        },
      ];

      _friendRequests = [
        {
          'id': '4',
          'name': 'فاطمة علي',
          'email': 'fatima@example.com',
          'isOnline': false,
          'lastSeen': DateTime.now().subtract(const Duration(hours: 2)),
          'avatar': null,
        },
      ];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _searchResults =
          [
                {
                  'id': '5',
                  'name': 'خالد محمود',
                  'email': 'khalid@example.com',
                  'isOnline': true,
                  'lastSeen': DateTime.now(),
                  'avatar': null,
                },
                {
                  'id': '6',
                  'name': 'نورا سامي',
                  'email': 'noura@example.com',
                  'isOnline': false,
                  'lastSeen': DateTime.now().subtract(const Duration(hours: 1)),
                  'avatar': null,
                },
              ]
              .where(
                (user) =>
                    (user['name']?.toString().toLowerCase() ?? '').contains(
                      query.toLowerCase(),
                    ) ||
                    (user['email']?.toString().toLowerCase() ?? '').contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    } finally {
      setState(() => _isSearching = false);
    }
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
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: CustomScrollView(
                    slivers: [
                      _buildStellarAppBar(),
                      SliverPadding(
                        padding: ResponsiveHelper.getResponsivePadding(context),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildTabNavigation(),
                            SizedBox(
                              height: ResponsiveHelper.isSmallScreen(context)
                                  ? 12
                                  : AppDimensions.paddingLG,
                            ),
                            if (_selectedTab == 'search') _buildSearchSection(),
                            if (_selectedTab == 'friends')
                              _buildFriendsSection(),
                            if (_selectedTab == 'requests')
                              _buildRequestsSection(),
                            SizedBox(
                              height: ResponsiveHelper.isSmallScreen(context)
                                  ? 16
                                  : AppDimensions.paddingXXL,
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStellarAppBar() {
    return SliverAppBar(
      expandedHeight: ResponsiveHelper.getResponsiveAppBarHeight(context),
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.nebularGradient,
            boxShadow: AppShadows.card,
          ),
          child: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.nebularGradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: ResponsiveHelper.isSmallScreen(context) ? 40 : 60,
              ),
              Container(
                padding: EdgeInsets.all(
                  ResponsiveHelper.isSmallScreen(context) ? 16 : 20,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.stellarGradient,
                  boxShadow: AppShadows.stellar,
                ),
                child: Icon(
                  Icons.people,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 50),
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.isSmallScreen(context)
                    ? 8
                    : AppDimensions.paddingLG,
              ),
              Text(
                'الأصدقاء النجميون',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24),
                ),
              ),
              SizedBox(
                height: ResponsiveHelper.isSmallScreen(context)
                    ? 4
                    : AppDimensions.paddingSM,
              ),
              Text(
                'اتصل مع أصدقائك عبر المجرة',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return AppComponents.stellarCard(
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'friends',
              'الأصدقاء',
              Icons.people,
              _friends.length,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.dividerPrimary),
          Expanded(
            child: _buildTabButton('search', 'البحث', Icons.search, null),
          ),
          Container(width: 1, height: 40, color: AppColors.dividerPrimary),
          Expanded(
            child: _buildTabButton(
              'requests',
              'الطلبات',
              Icons.person_add,
              _friendRequests.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String title, IconData icon, int? count) {
    final isSelected = _selectedTab == tab;
    final isSmall = ResponsiveHelper.isSmallScreen(context);

    return InkWell(
      onTap: () {
        setState(() => _selectedTab = tab);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                ),
                if (count != null && count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: EdgeInsets.all(isSmall ? 2 : 4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 1,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count.toString(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            10,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isSmall ? 2 : 4),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: _searchUsers,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
          ),
          decoration: InputDecoration(
            hintText: 'ابحث عن أصدقاء جدد...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textTertiary,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: ResponsiveHelper.getResponsiveIconSize(context, 24),
            ),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.isSmallScreen(context) ? 12 : 16,
              horizontal: 16,
            ),
          ),
        ),
        SizedBox(
          height: ResponsiveHelper.isSmallScreen(context)
              ? 12
              : AppDimensions.paddingLG,
        ),
        if (_isSearching)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        else if (_searchResults.isEmpty && _searchController.text.isNotEmpty)
          _buildEmptyState(
            'لا توجد نتائج',
            'لم نجد أي مستخدمين يطابقون بحثك',
            Icons.search_off,
          )
        else
          ..._searchResults.map(
            (user) => _buildUserCard(user, _buildAddFriendButton(user)),
          ),
      ],
    );
  }

  Widget _buildFriendsSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_friends.isEmpty) {
      return _buildEmptyState(
        'لا يوجد أصدقاء',
        'ابدأ بالبحث عن أصدقاء جدد!',
        Icons.person_add,
      );
    }

    return Column(
      children: [
        ..._friends.map(
          (friend) => _buildUserCard(friend, _buildFriendActions(friend)),
        ),
      ],
    );
  }

  Widget _buildRequestsSection() {
    if (_friendRequests.isEmpty) {
      return _buildEmptyState(
        'لا توجد طلبات',
        'ستظهر طلبات الصداقة الجديدة هنا',
        Icons.notifications,
      );
    }

    return Column(
      children: [
        ..._friendRequests.map(
          (user) => _buildUserCard(user, _buildRequestActions(user)),
        ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, Widget actions) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    final avatarSize = isSmall ? 50.0 : 60.0;
    final iconSize = isSmall ? 24.0 : 30.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isSmall ? 8 : AppDimensions.paddingMD),
      child: AppComponents.stellarCard(
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.stellarGradient,
                    border: Border.all(
                      color: user['isOnline']
                          ? AppColors.success
                          : AppColors.textTertiary,
                      width: isSmall ? 2 : 3,
                    ),
                  ),
                  child: Icon(
                    Icons.person,
                    size: iconSize,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (user['isOnline'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: isSmall ? 12 : 16,
                      height: isSmall ? 12 : 16,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: isSmall ? 8 : AppDimensions.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        16,
                      ),
                    ),
                    maxLines: ResponsiveHelper.getResponsiveMaxLines(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['isOnline']
                        ? 'متصل الآن'
                        : 'آخر ظهور ${_formatLastSeen(user['lastSeen'])}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: user['isOnline']
                          ? AppColors.success
                          : AppColors.textTertiary,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        12,
                      ),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            actions,
          ],
        ),
      ),
    );
  }

  Widget _buildAddFriendButton(Map<String, dynamic> user) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);

    return ElevatedButton.icon(
      onPressed: () => _addFriend(user),
      icon: Icon(
        Icons.person_add,
        size: ResponsiveHelper.getResponsiveIconSize(context, 18),
      ),
      label: Text(
        'إضافة',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 12,
          vertical: isSmall ? 4 : 6,
        ),
        minimumSize: Size(isSmall ? 70 : 80, isSmall ? 28 : 32),
      ),
    );
  }

  Widget _buildFriendActions(Map<String, dynamic> friend) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context, 20);
    final paddingSize = isSmall ? 6.0 : 8.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(paddingSize),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.cosmicButtonGradient,
            ),
            child: Icon(
              Icons.games,
              color: AppColors.textPrimary,
              size: iconSize,
            ),
          ),
          onPressed: () => _inviteToGame(friend),
        ),
        SizedBox(width: isSmall ? 4 : AppDimensions.paddingSM),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(paddingSize),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.error),
            ),
            child: Icon(
              Icons.person_remove,
              color: AppColors.error,
              size: iconSize,
            ),
          ),
          onPressed: () => _removeFriend(friend),
        ),
      ],
    );
  }

  Widget _buildRequestActions(Map<String, dynamic> user) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context, 18);
    final paddingSize = isSmall ? 6.0 : 8.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: () => _acceptRequest(user),
          icon: Icon(Icons.check, size: iconSize),
          label: Text(
            'قبول',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.textPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 8 : 12,
              vertical: isSmall ? 4 : 6,
            ),
            minimumSize: Size(isSmall ? 70 : 80, isSmall ? 28 : 32),
          ),
        ),
        SizedBox(width: isSmall ? 4 : AppDimensions.paddingSM),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(paddingSize),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.error),
            ),
            child: Icon(Icons.close, color: AppColors.error, size: iconSize),
          ),
          onPressed: () => _rejectRequest(user),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    final isSmall = ResponsiveHelper.isSmallScreen(context);
    final iconSize = ResponsiveHelper.getResponsiveIconSize(context, 48);

    return AppComponents.stellarCard(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 16 : 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textTertiary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, size: iconSize, color: AppColors.textTertiary),
          ),
          SizedBox(height: isSmall ? 12 : AppDimensions.paddingLG),
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            ),
          ),
          SizedBox(height: isSmall ? 8 : AppDimensions.paddingSM),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  Future<void> _addFriend(Map<String, dynamic> user) async {
    try {
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال طلب الصداقة إلى ${user['name']}'),
          backgroundColor: AppColors.success,
        ),
      );

      setState(() {
        _searchResults.remove(user);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال طلب الصداقة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _acceptRequest(Map<String, dynamic> user) async {
    try {
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _friendRequests.remove(user);
        _friends.add(user);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم قبول طلب صداقة ${user['name']}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في قبول طلب الصداقة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _rejectRequest(Map<String, dynamic> user) async {
    try {
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _friendRequests.remove(user);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم رفض طلب صداقة ${user['name']}'),
          backgroundColor: AppColors.warning,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في رفض طلب الصداقة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _removeFriend(Map<String, dynamic> friend) async {
    try {
      HapticFeedback.lightImpact();

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfacePrimary,
          title: Text(
            'إزالة صديق',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'هل أنت متأكد من إزالة ${friend['name']} من قائمة الأصدقاء؟',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'إلغاء',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'تأكيد',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _friends.remove(friend);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف ${friend['name']} من الأصدقاء'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حذف الصديق: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _inviteToGame(Map<String, dynamic> friend) async {
    try {
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال دعوة لعبة إلى ${friend['name']}'),
          backgroundColor: AppColors.info,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إرسال دعوة اللعبة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
