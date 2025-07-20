import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/stellar_home_screen.dart';
import 'themes/stellar_theme.dart';

// ======================================================================
// 🎮 TIC TAC TOE - WINDOWS VERSION (No Firebase)
// نسخة Windows بدون Firebase لحل مشاكل التشغيل
// ======================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لعبة X O النجمية',
      debugShowCheckedModeBanner: false,
      theme: StellarTheme.dark,
      home: const StellarHomeScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
  }
}
