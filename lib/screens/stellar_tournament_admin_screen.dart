import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/tournament_models.dart';
import '../services/tournament_service.dart';
import '../services/firebase_auth_service.dart';
import '../utils/app_theme_new.dart';

class StellarTournamentAdminScreen extends StatefulWidget {
  const StellarTournamentAdminScreen({super.key});

  @override
  State<StellarTournamentAdminScreen> createState() =>
      _StellarTournamentAdminScreenState();
}

class _StellarTournamentAdminScreenState
    extends State<StellarTournamentAdminScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  final TournamentService _tournamentService = TournamentService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  List<Tournament> _tournaments = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      await _tournamentService.initialize();
      _refreshTournaments();
    } catch (e) {
      _showErrorSnackBar('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _refreshTournaments() {
    setState(() {
      switch (_selectedFilter) {
        case 'active':
          _tournaments = _tournamentService.activeTournaments;
          break;
        case 'upcoming':
          _tournaments = _tournamentService.upcomingTournaments;
          break;
        case 'completed':
          _tournaments = _tournamentService.filterTournaments(
            status: TournamentStatus.completed,
          );
          break;
        default:
          _tournaments = _tournamentService.allTournaments;
      }

      if (_searchQuery.isNotEmpty) {
        _tournaments = _tournaments
            .where((t) =>
                t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList();
      }

      // ترتيب المسابقات حسب التاريخ
      _tournaments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                )
              : AnimatedBuilder(
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
                              padding:
                                  const EdgeInsets.all(AppDimensions.paddingLG),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  _buildStatsCards(),
                                  const SizedBox(
                                      height: AppDimensions.paddingXL),
                                  _buildFilterAndSearch(),
                                  const SizedBox(
                                      height: AppDimensions.paddingLG),
                                  _buildTournamentsList(),
                                  const SizedBox(
                                      height: AppDimensions.paddingXXL),
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
        floatingActionButton: _buildCreateTournamentFAB(),
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
      flexibleSpace: FlexibleSpaceBar(
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.stellarGradient.createShader(bounds),
          child: const Text(
            'إدارة المسابقات النجمية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.starfieldGradient,
              ),
            ),
            AnimatedBuilder(
              animation: _pulseController,
              child: const Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.white24,
              ),
              builder: (context, child) {
                return Positioned(
                  top: 60,
                  right: 20,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildStatsCards() {
    final stats = _tournamentService.tournamentStats;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'إجمالي المسابقات',
            '${stats['totalTournaments']}',
            Icons.emoji_events,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMD),
        Expanded(
          child: _buildStatCard(
            'المسابقات النشطة',
            '${stats['activeTournaments']}',
            Icons.play_circle,
            AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingMD),
        Expanded(
          child: _buildStatCard(
            'إجمالي المشاركين',
            '${stats['totalParticipants']}',
            Icons.people,
            AppColors.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return AppComponents.stellarCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearch() {
    return Column(
      children: [
        // شريط البحث
        AppComponents.stellarTextField(
          controller: _searchController,
          hintText: 'ابحث في المسابقات...',
          prefixIcon: Icons.search,
        ),
        const SizedBox(height: AppDimensions.paddingMD),

        // فلاتر الحالة
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('all', 'الجميع'),
              _buildFilterChip('active', 'النشطة'),
              _buildFilterChip('upcoming', 'القادمة'),
              _buildFilterChip('completed', 'المكتملة'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppDimensions.paddingSM),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
            _refreshTournaments();
          });
        },
        backgroundColor: AppColors.surfaceSecondary,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.borderPrimary,
        ),
      ),
    );
  }

  Widget _buildTournamentsList() {
    if (_tournaments.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _tournaments
          .map(
            (tournament) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
              child: _buildTournamentCard(tournament),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final statusColor = _getStatusColor(tournament.status);
    final typeIcon = _getTypeIcon(tournament.type);

    return AppComponents.stellarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSM),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Icon(typeIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: AppDimensions.paddingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tournament.name,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(tournament.status),
                        const SizedBox(width: AppDimensions.paddingSM),
                        Text(
                          tournament.typeDisplayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon:
                    const Icon(Icons.more_vert, color: AppColors.textTertiary),
                onSelected: (action) =>
                    _handleTournamentAction(tournament, action),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(
                      value: 'participants', child: Text('المشاركون')),
                  const PopupMenuItem(
                      value: 'matches', child: Text('المباريات')),
                  PopupMenuItem(
                    value: tournament.status == TournamentStatus.registration
                        ? 'start'
                        : 'status',
                    child: Text(
                        tournament.status == TournamentStatus.registration
                            ? 'بدء المسابقة'
                            : 'تغيير الحالة'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingMD),

          // معلومات المسابقة
          Text(
            tournament.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.paddingMD),

          // إحصائيات سريعة
          Row(
            children: [
              _buildQuickStat(
                Icons.people,
                '${tournament.currentParticipants}/${tournament.maxParticipants}',
                'مشارك',
              ),
              const SizedBox(width: AppDimensions.paddingLG),
              _buildQuickStat(
                Icons.schedule,
                _formatDate(tournament.startDate),
                'تاريخ البدء',
              ),
              const Spacer(),
              if (tournament.entryFee > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingSM,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: Text(
                    '${tournament.entryFee.toInt()} 💎',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          if (tournament.status == TournamentStatus.registration)
            Column(
              children: [
                const SizedBox(height: AppDimensions.paddingMD),
                LinearProgressIndicator(
                  value: tournament.progressPercentage / 100,
                  backgroundColor: AppColors.borderPrimary,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tournament.progressPercentage.toInt()}% ممتلئة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TournamentStatus status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: color),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AppComponents.stellarCard(
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppDimensions.paddingMD),
          Text(
            'لا توجد مسابقات',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSM),
          Text(
            'ابدأ بإنشاء مسابقة جديدة لجذب اللاعبين',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingLG),
          AppComponents.stellarButton(
            text: 'إنشاء مسابقة جديدة',
            onPressed: _showCreateTournamentDialog,
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTournamentFAB() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
          child: FloatingActionButton.extended(
            onPressed: _showCreateTournamentDialog,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            label: const Text('مسابقة جديدة'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // دوال مساعدة للألوان والأيقونات
  Color _getStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.upcoming:
        return AppColors.info;
      case TournamentStatus.registration:
        return AppColors.warning;
      case TournamentStatus.inProgress:
        return AppColors.success;
      case TournamentStatus.completed:
        return AppColors.primary;
      case TournamentStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getTypeIcon(TournamentType type) {
    switch (type) {
      case TournamentType.knockout:
        return Icons.sports_martial_arts;
      case TournamentType.roundRobin:
        return Icons.repeat;
      case TournamentType.swiss:
        return Icons.shuffle;
      case TournamentType.bracket:
        return Icons.account_tree;
    }
  }

  String _getStatusDisplayName(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.upcoming:
        return 'قادمة';
      case TournamentStatus.registration:
        return 'التسجيل مفتوح';
      case TournamentStatus.inProgress:
        return 'جارية';
      case TournamentStatus.completed:
        return 'مكتملة';
      case TournamentStatus.cancelled:
        return 'ملغية';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // دوال التفاعل
  void _handleTournamentAction(Tournament tournament, String action) {
    switch (action) {
      case 'edit':
        _showEditTournamentDialog(tournament);
        break;
      case 'participants':
        _showParticipantsDialog(tournament);
        break;
      case 'matches':
        _showMatchesDialog(tournament);
        break;
      case 'start':
        _startTournament(tournament);
        break;
      case 'status':
        _showStatusChangeDialog(tournament);
        break;
      case 'delete':
        _showDeleteConfirmation(tournament);
        break;
    }
  }

  void _showCreateTournamentDialog() {
    showDialog(
      context: context,
      builder: (context) => _TournamentFormDialog(
        onSave: (tournament) async {
          try {
            final currentUser = _authService.currentUser;
            if (currentUser == null) return;

            await _tournamentService.createTournament(
              name: tournament['name'],
              description: tournament['description'],
              type: tournament['type'],
              format: tournament['format'],
              startDate: tournament['startDate'],
              endDate: tournament['endDate'],
              registrationDeadline: tournament['registrationDeadline'],
              maxParticipants: tournament['maxParticipants'],
              entryFee: tournament['entryFee'],
              createdBy: currentUser.id,
            );

            _refreshTournaments();
            _showSuccessSnackBar('تم إنشاء المسابقة بنجاح');
          } catch (e) {
            _showErrorSnackBar('خطأ في إنشاء المسابقة: $e');
          }
        },
      ),
    );
  }

  void _showEditTournamentDialog(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => _TournamentFormDialog(
        tournament: tournament,
        onSave: (updatedData) async {
          try {
            final updatedTournament = tournament.copyWith(
              name: updatedData['name'],
              description: updatedData['description'],
              type: updatedData['type'],
              format: updatedData['format'],
              startDate: updatedData['startDate'],
              endDate: updatedData['endDate'],
              registrationDeadline: updatedData['registrationDeadline'],
              maxParticipants: updatedData['maxParticipants'],
              entryFee: updatedData['entryFee'],
            );

            await _tournamentService.updateTournament(
                tournament.id, updatedTournament);
            _refreshTournaments();
            _showSuccessSnackBar('تم تحديث المسابقة بنجاح');
          } catch (e) {
            _showErrorSnackBar('خطأ في تحديث المسابقة: $e');
          }
        },
      ),
    );
  }

  void _showParticipantsDialog(Tournament tournament) {
    final participants =
        _tournamentService.getTournamentParticipants(tournament.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مشاركو ${tournament.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: participants.isEmpty
              ? const Center(child: Text('لا يوجد مشاركون بعد'))
              : ListView.builder(
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('مشارك ${participant.userId}'),
                      subtitle: Text(
                          'تسجل في: ${_formatDate(participant.registrationTime)}'),
                    );
                  },
                ),
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

  void _showMatchesDialog(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مباريات ${tournament.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: tournament.matches.isEmpty
              ? const Center(child: Text('لم يتم إنشاء المباريات بعد'))
              : ListView.builder(
                  itemCount: tournament.matches.length,
                  itemBuilder: (context, index) {
                    final match = tournament.matches[index];
                    return ListTile(
                      title: Text('مباراة ${index + 1}'),
                      subtitle: Text('الجولة ${match.round}'),
                      trailing: Text(match.status.name),
                    );
                  },
                ),
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

  void _startTournament(Tournament tournament) async {
    try {
      await _tournamentService.startTournament(tournament.id);
      _refreshTournaments();
      _showSuccessSnackBar('تم بدء المسابقة بنجاح');
    } catch (e) {
      _showErrorSnackBar('خطأ في بدء المسابقة: $e');
    }
  }

  void _showStatusChangeDialog(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير حالة المسابقة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TournamentStatus.values
              .map(
                (status) => ListTile(
                  title: Text(_getStatusDisplayName(status)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      await _tournamentService.updateTournamentStatus(
                          tournament.id, status);
                      _refreshTournaments();
                      _showSuccessSnackBar('تم تغيير حالة المسابقة بنجاح');
                    } catch (e) {
                      _showErrorSnackBar('خطأ في تغيير الحالة: $e');
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Tournament tournament) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف مسابقة "${tournament.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _tournamentService.deleteTournament(tournament.id);
                _refreshTournaments();
                _showSuccessSnackBar('تم حذف المسابقة بنجاح');
              } catch (e) {
                _showErrorSnackBar('خطأ في حذف المسابقة: $e');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}

// نموذج إنشاء/تعديل المسابقة
class _TournamentFormDialog extends StatefulWidget {
  final Tournament? tournament;
  final Function(Map<String, dynamic>) onSave;

  const _TournamentFormDialog({
    this.tournament,
    required this.onSave,
  });

  @override
  State<_TournamentFormDialog> createState() => _TournamentFormDialogState();
}

class _TournamentFormDialogState extends State<_TournamentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _entryFeeController;

  TournamentType _selectedType = TournamentType.knockout;
  TournamentFormat _selectedFormat = TournamentFormat.classic;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  DateTime _registrationDeadline =
      DateTime.now().add(const Duration(hours: 12));

  @override
  void initState() {
    super.initState();

    final tournament = widget.tournament;
    _nameController = TextEditingController(text: tournament?.name ?? '');
    _descriptionController =
        TextEditingController(text: tournament?.description ?? '');
    _maxParticipantsController = TextEditingController(
      text: tournament?.maxParticipants.toString() ?? '16',
    );
    _entryFeeController = TextEditingController(
      text: tournament?.entryFee.toString() ?? '0',
    );

    if (tournament != null) {
      _selectedType = tournament.type;
      _selectedFormat = tournament.format;
      _startDate = tournament.startDate;
      _endDate = tournament.endDate;
      _registrationDeadline = tournament.registrationDeadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _entryFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.tournament == null ? 'إنشاء مسابقة جديدة' : 'تعديل المسابقة'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم المسابقة'),
                  validator: (value) =>
                      value?.isEmpty == true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty == true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TournamentType>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: 'نوع المسابقة'),
                  items: TournamentType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeDisplayName(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TournamentFormat>(
                  value: _selectedFormat,
                  decoration:
                      const InputDecoration(labelText: 'تنسيق المسابقة'),
                  items: TournamentFormat.values
                      .map(
                        (format) => DropdownMenuItem(
                          value: format,
                          child: Text(_getFormatDisplayName(format)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedFormat = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxParticipantsController,
                  decoration:
                      const InputDecoration(labelText: 'عدد المشاركين الأقصى'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'الحقل مطلوب';
                    final number = int.tryParse(value!);
                    if (number == null || number < 2)
                      return 'يجب أن يكون 2 على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _entryFeeController,
                  decoration:
                      const InputDecoration(labelText: 'رسوم الدخول (جواهر)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'الحقل مطلوب';
                    final number = double.tryParse(value!);
                    if (number == null || number < 0)
                      return 'يجب أن يكون صفر أو أكثر';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: _saveTournament,
          child: Text(widget.tournament == null ? 'إنشاء' : 'تحديث'),
        ),
      ],
    );
  }

  void _saveTournament() {
    if (_formKey.currentState?.validate() == true) {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'type': _selectedType,
        'format': _selectedFormat,
        'startDate': _startDate,
        'endDate': _endDate,
        'registrationDeadline': _registrationDeadline,
        'maxParticipants': int.parse(_maxParticipantsController.text),
        'entryFee': double.parse(_entryFeeController.text),
      };

      widget.onSave(data);
      Navigator.pop(context);
    }
  }

  String _getTypeDisplayName(TournamentType type) {
    switch (type) {
      case TournamentType.knockout:
        return 'خروج المغلوب';
      case TournamentType.roundRobin:
        return 'الدوري';
      case TournamentType.swiss:
        return 'السويسري';
      case TournamentType.bracket:
        return 'الأقواس';
    }
  }

  String _getFormatDisplayName(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.classic:
        return 'كلاسيكي';
      case TournamentFormat.blitz:
        return 'خاطف';
      case TournamentFormat.bullet:
        return 'سريع';
      case TournamentFormat.ultraBullet:
        return 'سريع جداً';
    }
  }
}
