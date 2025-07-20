import 'package:flutter/material.dart';
import '../utils/app_theme_new.dart';
import '../models/store_models.dart';

class ThemeManagementScreen extends StatefulWidget {
  const ThemeManagementScreen({super.key});

  @override
  State<ThemeManagementScreen> createState() => _ThemeManagementScreenState();
}

class _ThemeManagementScreenState extends State<ThemeManagementScreen> {
  List<StoreTheme> _themes = [];
  String _selectedThemeId = 'default';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() => _isLoading = true);
    
    // تحميل الثيمات المتاحة
    _themes = [
      StoreTheme(
        id: 'default',
        name: 'الثيم الافتراضي',
        description: 'الثيم الأساسي للتطبيق',
        price: 0,
        colorScheme: {
          'primary': '0xFF6366F1',
          'secondary': '0xFF8B5CF6',
          'background': '0xFFFFFFFF',
        },
        isUnlocked: true,
      ),
      StoreTheme(
        id: 'dark',
        name: 'الثيم المظلم',
        description: 'ثيم أنيق بألوان داكنة',
        price: 50,
        colorScheme: {
          'primary': '0xFF1F2937',
          'secondary': '0xFF374151',
          'background': '0xFF111827',
        },
        isUnlocked: true,
      ),
      StoreTheme(
        id: 'stellar',
        name: 'الثيم النجمي',
        description: 'ثيم رائع بألوان الفضاء',
        price: 100,
        colorScheme: {
          'primary': '0xFF6366F1',
          'secondary': '0xFF8B5CF6',
          'background': '0xFF0F0F23',
        },
        isUnlocked: true,
      ),
    ];

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الثيمات'),
        backgroundColor: AppColors.surfacePrimary,
      ),
      backgroundColor: AppColors.backgroundPrimary,
      body: _isLoading ? _buildLoadingView() : _buildContent(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildHeader(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildThemesList(),
          const SizedBox(height: AppDimensions.paddingXL),
          _buildThemeEditor(),
          ],
        ),
      );
    }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
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
              Icon(Icons.palette, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Text(
                'إدارة الثيمات',
                style: AppTextStyles.headlineMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                  Text(
            'إدارة وتخصيص ثيمات التطبيق',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الثيمات المتاحة',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMD),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingMD,
            mainAxisSpacing: AppDimensions.paddingMD,
            childAspectRatio: 1.2,
          ),
          itemCount: _themes.length,
          itemBuilder: (context, index) {
            return _buildThemeCard(_themes[index]);
          },
        ),
      ],
    );
  }

  Widget _buildThemeCard(StoreTheme theme) {
    final isSelected = _selectedThemeId == theme.id;
    
    return GestureDetector(
      onTap: () => _selectTheme(theme.id),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(int.parse(theme.colorScheme['primary']!)),
              Color(int.parse(theme.colorScheme['secondary']!)),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.palette,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
                    Text(
              theme.name,
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
              textAlign: TextAlign.center,
                    ),
            const SizedBox(height: 4),
                    Text(
              theme.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildThemeEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
          'إعدادات الثيم',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
        const SizedBox(height: AppDimensions.paddingMD),
                    Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
                      decoration: BoxDecoration(
            color: AppColors.surfacePrimary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderPrimary),
          ),
          child: Column(
            children: [
              _buildSettingRow('تطبيق تلقائياً', true),
              _buildSettingRow('حفظ في التفضيلات', true),
              _buildSettingRow('مشاركة مع الأصدقاء', false),
              const SizedBox(height: AppDimensions.paddingMD),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyTheme,
                      child: const Text('تطبيق الثيم'),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMD),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetToDefault,
                      child: const Text('إعادة تعيين'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String title, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // TODO: تطبيق تغيير الإعداد
            },
          ),
        ],
      ),
    );
  }

  void _selectTheme(String themeId) {
    setState(() {
      _selectedThemeId = themeId;
    });
  }

  void _applyTheme() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تطبيق الثيم بنجاح'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _selectedThemeId = 'default';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إعادة التعيين للثيم الافتراضي'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
