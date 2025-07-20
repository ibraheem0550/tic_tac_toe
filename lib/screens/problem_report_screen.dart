import 'package:flutter/material.dart';
import '../utils/app_theme_new.dart';
import '../services/unified_auth_services.dart';

class ProblemReportScreen extends StatefulWidget {
  const ProblemReportScreen({super.key});

  @override
  State<ProblemReportScreen> createState() => _ProblemReportScreenState();
}

class _ProblemReportScreenState extends State<ProblemReportScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  
  String _selectedCategory = 'bug';
  String _selectedPriority = 'medium';
  bool _isSubmitting = false;
  bool _includeSystemInfo = true;

  final List<Map<String, String>> _categories = [
    {'id': 'bug', 'name': 'خطأ في التطبيق'},
    {'id': 'crash', 'name': 'توقف مفاجئ'},
    {'id': 'performance', 'name': 'مشكلة في الأداء'},
    {'id': 'feature', 'name': 'طلب ميزة جديدة'},
    {'id': 'ui', 'name': 'مشكلة في الواجهة'},
    {'id': 'gameplay', 'name': 'مشكلة في اللعب'},
    {'id': 'account', 'name': 'مشكلة في الحساب'},
    {'id': 'payment', 'name': 'مشكلة في الدفع'},
    {'id': 'other', 'name': 'أخرى'},
  ];

  final List<Map<String, String>> _priorities = [
    {'id': 'low', 'name': 'منخفضة', 'color': '0xFF10B981'},
    {'id': 'medium', 'name': 'متوسطة', 'color': '0xFFF59E0B'},
    {'id': 'high', 'name': 'عالية', 'color': '0xFFEF4444'},
    {'id': 'urgent', 'name': 'عاجلة', 'color': '0xFF7C3AED'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeUserInfo();
  }

  void _initializeUserInfo() {
    final user = _authService.currentUser;
    if (user != null && !user.isGuest) {
      _emailController.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإبلاغ عن مشكلة'),
        backgroundColor: AppColors.surfacePrimary,
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildCategorySection(),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildPrioritySection(),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildTitleField(),
              const SizedBox(height: AppDimensions.paddingLG),
              _buildDescriptionField(),
              const SizedBox(height: AppDimensions.paddingLG),
              _buildEmailField(),
              const SizedBox(height: AppDimensions.paddingLG),
              _buildOptionsSection(),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildSystemInfoSection(),
              const SizedBox(height: AppDimensions.paddingXL),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'الإبلاغ عن مشكلة',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'نحن نقدر ملاحظاتك ونسعى لحل جميع المشاكل بسرعة',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع المشكلة *',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category['id']!;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderPrimary,
                  ),
                ),
                child: Text(
                  category['name']!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستوى الأولوية *',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        Row(
          children: _priorities.map((priority) {
            final isSelected = _selectedPriority == priority['id'];
            final color = Color(int.parse(priority['color']!));
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPriority = priority['id']!;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(
                      color: isSelected ? color : AppColors.borderPrimary,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priority['name']!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? color : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عنوان المشكلة *',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'وصف مختصر للمشكلة...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال عنوان المشكلة';
            }
            if (value.trim().length < 10) {
              return 'العنوان قصير جداً (10 أحرف على الأقل)';
            }
            return null;
          },
          maxLength: 100,
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل المشكلة *',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'اشرح المشكلة بالتفصيل، متى حدثت، والخطوات المتبعة...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
          ),
          maxLines: 6,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال تفاصيل المشكلة';
            }
            if (value.trim().length < 20) {
              return 'التفاصيل قصيرة جداً (20 حرف على الأقل)';
            }
            return null;
          },
          maxLength: 1000,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البريد الإلكتروني *',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingXS),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'your.email@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            filled: true,
            fillColor: AppColors.surfaceSecondary,
            prefixIcon: const Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'يرجى إدخال بريد إلكتروني صحيح';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text('تضمين معلومات النظام'),
            subtitle: const Text('يساعد في تشخيص المشكلة بشكل أفضل'),
            value: _includeSystemInfo,
            onChanged: (value) {
              setState(() {
                _includeSystemInfo = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoSection() {
    if (!_includeSystemInfo) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderSecondary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'معلومات النظام',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSystemInfoRow('النظام', 'Windows 10'),
          _buildSystemInfoRow('إصدار التطبيق', '1.0.0'),
          _buildSystemInfoRow('المنصة', 'Desktop'),
          _buildSystemInfoRow('الدقة', '1920x1080'),
        ],
      ),
    );
  }

  Widget _buildSystemInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitReport,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.send),
        label: Text(
          _isSubmitting ? 'جاري الإرسال...' : 'إرسال البلاغ',
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // محاكاة إرسال البلاغ
      await Future.delayed(const Duration(seconds: 2));

      // إظهار رسالة نجاح
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إرسال البلاغ: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 64,
        ),
        title: const Text('تم الإرسال بنجاح'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('شكراً لك على التبليغ عن هذه المشكلة.'),
            const SizedBox(height: 8),
            const Text('سنقوم بمراجعتها والرد عليك قريباً.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'رقم البلاغ: #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الحوار
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
} 