import 'package:shared_preferences/shared_preferences.dart';

class AILevelManager {
  static const String _key = 'unlocked_level';

  /// يرجع المستوى المفتوح حالياً (الأعلى)
  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 1; // أول مستوى مفتوح دائماً هو 1
  }

  /// يفتح مستوى جديد إن لم يكن مفتوحاً
  static Future<void> unlockLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    int currentLevel = prefs.getInt(_key) ?? 1;
    if (level > currentLevel) {
      await prefs.setInt(_key, level);
    }
  }

  /// يعيد قائمة بكل المستويات المفتوحة (من 1 حتى المستوى الأعلى المفتوح)
  static Future<List<int>> getUnlockedLevels() async {
    int currentLevel = await getUnlockedLevel();
    return List<int>.generate(currentLevel, (index) => index + 1);
  }

  /// يتحقق إذا كان المستوى المحدد مفتوحًا أم لا
  static Future<bool> isLevelUnlocked(int level) async {
    int currentLevel = await getUnlockedLevel();
    return level <= currentLevel;
  }
}
