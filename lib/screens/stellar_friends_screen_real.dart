import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme_new.dart';
import '../services/firebase_auth_service.dart';

/// خدمة إدارة الأصدقاء الحقيقية (مبسطة مؤقتاً)
class FriendsService {
  static final FriendsService _instance = FriendsService._internal();
  factory FriendsService() => _instance;
  FriendsService._internal();

  final FirebaseAuthService _authService = FirebaseAuthService();

  /// الحصول على قائمة الأصدقاء الحقيقية
  Future<List<Map<String, dynamic>>> getFriends() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      // TODO: Implement with Firestore when ready
      print('FriendsService: getFriends called for user ${user.id}');

      return [];
    } catch (e) {
      print('خطأ في جلب الأصدقاء: $e');
      return [];
    }
  }

  /// الحصول على طلبات الصداقة المعلقة
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      // TODO: Implement with Firestore when ready
      print('FriendsService: getFriendRequests called for user ${user.id}');

      return [];
    } catch (e) {
      print('خطأ في جلب طلبات الصداقة: $e');
      return [];
    }
  }

  /// البحث عن مستخدمين
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final user = _authService.currentUser;
      if (user == null || query.isEmpty) return [];

      // TODO: Implement with Firestore when ready
      print('FriendsService: searchUsers called with query: $query');

      return [];
    } catch (e) {
      print('خطأ في البحث عن المستخدمين: $e');
      return [];
    }
  }

  /// إرسال طلب صداقة
  Future<bool> sendFriendRequest(String friendId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      // TODO: Implement with Firestore when ready
      print('FriendsService: sendFriendRequest called for friend: $friendId');

      return true;
    } catch (e) {
      print('خطأ في إرسال طلب الصداقة: $e');
      return false;
    }
  }

  /// قبول طلب صداقة
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      // TODO: Implement with Firestore when ready
      print(
          'FriendsService: acceptFriendRequest called for request: $requestId');

      return true;
    } catch (e) {
      print('خطأ في قبول طلب الصداقة: $e');
      return false;
    }
  }

  /// رفض طلب صداقة
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      // TODO: Implement with Firestore when ready
      print(
          'FriendsService: rejectFriendRequest called for request: $requestId');

      return true;
    } catch (e) {
      print('خطأ في رفض طلب الصداقة: $e');
      return false;
    }
  }

  /// إزالة صديق
  Future<bool> removeFriend(String friendshipId) async {
    try {
      // TODO: Implement with Firestore when ready
      print(
          'FriendsService: removeFriend called for friendship: $friendshipId');

      return true;
    } catch (e) {
      print('خطأ في إزالة الصديق: $e');
      return false;
    }
  }
}

/// شاشة الأصدقاء النجمية الحقيقية - مبسطة مؤقتاً
class StellarFriendsScreenReal extends StatefulWidget {
  const StellarFriendsScreenReal({super.key});

  @override
  State<StellarFriendsScreenReal> createState() =>
      _StellarFriendsScreenRealState();
}

class _StellarFriendsScreenRealState extends State<StellarFriendsScreenReal> {
  final FriendsService _friendsService = FriendsService();
  String _selectedTab = 'friends';
  bool _isLoading = false;

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final friends = await _friendsService.getFriends();
      final requests = await _friendsService.getFriendRequests();

      if (mounted) {
        setState(() {
          _friends = friends;
          _friendRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('خطأ في تحميل بيانات الأصدقاء: $e');
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final results = await _friendsService.searchUsers(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('خطأ في البحث: $e');
      }
    }
  }

  Future<void> _sendFriendRequest(String friendId, String friendName) async {
    final success = await _friendsService.sendFriendRequest(friendId);
    if (success && mounted) {
      _showSuccessSnackBar('تم إرسال طلب الصداقة إلى $friendName');
    }
  }

  Future<void> _acceptFriendRequest(String requestId, String friendName) async {
    final success = await _friendsService.acceptFriendRequest(requestId);
    if (success && mounted) {
      _showSuccessSnackBar('تم قبول طلب صداقة $friendName');
      _loadFriendsData();
    }
  }

  Future<void> _rejectFriendRequest(String requestId, String friendName) async {
    final success = await _friendsService.rejectFriendRequest(requestId);
    if (success && mounted) {
      _showSuccessSnackBar('تم رفض طلب صداقة $friendName');
      _loadFriendsData();
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text(
          'الأصدقاء',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundSecondary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // تبويبات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                      'friends', 'الأصدقاء', '${_friends.length}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                      'requests', 'الطلبات', '${_friendRequests.length}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                      'search', 'البحث', '${_searchResults.length}'),
                ),
              ],
            ),
          ),

          // محتوى التبويب
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tabId, String label, String count) {
    final isSelected = _selectedTab == tabId;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabId),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderPrimary,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    switch (_selectedTab) {
      case 'friends':
        return _buildFriendsList();
      case 'requests':
        return _buildRequestsList();
      case 'search':
        return _buildSearchTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد أصدقاء بعد',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friends.length,
      itemBuilder: (context, index) {
        final friend = _friends[index];
        return _buildFriendCard(friend);
      },
    );
  }

  Widget _buildRequestsList() {
    if (_friendRequests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد طلبات صداقة',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        final request = _friendRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // شريط البحث
        Container(
          margin: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'ابحث عن أصدقاء...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primary,
              ),
              filled: true,
              fillColor: AppColors.surfacePrimary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onSubmitted: _searchUsers,
          ),
        ),

        // نتائج البحث
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'ابدأ بالبحث عن أصدقاء',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final user = _searchResults[index];
                    return _buildSearchResultCard(user);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderPrimary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage: friend['photo_url'] != null
                ? NetworkImage(friend['photo_url'])
                : null,
            child: friend['photo_url'] == null
                ? Text(
                    friend['display_name']?[0]?.toUpperCase() ?? 'F',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend['display_name'] ?? 'مستخدم مجهول',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: friend['is_online'] == true
                            ? AppColors.success
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      friend['is_online'] == true ? 'متصل' : 'غير متصل',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // إضافة خيارات الصديق (رسالة، إزالة، إلخ)
            },
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final requester = request['requester'] ?? request;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderPrimary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage: requester['photo_url'] != null
                ? NetworkImage(requester['photo_url'])
                : null,
            child: requester['photo_url'] == null
                ? Text(
                    requester['display_name']?[0]?.toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              requester['display_name'] ?? 'مستخدم مجهول',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => _acceptFriendRequest(
                  request['id'],
                  requester['display_name'] ?? 'مستخدم مجهول',
                ),
                icon: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
              IconButton(
                onPressed: () => _rejectFriendRequest(
                  request['id'],
                  requester['display_name'] ?? 'مستخدم مجهول',
                ),
                icon: const Icon(
                  Icons.cancel,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderPrimary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage: user['photo_url'] != null
                ? NetworkImage(user['photo_url'])
                : null,
            child: user['photo_url'] == null
                ? Text(
                    user['display_name']?[0]?.toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user['display_name'] ?? 'مستخدم مجهول',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _sendFriendRequest(
              user['id'],
              user['display_name'] ?? 'مستخدم مجهول',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'إضافة',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
