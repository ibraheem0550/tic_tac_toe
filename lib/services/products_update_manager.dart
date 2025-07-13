import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/products_api_service.dart';
import '../services/products_local_service.dart';

class ProductsUpdateManager extends ChangeNotifier {
  static final ProductsUpdateManager _instance =
      ProductsUpdateManager._internal();
  factory ProductsUpdateManager() => _instance;
  ProductsUpdateManager._internal();

  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _updateTimer;
  DateTime? _lastUpdateCheck;
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  DateTime? get lastUpdateCheck => _lastUpdateCheck;

  /// بدء خدمة التحديث التلقائي
  void startAutoUpdate() {
    // فحص التحديثات كل 5 دقائق
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(Duration(minutes: 5), (_) {
      checkForUpdates();
    });

    // فحص فوري عند البدء
    checkForUpdates();
  }

  /// إيقاف خدمة التحديث التلقائي
  void stopAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// فحص التحديثات يدوياً
  Future<void> checkForUpdates() async {
    try {
      _lastUpdateCheck = DateTime.now();

      // التحقق من وجود تحديثات
      final hasUpdates = await ProductsApiService.hasUpdates();

      if (hasUpdates) {
        await _downloadUpdates();
      }
    } catch (e) {
      _handleError('خطأ في فحص التحديثات: $e');
    }
  }

  /// تنزيل التحديثات
  Future<void> _downloadUpdates() async {
    try {
      _setLoading(true);

      // جلب المنتجات الجديدة
      final newProducts = await ProductsApiService.fetchProducts();

      // تحديث القائمة المحلية
      _products = newProducts;

      // حفظ التحديثات محلياً
      await ProductsLocalService.saveProducts(_products);
      await ProductsLocalService.saveLastUpdate(DateTime.now());

      _setLoading(false);
      _clearError();

      // إشعار المستمعين بالتحديث
      notifyListeners();

      // إظهار إشعار للمستخدم
      _showUpdateNotification();
    } catch (e) {
      _setLoading(false);
      _handleError('خطأ في تنزيل التحديثات: $e');
    }
  }

  /// تحميل المنتجات المحفوظة محلياً
  Future<void> loadLocalProducts() async {
    try {
      _setLoading(true);

      final localProducts = await ProductsLocalService.getLocalProducts();
      _products = localProducts;

      _setLoading(false);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _handleError('خطأ في تحميل المنتجات المحلية: $e');
    }
  }

  /// فلترة المنتجات حسب التصنيف
  List<Product> getProductsByCategory(String category) {
    return _products
        .where((product) => product.category == category && product.isActive)
        .toList();
  }

  /// البحث في المنتجات
  List<Product> searchProducts(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _products
        .where((product) =>
            product.name.toLowerCase().contains(lowercaseQuery) ||
            product.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// الحصول على منتج بالمعرف
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  /// تحديث منتج واحد
  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  /// إضافة منتج جديد
  void addProduct(Product newProduct) {
    _products.add(newProduct);
    notifyListeners();
  }

  /// حذف منتج
  void removeProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  /// تعيين حالة التحميل
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// معالجة الأخطاء
  void _handleError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
    debugPrint('ProductsUpdateManager Error: $message');
  }

  /// مسح الأخطاء
  void _clearError() {
    if (_hasError) {
      _hasError = false;
      _errorMessage = '';
      notifyListeners();
    }
  }

  /// إظهار إشعار التحديث
  void _showUpdateNotification() {
    // يمكن استخدام local notifications أو إشعار داخل التطبيق
    debugPrint('تم تحديث المنتجات! ${_products.length} منتج متاح');
  }

  /// فرض التحديث
  Future<void> forceUpdate() async {
    await _downloadUpdates();
  }

  /// الحصول على إحصائيات المنتجات
  Map<String, int> getProductStats() {
    final stats = <String, int>{};

    for (final category in ProductCategory.all) {
      stats[category] = getProductsByCategory(category).length;
    }

    return stats;
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
