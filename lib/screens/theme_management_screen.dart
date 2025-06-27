import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/products_update_manager.dart';
import '../services/theme_service.dart';
import 'theme_editor_screen.dart';

class ThemeManagementScreen extends StatefulWidget {
  const ThemeManagementScreen({super.key});

  @override
  State<ThemeManagementScreen> createState() => _ThemeManagementScreenState();
}

class _ThemeManagementScreenState extends State<ThemeManagementScreen> {
  final ProductsUpdateManager _productsManager = ProductsUpdateManager();
  bool _isLoading = false;
  List<Product> _themes = [];

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() => _isLoading = true);
    await _productsManager.loadLocalProducts();
    await _productsManager.checkForUpdates();

    _themes = _productsManager.products
        .where((product) => product.category == ProductCategory.themes)
        .toList();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 إدارة السمات'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemeEditorScreen(),
                ),
              );
              if (result == true) {
                _loadThemes(); // إعادة تحميل السمات بعد إضافة سمة جديدة
              }
            },
            icon: const Icon(Icons.add),
            tooltip: 'إنشاء سمة جديدة',
          ),
          IconButton(
            onPressed: _loadThemes,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildThemesList(),
    );
  }

  Widget _buildThemesList() {
    if (_themes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 100,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد سمات متاحة',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ابدأ بإنشاء سمة جديدة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeEditorScreen(),
                  ),
                );
                if (result == true) {
                  _loadThemes();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('إنشاء سمة جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final theme = _themes[index];
        return _buildThemeCard(theme);
      },
    );
  }

  Widget _buildThemeCard(Product theme) {
    // استخراج الألوان من metadata
    final metadata = theme.metadata;
    final primaryColor =
        Color(metadata['primaryColor'] ?? Colors.deepPurple.value);
    final secondaryColor =
        Color(metadata['secondaryColor'] ?? Colors.teal.value);
    final accentColor =
        Color(metadata['accentColor'] ?? Colors.amberAccent.value);
    final gradientStart =
        Color(metadata['gradientStart'] ?? Colors.grey.shade900.value);
    final gradientEnd =
        Color(metadata['gradientEnd'] ?? Colors.grey.shade900.value);
    final gameXColor =
        Color(metadata['gameXColor'] ?? Colors.blue.shade400.value);
    final gameOColor =
        Color(metadata['gameOColor'] ?? Colors.red.shade400.value);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // معاينة السمة المحسّنة
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [gradientStart, gradientEnd],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // عرض ألوان اللعبة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: gameXColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Center(
                                child: Text(
                                  'X',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: gameOColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Center(
                                child: Text(
                                  'O',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: accentColor, width: 1),
                          ),
                          child: Text(
                            'سمة متطورة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // مؤشر نشاط السمة
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.isActive ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        theme.isActive ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // معلومات السمة
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${theme.price} عملة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // أزرار الإجراءات
                  Row(
                    children: [
                      // عرض الألوان الرئيسية
                      Row(
                        children: [
                          _buildColorDot(primaryColor),
                          const SizedBox(width: 4),
                          _buildColorDot(secondaryColor),
                          const SizedBox(width: 4),
                          _buildColorDot(accentColor),
                        ],
                      ),
                      const Spacer(),
                      // أزرار التحكم
                      IconButton(
                        onPressed: () => _previewTheme(theme),
                        icon: const Icon(Icons.visibility),
                        iconSize: 20,
                        tooltip: 'معاينة',
                      ),
                      IconButton(
                        onPressed: () => _editTheme(theme),
                        icon: const Icon(Icons.edit),
                        iconSize: 20,
                        tooltip: 'تعديل',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  void _previewTheme(Product theme) {
    // تطبيق السمة مؤقتاً وعرض معاينة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildThemePreview(theme),
      ),
    );
  }

  Widget _buildThemePreview(Product theme) {
    final metadata = theme.metadata;
    final primaryColor =
        Color(metadata['primaryColor'] ?? Colors.deepPurple.value);
    final backgroundColor =
        Color(metadata['backgroundColor'] ?? Colors.grey.shade900.value);
    final titleTextColor =
        Color(metadata['titleTextColor'] ?? Colors.yellow.value);
    final primaryTextColor =
        Color(metadata['primaryTextColor'] ?? Colors.white.value);
    final gradientStart =
        Color(metadata['gradientStart'] ?? Colors.grey.shade900.value);
    final gradientMiddle =
        Color(metadata['gradientMiddle'] ?? Colors.deepPurple.shade900.value);
    final gradientEnd =
        Color(metadata['gradientEnd'] ?? Colors.grey.shade900.value);
    final gameXColor =
        Color(metadata['gameXColor'] ?? Colors.blue.shade400.value);
    final gameOColor =
        Color(metadata['gameOColor'] ?? Colors.red.shade400.value);
    final gameBoardColor =
        Color(metadata['gameBoardColor'] ?? Colors.grey.shade700.value);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('معاينة: ${theme.name}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradientStart, gradientMiddle, gradientEnd],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // عنوان التطبيق
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎮',
                      style: const TextStyle(fontSize: 60),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tic Tac Toe',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: titleTextColor,
                      ),
                    ),
                    Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // معاينة لعبة محسّنة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'معاينة اللعبة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleTextColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: gameBoardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryColor, width: 2),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        ),
                        itemCount: 9,
                        itemBuilder: (context, index) {
                          String symbol = '';
                          Color symbolColor = primaryTextColor;

                          if (index == 0 || index == 4 || index == 8) {
                            symbol = 'X';
                            symbolColor = gameXColor;
                          } else if (index == 2 || index == 6) {
                            symbol = 'O';
                            symbolColor = gameOColor;
                          }

                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                symbol,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: symbolColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // أزرار العودة والتطبيق
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('العودة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // تطبيق السمة على التطبيق
                        final themeService = ThemeService();
                        await themeService.applyTheme(
                            theme.metadata, theme.name);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'تم تطبيق السمة "${theme.name}" على التطبيق بالكامل!'),
                            backgroundColor: Colors.green,
                            action: SnackBarAction(
                              label: 'إعادة تشغيل',
                              onPressed: () {
                                // يمكن إضافة إعادة تشغيل التطبيق هنا
                              },
                            ),
                          ),
                        );

                        // العودة للشاشة السابقة لرؤية التأثير
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('تطبيق السمة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editTheme(Product theme) {
    // فتح محرر السمات مع البيانات المحملة مسبقاً
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ThemeEditorScreen(existingTheme: theme),
      ),
    ).then((result) {
      if (result == true) {
        _loadThemes();
      }
    });
  }
}
