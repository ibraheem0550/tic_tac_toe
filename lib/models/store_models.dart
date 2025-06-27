import 'package:flutter/material.dart';

/// نماذج المتجر الشامل
enum StoreCategory {
  gems('الجواهر', Icons.diamond, Colors.purple),
  themes('الثيمات', Icons.palette, Colors.blue),
  sounds('الأصوات', Icons.music_note, Colors.green),
  upgrades('التحسينات', Icons.upgrade, Colors.orange),
  special('العروض الخاصة', Icons.local_offer, Colors.red);

  const StoreCategory(this.title, this.icon, this.color);
  final String title;
  final IconData icon;
  final Color color;
}

enum ProductType { gems, theme, sound, upgrade, bundle, special }

enum ProductRarity {
  common('عادي', Colors.grey),
  rare('نادر', Colors.blue),
  epic('ملحمي', Colors.purple),
  legendary('أسطوري', Colors.orange);

  const ProductRarity(this.title, this.color);
  final String title;
  final Color color;
}

class StoreProduct {
  final String id;
  final String name;
  final String description;
  final ProductType type;
  final StoreCategory category;
  final double price;
  final String currency;
  final ProductRarity rarity;
  final String iconPath;
  final String? previewPath;
  final bool isPopular;
  final bool isNew;
  final bool isLimited;
  final bool isOwned;
  final Map<String, dynamic> rewards;
  final Map<String, dynamic> metadata;
  final DateTime? expiryDate;

  const StoreProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.price,
    this.currency = 'USD',
    this.rarity = ProductRarity.common,
    required this.iconPath,
    this.previewPath,
    this.isPopular = false,
    this.isNew = false,
    this.isLimited = false,
    this.isOwned = false,
    this.rewards = const {},
    this.metadata = const {},
    this.expiryDate,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: ProductType.values.firstWhere((e) => e.name == json['type']),
      category:
          StoreCategory.values.firstWhere((e) => e.name == json['category']),
      price: json['price'].toDouble(),
      currency: json['currency'] ?? 'USD',
      rarity: ProductRarity.values.firstWhere((e) => e.name == json['rarity']),
      iconPath: json['iconPath'],
      previewPath: json['previewPath'],
      isPopular: json['isPopular'] ?? false,
      isNew: json['isNew'] ?? false,
      isLimited: json['isLimited'] ?? false,
      isOwned: json['isOwned'] ?? false,
      rewards: Map<String, dynamic>.from(json['rewards'] ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'category': category.name,
      'price': price,
      'currency': currency,
      'rarity': rarity.name,
      'iconPath': iconPath,
      'previewPath': previewPath,
      'isPopular': isPopular,
      'isNew': isNew,
      'isLimited': isLimited,
      'isOwned': isOwned,
      'rewards': rewards,
      'metadata': metadata,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  StoreProduct copyWith({
    String? id,
    String? name,
    String? description,
    ProductType? type,
    StoreCategory? category,
    double? price,
    String? currency,
    ProductRarity? rarity,
    String? iconPath,
    String? previewPath,
    bool? isPopular,
    bool? isNew,
    bool? isLimited,
    bool? isOwned,
    Map<String, dynamic>? rewards,
    Map<String, dynamic>? metadata,
    DateTime? expiryDate,
  }) {
    return StoreProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      rarity: rarity ?? this.rarity,
      iconPath: iconPath ?? this.iconPath,
      previewPath: previewPath ?? this.previewPath,
      isPopular: isPopular ?? this.isPopular,
      isNew: isNew ?? this.isNew,
      isLimited: isLimited ?? this.isLimited,
      isOwned: isOwned ?? this.isOwned,
      rewards: rewards ?? this.rewards,
      metadata: metadata ?? this.metadata,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

class UserInventory {
  final String userId;
  final List<String> ownedProducts;
  final Map<String, int> currencies;
  final Map<String, DateTime> lastPurchases;
  final Map<String, dynamic> settings;

  const UserInventory({
    required this.userId,
    this.ownedProducts = const [],
    this.currencies = const {},
    this.lastPurchases = const {},
    this.settings = const {},
  });

  factory UserInventory.fromJson(Map<String, dynamic> json) {
    return UserInventory(
      userId: json['userId'],
      ownedProducts: List<String>.from(json['ownedProducts'] ?? []),
      currencies: Map<String, int>.from(json['currencies'] ?? {}),
      lastPurchases: Map<String, DateTime>.from(
        (json['lastPurchases'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, DateTime.parse(value)),
        ),
      ),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'ownedProducts': ownedProducts,
      'currencies': currencies,
      'lastPurchases': lastPurchases.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'settings': settings,
    };
  }

  bool ownsProduct(String productId) => ownedProducts.contains(productId);

  int getCurrency(String currencyType) => currencies[currencyType] ?? 0;

  UserInventory copyWith({
    String? userId,
    List<String>? ownedProducts,
    Map<String, int>? currencies,
    Map<String, DateTime>? lastPurchases,
    Map<String, dynamic>? settings,
  }) {
    return UserInventory(
      userId: userId ?? this.userId,
      ownedProducts: ownedProducts ?? this.ownedProducts,
      currencies: currencies ?? this.currencies,
      lastPurchases: lastPurchases ?? this.lastPurchases,
      settings: settings ?? this.settings,
    );
  }
}

/// البيانات الافتراضية للمتجر
class StoreData {
  static List<StoreProduct> getAllProducts() {
    return [
      // منتجات الجواهر
      ...getGemProducts(),
      // منتجات الثيمات
      ...getThemeProducts(),
      // منتجات الأصوات
      ...getSoundProducts(),
      // منتجات التحسينات
      ...getUpgradeProducts(),
      // العروض الخاصة
      ...getSpecialProducts(),
    ];
  }

  static List<StoreProduct> getGemProducts() {
    return [
      const StoreProduct(
        id: 'gems_100',
        name: 'حزمة البداية',
        description: '100 جوهرة للمبتدئين',
        type: ProductType.gems,
        category: StoreCategory.gems,
        price: 0.99,
        rarity: ProductRarity.common,
        iconPath: 'assets/icons/gem_small.png',
        isNew: true,
        rewards: {'gems': 100},
      ),
      const StoreProduct(
        id: 'gems_500',
        name: 'حزمة الفضة',
        description: '500 جوهرة + 20% مجاناً',
        type: ProductType.gems,
        category: StoreCategory.gems,
        price: 4.99,
        rarity: ProductRarity.rare,
        iconPath: 'assets/icons/gem_medium.png',
        isPopular: true,
        rewards: {'gems': 600},
      ),
      const StoreProduct(
        id: 'gems_1200',
        name: 'حزمة الذهب',
        description: '1200 جوهرة + 30% مجاناً',
        type: ProductType.gems,
        category: StoreCategory.gems,
        price: 9.99,
        rarity: ProductRarity.epic,
        iconPath: 'assets/icons/gem_large.png',
        rewards: {'gems': 1560},
      ),
      const StoreProduct(
        id: 'gems_2500',
        name: 'حزمة البلاتين',
        description: '2500 جوهرة + 50% مجاناً',
        type: ProductType.gems,
        category: StoreCategory.gems,
        price: 19.99,
        rarity: ProductRarity.legendary,
        iconPath: 'assets/icons/gem_mega.png',
        rewards: {'gems': 3750},
      ),
      const StoreProduct(
        id: 'gems_6000',
        name: 'الحزمة الضخمة',
        description: '6000 جوهرة + 100% مجاناً',
        type: ProductType.gems,
        category: StoreCategory.gems,
        price: 49.99,
        rarity: ProductRarity.legendary,
        iconPath: 'assets/icons/gem_ultimate.png',
        isLimited: true,
        rewards: {'gems': 12000},
      ),
    ];
  }

  static List<StoreProduct> getThemeProducts() {
    return [
      const StoreProduct(
        id: 'theme_neon',
        name: 'ثيم النيون',
        description: 'ألوان نيون زاهية وحيوية',
        type: ProductType.theme,
        category: StoreCategory.themes,
        price: 199,
        currency: 'gems',
        rarity: ProductRarity.rare,
        iconPath: 'assets/themes/neon_preview.png',
        previewPath: 'assets/themes/neon_full.png',
        metadata: {'themeId': 'neon'},
      ),
      const StoreProduct(
        id: 'theme_ocean',
        name: 'ثيم المحيط',
        description: 'ألوان زرقاء هادئة مثل المحيط',
        type: ProductType.theme,
        category: StoreCategory.themes,
        price: 249,
        currency: 'gems',
        rarity: ProductRarity.epic,
        iconPath: 'assets/themes/ocean_preview.png',
        previewPath: 'assets/themes/ocean_full.png',
        metadata: {'themeId': 'ocean'},
      ),
      const StoreProduct(
        id: 'theme_sunset',
        name: 'ثيم الغروب',
        description: 'ألوان دافئة مثل غروب الشمس',
        type: ProductType.theme,
        category: StoreCategory.themes,
        price: 299,
        currency: 'gems',
        rarity: ProductRarity.legendary,
        iconPath: 'assets/themes/sunset_preview.png',
        previewPath: 'assets/themes/sunset_full.png',
        isNew: true,
        metadata: {'themeId': 'sunset'},
      ),
      const StoreProduct(
        id: 'theme_galaxy',
        name: 'ثيم المجرة',
        description: 'ألوان كونية مع نجوم متلألئة',
        type: ProductType.theme,
        category: StoreCategory.themes,
        price: 399,
        currency: 'gems',
        rarity: ProductRarity.legendary,
        iconPath: 'assets/themes/galaxy_preview.png',
        previewPath: 'assets/themes/galaxy_full.png',
        isPopular: true,
        metadata: {'themeId': 'galaxy'},
      ),
    ];
  }

  static List<StoreProduct> getSoundProducts() {
    return [
      const StoreProduct(
        id: 'sound_classic',
        name: 'أصوات كلاسيكية',
        description: 'أصوات تقليدية مألوفة',
        type: ProductType.sound,
        category: StoreCategory.sounds,
        price: 99,
        currency: 'gems',
        rarity: ProductRarity.common,
        iconPath: 'assets/icons/sound_classic.png',
        metadata: {'soundPack': 'classic'},
      ),
      const StoreProduct(
        id: 'sound_electronic',
        name: 'أصوات إلكترونية',
        description: 'أصوات مستقبلية ومثيرة',
        type: ProductType.sound,
        category: StoreCategory.sounds,
        price: 149,
        currency: 'gems',
        rarity: ProductRarity.rare,
        iconPath: 'assets/icons/sound_electronic.png',
        isNew: true,
        metadata: {'soundPack': 'electronic'},
      ),
      const StoreProduct(
        id: 'sound_nature',
        name: 'أصوات الطبيعة',
        description: 'أصوات مهدئة من الطبيعة',
        type: ProductType.sound,
        category: StoreCategory.sounds,
        price: 199,
        currency: 'gems',
        rarity: ProductRarity.epic,
        iconPath: 'assets/icons/sound_nature.png',
        metadata: {'soundPack': 'nature'},
      ),
      const StoreProduct(
        id: 'sound_retro',
        name: 'أصوات ريترو',
        description: 'أصوات من عصر الألعاب الكلاسيكية',
        type: ProductType.sound,
        category: StoreCategory.sounds,
        price: 249,
        currency: 'gems',
        rarity: ProductRarity.legendary,
        iconPath: 'assets/icons/sound_retro.png',
        isPopular: true,
        metadata: {'soundPack': 'retro'},
      ),
    ];
  }

  static List<StoreProduct> getUpgradeProducts() {
    return [
      const StoreProduct(
        id: 'upgrade_xp_boost',
        name: 'مضاعف الخبرة',
        description: 'مضاعف خبرة x2 لمدة 24 ساعة',
        type: ProductType.upgrade,
        category: StoreCategory.upgrades,
        price: 99,
        currency: 'gems',
        rarity: ProductRarity.common,
        iconPath: 'assets/icons/xp_boost.png',
        metadata: {'boost': 'xp', 'multiplier': 2, 'duration': 24},
      ),
      const StoreProduct(
        id: 'upgrade_gem_boost',
        name: 'مضاعف الجواهر',
        description: 'مضاعف جواهر x2 لمدة 12 ساعة',
        type: ProductType.upgrade,
        category: StoreCategory.upgrades,
        price: 149,
        currency: 'gems',
        rarity: ProductRarity.rare,
        iconPath: 'assets/icons/gem_boost.png',
        isPopular: true,
        metadata: {'boost': 'gems', 'multiplier': 2, 'duration': 12},
      ),
      const StoreProduct(
        id: 'upgrade_premium',
        name: 'العضوية المميزة',
        description: 'مزايا حصرية لمدة 30 يوم',
        type: ProductType.upgrade,
        category: StoreCategory.upgrades,
        price: 4.99,
        rarity: ProductRarity.epic,
        iconPath: 'assets/icons/premium.png',
        metadata: {'type': 'premium', 'duration': 30},
      ),
      const StoreProduct(
        id: 'upgrade_ai_hints',
        name: 'مساعد الذكاء الاصطناعي',
        description: 'نصائح ذكية أثناء اللعب',
        type: ProductType.upgrade,
        category: StoreCategory.upgrades,
        price: 199,
        currency: 'gems',
        rarity: ProductRarity.legendary,
        iconPath: 'assets/icons/ai_hints.png',
        isNew: true,
        metadata: {'type': 'ai_hints'},
      ),
    ];
  }

  static List<StoreProduct> getSpecialProducts() {
    return [
      const StoreProduct(
        id: 'bundle_starter',
        name: 'حزمة المبتدئ',
        description: '500 جوهرة + ثيم + أصوات',
        type: ProductType.bundle,
        category: StoreCategory.special,
        price: 2.99,
        rarity: ProductRarity.epic,
        iconPath: 'assets/bundles/starter.png',
        isPopular: true,
        rewards: {
          'gems': 500,
          'themes': ['neon'],
          'sounds': ['classic']
        },
      ),
      const StoreProduct(
        id: 'bundle_premium',
        name: 'الحزمة المميزة',
        description: '1500 جوهرة + جميع الثيمات + أصوات',
        type: ProductType.bundle,
        category: StoreCategory.special,
        price: 9.99,
        rarity: ProductRarity.legendary,
        iconPath: 'assets/bundles/premium.png',
        isLimited: true,
        rewards: {
          'gems': 1500,
          'themes': ['neon', 'ocean', 'sunset'],
          'sounds': ['classic', 'electronic', 'nature']
        },
      ),
    ];
  }

  static List<StoreProduct> getProductsByCategory(StoreCategory category) {
    return getAllProducts()
        .where((product) => product.category == category)
        .toList();
  }

  static List<StoreProduct> getPopularProducts() {
    return getAllProducts().where((product) => product.isPopular).toList();
  }

  static List<StoreProduct> getNewProducts() {
    return getAllProducts().where((product) => product.isNew).toList();
  }

  static List<StoreProduct> getLimitedProducts() {
    return getAllProducts().where((product) => product.isLimited).toList();
  }
}

// Additional Store Models for comprehensive store system

class StoreOffer {
  final String id;
  final String name;
  final String description;
  final int originalPrice;
  final int discountedPrice;
  final double discountPercentage;
  final DateTime validUntil;
  final bool isActive;
  final String category;
  final String imageUrl;

  StoreOffer({
    required this.id,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.validUntil,
    this.isActive = true,
    this.category = 'general',
    this.imageUrl = '',
  });

  factory StoreOffer.fromJson(Map<String, dynamic> json) {
    return StoreOffer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      originalPrice: json['original_price'] ?? 0,
      discountedPrice: json['discounted_price'] ?? 0,
      discountPercentage: (json['discount_percentage'] ?? 0.0).toDouble(),
      validUntil:
          DateTime.tryParse(json['valid_until'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
      category: json['category'] ?? 'general',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'discount_percentage': discountPercentage,
      'valid_until': validUntil.toIso8601String(),
      'is_active': isActive,
      'category': category,
      'image_url': imageUrl,
    };
  }
}

class StoreTheme {
  final String id;
  final String name;
  final String description;
  final int price;
  final Map<String, dynamic> colorScheme;
  final bool isPremium;
  final bool isUnlocked;
  final String previewImageUrl;

  StoreTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.colorScheme,
    this.isPremium = false,
    this.isUnlocked = false,
    this.previewImageUrl = '',
  });

  factory StoreTheme.fromJson(Map<String, dynamic> json) {
    return StoreTheme(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      colorScheme: json['color_scheme'] ?? {},
      isPremium: json['is_premium'] ?? false,
      isUnlocked: json['is_unlocked'] ?? false,
      previewImageUrl: json['preview_image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'color_scheme': colorScheme,
      'is_premium': isPremium,
      'is_unlocked': isUnlocked,
      'preview_image_url': previewImageUrl,
    };
  }
}

class StoreSoundPack {
  final String id;
  final String name;
  final String description;
  final int price;
  final List<String> soundFiles;
  final bool isPremium;
  final bool isUnlocked;
  final String previewUrl;

  StoreSoundPack({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.soundFiles,
    this.isPremium = false,
    this.isUnlocked = false,
    this.previewUrl = '',
  });

  factory StoreSoundPack.fromJson(Map<String, dynamic> json) {
    return StoreSoundPack(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      soundFiles: List<String>.from(json['sound_files'] ?? []),
      isPremium: json['is_premium'] ?? false,
      isUnlocked: json['is_unlocked'] ?? false,
      previewUrl: json['preview_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'sound_files': soundFiles,
      'is_premium': isPremium,
      'is_unlocked': isUnlocked,
      'preview_url': previewUrl,
    };
  }
}

class StoreBoost {
  final String id;
  final String name;
  final String description;
  final int price;
  final int duration; // in hours
  final double multiplier;
  final String type; // 'xp', 'coins', 'gems'
  final bool isActive;

  StoreBoost({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.multiplier,
    required this.type,
    this.isActive = true,
  });

  factory StoreBoost.fromJson(Map<String, dynamic> json) {
    return StoreBoost(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      duration: json['duration'] ?? 24,
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      type: json['type'] ?? 'xp',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'multiplier': multiplier,
      'type': type,
      'is_active': isActive,
    };
  }
}
