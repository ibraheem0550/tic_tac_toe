import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gems_models.dart';
import 'unified_auth_services.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseAuthService _authService = FirebaseAuthService();

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
      description: 'حزمة كبيرة من الجواهر مع خصم',
      gemsAmount: 2500,
      price: 19.99,
      currency: 'USD',
    ),
  ];

  // Initialize payment service
  Future<void> initialize() async {
    // Simple initialization without external payment providers
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

  // Simulate purchase (for development/testing)
  Future<PurchaseResult> simulatePurchase(String packageId) async {
    try {
      final package = getPackageById(packageId);
      if (package == null) {
        return PurchaseResult(
          success: false,
          errorMessage: 'Package not found',
        );
      }

      final user = _authService.currentUserModel;
      if (user == null) {
        return PurchaseResult(
          success: false,
          errorMessage: 'User not authenticated',
        );
      }

      // Simulate successful purchase
      await _processPurchase(
        user.id,
        package,
        'simulated_payment_${DateTime.now().millisecondsSinceEpoch}',
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
      // TODO: تحديث لتستخدم FirestoreService
      debugPrint(
        'PaymentServiceSimple: recordPayment placeholder for $transactionId',
      );

      // Store locally for offline access
      await _storePurchaseLocally(userId, package, transactionId);
    } catch (e) {
      throw Exception('Failed to process purchase: $e');
    }
  }

  // Store purchase information locally
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
      // Log error but don't throw - local storage is not critical
      debugPrint('Failed to store purchase locally: $e');
    }
  }

  // Get purchase history
  Future<List<PurchaseHistory>> getPurchaseHistory() async {
    try {
      final user = _authService.currentUserModel;
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
      return [];
    }
  }

  // Check if payment methods are available
  bool get isPaymentMethodAvailable => true; // Always true for simulation

  // Get current user gems
  Future<int> getCurrentUserGems() async {
    try {
      final user = _authService.currentUserModel;
      if (user == null) return 0;

      return user.gems;
    } catch (e) {
      return 0;
    }
  }

  // Award free gems (for daily rewards, achievements, etc.)
  Future<bool> awardFreeGems(int amount, String reason) async {
    try {
      final user = _authService.currentUserModel;
      if (user == null) return false;

      // TODO: تحديث الجواهر عبر FirestoreService
      debugPrint(
        'PaymentServiceSimple: منح ${amount} جوهرة للمستخدم ${user.id} - السبب: $reason',
      );

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

      // TODO: تحديث الجواهر عبر FirestoreService
      debugPrint(
        'PaymentServiceSimple: updateUserGems placeholder - subtract ${amount} gems from user ${user.id}',
      );
      return true;
    } catch (e) {
      return false;
    }
  }
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
