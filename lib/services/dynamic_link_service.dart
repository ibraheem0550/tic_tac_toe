/// خدمة الروابط الديناميكية للمشاركة والدعوات
/// تمكن من إنشاء روابط قابلة للمشاركة تفتح التطبيق مع محتوى محدد

class DynamicLinkService {
  static const String domain = 'tictactoe.page.link';

  /// إنشاء رابط ديناميكي لدعوة صديق
  static Future<String> createInviteLink({
    String? playerName,
    String? gameMode,
  }) async {
    // في التطبيق الحقيقي، سيتم استخدام Firebase Dynamic Links
    // هنا مثال مبسط

    String link = 'https://$domain/invite';

    final params = <String, String>{};
    if (playerName != null) params['player'] = playerName;
    if (gameMode != null) params['mode'] = gameMode;

    if (params.isNotEmpty) {
      final queryString =
          params.entries.map((e) => '${e.key}=${e.value}').join('&');
      link += '?$queryString';
    }

    return link;
  }

  /// إنشاء رابط للمشاركة على وسائل التواصل
  static Future<String> createShareLink({
    required String type,
    String? title,
    String? description,
  }) async {
    String link = 'https://$domain/share';

    final params = <String, String>{
      'type': type,
    };

    if (title != null) params['title'] = title;
    if (description != null) params['desc'] = description;

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$link?$queryString';
  }

  /// معالجة الرابط الديناميكي عند فتح التطبيق
  static void handleDynamicLink(String link) {
    final uri = Uri.parse(link);

    if (uri.host == domain) {
      final path = uri.path;
      final params = uri.queryParameters;

      switch (path) {
        case '/invite':
          _handleInvite(params);
          break;
        case '/share':
          _handleShare(params);
          break;
        default:
          _handleDefault();
          break;
      }
    }
  }

  /// معالجة دعوة اللعب
  static void _handleInvite(Map<String, String> params) {
    final playerName = params['player'];
    final gameMode = params['mode'];

    // إظهار شاشة قبول الدعوة
    print('دعوة من $playerName للعب في وضع $gameMode');
  }

  /// معالجة المشاركة
  static void _handleShare(Map<String, String> params) {
    final type = params['type'];
    final title = params['title'];

    // التنقل إلى المحتوى المشارك
    print('مشاركة: $title من نوع $type');
  }

  /// معالجة افتراضية
  static void _handleDefault() {
    // فتح الشاشة الرئيسية
    print('فتح الشاشة الرئيسية');
  }
}
