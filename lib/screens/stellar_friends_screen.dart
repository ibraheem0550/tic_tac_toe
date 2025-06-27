import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';

class StellarFriendsScreen extends StatefulWidget {
  const StellarFriendsScreen({super.key});

  @override
  State<StellarFriendsScreen> createState() => _StellarFriendsScreenState();
}

class _StellarFriendsScreenState extends State<StellarFriendsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _searchController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final TextEditingController _searchTextController = TextEditingController();
  List<User> _friends = [];
  List<User> _searchResults = [];
  List<User> _friendRequests = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _selectedTab = 'friends'; // friends, search, requests
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadFriendsData();

    // إضافة listener للبحث
    _searchTextController.addListener(() {
      _searchUsers(_searchTextController.text);
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _searchController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    _searchTextController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    setState(() => _isLoading = true);
    try {
      // محاكاة تحميل بيانات الأصدقاء
      await Future.delayed(const Duration(milliseconds: 1000));
      // بيانات تجريبية للأصدقاء
      _friends = [
        _createMockUser('1', 'ahmed@example.com', 'أحمد محمد'),
        _createMockUser('2', 'sara@example.com', 'سارة أحمد'),
        _createMockUser('3', 'omar@example.com', 'عمر حسن'),
      ];

      // طلبات الصداقة التجريبية
      _friendRequests = [
        _createMockUser('4', 'fatima@example.com', 'فاطمة علي'),
      ];
    } finally {
      setState(() => _isLoading = false);
    }
  }

  User _createMockUser(String id, String email, String displayName) {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      profile: UserProfile(
        preferences: const UserPreferences(),
        gameStats: GameStats.empty(id),
      ),
    );
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

      // محاكاة البحث
      _searchResults = [
        _createMockUser('5', 'khalid@example.com', 'خالد محمود'),
        _createMockUser('6', 'noura@example.com', 'نورا سامي'),
      ]
          .where((user) =>
              user.displayName.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
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
                        padding: const EdgeInsets.all(AppDimensions.paddingLG),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildTabNavigation(),
                            const SizedBox(height: AppDimensions.paddingLG),
                            if (_selectedTab == 'search') _buildSearchSection(),
                            if (_selectedTab == 'friends')
                              _buildFriendsSection(),
                            if (_selectedTab == 'requests')
                              _buildRequestsSection(),
                            const SizedBox(height: AppDimensions.paddingXXL),
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
      expandedHeight: 200.0,
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
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.nebularGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.stellarGradient,
                  boxShadow: AppShadows.stellar,
                ),
                child: const Icon(
                  Icons.people,
                  size: 50,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingLG),
              Text(
                'الأصدقاء النجميون',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                'اتصل مع أصدقائك عبر المجرة',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
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
          Container(
            width: 1,
            height: 40,
            color: AppColors.dividerPrimary,
          ),
          Expanded(
            child: _buildTabButton(
              'search',
              'البحث',
              Icons.search,
              null,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.dividerPrimary,
          ),
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

    return InkWell(
      onTap: () {
        setState(() => _selectedTab = tab);
        HapticFeedback.selectionClick();
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary,
                  size: 24,
                ),
                if (count != null && count > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        AppComponents.stellarTextField(
          controller: _searchTextController,
          hintText: 'ابحث عن أصدقاء جدد...',
          prefixIcon: Icons.search,
        ),
        const SizedBox(height: AppDimensions.paddingLG),
        if (_isSearching)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          )
        else if (_searchResults.isEmpty &&
            _searchTextController.text.isNotEmpty)
          _buildEmptyState(
            'لا توجد نتائج',
            'لم نجد أي مستخدمين يطابقون بحثك',
            Icons.search_off,
          )
        else
          ..._searchResults
              .map((user) => _buildUserCard(user, _buildAddFriendButton(user))),
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
            (friend) => _buildUserCard(friend, _buildFriendActions(friend))),
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
        ..._friendRequests
            .map((user) => _buildUserCard(user, _buildRequestActions(user))),
      ],
    );
  }

  Widget _buildUserCard(User user, Widget actions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      child: AppComponents.stellarCard(
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.stellarGradient,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: user.photoURL != null
                        ? Image.network(
                            user.photoURL!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 30,
                            color: AppColors.textPrimary,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimensions.paddingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
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

  Widget _buildAddFriendButton(User user) {
    return AppComponents.stellarButton(
      text: 'إضافة',
      onPressed: () => _addFriend(user),
      icon: Icons.person_add,
    );
  }

  Widget _buildFriendActions(User friend) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.cosmicButtonGradient,
            ),
            child: const Icon(
              Icons.games,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          onPressed: () => _inviteToGame(friend),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withOpacity(0.2),
              border: Border.all(color: AppColors.error),
            ),
            child: const Icon(
              Icons.person_remove,
              color: AppColors.error,
              size: 20,
            ),
          ),
          onPressed: () => _removeFriend(friend),
        ),
      ],
    );
  }

  Widget _buildRequestActions(User user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppComponents.stellarButton(
          text: 'قبول',
          onPressed: () => _acceptRequest(user),
          icon: Icons.check,
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withOpacity(0.2),
              border: Border.all(color: AppColors.error),
            ),
            child: const Icon(
              Icons.close,
              color: AppColors.error,
              size: 20,
            ),
          ),
          onPressed: () => _rejectRequest(user),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return AppComponents.stellarCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textTertiary.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingLG),
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _addFriend(User user) async {
    try {
      HapticFeedback.lightImpact();

      // محاكاة إضافة صديق
      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال طلب الصداقة إلى ${user.displayName}'),
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

  Future<void> _acceptRequest(User user) async {
    try {
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _friendRequests.remove(user);
        _friends.add(user);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم قبول طلب صداقة ${user.displayName}'),
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

  Future<void> _rejectRequest(User user) async {
    try {
      HapticFeedback.lightImpact();

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _friendRequests.remove(user);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم رفض طلب صداقة ${user.displayName}'),
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

  Future<void> _removeFriend(User friend) async {
    try {
      HapticFeedback.lightImpact();

      // إظهار حوار تأكيد
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => _buildConfirmDialog(
          'إزالة صديق',
          'هل أنت متأكد من إزالة ${friend.displayName} من قائمة الأصدقاء؟',
        ),
      );

      if (confirmed == true) {
        await Future.delayed(const Duration(milliseconds: 500));

        setState(() {
          _friends.remove(friend);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف ${friend.displayName} من الأصدقاء'),
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

  Future<void> _inviteToGame(User friend) async {
    try {
      HapticFeedback.lightImpact();

      // محاكاة دعوة للعبة
      await Future.delayed(const Duration(milliseconds: 500));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال دعوة لعبة إلى ${friend.displayName}'),
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

  Widget _buildConfirmDialog(String title, String message) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.starfieldGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          boxShadow: AppShadows.modal,
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.warning.withOpacity(0.2),
                border: Border.all(color: AppColors.warning),
              ),
              child: const Icon(
                Icons.warning,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(
              message,
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
                    text: 'إلغاء',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                Expanded(
                  child: AppComponents.stellarButton(
                    text: 'تأكيد',
                    onPressed: () => Navigator.pop(context, true),
                    icon: Icons.check,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
