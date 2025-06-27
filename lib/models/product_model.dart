class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  /// تحويل من JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// إنشاء نسخة جديدة مع تعديلات
  Product copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? category,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price)';
  }
}

/// تصنيفات المنتجات
class ProductCategory {
  static const String themes = 'themes';
  static const String sounds = 'sounds';
  static const String powerUps = 'power_ups';
  static const String coins = 'coins';
  static const String premium = 'premium';

  static const List<String> all = [
    themes,
    sounds,
    powerUps,
    coins,
    premium,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case themes:
        return 'السمات';
      case sounds:
        return 'الأصوات';
      case powerUps:
        return 'التحسينات';
      case coins:
        return 'العملات';
      case premium:
        return 'المميزة';
      default:
        return 'غير محدد';
    }
  }
}
