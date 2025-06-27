/// نظام تعدد اللغات البسيط للتطبيق
class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // الشاشة الرئيسية
      'home': 'الرئيسية',
      'play': 'لعب',
      'friends': 'الأصدقاء',
      'stats': 'الإحصائيات',
      'store': 'المتجر',
      'settings': 'الإعدادات',

      // التسجيل والدخول
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'signup': 'إنشاء حساب',
      'guest': 'ضيف',
      'continue_as_guest': 'متابعة كضيف',
      'quick_signin': 'دخول سريع (تطوير)',

      // نمط اللعب
      'single_player': 'لاعب واحد',
      'multiplayer': 'متعدد اللاعبين',
      'online_game': 'لعبة أونلاين',
      'ai_game': 'لعب ضد الذكي الاصطناعي',

      // الإحصائيات
      'wins': 'انتصارات',
      'losses': 'هزائم',
      'draws': 'تعادل',
      'total_games': 'إجمالي الألعاب',
      'win_rate': 'معدل الفوز',
      'level': 'المستوى',
      'experience': 'الخبرة',
      'gems': 'الجواهر',

      // الأصدقاء
      'search_friends': 'البحث عن أصدقاء',
      'add_friend': 'إضافة صديق',
      'friend_requests': 'طلبات الصداقة',
      'online_friends': 'الأصدقاء المتاحون',
      'invite_friend': 'دعوة صديق',

      // الرسائل
      'success': 'نجح',
      'error': 'خطأ',
      'loading': 'جاري التحميل...',
      'no_data': 'لا توجد بيانات',
      'try_again': 'حاول مرة أخرى',

      // العامة
      'yes': 'نعم',
      'no': 'لا',
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'search': 'بحث',
      'filter': 'تصفية',
      'sort': 'ترتيب',

      // الإعدادات
      'language': 'اللغة',
      'sound': 'الأصوات',
      'vibration': 'الاهتزاز',
      'notifications': 'الإشعارات',
      'privacy': 'الخصوصية',
      'about': 'حول التطبيق',

      // أوضاع اللعب
      'easy_mode': 'سهل',
      'medium_mode': 'متوسط',
      'hard_mode': 'صعب',
      'expert_mode': 'خبير',
    },
    'en': {
      // الشاشة الرئيسية
      'home': 'Home',
      'play': 'Play',
      'friends': 'Friends',
      'stats': 'Statistics',
      'store': 'Store',
      'settings': 'Settings',

      // التسجيل والدخول
      'login': 'Login',
      'logout': 'Logout',
      'signup': 'Sign Up',
      'guest': 'Guest',
      'continue_as_guest': 'Continue as Guest',
      'quick_signin': 'Quick Sign In (Dev)',

      // نمط اللعب
      'single_player': 'Single Player',
      'multiplayer': 'Multiplayer',
      'online_game': 'Online Game',
      'ai_game': 'Play vs AI',

      // الإحصائيات
      'wins': 'Wins',
      'losses': 'Losses',
      'draws': 'Draws',
      'total_games': 'Total Games',
      'win_rate': 'Win Rate',
      'level': 'Level',
      'experience': 'Experience',
      'gems': 'Gems',

      // الأصدقاء
      'search_friends': 'Search Friends',
      'add_friend': 'Add Friend',
      'friend_requests': 'Friend Requests',
      'online_friends': 'Online Friends',
      'invite_friend': 'Invite Friend',

      // الرسائل
      'success': 'Success',
      'error': 'Error',
      'loading': 'Loading...',
      'no_data': 'No Data',
      'try_again': 'Try Again',

      // العامة
      'yes': 'Yes',
      'no': 'No',
      'cancel': 'Cancel',
      'ok': 'OK',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',

      // الإعدادات
      'language': 'Language',
      'sound': 'Sound',
      'vibration': 'Vibration',
      'notifications': 'Notifications',
      'privacy': 'Privacy',
      'about': 'About App',

      // أوضاع اللعب
      'easy_mode': 'Easy',
      'medium_mode': 'Medium',
      'hard_mode': 'Hard',
      'expert_mode': 'Expert',
    },
  };

  static String _currentLanguage = 'ar';
  static String get currentLanguage => _currentLanguage;

  /// تغيير اللغة
  static void setLanguage(String languageCode) {
    if (_localizedValues.containsKey(languageCode)) {
      _currentLanguage = languageCode;
    }
  }

  /// الحصول على نص مترجم
  static String tr(String key, {String? defaultValue}) {
    final languageMap = _localizedValues[_currentLanguage];
    if (languageMap != null && languageMap.containsKey(key)) {
      return languageMap[key]!;
    }

    // البحث في اللغة الافتراضية (العربية) إذا لم توجد في اللغة الحالية
    final defaultMap = _localizedValues['ar'];
    if (defaultMap != null && defaultMap.containsKey(key)) {
      return defaultMap[key]!;
    }

    return defaultValue ?? key;
  }

  /// الحصول على قائمة اللغات المتاحة
  static List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    ];
  }

  /// فحص إذا كانت اللغة من اليمين إلى اليسار
  static bool isRTL() {
    return _currentLanguage == 'ar';
  }
}

/// اختصار للحصول على النص المترجم
String tr(String key, {String? defaultValue}) {
  return AppLocalizations.tr(key, defaultValue: defaultValue);
}
