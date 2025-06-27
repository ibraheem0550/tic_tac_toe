class Currency {
  static const String coins = 'coins';
  static const String gems = 'gems';
}

class CurrencyType {
  final String id;
  final String name;
  final String icon;
  final bool isPremium;

  const CurrencyType({
    required this.id,
    required this.name,
    required this.icon,
    required this.isPremium,
  });

  static const coins = CurrencyType(
    id: Currency.coins,
    name: 'عملات ذهبية',
    icon: '🪙',
    isPremium: false,
  );

  static const gems = CurrencyType(
    id: Currency.gems,
    name: 'جواهر',
    icon: '💎',
    isPremium: true,
  );

  static List<CurrencyType> get all => [coins, gems];
}

class GemsPackage {
  final String id;
  final int amount;
  final double price;
  final String currency;
  final int bonusPercentage;
  final bool isPopular;

  const GemsPackage({
    required this.id,
    required this.amount,
    required this.price,
    required this.currency,
    this.bonusPercentage = 0,
    this.isPopular = false,
  });

  static const packages = [
    GemsPackage(
      id: 'gems_100',
      amount: 100,
      price: 0.99,
      currency: 'USD',
    ),
    GemsPackage(
      id: 'gems_500',
      amount: 500,
      price: 4.99,
      currency: 'USD',
      bonusPercentage: 10,
    ),
    GemsPackage(
      id: 'gems_1000',
      amount: 1000,
      price: 9.99,
      currency: 'USD',
      bonusPercentage: 15,
      isPopular: true,
    ),
    GemsPackage(
      id: 'gems_2500',
      amount: 2500,
      price: 19.99,
      currency: 'USD',
      bonusPercentage: 25,
    ),
    GemsPackage(
      id: 'gems_5000',
      amount: 5000,
      price: 39.99,
      currency: 'USD',
      bonusPercentage: 30,
    ),
  ];
}
