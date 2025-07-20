import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/products_api_service.dart';

class ThemeEditorScreen extends StatefulWidget {
  final Product? existingTheme;

  const ThemeEditorScreen({super.key, this.existingTheme});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // متغيرات التحكم في الألوان الأساسية
  Color _primaryColor = Colors.deepPurple;
  Color _secondaryColor = Colors.teal;
  Color _accentColor = Colors.amberAccent;
  Color _backgroundColor = Colors.grey.shade900;
  Color _surfaceColor = Colors.grey.shade800;
  Color _cardColor = const Color(0xFF424242);

  // ألوان النصوص
  Color _primaryTextColor = Colors.white;
  Color _secondaryTextColor = Colors.grey.shade300;
  Color _titleTextColor = Colors.yellow;

  // ألوان الأزرار
  Color _primaryButtonColor = Colors.deepPurple.shade500;
  Color _secondaryButtonColor = Colors.teal.shade500;
  Color _dangerButtonColor = Colors.red.shade500;
  Color _successButtonColor = Colors.green.shade500;

  // ألوان خاصة باللعبة
  Color _gameXColor = Colors.blue.shade400;
  Color _gameOColor = Colors.red.shade400;
  Color _gameBoardColor = Colors.grey.shade700;
  Color _gameWinColor = Colors.green.shade400;

  // متغيرات التحكم في التدرج
  Color _gradientStart = Colors.grey.shade900;
  Color _gradientMiddle = Colors.deepPurple.shade900;
  Color _gradientEnd = Colors.grey.shade900;

  // ألوان الحدود والظلال
  Color _borderColor = Colors.grey.shade600;
  Color _shadowColor = Colors.black54;
  Color _highlightColor = Colors.white24;

  // اسم السمة
  String _themeName = 'سمة مخصصة';
  final TextEditingController _themeNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // إذا كانت هناك سمة موجودة، قم بتحميل بياناتها
    if (widget.existingTheme != null) {
      _loadExistingTheme(widget.existingTheme!);
    }

    _themeNameController.text = _themeName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _themeNameController.dispose();
    super.dispose();
  }

  void _loadExistingTheme(Product theme) {
    final metadata = theme.metadata;

    _themeName = theme.name;
    _primaryColor = Color(
      metadata['primaryColor'] ?? Colors.deepPurple.toARGB32(),
    );
    _secondaryColor = Color(
      metadata['secondaryColor'] ?? Colors.teal.toARGB32(),
    );
    _accentColor = Color(
      metadata['accentColor'] ?? Colors.amberAccent.toARGB32(),
    );
    _backgroundColor = Color(
      metadata['backgroundColor'] ?? Colors.grey.shade900.toARGB32(),
    );
    _surfaceColor = Color(
      metadata['surfaceColor'] ?? Colors.grey.shade800.toARGB32(),
    );
    _cardColor = Color(
      metadata['cardColor'] ?? const Color(0xFF424242).toARGB32(),
    );

    _primaryTextColor = Color(
      metadata['primaryTextColor'] ?? Colors.white.toARGB32(),
    );
    _secondaryTextColor = Color(
      metadata['secondaryTextColor'] ?? Colors.grey.shade300.toARGB32(),
    );
    _titleTextColor = Color(
      metadata['titleTextColor'] ?? Colors.yellow.toARGB32(),
    );

    _primaryButtonColor = Color(
      metadata['primaryButtonColor'] ?? Colors.deepPurple.shade500.toARGB32(),
    );
    _secondaryButtonColor = Color(
      metadata['secondaryButtonColor'] ?? Colors.teal.shade500.toARGB32(),
    );
    _dangerButtonColor = Color(
      metadata['dangerButtonColor'] ?? Colors.red.shade500.toARGB32(),
    );
    _successButtonColor = Color(
      metadata['successButtonColor'] ?? Colors.green.shade500.toARGB32(),
    );

    _gameXColor = Color(
      metadata['gameXColor'] ?? Colors.blue.shade400.toARGB32(),
    );
    _gameOColor = Color(
      metadata['gameOColor'] ?? Colors.red.shade400.toARGB32(),
    );
    _gameBoardColor = Color(
      metadata['gameBoardColor'] ?? Colors.grey.shade700.toARGB32(),
    );
    _gameWinColor = Color(
      metadata['gameWinColor'] ?? Colors.green.shade400.toARGB32(),
    );

    _gradientStart = Color(
      metadata['gradientStart'] ?? Colors.grey.shade900.toARGB32(),
    );
    _gradientMiddle = Color(
      metadata['gradientMiddle'] ?? Colors.deepPurple.shade900.toARGB32(),
    );
    _gradientEnd = Color(
      metadata['gradientEnd'] ?? Colors.grey.shade900.toARGB32(),
    );

    _borderColor = Color(
      metadata['borderColor'] ?? Colors.grey.shade600.toARGB32(),
    );
    _shadowColor = Color(metadata['shadowColor'] ?? Colors.black54.toARGB32());
    _highlightColor = Color(
      metadata['highlightColor'] ?? Colors.white24.toARGB32(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildCurrentTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🎨 محرر السمات المتطور'),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveTheme,
              tooltip: 'حفظ السمة',
            ),
            IconButton(
              icon: const Icon(Icons.preview),
              onPressed: _previewTheme,
              tooltip: 'معاينة كاملة',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: _accentColor,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.palette), text: 'الألوان الأساسية'),
              Tab(icon: Icon(Icons.text_fields), text: 'ألوان النصوص'),
              Tab(icon: Icon(Icons.smart_button), text: 'ألوان الأزرار'),
              Tab(icon: Icon(Icons.games), text: 'ألوان اللعبة'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_gradientStart, _gradientMiddle, _gradientEnd],
            ),
          ),
          child: Column(
            children: [
              _buildThemeNameSection(),
              _buildQuickThemes(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicColorsTab(),
                    _buildTextColorsTab(),
                    _buildButtonColorsTab(),
                    _buildGameColorsTab(),
                  ],
                ),
              ),
              _buildPreviewSection(),
            ],
          ),
        ),
      ),
    );
  }

  ThemeData _buildCurrentTheme() {
    return ThemeData(
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _backgroundColor,
      cardColor: _cardColor,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _secondaryColor,
        tertiary: _accentColor,
        surface: _surfaceColor,
        background: _backgroundColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _primaryTextColor,
        onBackground: _primaryTextColor,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: _titleTextColor,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: _primaryTextColor,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: _primaryTextColor),
        bodyMedium: TextStyle(color: _secondaryTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryButtonColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildThemeNameSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اسم السمة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _themeNameController,
            style: TextStyle(color: _primaryTextColor),
            decoration: InputDecoration(
              hintText: 'أدخل اسم السمة...',
              hintStyle: TextStyle(color: _secondaryTextColor),
              filled: true,
              fillColor: _surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _primaryColor, width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _themeName = value.isNotEmpty ? value : 'سمة مخصصة';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBasicColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildColorSection('الألوان الأساسية', [
            _buildColorCard('اللون الأساسي', _primaryColor, (color) {
              setState(() => _primaryColor = color);
            }),
            _buildColorCard('اللون الثانوي', _secondaryColor, (color) {
              setState(() => _secondaryColor = color);
            }),
            _buildColorCard('لون التمييز', _accentColor, (color) {
              setState(() => _accentColor = color);
            }),
          ]),
          const SizedBox(height: 20),
          _buildColorSection('ألوان الخلفيات', [
            _buildColorCard('خلفية التطبيق', _backgroundColor, (color) {
              setState(() => _backgroundColor = color);
            }),
            _buildColorCard('لون السطح', _surfaceColor, (color) {
              setState(() => _surfaceColor = color);
            }),
            _buildColorCard('لون الكروت', _cardColor, (color) {
              setState(() => _cardColor = color);
            }),
          ]),
          const SizedBox(height: 20),
          _buildGradientSection(),
          const SizedBox(height: 20),
          _buildQuickThemes(),
        ],
      ),
    );
  }

  Widget _buildTextColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildColorSection('ألوان النصوص', [
            _buildColorCard('النص الأساسي', _primaryTextColor, (color) {
              setState(() => _primaryTextColor = color);
            }),
            _buildColorCard('النص الثانوي', _secondaryTextColor, (color) {
              setState(() => _secondaryTextColor = color);
            }),
            _buildColorCard('نص العناوين', _titleTextColor, (color) {
              setState(() => _titleTextColor = color);
            }),
          ]),
          const SizedBox(height: 20),
          _buildTextPreview(),
        ],
      ),
    );
  }

  Widget _buildButtonColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildColorSection('ألوان الأزرار', [
            _buildColorCard('الزر الأساسي', _primaryButtonColor, (color) {
              setState(() => _primaryButtonColor = color);
            }),
            _buildColorCard('الزر الثانوي', _secondaryButtonColor, (color) {
              setState(() => _secondaryButtonColor = color);
            }),
            _buildColorCard('زر الخطر', _dangerButtonColor, (color) {
              setState(() => _dangerButtonColor = color);
            }),
            _buildColorCard('زر النجاح', _successButtonColor, (color) {
              setState(() => _successButtonColor = color);
            }),
          ]),
          const SizedBox(height: 20),
          _buildButtonPreview(),
        ],
      ),
    );
  }

  Widget _buildGameColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildColorSection('ألوان اللعبة', [
            _buildColorCard('لاعب X', _gameXColor, (color) {
              setState(() => _gameXColor = color);
            }),
            _buildColorCard('لاعب O', _gameOColor, (color) {
              setState(() => _gameOColor = color);
            }),
            _buildColorCard('رقعة اللعب', _gameBoardColor, (color) {
              setState(() => _gameBoardColor = color);
            }),
            _buildColorCard('لون الفوز', _gameWinColor, (color) {
              setState(() => _gameWinColor = color);
            }),
          ]),
          const SizedBox(height: 20),
          _buildGamePreview(),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<Widget> colorCards) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 16),
          ...colorCards,
        ],
      ),
    );
  }

  Widget _buildColorCard(
    String name,
    Color color,
    Function(Color) onColorChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                color: _primaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showColorPicker(color, onColorChanged),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.palette,
                color: _getContrastColor(color),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تدرج الخلفية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildColorCard('بداية التدرج', _gradientStart, (color) {
            setState(() => _gradientStart = color);
          }),
          _buildColorCard('وسط التدرج', _gradientMiddle, (color) {
            setState(() => _gradientMiddle = color);
          }),
          _buildColorCard('نهاية التدرج', _gradientEnd, (color) {
            setState(() => _gradientEnd = color);
          }),
          const SizedBox(height: 16),
          Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gradientStart, _gradientMiddle, _gradientEnd],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Center(
              child: Text(
                'معاينة التدرج',
                style: TextStyle(
                  color: _getContrastColor(_gradientMiddle),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة النصوص',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'هذا عنوان رئيسي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هذا نص أساسي في التطبيق',
            style: TextStyle(fontSize: 16, color: _primaryTextColor),
          ),
          const SizedBox(height: 8),
          Text(
            'هذا نص ثانوي أو توضيحي',
            style: TextStyle(fontSize: 14, color: _secondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة الأزرار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryButtonColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('أساسي'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _secondaryButtonColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('ثانوي'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _successButtonColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('نجاح'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dangerButtonColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('خطر'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة اللعبة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: _gameBoardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _borderColor),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  String symbol = '';
                  Color symbolColor = _primaryTextColor;

                  if (index == 0 || index == 4 || index == 8) {
                    symbol = 'X';
                    symbolColor = _gameXColor;
                  } else if (index == 2 || index == 6) {
                    symbol = 'O';
                    symbolColor = _gameOColor;
                  }

                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: symbolColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'السمة: $_themeName',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _titleTextColor,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _previewTheme,
            icon: const Icon(Icons.preview, size: 20),
            label: const Text('معاينة كاملة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryButtonColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickThemes() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سمات جاهزة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _titleTextColor,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: [
              _buildQuickThemeCard(
                'الليل الأرجواني',
                Colors.deepPurple,
                Colors.purple.shade900,
                Colors.amberAccent,
              ),
              _buildQuickThemeCard(
                'المحيط الأزرق',
                Colors.blue,
                Colors.lightBlue.shade800,
                Colors.cyan,
              ),
              _buildQuickThemeCard(
                'الغابة الخضراء',
                Colors.green,
                Colors.teal.shade800,
                Colors.lightGreen,
              ),
              _buildQuickThemeCard(
                'الغروب البرتقالي',
                Colors.orange,
                Colors.deepOrange.shade800,
                Colors.yellow,
              ),
              _buildQuickThemeCard(
                'الياقوت الأحمر',
                Colors.red,
                Colors.pink.shade800,
                Colors.pinkAccent,
              ),
              _buildQuickThemeCard(
                'الأناقة الذهبية',
                Colors.amber,
                Colors.yellow.shade800,
                Colors.yellowAccent,
              ),
              _buildQuickThemeCard(
                'اللافندر الناعم',
                Colors.purple.shade300,
                Colors.purple.shade100,
                Colors.deepPurple,
              ),
              _buildQuickThemeCard(
                'النعناع البارد',
                Colors.teal.shade300,
                Colors.cyan.shade100,
                Colors.green,
              ),
              _buildQuickThemeCard(
                'الرمادي الأنيق',
                Colors.blueGrey,
                Colors.grey.shade700,
                Colors.lightBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickThemeCard(
    String name,
    Color primary,
    Color background,
    Color accent,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _primaryColor = primary;
          _backgroundColor = background;
          _accentColor = accent;
          _secondaryColor = primary.withValues(alpha: 0.7);
          _gradientStart = background;
          _gradientMiddle = primary.withValues(alpha: 0.3);
          _gradientEnd = background;
          _primaryButtonColor = primary;
          _secondaryButtonColor = accent;
          _gameXColor = primary;
          _gameOColor = accent;
          _themeName = name;
          _themeNameController.text = name;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [background, primary.withValues(alpha: 0.3), background],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primary, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getContrastColor(background),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('اختر اللون', style: TextStyle(color: _titleTextColor)),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  void _saveTheme() async {
    if (_themeName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال اسم للسمة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // إنشاء منتج جديد للسمة مع جميع الألوان
      final themeProduct = Product(
        id:
            widget.existingTheme?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _themeName,
        description: 'سمة مخصصة مع ألوان وتدرجات مميزة لجميع عناصر التطبيق',
        price: 100,
        category: ProductCategory.themes,
        imageUrl: 'assets/images/theme_preview.png',
        createdAt: widget.existingTheme?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          // الألوان الأساسية
          'primaryColor': _primaryColor.toARGB32(),
          'secondaryColor': _secondaryColor.toARGB32(),
          'accentColor': _accentColor.toARGB32(),
          'backgroundColor': _backgroundColor.toARGB32(),
          'surfaceColor': _surfaceColor.toARGB32(),
          'cardColor': _cardColor.toARGB32(),

          // ألوان النصوص
          'primaryTextColor': _primaryTextColor.toARGB32(),
          'secondaryTextColor': _secondaryTextColor.toARGB32(),
          'titleTextColor': _titleTextColor.toARGB32(),

          // ألوان الأزرار
          'primaryButtonColor': _primaryButtonColor.toARGB32(),
          'secondaryButtonColor': _secondaryButtonColor.toARGB32(),
          'dangerButtonColor': _dangerButtonColor.toARGB32(),
          'successButtonColor': _successButtonColor.toARGB32(),

          // ألوان اللعبة
          'gameXColor': _gameXColor.toARGB32(),
          'gameOColor': _gameOColor.toARGB32(),
          'gameBoardColor': _gameBoardColor.toARGB32(),
          'gameWinColor': _gameWinColor.toARGB32(),

          // التدرجات
          'gradientStart': _gradientStart.toARGB32(),
          'gradientMiddle': _gradientMiddle.toARGB32(),
          'gradientEnd': _gradientEnd.toARGB32(),

          // ألوان إضافية
          'borderColor': _borderColor.toARGB32(),
          'shadowColor': _shadowColor.toARGB32(),
          'highlightColor': _highlightColor.toARGB32(),

          'type': 'advanced_theme',
          'version': '2.0',
        },
      );

      // حفظ السمة في الخدمة
      if (widget.existingTheme != null) {
        await ProductsApiService.updateProduct(themeProduct);
      } else {
        await ProductsApiService.addProduct(themeProduct);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ السمة "$_themeName" بنجاح!'),
          backgroundColor: _successButtonColor,
          action: SnackBarAction(
            label: 'عرض',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في حفظ السمة: $e'),
          backgroundColor: _dangerButtonColor,
        ),
      );
    }
  }

  void _previewTheme() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _buildFullPreview()),
    );
  }

  Widget _buildFullPreview() {
    return MaterialApp(
      theme: _buildCurrentTheme(),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            title: Text(
              'معاينة: $_themeName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_gradientStart, _gradientMiddle, _gradientEnd],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // عنوان التطبيق
                  Card(
                    color: _cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text('🎮', style: const TextStyle(fontSize: 60)),
                          const SizedBox(height: 10),
                          Text(
                            'Tic Tac Toe',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _titleTextColor,
                            ),
                          ),
                          Text(
                            _themeName,
                            style: TextStyle(
                              fontSize: 16,
                              color: _secondaryTextColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // أزرار اللعب
                  _buildPreviewButton('🤖 ضد الكمبيوتر', _primaryButtonColor),
                  const SizedBox(height: 10),
                  _buildPreviewButton(
                    '👥 متعدد اللاعبين',
                    _secondaryButtonColor,
                  ),
                  const SizedBox(height: 10),
                  _buildPreviewButton('🏪 المتجر', _accentColor),
                  const SizedBox(height: 10),
                  _buildPreviewButton('🎯 المهام', _successButtonColor),

                  const SizedBox(height: 20),

                  // معاينة لعبة
                  Card(
                    color: _cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'معاينة اللعبة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _titleTextColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: _gameBoardColor,
                              borderRadius: BorderRadius.circular(12),
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
                                Color symbolColor = _primaryTextColor;

                                if (index == 0 || index == 4 || index == 8) {
                                  symbol = 'X';
                                  symbolColor = _gameXColor;
                                } else if (index == 2 || index == 6) {
                                  symbol = 'O';
                                  symbolColor = _gameOColor;
                                }

                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _surfaceColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _borderColor),
                                  ),
                                  child: Center(
                                    child: Text(
                                      symbol,
                                      style: TextStyle(
                                        fontSize: 32,
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
                  ),

                  const SizedBox(height: 20),

                  // معلومات السمة
                  Card(
                    color: _cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Text(
                            'تفاصيل السمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _titleTextColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildColorChip('أساسي', _primaryColor),
                              _buildColorChip('ثانوي', _secondaryColor),
                              _buildColorChip('مميز', _accentColor),
                              _buildColorChip('X', _gameXColor),
                              _buildColorChip('O', _gameOColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            backgroundColor: _primaryColor,
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: () {},
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: _getContrastColor(color),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      side: BorderSide(color: _borderColor),
    );
  }
}

// مكتبة اختيار الألوان المحسّنة
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final Function(Color) onColorChanged;

  const BlockPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      // ألوان أساسية
      Colors.red, Colors.red.shade300, Colors.red.shade700, Colors.red.shade900,
      Colors.pink, Colors.pink.shade300, Colors.pink.shade700,
      Colors.pink.shade900,
      Colors.purple, Colors.purple.shade300, Colors.purple.shade700,
      Colors.purple.shade900,
      Colors.deepPurple, Colors.deepPurple.shade300, Colors.deepPurple.shade700,
      Colors.deepPurple.shade900,
      Colors.indigo, Colors.indigo.shade300, Colors.indigo.shade700,
      Colors.indigo.shade900,
      Colors.blue, Colors.blue.shade300, Colors.blue.shade700,
      Colors.blue.shade900,
      Colors.lightBlue, Colors.lightBlue.shade300, Colors.lightBlue.shade700,
      Colors.lightBlue.shade900,
      Colors.cyan, Colors.cyan.shade300, Colors.cyan.shade700,
      Colors.cyan.shade900,
      Colors.teal, Colors.teal.shade300, Colors.teal.shade700,
      Colors.teal.shade900,
      Colors.green, Colors.green.shade300, Colors.green.shade700,
      Colors.green.shade900,
      Colors.lightGreen, Colors.lightGreen.shade300, Colors.lightGreen.shade700,
      Colors.lightGreen.shade900,
      Colors.lime, Colors.lime.shade300, Colors.lime.shade700,
      Colors.lime.shade900,
      Colors.yellow, Colors.yellow.shade300, Colors.yellow.shade700,
      Colors.yellow.shade900,
      Colors.amber, Colors.amber.shade300, Colors.amber.shade700,
      Colors.amber.shade900,
      Colors.orange, Colors.orange.shade300, Colors.orange.shade700,
      Colors.orange.shade900,
      Colors.deepOrange, Colors.deepOrange.shade300, Colors.deepOrange.shade700,
      Colors.deepOrange.shade900,
      Colors.brown, Colors.brown.shade300, Colors.brown.shade700,
      Colors.brown.shade900,
      Colors.grey, Colors.grey.shade300, Colors.grey.shade700,
      Colors.grey.shade900,
      Colors.blueGrey, Colors.blueGrey.shade300, Colors.blueGrey.shade700,
      Colors.blueGrey.shade900,
      Colors.black, Colors.white, const Color(0xFF424242),
      const Color(0xFF616161),
    ];

    return SizedBox(
      width: 320,
      height: 400,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          final isSelected = pickerColor.toARGB32() == color.toARGB32();
          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  width: isSelected ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
