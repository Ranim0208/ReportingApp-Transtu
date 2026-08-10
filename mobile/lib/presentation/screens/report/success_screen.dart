import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_shadows.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // Success icon
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 48,
                ),
              ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                'Signalement envoyé !',
                style: AppTextStyles.display,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Votre signalement a bien été enregistré.\nNous le traiterons dans les meilleurs délais.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 380.ms),

              const SizedBox(height: AppSpacing.xxxl),

              // Reference card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.large,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    Text(
                      'Référence du signalement',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          reference,
                          style: AppTextStyles.mono,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: reference));
                            SnackbarHelper.showSuccess(context, 'Copié !');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: AppRadius.small,
                            ),
                            child: const Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (attachmentCount > 0) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: AppRadius.small,
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
              ).animate().fadeIn(duration: 400.ms, delay: 450.ms),

              const SizedBox(height: AppSpacing.xxxl),

              // Track button
              ElevatedButton(
                onPressed: () => context.push('/report-detail/$uuid'),
                child: const Text('Suivre mon signalement'),
              ).animate().fadeIn(duration: 400.ms, delay: 520.ms),

              const SizedBox(height: AppSpacing.md),

              OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Retour à l\'accueil'),
              ).animate().fadeIn(duration: 400.ms, delay: 560.ms),

              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
