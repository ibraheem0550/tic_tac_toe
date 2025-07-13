import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductsLocalService {
  static const String _productsKey = 'local_products';
  static const String _lastUpdateKey = 'products_last_update';
  static const String _versionKey = 'products_version';

  /// حفظ المنتجات محلياً
  static Future<void> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = products.map((product) => product.toJson()).toList();
      await prefs.setString(_productsKey, json.encode(productsJson));
    } catch (e) {
      debugPrint('خطأ في حفظ المنتجات محلياً: $e');
    }
  }

  /// جلب المنتجات المحفوظة محلياً
  static Future<List<Product>> getLocalProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsString = prefs.getString(_productsKey);

      if (productsString == null) return [];

      final List<dynamic> productsJson = json.decode(productsString);
      return productsJson.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      debugPrint('خطأ في جلب المنتجات المحلية: $e');
      return [];
    }
  }

  /// حفظ تاريخ آخر تحديث
  static Future<void> saveLastUpdate(DateTime lastUpdate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastUpdateKey, lastUpdate.toIso8601String());
    } catch (e) {
      debugPrint('خطأ في حفظ تاريخ التحديث: $e');
    }
  }

  /// جلب تاريخ آخر تحديث
  static Future<DateTime?> getLastUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateString = prefs.getString(_lastUpdateKey);

      if (lastUpdateString == null) return null;

      return DateTime.parse(lastUpdateString);
    } catch (e) {
      debugPrint('خطأ في جلب تاريخ التحديث: $e');
      return null;
    }
  }

  /// حفظ إصدار المنتجات المحلي
  static Future<void> saveLocalVersion(int version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_versionKey, version);
    } catch (e) {
      debugPrint('خطأ في حفظ إصدار المنتجات: $e');
    }
  }

  /// جلب إصدار المنتجات المحلي
  static Future<int> getLocalVersion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_versionKey) ?? 0;
    } catch (e) {
      debugPrint('خطأ في جلب إصدار المنتجات: $e');
      return 0;
    }
  }

  /// مسح جميع البيانات المحلية
  static Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productsKey);
      await prefs.remove(_lastUpdateKey);
      await prefs.remove(_versionKey);
    } catch (e) {
      debugPrint('خطأ في مسح البيانات المحلية: $e');
    }
  }

  /// التحقق من وجود منتجات محفوظة
  static Future<bool> hasLocalProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_productsKey);
    } catch (e) {
      debugPrint('خطأ في التحقق من المنتجات المحلية: $e');
      return false;
    }
  }

  /// إضافة منتج واحد محلياً
  static Future<void> addProduct(Product product) async {
    try {
      final products = await getLocalProducts();
      products.add(product);
      await saveProducts(products);
    } catch (e) {
      debugPrint('خطأ في إضافة المنتج محلياً: $e');
    }
  }

  /// حذف منتج بواسطة ID
  static Future<void> removeProduct(String productId) async {
    try {
      final products = await getLocalProducts();
      products.removeWhere((product) => product.id == productId);
      await saveProducts(products);
    } catch (e) {
      debugPrint('خطأ في حذف المنتج محلياً: $e');
    }
  }

  /// تحديث منتج موجود
  static Future<void> updateProduct(Product updatedProduct) async {
    try {
      final products = await getLocalProducts();
      final index =
          products.indexWhere((product) => product.id == updatedProduct.id);

      if (index != -1) {
        products[index] = updatedProduct;
        await saveProducts(products);
      }
    } catch (e) {
      debugPrint('خطأ في تحديث المنتج محلياً: $e');
    }
  }

  /// البحث في المنتجات المحلية
  static Future<List<Product>> searchProducts(String query) async {
    try {
      final products = await getLocalProducts();
      return products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('خطأ في البحث في المنتجات: $e');
      return [];
    }
  }

  /// فلترة المنتجات حسب الفئة
  static Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final products = await getLocalProducts();
      return products
          .where((product) =>
              product.category.toLowerCase() == category.toLowerCase())
          .toList();
    } catch (e) {
      debugPrint('خطأ في فلترة المنتجات: $e');
      return [];
    }
  }

  /// الحصول على إحصائيات المنتجات
  static Future<Map<String, int>> getProductsStats() async {
    try {
      final products = await getLocalProducts();
      final categories = <String, int>{};

      for (final product in products) {
        categories[product.category] = (categories[product.category] ?? 0) + 1;
      }

      return {
        'total': products.length,
        'active': products.where((p) => p.isActive).length,
        'inactive': products.where((p) => !p.isActive).length,
        ...categories,
      };
    } catch (e) {
      debugPrint('خطأ في جلب إحصائيات المنتجات: $e');
      return {};
    }
  }
}
