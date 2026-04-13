import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    print('🎬 SplashScreen loaded - waiting 3 seconds...');
    Future.delayed(const Duration(seconds: 3), () {
      print('⏱️ 3 seconds passed - attempting navigation to /login');
      if (mounted) {
        print('📍 Context ready - calling context.go("/login")');
        context.go('/login');
        print('✅ Navigation called');
      } else {
        print('❌ Widget not mounted - skipping navigation');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural, size: 80, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Glowup AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
