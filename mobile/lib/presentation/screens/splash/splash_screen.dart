import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait for animation + session restore
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    // Auth state is already restored from SharedPreferences in AuthNotifier
    // No API call needed — just go to home (rule 8)
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Text(
              'TRANSTU',
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                fontSize: 36,
                letterSpacing: 4,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            // Tagline
            Text(
              'Signalez, on s\'en occupe.',
              style: AppTextStyles.body.copyWith(
                color: Colors.white70,
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

            const SizedBox(height: 48),

            // Loading indicator
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white54,
                strokeWidth: 2,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
