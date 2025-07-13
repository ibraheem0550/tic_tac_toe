/// خدمة الدفع الموحدة - تدمج جميع طرق الدفع في ملف واحد
/// يدعم: Google Pay، Apple Pay، وطرق الدفع المختلفة (Stripe معطل مؤقتاً)
library unified_payment_service;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // معطل مؤقتاً
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/complete_user_models.dart' as models;

class UnifiedPaymentService {
  static UnifiedPaymentService? _instance;
  static UnifiedPaymentService get instance =>
      _instance ??= UnifiedPaymentService._();
  UnifiedPaymentService._();

  // Configuration
  bool _isStripeEnabled = true;
  bool _isDevMode = false;
  String? _stripePublishableKey;
  String? _stripeSecretKey;

  // Local Storage
  SharedPreferences? _prefs;

  // Transaction History
  final List<models.PaymentTransaction> _transactionHistory = [];

  /// تهيئة الخدمة
  Future<void> initialize({
    bool enableStripe = true,
    bool devMode = false,
    String? stripePublishableKey,
    String? stripeSecretKey,
  }) async {
    try {
      _isStripeEnabled = enableStripe;
      _isDevMode = devMode;
      _stripePublishableKey = stripePublishableKey;
      _stripeSecretKey = stripeSecretKey;

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize Stripe if enabled (معطل مؤقتاً)
      if (_isStripeEnabled && !_isDevMode && _stripePublishableKey != null) {
        try {
          // Stripe.publishableKey = _stripePublishableKey!;
          // await Stripe.instance.applySettings();
          debugPrint('💳 Stripe disabled temporarily');
        } catch (e) {
          debugPrint('Stripe initialization failed: $e');
          _isStripeEnabled = false;
        }
      }

      // Load transaction history
      await _loadTransactionHistory();

      debugPrint(
        '💰 UnifiedPaymentService initialized (Stripe: $_isStripeEnabled, Dev: $_isDevMode)',
      );
    } catch (e) {
      debugPrint('❌ UnifiedPaymentService initialization failed: $e');
    }
  }

  /// شراء العملات (Coins)
  Future<models.PaymentResult> purchaseCoins({
    required int coinAmount,
    required double price,
    required String currency,
    required String userId,
    models.PaymentMethodType paymentMethod = models.PaymentMethodType.stripe,
  }) async {
    try {
      final product = models.StoreProduct(
        id: 'coins_$coinAmount',
        name: '$coinAmount عملة',
        description: 'شراء $coinAmount عملة ذهبية',
        price: price,
        currency: currency,
        type: models.ProductType.coins,
        coinAmount: coinAmount,
      );

      return await _processPayment(
        product: product,
        userId: userId,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل شراء العملات: ${e.toString()}',
      );
    }
  }

  /// شراء الجواهر (Gems)
  Future<models.PaymentResult> purchaseGems({
    required int gemAmount,
    required double price,
    required String currency,
    required String userId,
    models.PaymentMethodType paymentMethod = models.PaymentMethodType.stripe,
  }) async {
    try {
      final product = models.StoreProduct(
        id: 'gems_$gemAmount',
        name: '$gemAmount جوهرة',
        description: 'شراء $gemAmount جوهرة',
        price: price,
        currency: currency,
        type: models.ProductType.gems,
        gemAmount: gemAmount,
      );

      return await _processPayment(
        product: product,
        userId: userId,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل شراء الجواهر: ${e.toString()}',
      );
    }
  }

  /// شراء Premium
  Future<models.PaymentResult> purchasePremium({
    required models.PremiumType premiumType,
    required String userId,
    models.PaymentMethodType paymentMethod = models.PaymentMethodType.stripe,
  }) async {
    try {
      final product = _getPremiumProduct(premiumType);

      return await _processPayment(
        product: product,
        userId: userId,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل شراء Premium: ${e.toString()}',
      );
    }
  }

  /// معالجة عملية الدفع
  Future<models.PaymentResult> _processPayment({
    required models.StoreProduct product,
    required String userId,
    required models.PaymentMethodType paymentMethod,
  }) async {
    try {
      if (_isDevMode) {
        // Mock payment for development
        return await _processMockPayment(product, userId, paymentMethod);
      }

      switch (paymentMethod) {
        case models.PaymentMethodType.stripe:
          return await _processStripePayment(product, userId);
        case models.PaymentMethodType.googlePay:
          return await _processGooglePayPayment(product, userId);
        case models.PaymentMethodType.applePay:
          return await _processApplePayPayment(product, userId);
        case models.PaymentMethodType.paypal:
          return await _processPayPalPayment(product, userId);
        default:
          return await _processStripePayment(product, userId);
      }
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل معالجة الدفع: ${e.toString()}',
      );
    }
  }

  /// معالجة دفع Stripe
  Future<models.PaymentResult> _processStripePayment(
    models.StoreProduct product,
    String userId,
  ) async {
    try {
      if (!_isStripeEnabled) {
        throw Exception('Stripe غير مفعل');
      }

      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: (product.price * 100).round(), // Convert to cents
        currency: product.currency,
        productId: product.id,
        userId: userId,
      );

      if (paymentIntent == null) {
        throw Exception('فشل إنشاء Payment Intent');
      }

      // Stripe payment disabled temporarily
      throw Exception('دفع Stripe معطل مؤقتاً');
    } on Exception catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'خطأ في الدفع: ${e.toString()}',
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل دفع Stripe: ${e.toString()}',
      );
    }
  }

  /// معالجة دفع Google Pay (Mock)
  Future<models.PaymentResult> _processGooglePayPayment(
    models.StoreProduct product,
    String userId,
  ) async {
    try {
      // Mock Google Pay payment
      await Future.delayed(const Duration(seconds: 2));

      final transaction = models.PaymentTransaction(
        id: 'gp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        productId: product.id,
        amount: product.price,
        currency: product.currency,
        paymentMethod: models.PaymentMethodType.googlePay,
        status: models.PaymentStatus.completed,
        createdAt: DateTime.now(),
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );

      await _saveTransaction(transaction);

      return models.PaymentResult(
        success: true,
        transactionId: transaction.id,
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل دفع Google Pay: ${e.toString()}',
      );
    }
  }

  /// معالجة دفع Apple Pay (Mock)
  Future<models.PaymentResult> _processApplePayPayment(
    models.StoreProduct product,
    String userId,
  ) async {
    try {
      // Mock Apple Pay payment
      await Future.delayed(const Duration(seconds: 2));

      final transaction = models.PaymentTransaction(
        id: 'ap_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        productId: product.id,
        amount: product.price,
        currency: product.currency,
        paymentMethod: models.PaymentMethodType.applePay,
        status: models.PaymentStatus.completed,
        createdAt: DateTime.now(),
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );

      await _saveTransaction(transaction);

      return models.PaymentResult(
        success: true,
        transactionId: transaction.id,
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل دفع Apple Pay: ${e.toString()}',
      );
    }
  }

  /// معالجة دفع PayPal (Mock)
  Future<models.PaymentResult> _processPayPalPayment(
    models.StoreProduct product,
    String userId,
  ) async {
    try {
      // Mock PayPal payment
      await Future.delayed(const Duration(seconds: 2));

      final transaction = models.PaymentTransaction(
        id: 'pp_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        productId: product.id,
        amount: product.price,
        currency: product.currency,
        paymentMethod: models.PaymentMethodType.paypal,
        status: models.PaymentStatus.completed,
        createdAt: DateTime.now(),
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );

      await _saveTransaction(transaction);

      return models.PaymentResult(
        success: true,
        transactionId: transaction.id,
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل دفع PayPal: ${e.toString()}',
      );
    }
  }

  /// معالجة دفع وهمي للتطوير
  Future<models.PaymentResult> _processMockPayment(
    models.StoreProduct product,
    String userId,
    models.PaymentMethodType paymentMethod,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final transaction = models.PaymentTransaction(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        productId: product.id,
        amount: product.price,
        currency: product.currency,
        paymentMethod: paymentMethod,
        status: models.PaymentStatus.completed,
        createdAt: DateTime.now(),
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );

      await _saveTransaction(transaction);

      return models.PaymentResult(
        success: true,
        transactionId: transaction.id,
        coinAmount: product.coinAmount,
        gemAmount: product.gemAmount,
        premiumType: product.premiumType,
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل الدفع الوهمي: ${e.toString()}',
      );
    }
  }

  /// إنشاء Payment Intent لـ Stripe
  Future<Map<String, dynamic>?> _createPaymentIntent({
    required int amount,
    required String currency,
    required String productId,
    required String userId,
  }) async {
    try {
      if (_stripeSecretKey == null) {
        throw Exception('Stripe Secret Key مفقود');
      }

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency.toLowerCase(),
          'metadata[product_id]': productId,
          'metadata[user_id]': userId,
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل إنشاء Payment Intent: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      return null;
    }
  }

  /// الحصول على منتج Premium
  models.StoreProduct _getPremiumProduct(models.PremiumType premiumType) {
    switch (premiumType) {
      case models.PremiumType.monthly:
        return models.StoreProduct(
          id: 'premium_monthly',
          name: 'Premium شهري',
          description: 'اشتراك Premium لمدة شهر واحد',
          price: 9.99,
          currency: 'USD',
          type: models.ProductType.premium,
          premiumType: premiumType,
        );
      case models.PremiumType.yearly:
        return models.StoreProduct(
          id: 'premium_yearly',
          name: 'Premium سنوي',
          description: 'اشتراك Premium لمدة سنة كاملة',
          price: 99.99,
          currency: 'USD',
          type: models.ProductType.premium,
          premiumType: premiumType,
        );
      case models.PremiumType.lifetime:
        return models.StoreProduct(
          id: 'premium_lifetime',
          name: 'Premium مدى الحياة',
          description: 'اشتراك Premium مدى الحياة',
          price: 199.99,
          currency: 'USD',
          type: models.ProductType.premium,
          premiumType: premiumType,
        );
    }
  }

  /// حفظ المعاملة
  Future<void> _saveTransaction(models.PaymentTransaction transaction) async {
    try {
      _transactionHistory.add(transaction);

      if (_prefs != null) {
        final transactionsJson = _transactionHistory
            .map((t) => t.toJson())
            .toList();
        await _prefs!.setString(
          'payment_transactions',
          jsonEncode(transactionsJson),
        );
      }
    } catch (e) {
      debugPrint('Error saving transaction: $e');
    }
  }

  /// تحميل تاريخ المعاملات
  Future<void> _loadTransactionHistory() async {
    try {
      if (_prefs == null) return;

      final transactionsData = _prefs!.getString('payment_transactions');
      if (transactionsData != null) {
        final transactionsList = jsonDecode(transactionsData) as List;
        _transactionHistory.clear();
        for (final transactionJson in transactionsList) {
          _transactionHistory.add(
            models.PaymentTransaction.fromJson(transactionJson),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading transaction history: $e');
    }
  }

  /// الحصول على تاريخ المعاملات
  List<models.PaymentTransaction> getTransactionHistory(String userId) {
    return _transactionHistory.where((t) => t.userId == userId).toList();
  }

  /// التحقق من حالة المعاملة
  Future<models.PaymentStatus> getTransactionStatus(
    String transactionId,
  ) async {
    try {
      final transaction = _transactionHistory.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('المعاملة غير موجودة'),
      );

      return transaction.status;
    } catch (e) {
      return models.PaymentStatus.failed;
    }
  }

  /// استرداد الأموال (Mock)
  Future<models.PaymentResult> refundTransaction(String transactionId) async {
    try {
      final transactionIndex = _transactionHistory.indexWhere(
        (t) => t.id == transactionId,
      );
      if (transactionIndex == -1) {
        throw Exception('المعاملة غير موجودة');
      }

      final oldTransaction = _transactionHistory[transactionIndex];
      final updatedTransaction = models.PaymentTransaction(
        id: oldTransaction.id,
        userId: oldTransaction.userId,
        productId: oldTransaction.productId,
        amount: oldTransaction.amount,
        currency: oldTransaction.currency,
        paymentMethod: oldTransaction.paymentMethod,
        status: models.PaymentStatus.refunded,
        createdAt: oldTransaction.createdAt,
        updatedAt: DateTime.now(),
        coinAmount: oldTransaction.coinAmount,
        gemAmount: oldTransaction.gemAmount,
        premiumType: oldTransaction.premiumType,
      );

      _transactionHistory[transactionIndex] = updatedTransaction;

      await _saveTransaction(updatedTransaction);

      return models.PaymentResult(
        success: true,
        message: 'تم استرداد الأموال بنجاح',
      );
    } catch (e) {
      return models.PaymentResult(
        success: false,
        error: 'فشل استرداد الأموال: ${e.toString()}',
      );
    }
  }

  /// الحصول على المنتجات المتاحة
  List<models.StoreProduct> getAvailableProducts() {
    return [
      // Coins
      models.StoreProduct(
        id: 'coins_100',
        name: '100 عملة',
        description: 'شراء 100 عملة ذهبية',
        price: 0.99,
        currency: 'USD',
        type: models.ProductType.coins,
        coinAmount: 100,
      ),
      models.StoreProduct(
        id: 'coins_500',
        name: '500 عملة',
        description: 'شراء 500 عملة ذهبية',
        price: 4.99,
        currency: 'USD',
        type: models.ProductType.coins,
        coinAmount: 500,
      ),
      models.StoreProduct(
        id: 'coins_1000',
        name: '1000 عملة',
        description: 'شراء 1000 عملة ذهبية',
        price: 9.99,
        currency: 'USD',
        type: models.ProductType.coins,
        coinAmount: 1000,
      ),

      // Gems
      models.StoreProduct(
        id: 'gems_10',
        name: '10 جوهرة',
        description: 'شراء 10 جوهرة',
        price: 1.99,
        currency: 'USD',
        type: models.ProductType.gems,
        gemAmount: 10,
      ),
      models.StoreProduct(
        id: 'gems_50',
        name: '50 جوهرة',
        description: 'شراء 50 جوهرة',
        price: 9.99,
        currency: 'USD',
        type: models.ProductType.gems,
        gemAmount: 50,
      ),

      // Premium
      _getPremiumProduct(models.PremiumType.monthly),
      _getPremiumProduct(models.PremiumType.yearly),
      _getPremiumProduct(models.PremiumType.lifetime),
    ];
  }

  /// مسح تاريخ المعاملات
  Future<void> clearTransactionHistory() async {
    try {
      _transactionHistory.clear();
      if (_prefs != null) {
        await _prefs!.remove('payment_transactions');
      }
    } catch (e) {
      debugPrint('Error clearing transaction history: $e');
    }
  }

  /// تنظيف المصادر
  void dispose() {
    _transactionHistory.clear();
  }
}
