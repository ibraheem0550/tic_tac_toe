import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:firebase_core/firebase_core.dart'; // معطل مؤقتاً للتشغيل على Windows
import 'package:flutter/foundation.dart';
import 'screens/responsive_home_screen.dart';

// ======================================================================
// 🎮 TIC TAC TOE - UNIFIED MAIN FILE
// تجميع جميع إصدارات main في ملف واحد منظم
// ======================================================================

// App Configuration
enum AppMode {
  main, // التطبيق الرئيسي
  simple, // نسخة مبسطة
  admin, // لوحة الإدارة
  debug, // وضع التطوير
}

class AppConfig {
  static AppMode currentMode = AppMode.main;
  static bool isDebugMode = kDebugMode;

  static void setMode(AppMode mode) {
    currentMode = mode;
  }
}

// ======================================================================
// 🚀 MAIN ENTRY POINT
// ======================================================================

void main([List<String>? args]) async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحديد وضع التطبيق من المعاملات
  _determineAppMode(args);

  // تشغيل التطبيق المناسب
  switch (AppConfig.currentMode) {
    case AppMode.simple:
      runApp(const SimpleTicTacToeApp());
      break;
    case AppMode.admin:
      runApp(const AdminApp());
      break;
    case AppMode.debug:
      runApp(const DebugApp());
      break;
    case AppMode.main:
      runApp(const AdvancedTicTacToeApp());
      break;
  }
}

// تحديد وضع التطبيق
void _determineAppMode(List<String>? args) {
  const String appModeEnv = String.fromEnvironment(
    'app_mode',
    defaultValue: '',
  );

  if (appModeEnv.isNotEmpty) {
    switch (appModeEnv.toLowerCase()) {
      case 'simple':
        AppConfig.setMode(AppMode.simple);
        break;
      case 'admin':
        AppConfig.setMode(AppMode.admin);
        break;
      case 'debug':
        AppConfig.setMode(AppMode.debug);
        break;
      default:
        AppConfig.setMode(AppMode.main);
    }
  } else if (args != null && args.isNotEmpty) {
    switch (args[0].toLowerCase()) {
      case 'simple':
        AppConfig.setMode(AppMode.simple);
        break;
      case 'admin':
        AppConfig.setMode(AppMode.admin);
        break;
      case 'debug':
        AppConfig.setMode(AppMode.debug);
        break;
      default:
        AppConfig.setMode(AppMode.main);
    }
  }
}

// ======================================================================
// 🎮 ADVANCED TIC TAC TOE APP (النسخة المتطورة)
// ======================================================================

class AdvancedTicTacToeApp extends StatelessWidget {
  const AdvancedTicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🎮 Tic Tac Toe - Advanced',
      theme: _getAdvancedTheme(),
      debugShowCheckedModeBanner: false,
      home: const ResponsiveHomeScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // إعدادات دعم اللغة العربية
      supportedLocales: const [
        Locale('ar', 'SA'), // العربية
        Locale('en', 'US'), // الإنجليزية
      ],
      locale: const Locale('ar', 'SA'),
    );
  }

  ThemeData _getAdvancedTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}

// ======================================================================
// 🔧 SIMPLE TIC TAC TOE APP (النسخة المبسطة)
// ======================================================================

class SimpleTicTacToeApp extends StatelessWidget {
  const SimpleTicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe - Simple',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const SimpleGameScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      locale: const Locale('ar', 'SA'),
    );
  }
}

class SimpleGameScreen extends StatefulWidget {
  const SimpleGameScreen({super.key});

  @override
  State<SimpleGameScreen> createState() => _SimpleGameScreenState();
}

class _SimpleGameScreenState extends State<SimpleGameScreen> {
  List<String> board = List.filled(9, '');
  bool isXTurn = true;
  String winner = '';

  void _makeMove(int index) {
    if (board[index].isEmpty && winner.isEmpty) {
      setState(() {
        board[index] = isXTurn ? 'X' : 'O';
        isXTurn = !isXTurn;
        winner = _checkWinner();
      });
    }
  }

  String _checkWinner() {
    // فحص الصفوف
    for (int i = 0; i < 9; i += 3) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2]) {
        return board[i];
      }
    }

    // فحص الأعمدة
    for (int i = 0; i < 3; i++) {
      if (board[i].isNotEmpty &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        return board[i];
      }
    }

    // فحص الأقطار
    if (board[0].isNotEmpty && board[0] == board[4] && board[0] == board[8]) {
      return board[0];
    }
    if (board[2].isNotEmpty && board[2] == board[4] && board[2] == board[6]) {
      return board[2];
    }

    // فحص التعادل
    if (!board.contains('')) {
      return 'Tie';
    }

    return '';
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, '');
      isXTurn = true;
      winner = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Tic Tac Toe - Simple'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // حالة اللعبة
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              winner.isEmpty
                  ? 'دور اللاعب ${isXTurn ? 'X' : 'O'}'
                  : winner == 'Tie'
                  ? 'تعادل!'
                  : 'اللاعب $winner فاز!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          // لوحة اللعب
          Container(
            margin: const EdgeInsets.all(20),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _makeMove(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        board[index],
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: board[index] == 'X'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // زر إعادة التشغيل
          ElevatedButton(
            onPressed: _resetGame,
            child: const Text('لعبة جديدة'),
          ),
        ],
      ),
    );
  }
}

// ======================================================================
// 🔧 ADMIN APP (تطبيق الإدارة)
// ======================================================================

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      theme: ThemeData(primarySwatch: Colors.red, brightness: Brightness.dark),
      debugShowCheckedModeBanner: false,
      home: const AdminHomeScreen(),
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔧 لوحة الإدارة')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 64),
            SizedBox(height: 16),
            Text('لوحة إدارة Tic Tac Toe', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// 🔍 DEBUG APP (تطبيق التطوير)
// ======================================================================

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Mode',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: true,
      home: const DebugHomeScreen(),
    );
  }
}

class DebugHomeScreen extends StatelessWidget {
  const DebugHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔍 وضع التطوير')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bug_report, size: 64),
            SizedBox(height: 16),
            Text('وضع تطوير وتصحيح الأخطاء', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
