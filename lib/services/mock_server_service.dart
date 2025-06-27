import 'dart:math';
import '../models/product_model.dart';

/// خدمة محاكاة الخادم لأغراض التطوير والاختبار
class MockServerService {
  static final List<Product> _products = [];
  static int _version = 1;
  static final Random _random = Random();

  /// إضافة منتجات تجريبية عند بدء التشغيل
  static void initializeMockData() {
    if (_products.isEmpty) {
      _products.addAll([
        Product(
          id: 'theme_cosmic',
          name: 'ثيم الفضاء الكوني',
          description: 'ثيم مذهل بألوان الفضاء والنجوم',
          price: 150,
          category: ProductCategory.themes,
          imageUrl: 'https://example.com/cosmic_theme.jpg',
          createdAt: DateTime.now().subtract(Duration(days: 5)),
          updatedAt: DateTime.now().subtract(Duration(days: 1)),
          metadata: {
            'colors': ['purple', 'blue', 'pink'],
            'effects': ['particles', 'glow']
          },
        ),
        Product(
          id: 'sound_nature',
          name: 'حزمة أصوات الطبيعة',
          description: 'أصوات الطبيعة المهدئة للعبة أكثر استرخاءً',
          price: 80,
          category: ProductCategory.sounds,
          imageUrl: 'https://example.com/nature_sounds.jpg',
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          updatedAt: DateTime.now().subtract(Duration(hours: 12)),
          metadata: {
            'sounds': ['rain', 'ocean', 'forest'],
            'duration': '30s'
          },
        ),
        Product(
          id: 'powerup_timefreeze',
          name: 'تجميد الوقت',
          description: 'قدرة خاصة لتجميد الوقت لـ 5 ثوانٍ',
          price: 200,
          category: ProductCategory.powerUps,
          imageUrl: 'https://example.com/time_freeze.jpg',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          updatedAt: DateTime.now().subtract(Duration(hours: 6)),
          metadata: {'duration': 5, 'cooldown': 60, 'uses': 3},
        ),
        Product(
          id: 'coins_mega_pack',
          name: 'حزمة العملات الضخمة',
          description: '500 عملة ذهبية فورية',
          price: 99,
          category: ProductCategory.coins,
          imageUrl: 'https://example.com/mega_coins.jpg',
          createdAt: DateTime.now().subtract(Duration(hours: 18)),
          updatedAt: DateTime.now().subtract(Duration(hours: 2)),
          metadata: {'coins_amount': 500, 'bonus': 50},
        ),
        Product(
          id: 'premium_monthly',
          name: 'العضوية المميزة الشهرية',
          description: 'جميع المميزات الحصرية لمدة شهر كامل',
          price: 299,
          category: ProductCategory.premium,
          imageUrl: 'https://example.com/premium.jpg',
          createdAt: DateTime.now().subtract(Duration(hours: 12)),
          updatedAt: DateTime.now().subtract(Duration(hours: 1)),
          metadata: {
            'duration': 30,
            'features': ['no_ads', 'unlimited_hints', 'exclusive_themes']
          },
        ),
      ]);
    }
  }

  /// جلب جميع المنتجات
  static Future<List<Product>> fetchProducts() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)));

    initializeMockData();
    return List.from(_products);
  }

  /// جلب المنتجات الجديدة منذ تاريخ معين
  static Future<List<Product>> fetchNewProducts(DateTime since) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));

    initializeMockData();
    return _products
        .where((product) =>
            product.createdAt.isAfter(since) ||
            product.updatedAt.isAfter(since))
        .toList();
  }

  /// التحقق من وجود تحديثات
  static Future<bool> hasUpdates() async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    // محاكاة وجود تحديثات أحياناً
    return _random.nextBool();
  }

  /// جلب إصدار الخادم
  static Future<int> getServerVersion() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
    return _version;
  }

  /// إضافة منتج جديد (للواجهة الإدارية)
  static Future<bool> addProduct(Product product) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    try {
      // التحقق من عدم وجود منتج بنفس المعرف
      if (_products.any((p) => p.id == product.id)) {
        return false;
      }

      _products.add(product);
      _version++;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// تحديث منتج موجود
  static Future<bool> updateProduct(Product product) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    try {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index == -1) return false;

      _products[index] = product.copyWith(updatedAt: DateTime.now());
      _version++;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف منتج
  static Future<bool> deleteProduct(String productId) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(400)));

    try {
      final initialLength = _products.length;
      _products.removeWhere((p) => p.id == productId);
      if (_products.length < initialLength) {
        _version++;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// تبديل حالة المنتج
  static Future<bool> toggleProductStatus(String productId) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    try {
      final index = _products.indexWhere((p) => p.id == productId);
      if (index == -1) return false;

      final product = _products[index];
      _products[index] = product.copyWith(
        isActive: !product.isActive,
        updatedAt: DateTime.now(),
      );
      _version++;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على إحصائيات المنتجات
  static Future<Map<String, dynamic>> getProductStats() async {
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));

    initializeMockData();

    final stats = <String, int>{};
    for (final category in ProductCategory.all) {
      stats[category] = _products.where((p) => p.category == category).length;
    }

    return {
      'total': _products.length,
      'active': _products.where((p) => p.isActive).length,
      'inactive': _products.where((p) => !p.isActive).length,
      'by_category': stats,
      'version': _version,
      'last_updated': DateTime.now().toIso8601String(),
    };
  }

  /// إضافة منتج عشوائي للاختبار
  static Future<Product> addRandomProduct() async {
    final categories = ProductCategory.all;
    final category = categories[_random.nextInt(categories.length)];

    final product = Product(
      id: 'random_${DateTime.now().millisecondsSinceEpoch}',
      name: 'منتج تجريبي ${_random.nextInt(1000)}',
      description: 'وصف تجريبي لمنتج جديد تم إنشاؤه تلقائياً',
      price: 50 + _random.nextInt(200),
      category: category,
      imageUrl: 'https://example.com/random_${_random.nextInt(100)}.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: {
        'generated': true,
        'test_id': _random.nextInt(10000),
      },
    );

    await addProduct(product);
    return product;
  }

  /// محاكاة إشعار تحديث للمنتجات
  static Stream<String> getUpdateNotifications() async* {
    while (true) {
      await Future.delayed(Duration(minutes: 2 + _random.nextInt(8)));

      if (_random.nextDouble() < 0.3) {
        // 30% احتمالية إضافة منتج جديد
        final product = await addRandomProduct();
        yield 'تم إضافة منتج جديد: ${product.name}';
      }
    }
  }

  /// مسح جميع البيانات (للاختبار فقط)
  static void clearAllData() {
    _products.clear();
    _version = 1;
  }

  /// إعادة تعيين البيانات التجريبية
  static void resetMockData() {
    clearAllData();
    initializeMockData();
  }
}
