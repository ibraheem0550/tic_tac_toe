import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // TODO: Add when stripe is needed
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gems_models.dart';
import 'unified_auth_services.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Stripe configuration (TODO: Use when stripe package is added)
  // static const String _stripePublishableKey =
  //     'pk_test_your_publishable_key_here';
  // static const String _stripeSecretKey = 'sk_test_your_secret_key_here';

  // Available gems packages
  final List<GemsPackage> _availablePackages = [
    const GemsPackage(
      id: 'gems_100',
      name: '100 جوهرة',
      description: 'حزمة أساسية من الجواهر',
      gemsAmount: 100,
      price: 0.99,
      currency: 'USD',
    ),
    const GemsPackage(
      id: 'gems_500',
      name: '500 جوهرة',
      description: 'حزمة متوسطة من الجواهر',
      gemsAmount: 500,
      price: 4.99,
      currency: 'USD',
      isPopular: true,
    ),
    const GemsPackage(
      id: 'gems_1000',
      name: '1000 جوهرة',
      description: 'حزمة كبيرة من الجواهر',
      gemsAmount: 1000,
      price: 9.99,
      currency: 'USD',
    ),
    const GemsPackage(
      id: 'gems_2500',
      name: '2500 جوهرة',
      description: 'حزمة كبيرة جداً من الجواهر',
      gemsAmount: 2500,
      price: 19.99,
      currency: 'USD',
    ),
    const GemsPackage(
      id: 'gems_5000',
      name: '5000 جوهرة',
      description: 'حزمة عملاقة من الجواهر',
      gemsAmount: 5000,
      price: 39.99,
      currency: 'USD',
    ),
  ];

  // Initialize payment service
  Future<void> initialize() async {
    try {
      // TODO: Initialize Stripe when package is added
      // Stripe.publishableKey = _stripePublishableKey;
      // await Stripe.instance.applySettings();

      debugPrint('Payment service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize payment service: $e');
    }
  }

  // Get available packages
  List<GemsPackage> getAvailablePackages() {
    return List.unmodifiable(_availablePackages);
  }

  // Get gems package by ID
  GemsPackage? getPackageById(String packageId) {
    try {
      return _availablePackages.firstWhere(
        (package) => package.id == packageId,
      );
    } catch (e) {
      return null;
    }
  }

  // Create payment intent on backend
  // TODO: Use when stripe package is added
  /*
  Future<String> _createPaymentIntent(GemsPackage package) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend-url.com/create-payment-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_STRIPE_SECRET_KEY', // TODO: Use when stripe is added
        },
        body: jsonEncode({
          'amount': (package.price * 100).round(), // Convert to cents
          'currency': package.currency.toLowerCase(),
          'metadata': {
            'package_id': package.id,
            'gems_amount': package.gemsAmount.toString(),
            'user_id': _authService.currentUser?.id ?? '',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['client_secret'];
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error creating payment intent: $e');
    }
  }
  */

  // Process credit card payment
  Future<PurchaseResult> purchaseWithCreditCard(String packageId) async {
    try {
      final package = getPackageById(packageId);
      if (package == null) {
        return PurchaseResult(
          success: false,
          errorMessage: 'Package not found',
        );
      }

      final user = _authService.currentUser;
      if (user == null) {
        return PurchaseResult(
          success: false,
          errorMessage: 'User not authenticated',
        );
      }

      // Create payment intent
      // TODO: Create payment intent when stripe package is added
      // final clientSecret = await _createPaymentIntent(package);

      // TODO: Initialize payment sheet when stripe package is added
      /*
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Tic Tac Toe Game',
          style: ThemeMode.system,
          setupIntentClientSecret: null,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      */

      // If we reach here, payment was successful
      await _processPurchase(
        user.id,
        package,
        'stripe_${DateTime.now().millisecondsSinceEpoch}',
      );

      return PurchaseResult(
        success: true,
        gemsAwarded: package.gemsAmount,
        transactionId: 'stripe_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      // TODO: Handle StripeException when package is added
      return PurchaseResult(
        success: false,
        errorMessage: 'Purchase failed: $e',
      );
    }
  }

  // Simulate purchase for testing
  Future<PurchaseResult> simulatePurchase(String packageId) async {
    try {
      final package = getPackageById(packageId);
      if (package == null) {
        return PurchaseResult(
          success: false,
          errorMessage: 'Package not found',
        );
      }

      final user = _authService.currentUser;
      if (user == null) {
        return PurchaseResult(
          success: false,
          errorMessage: 'User not authenticated',
        );
      }

      // Simulate delay
      await Future.delayed(const Duration(seconds: 2));

      // Process simulated purchase
      await _processPurchase(
        user.id,
        package,
        'sim_${DateTime.now().millisecondsSinceEpoch}',
      );

      return PurchaseResult(
        success: true,
        gemsAwarded: package.gemsAmount,
        transactionId: 'sim_${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (e) {
      return PurchaseResult(
        success: false,
        errorMessage: 'Purchase failed: $e',
      );
    }
  }

  // Process successful purchase
  Future<void> _processPurchase(
    String userId,
    GemsPackage package,
    String transactionId,
  ) async {
    try {
      // Record payment in Supabase
      // TODO: Implement payment recording in Firestore
      /*
      await _firestoreService.recordPayment(
        userId: userId,
        paymentIntentId: transactionId,
        amount: (package.price * 100).round(),
        gemsAwarded: package.gemsAmount,
        currency: package.currency,
      );
      */

      // Store purchase locally
      await _storePurchaseLocally(userId, package, transactionId);

      debugPrint('Purchase processed successfully: $transactionId');
    } catch (e) {
      throw Exception('Failed to process purchase: $e');
    }
  }

  // Store purchase locally
  Future<void> _storePurchaseLocally(
    String userId,
    GemsPackage package,
    String transactionId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchases = prefs.getStringList('user_purchases_$userId') ?? [];

      final purchase = {
        'packageId': package.id,
        'transactionId': transactionId,
        'gemsAmount': package.gemsAmount,
        'price': package.price,
        'currency': package.currency,
        'timestamp': DateTime.now().toIso8601String(),
      };

      purchases.add(jsonEncode(purchase));
      await prefs.setStringList('user_purchases_$userId', purchases);
    } catch (e) {
      debugPrint('Failed to store purchase locally: $e');
    }
  }

  // Get saved payment methods
  Future<List<SavedPaymentMethod>> getSavedPaymentMethods() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final savedMethods =
          prefs.getStringList('saved_payment_methods_${user.id}') ?? [];

      return savedMethods.map((methodJson) {
        final data = jsonDecode(methodJson);
        return SavedPaymentMethod.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Failed to get saved payment methods: $e');
      return [];
    }
  }

  // Save payment method
  Future<bool> savePaymentMethod(
    String last4,
    String brand,
    String expiryMonth,
    String expiryYear,
  ) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final savedMethods =
          prefs.getStringList('saved_payment_methods_${user.id}') ?? [];

      final paymentMethod = SavedPaymentMethod(
        id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
        last4: last4,
        brand: brand,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: savedMethods.isEmpty,
        createdAt: DateTime.now(),
      );

      savedMethods.add(jsonEncode(paymentMethod.toJson()));
      await prefs.setStringList(
        'saved_payment_methods_${user.id}',
        savedMethods,
      );

      return true;
    } catch (e) {
      debugPrint('Failed to save payment method: $e');
      return false;
    }
  }

  // Remove saved payment method
  Future<bool> removeSavedPaymentMethod(String paymentMethodId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final savedMethods =
          prefs.getStringList('saved_payment_methods_${user.id}') ?? [];

      savedMethods.removeWhere((methodJson) {
        final data = jsonDecode(methodJson);
        return data['id'] == paymentMethodId;
      });

      await prefs.setStringList(
        'saved_payment_methods_${user.id}',
        savedMethods,
      );
      return true;
    } catch (e) {
      debugPrint('Failed to remove payment method: $e');
      return false;
    }
  }

  // Get purchase history
  Future<List<PurchaseHistory>> getPurchaseHistory() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final purchases = prefs.getStringList('user_purchases_${user.id}') ?? [];

      return purchases.map((purchaseJson) {
        final data = jsonDecode(purchaseJson);
        return PurchaseHistory(
          packageId: data['packageId'],
          transactionId: data['transactionId'],
          gemsAmount: data['gemsAmount'],
          price: data['price'],
          currency: data['currency'],
          timestamp: DateTime.parse(data['timestamp']),
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to get purchase history: $e');
      return [];
    }
  }

  // Get current user gems
  Future<int> getCurrentUserGems() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return 0;

      // TODO: Implement getUserGems in Firestore
      return 0; // await _firestoreService.getUserGems(user.id);
    } catch (e) {
      return 0;
    }
  }

  // Award free gems
  Future<bool> awardFreeGems(int amount, String reason) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final currentGems = await getCurrentUserGems();
      // TODO: Implement updateUserGems in Firestore
      // await _firestoreService.updateUserGems(user.id, currentGems + amount);
      debugPrint('Would add $amount gems. Current: $currentGems');

      return true;
    } catch (e) {
      return false;
    }
  }

  // Spend gems
  Future<bool> spendGems(int amount, String reason) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;
      final currentGems = await getCurrentUserGems();
      if (currentGems < amount) return false;

      // TODO: Implement updateUserGems in Firestore
      // await _firestoreService.updateUserGems(user.id, currentGems - amount);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if payment methods are available
  bool get isPaymentMethodAvailable => true;
}

// Purchase result class
class PurchaseResult {
  final bool success;
  final String? errorMessage;
  final int? gemsAwarded;
  final String? transactionId;

  PurchaseResult({
    required this.success,
    this.errorMessage,
    this.gemsAwarded,
    this.transactionId,
  });
}

// Purchase history class
class PurchaseHistory {
  final String packageId;
  final String transactionId;
  final int gemsAmount;
  final double price;
  final String currency;
  final DateTime timestamp;

  PurchaseHistory({
    required this.packageId,
    required this.transactionId,
    required this.gemsAmount,
    required this.price,
    required this.currency,
    required this.timestamp,
  });
}

// Saved payment method class
class SavedPaymentMethod {
  final String id;
  final String last4;
  final String brand;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;
  final DateTime createdAt;

  SavedPaymentMethod({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last4': last4,
      'brand': brand,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return SavedPaymentMethod(
      id: json['id'],
      last4: json['last4'],
      brand: json['brand'],
      expiryMonth: json['expiryMonth'],
      expiryYear: json['expiryYear'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
