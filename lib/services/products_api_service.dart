import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import 'products_local_service.dart';
import 'mock_server_service.dart';

class ProductsApiService {
  // يمكن استخدام Firebase, Supabase, أو خادم مخصص
  static const String baseUrl = 'https://your-server.com/api';
  static const String productsEndpoint = '/products';

  // استخدام الخادم المحاكي في بيئة التطوير
  static bool get _useMockServer => true; // تغيير إلى false للاتصال بخادم حقيقي
  /// جلب جميع المنتجات من الخادم
  static Future<List<Product>> fetchProducts() async {
    if (_useMockServer) {
      return MockServerService.fetchProducts();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$productsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب المنتجات: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('خطأ في جلب المنتجات: $e');
      return [];
    }
  }

  /// جلب المنتجات الجديدة منذ آخر تحديث
  static Future<List<Product>> fetchNewProducts(DateTime lastUpdate) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl$productsEndpoint/new?since=${lastUpdate.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('خطأ في جلب المنتجات الجديدة: $e');
      return [];
    }
  }

  /// التحقق من وجود تحديثات جديدة
  static Future<bool> hasUpdates() async {
    if (_useMockServer) {
      return MockServerService.hasUpdates();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl$productsEndpoint/version'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serverVersion = data['version'] as int;
        final localVersion = await ProductsLocalService.getLocalVersion();
        return serverVersion > localVersion;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في التحقق من التحديثات: $e');
      return false;
    }
  }

  /// إضافة منتج جديد (للتطبيق الإداري)
  static Future<bool> addProduct(Product product) async {
    if (_useMockServer) {
      return MockServerService.addProduct(product);
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$productsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ADMIN_TOKEN',
        },
        body: json.encode(product.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('خطأ في إضافة المنتج: $e');
      return false;
    }
  }

  /// حذف منتج (للتطبيق الإداري)
  static Future<bool> deleteProduct(String productId) async {
    if (_useMockServer) {
      return MockServerService.deleteProduct(productId);
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$productsEndpoint/$productId'),
        headers: {
          'Authorization': 'Bearer YOUR_ADMIN_TOKEN',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('خطأ في حذف المنتج: $e');
      return false;
    }
  }

  /// تحديث منتج موجود (للتطبيق الإداري)
  static Future<bool> updateProduct(Product product) async {
    if (_useMockServer) {
      return MockServerService.updateProduct(product);
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl$productsEndpoint/${product.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ADMIN_TOKEN',
        },
        body: json.encode(product.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('خطأ في تحديث المنتج: $e');
      return false;
    }
  }

  /// تبديل حالة المنتج (تفعيل/إلغاء تفعيل)
  static Future<bool> toggleProductStatus(
      String productId, bool isActive) async {
    if (_useMockServer) {
      return MockServerService.toggleProductStatus(productId);
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$productsEndpoint/$productId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ADMIN_TOKEN',
        },
        body: json.encode({'is_active': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('خطأ في تبديل حالة المنتج: $e');
      return false;
    }
  }
}
