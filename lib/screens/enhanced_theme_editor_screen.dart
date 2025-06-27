import 'package:flutter/material.dart';
import '../utils/app_theme_new.dart';
import '../utils/responsive_helper.dart';

class EnhancedThemeEditorScreen extends StatefulWidget {
  const EnhancedThemeEditorScreen({super.key});

  @override
  State<EnhancedThemeEditorScreen> createState() =>
      _EnhancedThemeEditorScreenState();
}

class _EnhancedThemeEditorScreenState extends State<EnhancedThemeEditorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _themeNameController = TextEditingController();

  // الألوان الحالية
  Color _primaryColor = AppColors.primary;
  Color _secondaryColor = AppColors.secondary;
  Color _accentColor = AppColors.accent;
  Color _backgroundColor = AppColors.background;
  Color _surfaceColor = AppColors.surface;
  Color _textColor = AppColors.textSecondary;
  Color _errorColor = AppColors.error;
  Color _successColor = AppColors.success;
  Color _warningColor = AppColors.warning;
  Color _infoColor = AppColors.info;

  // معاينة السمة
  bool _isPreviewMode = false;
  String _themeName = 'سمة مخصصة';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _themeNameController.text = _themeName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _themeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'محرر السمات المتقدم',
          style: AppTextStyles.h3.copyWith(color: AppColors.textLight),
        ),
        backgroundColor: _isPreviewMode ? _primaryColor : AppColors.primary,
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textLight.withOpacity(0.7),
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'الألوان'),
            Tab(icon: Icon(Icons.text_fields), text: 'النصوص'),
            Tab(icon: Icon(Icons.preview), text: 'المعاينة'),
            Tab(icon: Icon(Icons.save), text: 'الحفظ'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
            icon: Icon(
              _isPreviewMode ? Icons.edit : Icons.preview,
              color: AppColors.textLight,
            ),
            tooltip: _isPreviewMode ? 'وضع التحرير' : 'وضع المعاينة',
          ),
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restore, color: AppColors.textLight),
            tooltip: 'إعادة تعيين',
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildColorsTab(),
            _buildTypographyTab(),
            _buildPreviewTab(),
            _buildSaveTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsTab() {
    return ResponsiveWidget(
      mobile: _buildMobileColorsLayout(),
      tablet: _buildTabletColorsLayout(),
      desktop: _buildDesktopColorsLayout(),
    );
  }

  Widget _buildMobileColorsLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('الألوان الأساسية'),
          _buildColorCard('اللون الأساسي', _primaryColor, (color) {
            setState(() => _primaryColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorCard('اللون الثانوي', _secondaryColor, (color) {
            setState(() => _secondaryColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorCard('لون التمييز', _accentColor, (color) {
            setState(() => _accentColor = color);
          }),
          const SizedBox(height: 24),
          _buildSectionHeader('ألوان الخلفية'),
          _buildColorCard('خلفية التطبيق', _backgroundColor, (color) {
            setState(() => _backgroundColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorCard('خلفية السطح', _surfaceColor, (color) {
            setState(() => _surfaceColor = color);
          }),
          const SizedBox(height: 24),
          _buildSectionHeader('ألوان التنبيهات'),
          _buildColorCard('لون الخطأ', _errorColor, (color) {
            setState(() => _errorColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorCard('لون النجاح', _successColor, (color) {
            setState(() => _successColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorCard('لون التحذير', _warningColor, (color) {
            setState(() => _warningColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorCard('لون المعلومات', _infoColor, (color) {
            setState(() => _infoColor = color);
          }),
        ],
      ),
    );
  }

  Widget _buildTabletColorsLayout() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        children: [
          _buildSectionHeader('الألوان الأساسية'),
          Row(
            children: [
              Expanded(
                  child:
                      _buildColorCard('اللون الأساسي', _primaryColor, (color) {
                setState(() => _primaryColor = color);
              })),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildColorCard('اللون الثانوي', _secondaryColor,
                      (color) {
                setState(() => _secondaryColor = color);
              })),
            ],
          ),
          const SizedBox(height: 16),
          _buildColorCard('لون التمييز', _accentColor, (color) {
            setState(() => _accentColor = color);
          }),
          const SizedBox(height: 24),
          _buildSectionHeader('ألوان الخلفية والتنبيهات'),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 3,
            children: [
              _buildColorCard('خلفية التطبيق', _backgroundColor, (color) {
                setState(() => _backgroundColor = color);
              }),
              _buildColorCard('خلفية السطح', _surfaceColor, (color) {
                setState(() => _surfaceColor = color);
              }),
              _buildColorCard('لون الخطأ', _errorColor, (color) {
                setState(() => _errorColor = color);
              }),
              _buildColorCard('لون النجاح', _successColor, (color) {
                setState(() => _successColor = color);
              }),
              _buildColorCard('لون التحذير', _warningColor, (color) {
                setState(() => _warningColor = color);
              }),
              _buildColorCard('لون المعلومات', _infoColor, (color) {
                setState(() => _infoColor = color);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopColorsLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('تخصيص الألوان'),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    _buildColorCard('اللون الأساسي', _primaryColor, (color) {
                      setState(() => _primaryColor = color);
                    }),
                    _buildColorCard('اللون الثانوي', _secondaryColor, (color) {
                      setState(() => _secondaryColor = color);
                    }),
                    _buildColorCard('لون التمييز', _accentColor, (color) {
                      setState(() => _accentColor = color);
                    }),
                    _buildColorCard('خلفية التطبيق', _backgroundColor, (color) {
                      setState(() => _backgroundColor = color);
                    }),
                    _buildColorCard('خلفية السطح', _surfaceColor, (color) {
                      setState(() => _surfaceColor = color);
                    }),
                    _buildColorCard('لون النص', _textColor, (color) {
                      setState(() => _textColor = color);
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('ألوان التنبيهات'),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  children: [
                    _buildColorCard('لون الخطأ', _errorColor, (color) {
                      setState(() => _errorColor = color);
                    }),
                    _buildColorCard('لون النجاح', _successColor, (color) {
                      setState(() => _successColor = color);
                    }),
                    _buildColorCard('لون التحذير', _warningColor, (color) {
                      setState(() => _warningColor = color);
                    }),
                    _buildColorCard('لون المعلومات', _infoColor, (color) {
                      setState(() => _infoColor = color);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: _buildLivePreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorCard(
      String title, Color color, Function(Color) onColorChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.card,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildColorPicker(color, onColorChanged),
        ],
      ),
    );
  }

  Widget _buildColorPicker(Color currentColor, Function(Color) onColorChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // مجموعة الألوان المحددة مسبقاً
        ...[
          AppColors.primary,
          AppColors.secondary,
          AppColors.accent,
          AppColors.starGold,
          AppColors.nebulaPurple,
          AppColors.galaxyBlue,
          AppColors.cosmicTeal,
          AppColors.stellarOrange,
          AppColors.planetGreen,
          AppColors.success,
          AppColors.warning,
          AppColors.error,
          AppColors.info,
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.orange,
          Colors.purple,
          Colors.teal,
          Colors.pink,
          Colors.indigo,
          Colors.cyan,
          Colors.amber,
          Colors.lime,
        ].map((color) => GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentColor == color
                        ? AppColors.textSecondary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            )),
        // زر اختيار لون مخصص
        GestureDetector(
          onTap: () => _showColorDialog(currentColor, onColorChanged),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textSecondary),
            ),
            child: const Icon(Icons.add, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypographyTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('معاينة الخطوط'),
          _buildTypographyPreview(),
          const SizedBox(height: 24),
          _buildSectionHeader('إعدادات النص'),
          _buildTextSettingsCard(),
        ],
      ),
    );
  }

  Widget _buildTypographyPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عنوان رئيسي',
            style: AppTextStyles.h1.copyWith(color: _textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'عنوان ثانوي',
            style: AppTextStyles.h2.copyWith(color: _textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'عنوان فرعي',
            style: AppTextStyles.h3.copyWith(color: _textColor),
          ),
          const SizedBox(height: 16),
          Text(
            'هذا نص عادي للمحتوى الأساسي في التطبيق. يجب أن يكون واضحاً وسهل القراءة.',
            style: AppTextStyles.bodyLarge.copyWith(color: _textColor),
          ),
          const SizedBox(height: 8),
          Text(
            'نص متوسط الحجم للمعلومات الإضافية والتفاصيل.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: _textColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            'نص صغير للملاحظات والمعلومات الثانوية.',
            style: AppTextStyles.bodySmall
                .copyWith(color: _textColor.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorCard('لون النص الأساسي', _textColor, (color) {
            setState(() => _textColor = color);
          }),
          const SizedBox(height: 16),
          Text(
            'معاينة النص مع الألوان المختارة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: _textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('معاينة السمة'),
          _buildLivePreview(),
        ],
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط التطبيق المعاين
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.menu, color: _textColor),
                const SizedBox(width: 16),
                Text(
                  'اسم التطبيق',
                  style:
                      AppTextStyles.headlineSmall.copyWith(color: _textColor),
                ),
                const Spacer(),
                Icon(Icons.search, color: _textColor),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // بطاقات المعاينة
          Row(
            children: [
              Expanded(
                child: _buildPreviewCard(
                  'بطاقة عادية',
                  'محتوى البطاقة',
                  _successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPreviewCard(
                  'بطاقة ثانية',
                  'محتوى آخر',
                  _infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // أزرار المعاينة
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: _textColor,
                  ),
                  child: const Text('زر أساسي'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _secondaryColor),
                    foregroundColor: _secondaryColor,
                  ),
                  child: const Text('زر ثانوي'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(String title, String content, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodySmall.copyWith(
              color: _textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('حفظ السمة'),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _themeNameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم السمة',
                    hintText: 'أدخل اسماً للسمة المخصصة',
                    prefixIcon: Icon(Icons.edit),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _themeName = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // ملخص السمة
                Text(
                  'ملخص السمة',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildThemeSummary(),

                const SizedBox(height: 24),

                // أزرار الحفظ
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveTheme,
                        icon: const Icon(Icons.save),
                        label: const Text('حفظ السمة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: _textColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _exportTheme,
                        icon: const Icon(Icons.file_download),
                        label: const Text('تصدير'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('اللون الأساسي', _primaryColor),
          _buildSummaryRow('اللون الثانوي', _secondaryColor),
          _buildSummaryRow('لون التمييز', _accentColor),
          _buildSummaryRow('خلفية التطبيق', _backgroundColor),
          _buildSummaryRow('لون النص', _textColor),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border:
                  Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: _textColor),
          ),
          const Spacer(),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: AppTextStyles.bodySmall.copyWith(
              color: _textColor.withOpacity(0.7),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  void _showColorDialog(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختيار لون مخصص'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _primaryColor = AppColors.primary;
      _secondaryColor = AppColors.secondary;
      _accentColor = AppColors.accent;
      _backgroundColor = AppColors.background;
      _surfaceColor = AppColors.surface;
      _textColor = AppColors.textSecondary;
      _errorColor = AppColors.error;
      _successColor = AppColors.success;
      _warningColor = AppColors.warning;
      _infoColor = AppColors.info;
      _themeName = 'سمة افتراضية';
      _themeNameController.text = _themeName;
    });
  }

  void _saveTheme() {
    // حفظ السمة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ السمة "$_themeName" بنجاح'),
        backgroundColor: _successColor,
      ),
    );
  }

  void _exportTheme() {
    // تصدير السمة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تصدير السمة "$_themeName"'),
        backgroundColor: _infoColor,
      ),
    );
  }
}

// ويدجت منتقي الألوان
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final Function(Color) onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Colors.primaries.map((color) {
        return GestureDetector(
          onTap: () => onColorChanged(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: pickerColor == color ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
