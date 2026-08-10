import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // ── Logo ──────────────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo image
                  Image.asset(
                    'assets/images/transtu_logo.png',
                    width: 160,
                    fit: BoxFit.contain,
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.0, 1.0),
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: AppSpacing.xl),

                  // Tagline
                  Text(
                    'Signalez, on s\'en occupe.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.2,
                    ),
                  ).animate().fadeIn(
                        duration: 500.ms,
                        delay: 400.ms,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // ── Bottom loading indicator ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ).animate().fadeIn(
                        duration: 400.ms,
                        delay: 800.ms,
                      ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chargement...',
                    style: AppTextStyles.caption,
                  ).animate().fadeIn(
                        duration: 400.ms,
                        delay: 900.ms,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
