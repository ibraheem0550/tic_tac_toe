import 'package:flutter/material.dart';
import '../utils/app_theme_new.dart';
import '../services/unified_auth_services.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  List<Map<String, dynamic>> _blockedUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);

    // بيانات وهمية للمستخدمين المحظورين
    await Future.delayed(const Duration(milliseconds: 500));

    _blockedUsers = [
      {
        'id': 'blocked_1',
        'name': 'مستخدم مخالف 1',
        'email': 'blocked1@example.com',
        'avatar': 'https://via.placeholder.com/100',
        'blockedAt': DateTime.now().subtract(Duration(days: 5)),
        'reason': 'سلوك غير لائق',
        'reportCount': 3,
      },
      {
        'id': 'blocked_2',
        'name': 'مستخدم مخالف 2',
        'email': 'blocked2@example.com',
        'avatar': 'https://via.placeholder.com/100',
        'blockedAt': DateTime.now().subtract(Duration(days: 12)),
        'reason': 'رسائل مزعجة',
        'reportCount': 5,
      },
      {
        'id': 'blocked_3',
        'name': 'مستخدم مخالف 3',
        'email': 'blocked3@example.com',
        'avatar': 'https://via.placeholder.com/100',
        'blockedAt': DateTime.now().subtract(Duration(days: 2)),
        'reason': 'غش في اللعبة',
        'reportCount': 7,
      },
    ];

    _filteredUsers = List.from(_blockedUsers);
    setState(() => _isLoading = false);
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_blockedUsers);
      } else {
        _filteredUsers = _blockedUsers.where((user) {
          return user['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              user['email'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              user['reason'].toString().toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمون المحظورون'),
        backgroundColor: AppColors.surfacePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBlockedUsers,
            tooltip: 'تحديث',
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(child: _isLoading ? _buildLoadingView() : _buildContent()),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        border: Border(bottom: BorderSide(color: AppColors.borderPrimary)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث في المستخدمين المحظورين...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterUsers('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              filled: true,
              fillColor: AppColors.surfaceSecondary,
            ),
            onChanged: _filterUsers,
          ),
          const SizedBox(height: AppDimensions.paddingMD),
          Row(
            children: [
              Icon(Icons.block, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'إجمالي المحظورين: ${_blockedUsers.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    if (_filteredUsers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildBlockedUserCard(_filteredUsers[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'لا توجد نتائج للبحث'
                : 'لا يوجد مستخدمون محظورون',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'جرب مصطلحات بحث مختلفة'
                : 'جميع المستخدمين يتبعون القواعد!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  child: Icon(Icons.person_off, color: AppColors.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user['email'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'محظور',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('السبب', user['reason']),
            _buildInfoRow('عدد البلاغات', '${user['reportCount']}'),
            _buildInfoRow('تاريخ الحظر', _formatDate(user['blockedAt'])),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewUserDetails(user),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('التفاصيل'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _unblockUser(user),
                    icon: const Icon(Icons.restore),
                    label: const Text('إلغاء الحظر'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inMinutes} دقيقة';
    }
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المستخدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('الاسم', user['name']),
            _buildDetailRow('البريد الإلكتروني', user['email']),
            _buildDetailRow('سبب الحظر', user['reason']),
            _buildDetailRow('عدد البلاغات', '${user['reportCount']}'),
            _buildDetailRow(
              'تاريخ الحظر',
              user['blockedAt'].toString().substring(0, 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _unblockUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الحظر'),
        content: Text('هل أنت متأكد من إلغاء حظر "${user['name']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performUnblock(user);
            },
            child: const Text('نعم، ألغ الحظر'),
          ),
        ],
      ),
    );
  }

  void _performUnblock(Map<String, dynamic> user) {
    setState(() {
      _blockedUsers.removeWhere((u) => u['id'] == user['id']);
      _filteredUsers.removeWhere((u) => u['id'] == user['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إلغاء حظر "${user['name']}" بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
