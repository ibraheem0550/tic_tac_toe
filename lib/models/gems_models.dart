class GemsPackage {
  final String id;
  final String name;
  final String description;
  final int gemsAmount;
  final double price;
  final String currency;
  final bool isPopular;
  final double? discount;
  final String? imageUrl;

  const GemsPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.gemsAmount,
    required this.price,
    this.currency = 'USD',
    this.isPopular = false,
    this.discount,
    this.imageUrl,
  });

  factory GemsPackage.fromJson(Map<String, dynamic> json) {
    return GemsPackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      gemsAmount: json['gemsAmount'],
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'USD',
      isPopular: json['isPopular'] ?? false,
      discount: json['discount']?.toDouble(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'gemsAmount': gemsAmount,
      'price': price,
      'currency': currency,
      'isPopular': isPopular,
      'discount': discount,
      'imageUrl': imageUrl,
    };
  }

  double get finalPrice =>
      discount != null ? price - (price * discount! / 100) : price;
}

class PurchaseTransaction {
  final String id;
  final String userId;
  final String packageId;
  final int gemsAmount;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? receiptData;

  const PurchaseTransaction({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.gemsAmount,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    this.receiptData,
  });

  factory PurchaseTransaction.fromJson(Map<String, dynamic> json) {
    return PurchaseTransaction(
      id: json['id'],
      userId: json['userId'],
      packageId: json['packageId'],
      gemsAmount: json['gemsAmount'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      paymentMethod: PaymentMethod.values.byName(json['paymentMethod']),
      status: TransactionStatus.values.byName(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      receiptData: json['receiptData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'packageId': packageId,
      'gemsAmount': gemsAmount,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'receiptData': receiptData,
    };
  }
}

enum PaymentMethod {
  creditCard,
  debitCard,
  googlePay,
  applePay,
  paypal,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
  refunded,
}

class UserGems {
  final String userId;
  int currentGems;
  int totalEarned;
  int totalSpent;
  DateTime lastUpdated;

  UserGems({
    required this.userId,
    this.currentGems = 0,
    this.totalEarned = 0,
    this.totalSpent = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory UserGems.fromJson(Map<String, dynamic> json) {
    return UserGems(
      userId: json['userId'],
      currentGems: json['currentGems'] ?? 0,
      totalEarned: json['totalEarned'] ?? 0,
      totalSpent: json['totalSpent'] ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'currentGems': currentGems,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  void addGems(int amount) {
    currentGems += amount;
    totalEarned += amount;
    lastUpdated = DateTime.now();
  }

  bool spendGems(int amount) {
    if (currentGems >= amount) {
      currentGems -= amount;
      totalSpent += amount;
      lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  UserGems copyWith({
    String? userId,
    int? currentGems,
    int? totalEarned,
    int? totalSpent,
    DateTime? lastUpdated,
  }) {
    return UserGems(
      userId: userId ?? this.userId,
      currentGems: currentGems ?? this.currentGems,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
