import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'screens/stellar_home_screen.dart';
import 'screens/auth_screen.dart';
import 'audio_helper.dart';
import 'store/store_manager.dart';
import 'services/theme_service.dart';
import 'services/firebase_auth_service.dart';
import 'models/product_model.dart';
import 'services/mock_server_service.dart';
import 'firebase_options.dart';

// App Mode Configuration
enum AppMode { main, admin }

// Global configuration
class AppConfig {
  static AppMode currentMode = AppMode.main;
  static bool isDebugMode = kDebugMode;

  static void setMode(AppMode mode) {
    currentMode = mode;
  }
}

void main([List<String>? args]) async {
  WidgetsFlutterBinding
      .ensureInitialized(); // تحديد وضع التطبيق بناءً على dart-define أو المعاملات
  const String appModeEnv =
      String.fromEnvironment('app_mode', defaultValue: '');
  if (appModeEnv.isNotEmpty) {
    switch (appModeEnv) {
      case 'admin':
      case 'product-manager':
      case 'simple-admin':
        AppConfig.setMode(AppMode.admin);
        break;
      default:
        AppConfig.setMode(AppMode.main);
    }
  } else if (args != null && args.isNotEmpty) {
    // البديل - استخدام المعاملات المباشرة
    switch (args[0]) {
      case 'admin':
      case 'product-manager':
      case 'simple-admin':
        AppConfig.setMode(AppMode.admin);
        break;
      default:
        AppConfig.setMode(AppMode.main);
    }
  }

  try {
    print('🔄 Initializing App in ${AppConfig.currentMode} mode...');
    // تهيئة Firebase للتطبيق الرئيسي
    if (AppConfig.currentMode == AppMode.main) {
      print('🔄 Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
      // Initialize services
      print('🔄 Initializing other services...');
      await AudioHelper.initializeAudio();
      await StoreManager.initialize();
      await ThemeService().loadSavedTheme();
      await FirebaseAuthService().initialize();
      print('✅ All services initialized successfully');
    } else {
      // تهيئة الخدمات الأساسية للإدارة
      print('🔄 Initializing admin services...');
      MockServerService.initializeMockData();
      print('✅ Admin services initialized successfully');
    }
  } catch (e) {
    print('❌ Error during initialization: $e');
    print('📋 Stack trace: ${StackTrace.current}');
  }
  // تشغيل التطبيق المناسب بناءً على الوضع
  switch (AppConfig.currentMode) {
    case AppMode.admin:
      runApp(const UnifiedAdminApp());
      break;
    case AppMode.main:
      runApp(const TicTacToeApp());
  }
}

// التطبيق الرئيسي - Tic Tac Toe
class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Tic Tac Toe',
          theme: ThemeService().createThemeData(),
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const StellarHomeScreen(),
          },
        );
      },
    );
  }
}

// غلاف المصادقة للتطبيق الرئيسي
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService.addAuthListener(_onAuthStateChanged);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _authService.removeAuthListener(_onAuthStateChanged);
    super.dispose();
  }

  void _onAuthStateChanged(user) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final user = _authService.currentUser;
    if (user != null) {
      // User is logged in, navigate to home screen
      return const StellarHomeScreen();
    } else {
      // User is not logged in, show auth screen
      return const AuthScreen();
    }
  }
}

// تطبيق الإدارة الموحد
class UnifiedAdminApp extends StatelessWidget {
  const UnifiedAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'وضع الإدارة - Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const UnifiedAdminDashboard(),
    );
  }
}

// لوحة الإدارة الموحدة
class UnifiedAdminDashboard extends StatefulWidget {
  const UnifiedAdminDashboard({super.key});

  @override
  State<UnifiedAdminDashboard> createState() => _UnifiedAdminDashboardState();
}

class _UnifiedAdminDashboardState extends State<UnifiedAdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    _products = await MockServerService.fetchProducts();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وضع الإدارة'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
            tooltip: 'تحديث البيانات',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showExitDialog(),
            tooltip: 'خروج من وضع الإدارة',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'لوحة التحكم'),
            Tab(icon: Icon(Icons.inventory), text: 'إدارة المنتجات'),
            Tab(icon: Icon(Icons.grid_view), text: 'عرض مبسط'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildProductManagementTab(),
                _buildSimpleViewTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: () => _showAddProductDialog(),
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
              tooltip: 'إضافة منتج جديد',
            )
          : null,
    );
  }

  // تبويب لوحة التحكم - يجمع الإحصائيات والمعلومات العامة
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بطاقة الترحيب
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade400,
                  Colors.deepPurple.shade600
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.admin_panel_settings,
                    size: 40, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'مرحباً بك في وضع الإدارة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'إدارة شاملة لجميع جوانب التطبيق',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // إحصائيات سريعة
          const Text(
            'الإحصائيات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard('إجمالي المنتجات',
                      '${_products.length}', Icons.inventory, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'المنتجات النشطة',
                      '${_products.where((p) => p.isActive).length}',
                      Icons.check_circle,
                      Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      'المنتجات غير النشطة',
                      '${_products.where((p) => !p.isActive).length}',
                      Icons.cancel,
                      Colors.red)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      'إجمالي القيمة',
                      '\$${_products.fold(0, (sum, p) => sum + p.price)}',
                      Icons.attach_money,
                      Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),

          // الأنشطة الحديثة
          const Text(
            'آخر المنتجات المضافة',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._products
              .take(3)
              .map((product) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            product.isActive ? Colors.green : Colors.red,
                        child: Icon(
                          product.isActive ? Icons.check : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                          'السعر: \$${product.price} - ${product.category}'),
                      trailing: Text(
                        product.isActive ? 'نشط' : 'غير نشط',
                        style: TextStyle(
                          color: product.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // تبويب إدارة المنتجات - إدارة تفصيلية للمنتجات
  Widget _buildProductManagementTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          product.isActive ? Colors.green : Colors.red,
                      child: Icon(
                        product.isActive ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${product.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product.isActive ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.isActive ? 'نشط' : 'غير نشط',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showProductDetails(product),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('عرض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _toggleProductStatus(product, index),
                      icon: Icon(
                        product.isActive ? Icons.pause : Icons.play_arrow,
                        size: 16,
                      ),
                      label: Text(product.isActive ? 'إيقاف' : 'تفعيل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            product.isActive ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _editProduct(product, index),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('تعديل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // تبويب العرض المبسط - عرض مرئي بسيط للمنتجات
  Widget _buildSimpleViewTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 32,
                  color: product.isActive ? Colors.deepPurple : Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.isActive ? 'متوفر' : 'غير متوفر',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(product.name),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('الاسم', product.name),
              _buildDetailRow('الوصف', product.description),
              _buildDetailRow('السعر', '\$${product.price}'),
              _buildDetailRow('الفئة', product.category),
              _buildDetailRow('الحالة', product.isActive ? 'نشط' : 'غير نشط'),
              _buildDetailRow('تاريخ الإنشاء',
                  '${product.createdAt.day}/${product.createdAt.month}/${product.createdAt.year}'),
              _buildDetailRow('آخر تحديث',
                  '${product.updatedAt.day}/${product.updatedAt.month}/${product.updatedAt.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _toggleProductStatus(Product product, int index) {
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      imageUrl: product.imageUrl,
      isActive: !product.isActive,
      createdAt: product.createdAt,
      updatedAt: DateTime.now(),
    );
    setState(() {
      _products[index] = updatedProduct;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updatedProduct.isActive
              ? 'تم تفعيل ${product.name}'
              : 'تم إيقاف ${product.name}',
        ),
        backgroundColor: updatedProduct.isActive ? Colors.green : Colors.orange,
      ),
    );
  }

  void _editProduct(Product product, int index) {
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(text: product.description);
    final priceController =
        TextEditingController(text: product.price.toString());
    final categoryController = TextEditingController(text: product.category);
    bool isActive = product.isActive;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text('تعديل المنتج'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('المنتج نشط'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final updatedProduct = Product(
                    id: product.id,
                    name: nameController.text,
                    description: descController.text,
                    price: int.tryParse(priceController.text) ?? product.price,
                    category: categoryController.text,
                    imageUrl: product.imageUrl,
                    isActive: isActive,
                    createdAt: product.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  this.setState(() {
                    _products[index] = updatedProduct;
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تحديث المنتج بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController(text: 'عام');
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text('إضافة منتج جديد'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المنتج *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'السعر *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('المنتج نشط'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value),
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final now = DateTime.now();
                  final product = Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    description: descController.text.isEmpty
                        ? 'لا يوجد وصف'
                        : descController.text,
                    price: int.tryParse(priceController.text) ?? 0,
                    category: categoryController.text.isEmpty
                        ? 'عام'
                        : categoryController.text,
                    imageUrl: 'https://via.placeholder.com/150',
                    isActive: isActive,
                    createdAt: now,
                    updatedAt: now,
                  );
                  this.setState(() {
                    _products.add(product);
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إضافة المنتج بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.exit_to_app, color: Colors.red),
            SizedBox(width: 8),
            Text('تأكيد الخروج'),
          ],
        ),
        content: const Text('هل تريد الخروج من وضع الإدارة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // إعادة تشغيل التطبيق في الوضع الرئيسي
              AppConfig.setMode(AppMode.main);
              // يمكن إضافة منطق إعادة التشغيل هنا
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
  }
}
