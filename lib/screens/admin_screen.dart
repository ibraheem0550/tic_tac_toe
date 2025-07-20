import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/products_update_manager.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_theme_new.dart';
import '../audio_helper.dart';
import 'stellar_tournament_admin_screen.dart';
import 'theme_management_screen.dart';
import 'system_analytics_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ProductsUpdateManager _productsManager = ProductsUpdateManager();
  bool _isLoading = false;
  String _selectedCategory = 'all';
  // إعدادات الصوت والتحسينات
  bool _soundEnabled = true;
  bool _showAdvancedSettings = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // تحميل إعدادات الصوت
    _soundEnabled = AudioHelper.isSoundEnabled;
    setState(() {});
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    await _productsManager.loadLocalProducts();
    await _productsManager.checkForUpdates();
    setState(() => _isLoading = false);
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث قائمة المنتجات',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
            ),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        onSave: (product) {
          _productsManager.addProduct(product);
          _loadProducts();
        },
      ),
    );
  }

  void _navigateToTournamentAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StellarTournamentAdminScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          title: Text(
            'إدارة المنتجات',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 8,
          actions: _buildAppBarActions(),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Container(
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

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        onPressed: _showAddProductDialog,
        icon: const Icon(Icons.add),
        tooltip: 'إضافة منتج جديد',
      ),
      IconButton(
        onPressed: _refreshProducts,
        icon: const Icon(Icons.refresh),
        tooltip: 'تحديث المنتجات',
      ),
    ];
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Column(
        children: [
          // شريط أدوات سريع
          Container(
            padding: EdgeInsets.all(
              ResponsiveHelper.getPadding(context, size: PaddingSize.small),
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showAddProductDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('إضافة منتج'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _refreshProducts,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('تحديث'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.textLight,
                          minimumSize: const Size(double.infinity, 40),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // إعدادات الصوت المبسطة للموبايل
                Row(
                  children: [
                    Icon(Icons.volume_up, color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'الصوت',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                        AudioHelper.setSoundEnabled(value);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value ? 'تم تفعيل الصوت' : 'تم إلغاء الصوت',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context)),
          _buildCategoryFilter(),
          SizedBox(height: ResponsiveHelper.getPadding(context)),
          Expanded(child: _buildProductsList()),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      // في الوضع الأفقي للتابلت، نستخدم تخطيط مشابه للديسكتوب
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
        child: Row(
          children: [
            // Panel جانبي مُصغر للتحكم
            Container(
              width: 280,
              padding: EdgeInsets.all(
                ResponsiveHelper.getPadding(context, size: PaddingSize.small),
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة التحكم',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getPadding(
                      context,
                      size: PaddingSize.small,
                    ),
                  ),
                  _buildCategoryFilter(),
                  SizedBox(
                    height: ResponsiveHelper.getPadding(
                      context,
                      size: PaddingSize.small,
                    ),
                  ),
                  Expanded(child: _buildQuickActions()),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // منطقة المنتجات
            Expanded(child: _buildProductsList()),
          ],
        ),
      );
    } else {
      // في الوضع العمودي للتابلت
      return Padding(
        padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
        child: Column(
          children: [
            // إعدادات سريعة في الأعلى
            Container(
              padding: EdgeInsets.all(
                ResponsiveHelper.getPadding(context, size: PaddingSize.small),
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(flex: 2, child: _buildCategoryFilter()),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _showAddProductDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('إضافة منتج'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _refreshProducts,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('تحديث'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.textLight,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            Expanded(child: _buildProductsList()),
          ],
        ),
      );
    }
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      child: Row(
        children: [
          // Panel جانبي للتحكم
          Container(
            width: 350,
            padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة التحكم',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getPadding(context)),
                _buildCategoryFilter(),
                SizedBox(height: ResponsiveHelper.getPadding(context)),
                _buildQuickActions(),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // منطقة المنتجات
          Expanded(child: _buildProductsList()),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickActionButton(
          'إضافة منتج جديد',
          Icons.add_circle_outline,
          _showAddProductDialog,
        ),
        const SizedBox(height: 8),
        _buildQuickActionButton(
          'تحديث المنتجات',
          Icons.refresh,
          _refreshProducts,
        ),
        const SizedBox(height: 8),
        _buildQuickActionButton(
          'إدارة المسابقات',
          Icons.emoji_events,
          _navigateToTournamentAdmin,
        ),
        const SizedBox(height: 20),
        _buildAdminSettings(),
      ],
    );
  }

  Widget _buildAdminSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات النظام',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // إعدادات الصوت
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.volume_up, color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'الصوت',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _soundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                      AudioHelper.setSoundEnabled(value);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value ? 'تم تفعيل الصوت' : 'تم إلغاء الصوت',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // إعدادات متقدمة
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _showAdvancedSettings = !_showAdvancedSettings;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.settings_applications,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'إعدادات متقدمة',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _showAdvancedSettings
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: AppColors.textLight,
                    ),
                  ],
                ),
              ),
              if (_showAdvancedSettings) ...[
                const SizedBox(height: 12),
                _buildQuickActionButton('إدارة الثيمات', Icons.palette, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeManagementScreen(),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                _buildQuickActionButton('إحصائيات النظام', Icons.analytics, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SystemAnalyticsScreen(),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(title),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textLight,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تصفية حسب الفئة',
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getPadding(context) * 0.5),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('all', 'الكل'),
              _buildCategoryChip(ProductCategory.themes, 'السمات'),
              _buildCategoryChip(ProductCategory.sounds, 'الأصوات'),
              _buildCategoryChip(ProductCategory.powerUps, 'التحسينات'),
              _buildCategoryChip(ProductCategory.coins, 'العملات'),
              _buildCategoryChip(ProductCategory.premium, 'المميزة'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return FilterChip(
      label: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected
              ? AppColors.textLight
              : AppColors.textLight.withValues(alpha: 0.7),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.textLight,
      backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.2),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.3),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }

  Widget _buildProductsList() {
    final filteredProducts = _productsManager.products.where((product) {
      if (_selectedCategory == 'all') return true;
      return product.category == _selectedCategory;
    }).toList();

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات في هذه الفئة',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textLight.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    final columns = ResponsiveHelper.getColumnsCount(
      context,
      maxColumns: 4,
      minColumns: 1,
    );

    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المنتج أو أيقونة
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(product.category),
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            // اسم المنتج
            Text(
              product.name,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // وصف المنتج
            Text(
              product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight.withValues(alpha: 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // السعر والحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${product.price} 🪙',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: product.isActive
                        ? AppColors.accent.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.isActive ? 'مفعل' : 'معطل',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: product.isActive ? AppColors.accent : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: () => _editProduct(product),
                    icon: const Icon(Icons.edit, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.2,
                      ),
                      foregroundColor: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: IconButton(
                    onPressed: () => _deleteProduct(product),
                    icon: const Icon(Icons.delete, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.2),
                      foregroundColor: Colors.red,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case ProductCategory.themes:
        return Icons.palette;
      case ProductCategory.sounds:
        return Icons.volume_up;
      case ProductCategory.powerUps:
        return Icons.flash_on;
      case ProductCategory.coins:
        return Icons.monetization_on;
      case ProductCategory.premium:
        return Icons.star;
      default:
        return Icons.shopping_bag;
    }
  }

  void _editProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        product: product,
        onSave: (updatedProduct) {
          _productsManager.updateProduct(updatedProduct);
          _loadProducts();
        },
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.9),
        title: Text(
          'حذف المنتج',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textLight,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${product.name}"؟',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textLight.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // حذف المنتج من القائمة المحلية
              _productsManager.products.removeWhere((p) => p.id == product.id);
              _loadProducts();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;
  final Function(Product) onSave;

  const ProductFormDialog({super.key, this.product, required this.onSave});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  String _selectedCategory = ProductCategory.themes;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.product?.imageUrl ?? '',
    );
    _selectedCategory = widget.product?.category ?? ProductCategory.themes;
    _isActive = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.95),
      title: Text(
        widget.product == null ? 'إضافة منتج جديد' : 'تعديل المنتج',
        style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textLight),
      ),
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
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال اسم المنتج';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'وصف المنتج',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال وصف المنتج';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر (بالعملات)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال السعر';
                    }
                    if (int.tryParse(value) == null) {
                      return 'يرجى إدخال رقم صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    border: OutlineInputBorder(),
                  ),
                  items: ProductCategory.all.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(ProductCategory.getDisplayName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الصورة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('المنتج مفعل'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
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
          child: Text(
            'إلغاء',
            style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.7)),
          ),
        ),
        ElevatedButton(
          onPressed: _saveProduct,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('حفظ', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final product = Product(
        id: widget.product?.id ?? 'product_${now.millisecondsSinceEpoch}',
        name: _nameController.text,
        description: _descriptionController.text,
        price: int.parse(_priceController.text),
        category: _selectedCategory,
        imageUrl: _imageUrlController.text,
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
        metadata: widget.product?.metadata ?? {},
      );

      widget.onSave(product);
      Navigator.pop(context);
    }
  }
}
