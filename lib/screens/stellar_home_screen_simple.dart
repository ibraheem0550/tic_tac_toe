import 'package:flutter/material.dart';
import '../services/unified_auth_services.dart';
import '../models/complete_user_models.dart';
import '../utils/app_theme_new.dart';
import '../screens/auth_screen.dart';

class StellarHomeScreenSimple extends StatefulWidget {
  const StellarHomeScreenSimple({super.key});

  @override
  State<StellarHomeScreenSimple> createState() =>
      _StellarHomeScreenSimpleState();
}

class _StellarHomeScreenSimpleState extends State<StellarHomeScreenSimple> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUser == null) {
      return const AuthScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TIC TAC TOE'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // معلومات المستخدم
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      _currentUser!.displayName.isNotEmpty
                          ? _currentUser!.displayName
                          : 'مستخدم',
                    ),
                    subtitle: Text(
                      _currentUser!.isGuest ? 'مستخدم ضيف' : 'مستخدم مسجل',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // أزرار الألعاب
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('لعبة جديدة');
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('لعبة جديدة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint('لعب مع الذكاء الاصطناعي');
                  },
                  icon: const Icon(Icons.smart_toy),
                  label: const Text('لعب مع الذكاء الاصطناعي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          debugPrint('الأصدقاء');
                        },
                        icon: const Icon(Icons.people),
                        label: const Text('الأصدقاء'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _authService.signOut();
                          if (mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const AuthScreen(),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('خروج'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
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
}
