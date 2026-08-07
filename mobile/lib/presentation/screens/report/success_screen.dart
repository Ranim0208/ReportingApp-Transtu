import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/snackbar_helper.dart';

class SuccessScreen extends StatelessWidget {
  final Map<String, dynamic> report;
  const SuccessScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final reference = report['reference'] as String? ?? '';
    final uuid = report['uuid'] as String? ?? '';
    final attachmentCount = report['attachmentCount'] as int? ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated check circle
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 56,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shake(duration: 300.ms),

              const SizedBox(height: 24),

              Text('Signalement envoyé !', style: AppTextStyles.display)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 8),

              Text(
                'Votre signalement a bien été enregistré.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              const SizedBox(height: 32),

              // Reference card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text('Référence', style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          reference,
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: reference));
                            SnackbarHelper.showSuccess(context, 'Copié !');
                          },
                        ),
                      ],
                    ),
                    if (attachmentCount > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$attachmentCount photo(s) jointe(s)',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

              const SizedBox(height: 32),

              // Track button
              ElevatedButton(
                onPressed: () => context.push('/report-detail/$uuid'),
                child: const Text('Suivre mon signalement'),
              ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Retour à l\'accueil'),
              ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
