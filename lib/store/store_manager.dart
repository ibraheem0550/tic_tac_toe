import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'coins_notifier.dart';

enum PurchaseResult { success, alreadyOwned, insufficientFunds, failed }

class StoreManager {
  static final _prefs = SharedPreferences.getInstance();
  static const String _coinsKey = 'coins';
  static const String _ownedItemsKey = 'owned_items';
  static const String _activeThemeKey = 'active_theme';

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_ownedItemsKey)) {
      await prefs.setStringList(_ownedItemsKey, []);
    }
    if (!prefs.containsKey(_activeThemeKey)) {
      await prefs.setString(_activeThemeKey, 'classic');
    }
    if (!prefs.containsKey(_coinsKey)) {
      await prefs.setInt(_coinsKey, 100); // Start with 100 coins
    }
  }

  static Future<int> getCoins() async {
    final prefs = await _prefs;
    return prefs.getInt(_coinsKey) ?? 100; // Start with 100 coins
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await _prefs;
    final currentCoins = await getCoins();
    await prefs.setInt(_coinsKey, currentCoins + amount);
    coinsChangeNotifier.notifyCoinsChanged();
  }

  static Future<void> decreaseCoins(int amount) async {
    final prefs = await _prefs;
    final currentCoins = await getCoins();
    await prefs.setInt(
        _coinsKey, (currentCoins - amount).clamp(0, double.infinity).toInt());
    coinsChangeNotifier.notifyCoinsChanged();
  }

  static Future<List<String>> getOwnedItems() async {
    final prefs = await _prefs;
    return prefs.getStringList(_ownedItemsKey) ?? [];
  }

  static Future<bool> isItemOwned(String itemId) async {
    final ownedItems = await getOwnedItems();
    return ownedItems.contains(itemId);
  }

  static Future<void> setActiveTheme(String themeId) async {
    final prefs = await _prefs;
    await prefs.setString(_activeThemeKey, themeId);
  }

  static Future<String> getActiveTheme() async {
    final prefs = await _prefs;
    return prefs.getString(_activeThemeKey) ?? 'classic';
  }

  static Future<PurchaseResult> purchaseItem(String itemId, int cost) async {
    final prefs = await _prefs;

    if (await isItemOwned(itemId)) {
      return PurchaseResult.alreadyOwned;
    }

    final currentCoins = await getCoins();
    if (currentCoins < cost) {
      return PurchaseResult.insufficientFunds;
    }

    try {
      // Deduct coins
      await prefs.setInt(_coinsKey, currentCoins - cost);
      coinsChangeNotifier.notifyCoinsChanged();

      // Add to owned items
      final ownedItems = await getOwnedItems();
      ownedItems.add(itemId);
      await prefs.setStringList(_ownedItemsKey, ownedItems);

      // If it's a theme, set it as active
      if (itemId.startsWith('theme_')) {
        await setActiveTheme(itemId);
      }

      return PurchaseResult.success;
    } catch (e) {
      return PurchaseResult.failed;
    }
  }

  static ThemeData getThemeData(String? themeId) {
    switch (themeId) {
      case 'theme_gold':
        return ThemeData(
          primaryColor: Colors.amber,
          colorScheme: ColorScheme.dark(
            primary: Colors.amber,
            secondary: Colors.amberAccent.shade200,
            surface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.black,
        );
      case 'theme_neon':
        return ThemeData(
          primaryColor: Colors.pink,
          colorScheme: ColorScheme.dark(
            primary: Colors.pink,
            secondary: Colors.pinkAccent.shade200,
            surface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.black,
        );
      default:
        return ThemeData(
          primaryColor: Colors.deepPurple,
          colorScheme: ColorScheme.dark(
            primary: Colors.deepPurple,
            secondary: Colors.deepPurpleAccent,
            surface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.black,
        );
    }
  }
}
