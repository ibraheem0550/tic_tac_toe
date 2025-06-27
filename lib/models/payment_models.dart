// Payment-related models for the payment system

class SavedPaymentMethod {
  final String id;
  final String name;
  final String type; // 'card', 'paypal', 'apple_pay', 'google_pay'
  final String last4Digits;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;
  final DateTime createdAt;

  SavedPaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.last4Digits,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
    required this.createdAt,
  });

  // Getters للتوافق مع الكود الموجود
  String get brand => type;
  String get last4 => last4Digits;

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return SavedPaymentMethod(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'card',
      last4Digits: json['last_4_digits'] ?? '',
      expiryMonth: json['expiry_month'] ?? '',
      expiryYear: json['expiry_year'] ?? '',
      isDefault: json['is_default'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'last_4_digits': last4Digits,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName {
    switch (type) {
      case 'card':
        return '$name ****$last4Digits';
      case 'paypal':
        return 'PayPal ($name)';
      case 'apple_pay':
        return 'Apple Pay';
      case 'google_pay':
        return 'Google Pay';
      default:
        return name;
    }
  }
}

enum PurchaseStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded
}

class PurchaseResult {
  final String transactionId;
  final PurchaseStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? transactionData;
  final DateTime timestamp;

  PurchaseResult({
    required this.transactionId,
    required this.status,
    this.errorMessage,
    this.transactionData,
    required this.timestamp,
  });

  // Getter للتوافق مع الكود الموجود
  bool get success => status == PurchaseStatus.completed;

  factory PurchaseResult.success(String transactionId,
      {Map<String, dynamic>? data}) {
    return PurchaseResult(
      transactionId: transactionId,
      status: PurchaseStatus.completed,
      transactionData: data,
      timestamp: DateTime.now(),
    );
  }

  factory PurchaseResult.failed(String transactionId, String errorMessage) {
    return PurchaseResult(
      transactionId: transactionId,
      status: PurchaseStatus.failed,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  factory PurchaseResult.cancelled(String transactionId) {
    return PurchaseResult(
      transactionId: transactionId,
      status: PurchaseStatus.cancelled,
      timestamp: DateTime.now(),
    );
  }

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    return PurchaseResult(
      transactionId: json['transaction_id'] ?? '',
      status: PurchaseStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PurchaseStatus.pending,
      ),
      errorMessage: json['error_message'],
      transactionData: json['transaction_data'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'status': status.toString().split('.').last,
      'error_message': errorMessage,
      'transaction_data': transactionData,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isSuccess => status == PurchaseStatus.completed;
  bool get isFailed => status == PurchaseStatus.failed;
  bool get isCancelled => status == PurchaseStatus.cancelled;
  bool get isPending =>
      status == PurchaseStatus.pending || status == PurchaseStatus.processing;
}
