import 'package:flutter/material.dart';
import '../models/gems_models.dart';
import '../models/store_models.dart';
import '../services/unified_auth_services.dart';
import '../utils/app_theme_new.dart';

class StellarComprehensiveStoreScreen extends StatefulWidget {
  const StellarComprehensiveStoreScreen({super.key});

  @override
  State<StellarComprehensiveStoreScreen> createState() =>
      _StellarComprehensiveStoreScreenState();
}

class _StellarComprehensiveStoreScreenState
    extends State<StellarComprehensiveStoreScreen>
    with TickerProviderStateMixin {
  final FirebaseAuthService _authService = FirebaseAuthService();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _fadeAnimation;

  // بيانات المتجر
  List<GemsPackage> _gemsPackages = [];
  List<StoreTheme> _availableThemes = [];
  List<StoreSoundPack> _availableSounds = [];
  List<StoreBoost> _availableBoosts = [];
  List<StoreOffer> _availableOffers = [];

  UserGems? _userGems;
  bool _isLoading = true;
  String _selectedCategory = 'gems'; // gems, themes, sounds, boosts, offers

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'gems',
      'title': 'الجواهر النجمية',
      'icon': Icons.diamond,
      'gradient': AppColors.stellarGradient,
    },
    {
      'id': 'themes',
      'title': 'الثيمات الكونية',
      'icon': Icons.palette,
      'gradient': const LinearGradient(
        colors: [AppColors.galaxyBlue, AppColors.nebulaPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'id': 'sounds',
      'title': 'مكتبة الأصوات',
      'icon': Icons.music_note,
      'gradient': const LinearGradient(
        colors: [AppColors.planetGreen, AppColors.cosmicTeal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'id': 'boosts',
      'title': 'التحسينات القوية',
      'icon': Icons.flash_on,
      'gradient': const LinearGradient(
        colors: [AppColors.stellarOrange, AppColors.warningDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
    {
      'id': 'offers',
      'title': 'العروض المحدودة',
      'icon': Icons.local_offer,
      'gradient': const LinearGradient(
        colors: [AppColors.starGold, AppColors.stellarOrange],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      // تحميل بيانات المستخدم
      final user = _authService.currentUserModel;
      if (user != null) {
        _userGems = UserGems(
          userId: user.id,
          currentGems: user.gems,
          totalEarned: user.gems,
          totalSpent: 0,
          lastUpdated: DateTime.now(),
        );
      }

      // تحميل البيانات من الخدمات
      await Future.wait([_loadGemsPackages()]);
    } catch (e) {
      debugPrint('Error initializing store data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadGemsPackages() async {
    // Temporary mock data for gems
    _gemsPackages = [
      GemsPackage(
        id: 'starter_gems',
        name: 'حزمة البداية النجمية',
        description: 'ابدأ رحلتك بهذه الحزمة الأساسية',
        gemsAmount: 100,
        price: 0.99,
        currency: 'USD',
        discount: 0,
        isPopular: false,
      ),
      GemsPackage(
        id: 'cosmic_gems',
        name: 'حزمة الكون الرائعة',
        description: 'احصل على جواهر أكثر مع مكافآت إضافية',
        gemsAmount: 500,
        price: 4.99,
        currency: 'USD',
        discount: 10,
        isPopular: true,
      ),
    ];

    // Mock data for themes
    _availableThemes = [
      StoreTheme(
        id: 'dark_theme',
        name: 'الثيم المظلم',
        description: 'ثيم أنيق بألوان داكنة',
        price: 50,
        colorScheme: {
          'primary': '0xFF1F2937',
          'secondary': '0xFF374151',
          'background': '0xFF111827',
        },
        isUnlocked: false,
      ),
      StoreTheme(
        id: 'gold_theme',
        name: 'الثيم الذهبي',
        description: 'ثيم فاخر بألوان ذهبية',
        price: 100,
        colorScheme: {
          'primary': '0xFFFFD700',
          'secondary': '0xFFFFA500',
          'background': '0xFFFFF8DC',
        },
        isPremium: true,
        isUnlocked: false,
      ),
      StoreTheme(
        id: 'neon_theme',
        name: 'ثيم النيون',
        description: 'ثيم مشرق بألوان النيون',
        price: 75,
        colorScheme: {
          'primary': '0xFF00FF87',
          'secondary': '0xFF00D9FF',
          'background': '0xFF0D1117',
        },
        isUnlocked: false,
      ),
    ];

    // Mock data for sound packs
    _availableSounds = [
      StoreSoundPack(
        id: 'classic_sounds',
        name: 'الأصوات الكلاسيكية',
        description: 'أصوات تقليدية ومألوفة',
        price: 30,
        soundFiles: ['click.mp3', 'win.mp3', 'lose.mp3'],
        isUnlocked: true,
      ),
      StoreSoundPack(
        id: 'space_sounds',
        name: 'أصوات الفضاء',
        description: 'أصوات فضائية مستقبلية',
        price: 50,
        soundFiles: ['space_click.mp3', 'victory.mp3', 'defeat.mp3'],
        isPremium: true,
        isUnlocked: false,
      ),
      StoreSoundPack(
        id: 'nature_sounds',
        name: 'أصوات الطبيعة',
        description: 'أصوات الطبيعة المهدئة',
        price: 40,
        soundFiles: ['water_drop.mp3', 'bird_song.mp3', 'wind.mp3'],
        isUnlocked: false,
      ),
    ];

    // Mock data for boosts
    _availableBoosts = [
      StoreBoost(
        id: 'xp_boost',
        name: 'مضاعف الخبرة',
        description: 'احصل على ضعف نقاط الخبرة',
        price: 25,
        duration: 24,
        multiplier: 2.0,
        type: 'xp',
      ),
      StoreBoost(
        id: 'gem_boost',
        name: 'مضاعف الجواهر',
        description: 'احصل على جواهر إضافية من الانتصارات',
        price: 40,
        duration: 12,
        multiplier: 1.5,
        type: 'gems',
      ),
      StoreBoost(
        id: 'coin_boost',
        name: 'مضاعف العملات',
        description: 'احصل على عملات إضافية',
        price: 20,
        duration: 48,
        multiplier: 3.0,
        type: 'coins',
      ),
    ];

    // Mock data for special offers
    _availableOffers = [
      StoreOffer(
        id: 'weekend_special',
        name: 'عرض نهاية الأسبوع',
        description: 'خصم خاص على جميع حزم الجواهر',
        originalPrice: 100,
        discountedPrice: 70,
        discountPercentage: 30.0,
        validUntil: DateTime.now().add(Duration(days: 2)),
        category: 'gems',
      ),
      StoreOffer(
        id: 'theme_bundle',
        name: 'حزمة الثيمات الكاملة',
        description: 'احصل على جميع الثيمات بسعر مخفض',
        originalPrice: 300,
        discountedPrice: 200,
        discountPercentage: 33.3,
        validUntil: DateTime.now().add(Duration(days: 7)),
        category: 'themes',
      ),
      StoreOffer(
        id: 'starter_pack',
        name: 'حزمة المبتدئين',
        description: 'كل ما تحتاجه للبداية بسعر رائع',
        originalPrice: 150,
        discountedPrice: 99,
        discountPercentage: 34.0,
        validUntil: DateTime.now().add(Duration(days: 30)),
        category: 'bundle',
      ),
    ];
  }

  // دوال بناء الكروت
  Widget _buildThemeCard(StoreTheme theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        gradient: LinearGradient(
          colors: [
            Color(
              int.parse(theme.colorScheme['primary'].replaceFirst('#', '0xFF')),
            ),
            Color(
              int.parse(
                theme.colorScheme['secondary'].replaceFirst('#', '0xFF'),
              ),
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with premium badge
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Row(
              children: [
                if (theme.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'مميز',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                Icon(
                  theme.isUnlocked ? Icons.check_circle : Icons.lock,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),

          // Theme preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMD,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.palette, color: Colors.white, size: 40),
            ),
          ),

          // Theme info
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  theme.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.diamond, color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${theme.price}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: theme.isUnlocked
                          ? null
                          : () => _purchaseTheme(theme),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.isUnlocked
                            ? Colors.grey
                            : AppColors.accent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        theme.isUnlocked ? 'مملوك' : 'شراء',
                        style: AppTextStyles.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundPackCard(StoreSoundPack soundPack) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.music_note,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soundPack.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${soundPack.soundFiles.length} أصوات',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (soundPack.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'مميز',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            soundPack.description,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              IconButton(
                onPressed: () => _previewSound(soundPack),
                icon: const Icon(Icons.play_arrow),
                color: AppColors.primary,
                tooltip: 'تجربة الصوت',
              ),
              const Spacer(),
              Icon(Icons.diamond, color: AppColors.accent, size: 16),
              const SizedBox(width: 4),
              Text(
                '${soundPack.price}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: soundPack.isUnlocked
                    ? null
                    : () => _purchaseSoundPack(soundPack),
                style: ElevatedButton.styleFrom(
                  backgroundColor: soundPack.isUnlocked
                      ? Colors.grey
                      : AppColors.primary,
                ),
                child: Text(
                  soundPack.isUnlocked ? 'مملوك' : 'شراء',
                  style: AppTextStyles.labelSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoostCard(StoreBoost boost) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getBoostIcon(boost.type),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      boost.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '×${boost.multiplier}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  boost.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${boost.duration} ساعة',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.diamond, color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${boost.price}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _purchaseBoost(boost),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'تفعيل',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(StoreOffer offer) {
    final timeLeft = offer.validUntil.difference(DateTime.now());
    final isExpired = timeLeft.isNegative;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.8),
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Discount badge
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '-${offer.discountPercentage.round()}%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  offer.name,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),

                // Price section
                Row(
                  children: [
                    Text(
                      '${offer.originalPrice}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.diamond, color: AppColors.starGold, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${offer.discountedPrice}',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.starGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (!isExpired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.schedule, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimeLeft(timeLeft),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isExpired ? null : () => _purchaseOffer(offer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpired ? Colors.grey : Colors.white,
                      foregroundColor: isExpired
                          ? Colors.white
                          : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      isExpired ? 'انتهى العرض' : 'شراء العرض',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // دوال مساعدة
  IconData _getBoostIcon(String type) {
    switch (type) {
      case 'xp':
        return Icons.trending_up;
      case 'gems':
        return Icons.diamond;
      case 'luck':
        return Icons.auto_awesome;
      default:
        return Icons.flash_on;
    }
  }

  String _formatTimeLeft(Duration timeLeft) {
    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays}د ${timeLeft.inHours % 24}س';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}س ${timeLeft.inMinutes % 60}د';
    } else {
      return '${timeLeft.inMinutes}د';
    }
  }

  // دوال الشراء
  void _purchaseTheme(StoreTheme theme) {
    // تطبيق شراء الثيم
    _showPurchaseDialog('ثيم', theme.name, theme.price);
  }

  void _purchaseSoundPack(StoreSoundPack soundPack) {
    // تطبيق شراء حزمة الأصوات
    _showPurchaseDialog('حزمة أصوات', soundPack.name, soundPack.price);
  }

  void _purchaseBoost(StoreBoost boost) {
    // تطبيق شراء التحسين
    _showPurchaseDialog('تحسين', boost.name, boost.price);
  }

  void _purchaseOffer(StoreOffer offer) {
    // تطبيق شراء العرض
    _showPurchaseDialog('عرض خاص', offer.name, offer.discountedPrice);
  }

  void _previewSound(StoreSoundPack soundPack) {
    // تشغيل معاينة الصوت
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تشغيل معاينة: ${soundPack.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showPurchaseDialog(String type, String name, int price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الشراء'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل تريد شراء $type التالي؟'),
              const SizedBox(height: 8),
              Text(
                name,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.diamond, color: AppColors.accent, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$price جوهرة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processPurchase(type, name, price);
              },
              child: const Text('شراء'),
            ),
          ],
        );
      },
    );
  }

  void _processPurchase(String type, String name, int price) {
    // معالجة الشراء
    if (_userGems != null && _userGems!.currentGems >= price) {
      setState(() {
        _userGems = _userGems!.copyWith(
          currentGems: _userGems!.currentGems - price,
          totalSpent: _userGems!.totalSpent + price,
          lastUpdated: DateTime.now(),
        );
      });

      _showSuccessMessage('تم شراء $name بنجاح!');
    } else {
      _showErrorMessage('لا تملك جواهر كافية لهذا الشراء');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.starfieldGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildUserGems(),
                _buildCategoryTabs(),
                Expanded(child: _buildStoreContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: AppDimensions.iconLG,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppDimensions.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'متجر النجوم الكوني',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'اكتشف كنوز المجرة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGems() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLG,
            ),
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            decoration: BoxDecoration(
              gradient: AppColors.stellarGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: [
                BoxShadow(
                  color: AppColors.starGold.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.diamond,
                  color: AppColors.textPrimary,
                  size: AppDimensions.iconLG,
                ),
                const SizedBox(width: AppDimensions.paddingMD),
                Text(
                  '${_userGems?.currentGems ?? 0}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingSM),
                Text(
                  'جوهرة نجمية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingLG),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category['id'];

          return GestureDetector(
            onTap: () => _selectCategory(category['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: AppDimensions.paddingMD),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLG,
                vertical: AppDimensions.paddingMD,
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? category['gradient'] : null,
                color: isSelected
                    ? null
                    : AppColors.surfacePrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : AppColors.borderPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    size: AppDimensions.iconMD,
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    category['title'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.starGold),
        ),
      );
    }

    return _getContentForCategory();
  }

  Widget _getContentForCategory() {
    switch (_selectedCategory) {
      case 'gems':
        return _buildGemsContent();
      case 'themes':
        return _buildThemesContent();
      case 'sounds':
        return _buildSoundsContent();
      case 'boosts':
        return _buildBoostsContent();
      case 'offers':
        return _buildOffersContent();
      default:
        return _buildGemsContent();
    }
  }

  Widget _buildGemsContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      itemCount: _gemsPackages.length,
      itemBuilder: (context, index) {
        return _buildGemsPackageCard(_gemsPackages[index]);
      },
    );
  }

  Widget _buildGemsPackageCard(GemsPackage package) {
    final isPopular = package.isPopular;
    final hasDiscount = (package.discount ?? 0) > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: isPopular
            ? AppColors.stellarGradient
            : AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [
          BoxShadow(
            color: (isPopular ? AppColors.starGold : AppColors.shadowPrimary)
                .withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          onTap: () => _purchaseGemsPackage(package),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMD),
                      decoration: BoxDecoration(
                        gradient: AppColors.cosmicButtonGradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMD,
                        ),
                      ),
                      child: const Icon(
                        Icons.diamond,
                        color: AppColors.textPrimary,
                        size: AppDimensions.iconLG,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: isPopular
                                  ? AppColors.textPrimary
                                  : AppColors.starGold,
                            ),
                          ),
                          Text(
                            package.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color:
                                  (isPopular
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary)
                                      .withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLG),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${package.gemsAmount} جوهرة',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.starGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasDiscount)
                          Text(
                            'خصم ${package.discount}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.successPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingLG,
                        vertical: AppDimensions.paddingMD,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.cosmicButtonGradient,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLG,
                        ),
                      ),
                      child: Text(
                        '\$${package.price.toStringAsFixed(2)}',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemesContent() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingMD,
        mainAxisSpacing: AppDimensions.paddingMD,
        childAspectRatio: 0.8,
      ),
      itemCount: _availableThemes.length,
      itemBuilder: (context, index) {
        final theme = _availableThemes[index];
        return _buildThemeCard(theme);
      },
    );
  }

  Widget _buildSoundsContent() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.paddingMD,
        mainAxisSpacing: AppDimensions.paddingMD,
        childAspectRatio: 1.2,
      ),
      itemCount: _availableSounds.length,
      itemBuilder: (context, index) {
        final soundPack = _availableSounds[index];
        return _buildSoundPackCard(soundPack);
      },
    );
  }

  Widget _buildBoostsContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: _availableBoosts.length,
      itemBuilder: (context, index) {
        final boost = _availableBoosts[index];
        return _buildBoostCard(boost);
      },
    );
  }

  Widget _buildOffersContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: _availableOffers.length,
      itemBuilder: (context, index) {
        final offer = _availableOffers[index];
        return _buildOfferCard(offer);
      },
    );
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
  }

  Future<void> _purchaseGemsPackage(GemsPackage package) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showPurchaseConfirmationDialog(
        package.name,
        package.price,
        package.currency,
        Icons.diamond,
      );

      if (confirmed == true) {
        // Process payment (mock for now)
        await Future.delayed(const Duration(seconds: 2));

        // Update user gems
        if (_userGems != null) {
          setState(() {
            _userGems = _userGems!.copyWith(
              currentGems: _userGems!.currentGems + package.gemsAmount,
              totalEarned: _userGems!.totalEarned + package.gemsAmount,
              lastUpdated: DateTime.now(),
            );
          });
        }

        _showSuccessMessage('تم شراء الحزمة بنجاح!');
      }
    } catch (e) {
      _showErrorMessage('حدث خطأ أثناء الشراء');
    }
  }

  Future<bool?> _showPurchaseConfirmationDialog(
    String title,
    double price,
    String currency,
    IconData icon,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: Row(
          children: [
            Icon(icon, color: AppColors.starGold),
            const SizedBox(width: 8),
            Text(
              'تأكيد الشراء',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'هل تريد شراء $title مقابل \$${price.toStringAsFixed(2)}؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.starGold,
            ),
            child: Text('شراء', style: TextStyle(color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successPrimary,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
