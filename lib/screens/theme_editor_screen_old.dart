import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/products_api_service.dart';

class ThemeEditorScreen extends StatefulWidget {
  final Product? existingTheme;

  const ThemeEditorScreen({super.key, this.existingTheme});

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  // متغيرات التحكم في الألوان الأساسية
  Color _primaryColor = Colors.deepPurple;
  Color _secondaryColor = Colors.teal;
  Color _accentColor = Colors.amberAccent;
  Color _backgroundColor = Colors.grey.shade900;
  // ألوان النصوص
  Color _textColor = Colors.white; // متغير لون النص العام

  // ألوان الأزرار
  Color _buttonColor = Colors.deepPurple.shade500; // متغير لون الأزرار العام

  // متغيرات التحكم في التدرج
  Color _gradientStart = Colors.grey.shade900;
  Color _gradientMiddle = Colors.deepPurple.shade900;
  Color _gradientEnd = Colors.grey.shade900;

  // اسم السمة
  String _themeName = 'سمة مخصصة';
  final TextEditingController _themeNameController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // إذا كانت هناك سمة موجودة، قم بتحميل بياناتها
    if (widget.existingTheme != null) {
      _loadExistingTheme(widget.existingTheme!);
    }

    _themeNameController.text = _themeName;
  }

  void _loadExistingTheme(Product theme) {
    final metadata = theme.metadata;
    _themeName = theme.name;
    _primaryColor = Color(metadata['primaryColor'] ?? Colors.deepPurple.value);
    _secondaryColor = Color(metadata['secondaryColor'] ?? Colors.teal.value);
    _accentColor = Color(metadata['accentColor'] ?? Colors.amberAccent.value);
    _backgroundColor =
        Color(metadata['backgroundColor'] ?? Colors.grey.shade900.value);

    _textColor = Color(metadata['textColor'] ?? Colors.white.value);
    _buttonColor =
        Color(metadata['buttonColor'] ?? Colors.deepPurple.shade500.value);

    _gradientStart =
        Color(metadata['gradientStart'] ?? Colors.grey.shade900.value);
    _gradientMiddle =
        Color(metadata['gradientMiddle'] ?? Colors.deepPurple.shade900.value);
    _gradientEnd = Color(metadata['gradientEnd'] ?? Colors.grey.shade900.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 محرر السمات'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTheme,
            tooltip: 'حفظ السمة',
          ),
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _previewTheme,
            tooltip: 'معاينة السمة',
          ),
        ],
      ),
      body: Row(
        children: [
          // لوحة التحكم
          Expanded(
            flex: 1,
            child: _buildControlPanel(),
          ),
          // معاينة مباشرة
          Expanded(
            flex: 2,
            child: _buildPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم السمة
            _buildSectionTitle('اسم السمة'),
            TextField(
              controller: _themeNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'أدخل اسم السمة',
              ),
              onChanged: (value) {
                setState(() {
                  _themeName = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // الألوان الأساسية
            _buildSectionTitle('الألوان الأساسية'),
            _buildColorPicker('اللون الأساسي', _primaryColor, (color) {
              setState(() {
                _primaryColor = color;
              });
            }),
            _buildColorPicker('اللون الثانوي', _secondaryColor, (color) {
              setState(() {
                _secondaryColor = color;
              });
            }),
            _buildColorPicker('لون التمييز', _accentColor, (color) {
              setState(() {
                _accentColor = color;
              });
            }),
            const SizedBox(height: 24),

            // ألوان النص والخلفية
            _buildSectionTitle('النص والخلفية'),
            _buildColorPicker('لون الخلفية', _backgroundColor, (color) {
              setState(() {
                _backgroundColor = color;
              });
            }),
            _buildColorPicker('لون النص', _textColor, (color) {
              setState(() {
                _textColor = color;
              });
            }),
            _buildColorPicker('لون الأزرار', _buttonColor, (color) {
              setState(() {
                _buttonColor = color;
              });
            }),
            const SizedBox(height: 24),

            // تدرج الخلفية
            _buildSectionTitle('تدرج الخلفية'),
            _buildColorPicker('بداية التدرج', _gradientStart, (color) {
              setState(() {
                _gradientStart = color;
              });
            }),
            _buildColorPicker('وسط التدرج', _gradientMiddle, (color) {
              setState(() {
                _gradientMiddle = color;
              });
            }),
            _buildColorPicker('نهاية التدرج', _gradientEnd, (color) {
              setState(() {
                _gradientEnd = color;
              });
            }),
            const SizedBox(height: 24),

            // سمات جاهزة
            _buildSectionTitle('سمات جاهزة'),
            _buildPresetThemes(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildColorPicker(
      String label, Color currentColor, Function(Color) onColorChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: () =>
                _showColorPicker(context, currentColor, onColorChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetThemes() {
    return Column(
      children: [
        _buildPresetThemeButton('الافتراضي', () => _loadDefaultTheme()),
        _buildPresetThemeButton('الليل الداكن', () => _loadDarkTheme()),
        _buildPresetThemeButton('الطبيعة', () => _loadNatureTheme()),
        _buildPresetThemeButton('المحيط', () => _loadOceanTheme()),
        _buildPresetThemeButton('الغروب', () => _loadSunsetTheme()),
      ],
    );
  }

  Widget _buildPresetThemeButton(String name, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(name),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _gradientStart,
            _gradientMiddle,
            _gradientEnd,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.store),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.assignment),
              onPressed: () {},
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎮',
                  style: TextStyle(
                    fontSize: 80,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'مرحبا بك في لعبة\nTic Tac Toe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                    shadows: [
                      Shadow(
                        blurRadius: 6,
                        color: Colors.black54,
                        offset: const Offset(2, 2),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      'ابدأ اللعب',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people_alt_rounded, size: 26),
                    label: const Text(
                      'لاعب ضد لاعب',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor,
      Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('اختر لون'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تم'),
            ),
          ],
        );
      },
    );
  }

  void _loadDefaultTheme() {
    setState(() {
      _primaryColor = Colors.deepPurple;
      _secondaryColor = Colors.teal;
      _accentColor = Colors.amberAccent;
      _backgroundColor = Colors.grey.shade900;
      _textColor = Colors.yellow;
      _buttonColor = Colors.deepPurple.shade500;
      _gradientStart = Colors.grey.shade900;
      _gradientMiddle = Colors.deepPurple.shade900;
      _gradientEnd = Colors.grey.shade900;
      _themeName = 'السمة الافتراضية';
      _themeNameController.text = _themeName;
    });
  }

  void _loadDarkTheme() {
    setState(() {
      _primaryColor = Colors.black;
      _secondaryColor = Colors.grey.shade800;
      _accentColor = Colors.white;
      _backgroundColor = Colors.black;
      _textColor = Colors.white;
      _buttonColor = Colors.grey.shade700;
      _gradientStart = Colors.black;
      _gradientMiddle = Colors.grey.shade900;
      _gradientEnd = Colors.black;
      _themeName = 'الليل الداكن';
      _themeNameController.text = _themeName;
    });
  }

  void _loadNatureTheme() {
    setState(() {
      _primaryColor = Colors.green.shade700;
      _secondaryColor = Colors.brown.shade600;
      _accentColor = Colors.lightGreen;
      _backgroundColor = Colors.green.shade50;
      _textColor = Colors.green.shade800;
      _buttonColor = Colors.green.shade600;
      _gradientStart = Colors.green.shade100;
      _gradientMiddle = Colors.green.shade300;
      _gradientEnd = Colors.green.shade100;
      _themeName = 'الطبيعة';
      _themeNameController.text = _themeName;
    });
  }

  void _loadOceanTheme() {
    setState(() {
      _primaryColor = Colors.blue.shade800;
      _secondaryColor = Colors.cyan.shade600;
      _accentColor = Colors.lightBlue;
      _backgroundColor = Colors.blue.shade50;
      _textColor = Colors.blue.shade900;
      _buttonColor = Colors.blue.shade700;
      _gradientStart = Colors.blue.shade100;
      _gradientMiddle = Colors.blue.shade400;
      _gradientEnd = Colors.blue.shade100;
      _themeName = 'المحيط';
      _themeNameController.text = _themeName;
    });
  }

  void _loadSunsetTheme() {
    setState(() {
      _primaryColor = Colors.orange.shade800;
      _secondaryColor = Colors.red.shade600;
      _accentColor = Colors.yellow;
      _backgroundColor = Colors.orange.shade50;
      _textColor = Colors.orange.shade900;
      _buttonColor = Colors.orange.shade700;
      _gradientStart = Colors.orange.shade200;
      _gradientMiddle = Colors.red.shade300;
      _gradientEnd = Colors.yellow.shade200;
      _themeName = 'الغروب';
      _themeNameController.text = _themeName;
    });
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
      // إنشاء منتج جديد للسمة
      final themeProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _themeName,
        description: 'سمة مخصصة مع ألوان وتدرجات مميزة',
        price: 100, // سعر افتراضي للسمة
        category: ProductCategory.themes,
        imageUrl: 'assets/images/theme_preview.png', // صورة افتراضية
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        metadata: {
          'primaryColor': _primaryColor.value,
          'secondaryColor': _secondaryColor.value,
          'accentColor': _accentColor.value,
          'backgroundColor': _backgroundColor.value,
          'textColor': _textColor.value,
          'buttonColor': _buttonColor.value,
          'gradientStart': _gradientStart.value,
          'gradientMiddle': _gradientMiddle.value,
          'gradientEnd': _gradientEnd.value,
          'type': 'custom_theme',
        },
      ); // حفظ السمة في الخدمة
      await ProductsApiService.addProduct(themeProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ السمة "$_themeName" بنجاح كمنتج في المتجر!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'عرض في المتجر',
            onPressed: () {
              Navigator.pop(context, true); // إرجاع تأكيد النجاح
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في حفظ السمة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previewTheme() {
    // فتح معاينة كاملة للسمة
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _buildFullPreview(),
      ),
    );
  }

  Widget _buildFullPreview() {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          appBar: AppBar(
            title: Text(
              'Tic Tac Toe',
              style: TextStyle(
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
                colors: [
                  _gradientStart,
                  _gradientMiddle,
                  _gradientEnd,
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // العنوان الرئيسي
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _accentColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🎮',
                            style: TextStyle(
                              fontSize: 60,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tic Tac Toe',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            'معاينة السمة: $_themeName',
                            style: TextStyle(
                              fontSize: 16,
                              color: _accentColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // أزرار اللعب
                    _buildPreviewButton('🤖 ضد الكمبيوتر', _buttonColor),
                    const SizedBox(height: 15),
                    _buildPreviewButton('👥 متعدد اللاعبين', _secondaryColor),
                    const SizedBox(height: 15),
                    _buildPreviewButton('🏪 المتجر', _primaryColor),
                    const SizedBox(height: 15),
                    _buildPreviewButton(
                        '🎯 المهام', _accentColor.withOpacity(0.8)),

                    const SizedBox(height: 40),

                    // معلومات السمة
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryColor, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'تفاصيل السمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildColorChip('الأساسي', _primaryColor),
                              _buildColorChip('الثانوي', _secondaryColor),
                              _buildColorChip('المميز', _accentColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewButton(String text, Color color) {
    return Container(
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
          shadowColor: color.withOpacity(0.5),
        ),
        onPressed: () {
          // معاينة فقط - لا تفعل شيئاً
        },
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _textColor,
          ),
        ),
      ],
    );
  }
}

// مكتبة اختيار الألوان البسيطة
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
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];

    return SizedBox(
      width: 300,
      height: 200,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final color = colors[index];
          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                border: Border.all(
                  color: pickerColor == color ? Colors.white : Colors.grey,
                  width: pickerColor == color ? 3 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}
