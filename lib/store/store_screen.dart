import 'package:flutter/material.dart';
import 'store_manager.dart';
import 'coins_notifier.dart';
import '../services/products_update_manager.dart';
import '../models/product_model.dart';
import '../utils/responsive_helper.dart';
import '../utils/app_theme_new.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _coins = 0;
  final ProductsUpdateManager _productsManager = ProductsUpdateManager();
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCoins();
    _initializeProducts();
    coinsChangeNotifier.addListener(_handleCoinsChange);
    _productsManager.addListener(_handleProductsUpdate);
  }

  Future<void> _initializeProducts() async {
    setState(() => _isLoadingProducts = true);
    await _productsManager.loadLocalProducts();
    _productsManager.startAutoUpdate();
    setState(() => _isLoadingProducts = false);
  }

  void _handleProductsUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadCoins() async {
    final coins = await StoreManager.getCoins();
    if (mounted) {
      setState(() {
        _coins = coins;
      });
    }
  }

  void _handleCoinsChange() {
    _loadCoins();
  }

  @override
  void dispose() {
    _tabController.dispose();
    coinsChangeNotifier.removeListener(_handleCoinsChange);
    _productsManager.removeListener(_handleProductsUpdate);
    _productsManager.stopAutoUpdate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textLight,
              size: ResponsiveHelper.getIconSize(context),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'المتجر',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          elevation: 8,
          actions: [
            Container(
              margin:
                  EdgeInsets.only(right: ResponsiveHelper.getPadding(context)),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getPadding(context) * 0.5,
                vertical: ResponsiveHelper.getPadding(context) * 0.25,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _coins.toString(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getPadding(context) * 0.25),
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.accent,
                    size: ResponsiveHelper.getIconSize(context) * 0.8,
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.accent,
            labelColor: AppColors.textLight,
            unselectedLabelColor: AppColors.textLight.withValues(alpha: 0.7),
            tabs: const [
              Tab(text: 'الثيمات'),
              Tab(text: 'الأصوات'),
              Tab(text: 'الإضافات'),
              Tab(text: 'المنتجات'),
            ],
          ),
        ),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductsTab(ProductCategory.themes),
              _buildProductsTab(ProductCategory.sounds),
              _buildProductsTab(ProductCategory.powerUps),
              _buildAllProductsTab(),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.95),
        title: Text(
          product.name,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              product.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: AppColors.accent,
                  size: ResponsiveHelper.getIconSize(context) * 0.8,
                ),
                SizedBox(width: ResponsiveHelper.getPadding(context) * 0.25),
                Text(
                  'السعر: ${product.price} عملة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
            ),
            child: Text(
              'شراء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseProduct(Product product) async {
    if (_coins >= product.price) {
      await StoreManager.decreaseCoins(product.price);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم شراء ${product.name} بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('لا تملك عملات كافية'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildProductsTab(String category) {
    if (_isLoadingProducts) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      );
    }

    final products = _productsManager.products
        .where((product) => product.category == category && product.isActive)
        .toList();

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: ResponsiveHelper.getIconSize(context) * 2,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            Text(
              'لا توجد ${ProductCategory.getDisplayName(category)} متاحة حالياً',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            ElevatedButton(
              onPressed: () => _productsManager.checkForUpdates(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
              child: Text(
                'تحديث المنتجات',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final columns =
        ResponsiveHelper.getColumnsCount(context, maxColumns: 3, minColumns: 2);

    return GridView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: ResponsiveHelper.getPadding(context) * 0.5,
        mainAxisSpacing: ResponsiveHelper.getPadding(context) * 0.5,
        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildAllProductsTab() {
    if (_isLoadingProducts) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      );
    }

    final products =
        _productsManager.products.where((product) => product.isActive).toList();

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: ResponsiveHelper.getIconSize(context) * 2,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            Text(
              'لا توجد منتجات متاحة حالياً',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getPadding(context)),
            ElevatedButton(
              onPressed: () => _productsManager.checkForUpdates(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
              child: Text(
                'تحديث المنتجات',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(ResponsiveHelper.getPadding(context)),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductListItem(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      color: AppColors.surfaceLight.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getPadding(context) * 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getCategoryColor(product.category),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(product.category),
                  size: ResponsiveHelper.getIconSize(context) * 1.5,
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getPadding(context) * 0.25),
              Text(
                product.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ResponsiveHelper.getPadding(context) * 0.25),
              Text(
                product.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${product.price}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.accent,
                    size: ResponsiveHelper.getIconSize(context) * 0.7,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductListItem(Product product) {
    return Card(
      margin:
          EdgeInsets.only(bottom: ResponsiveHelper.getPadding(context) * 0.5),
      color: AppColors.surfaceLight.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(product.category),
          child: Icon(
            _getCategoryIcon(product.category),
            color: AppColors.textLight,
            size: ResponsiveHelper.getIconSize(context) * 0.8,
          ),
        ),
        title: Text(
          product.name,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          product.description,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${product.price}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            Icon(
              Icons.monetization_on,
              color: AppColors.accent,
              size: ResponsiveHelper.getIconSize(context) * 0.7,
            ),
          ],
        ),
        onTap: () => _showProductDetails(product),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case ProductCategory.themes:
        return Icons.palette;
      case ProductCategory.sounds:
        return Icons.music_note;
      case ProductCategory.powerUps:
        return Icons.flash_on;
      case ProductCategory.coins:
        return Icons.monetization_on;
      case ProductCategory.premium:
        return Icons.star;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case ProductCategory.themes:
        return AppColors.primary;
      case ProductCategory.sounds:
        return AppColors.secondary;
      case ProductCategory.powerUps:
        return AppColors.warning;
      case ProductCategory.coins:
        return AppColors.success;
      case ProductCategory.premium:
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }
}
