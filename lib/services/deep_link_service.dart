/// خدمة الروابط العميقة (Deep Links)
/// تمكن التطبيق من فتح شاشات محددة من خلال روابط خارجية

class DeepLinkService {
  static const String baseUrl = 'tictactoe://';

  /// معالجة الروابط العميقة الواردة
  static void handleDeepLink(String link) {
    if (link.startsWith(baseUrl)) {
      final path = link.replaceFirst(baseUrl, '');
      _navigateToPath(path);
    }
  }

  /// التنقل إلى المسار المحدد
  static void _navigateToPath(String path) {
    switch (path) {
      case 'store':
        // الانتقال إلى المتجر
        break;
      case 'game':
        // بدء لعبة جديدة
        break;
      case 'missions':
        // فتح شاشة المهام
        break;
      default:
        // الانتقال إلى الشاشة الرئيسية
        break;
    }
  }

  /// إنشاء رابط عميق لمشاركة
  static String createShareLink(String type, [Map<String, String>? params]) {
    String link = '$baseUrl$type';
    if (params != null && params.isNotEmpty) {
      final queryString =
          params.entries.map((e) => '${e.key}=${e.value}').join('&');
      link += '?$queryString';
    }
    return link;
  }
}
