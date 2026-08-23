import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_shadows.dart';

class VehicleConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  const VehicleConfirmationScreen({super.key, required this.vehicle});

  IconData _vehicleIcon(String? code) => switch (code?.toUpperCase()) {
        'BUS'   => Icons.directions_bus_rounded,
        'METRO' => Icons.subway_rounded,
        _       => Icons.directions_transit_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final typeCode  = vehicle['supportTypeCode']  as String?;
    final typeLabel = vehicle['supportTypeLabel'] as String? ?? '';
    final label     = vehicle['label']            as String? ?? '';
    final reference = vehicle['reference']        as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            // ── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical:   AppSpacing.md,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width:  34,
                      height: 34,
                      decoration: BoxDecoration(
                        color:        AppColors.surface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size:  16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Véhicule identifié', style: AppTextStyles.h2),
                ],
              ),
            ),

            const Spacer(),

            // ── Content ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [

                  // Check
                  Container(
                    width:  72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size:  36,
                    ),
                  )
                      .animate()
                      .scale(
                        begin:    const Offset(0, 0),
                        end:      const Offset(1, 1),
                        duration: 400.ms,
                        curve:    Curves.elasticOut,
                      ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Vehicle card — style ticket
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color:        AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow:    AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:  56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:        AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _vehicleIcon(typeCode),
                            color: AppColors.primary,
                            size:  26,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(label,
                                  style: AppTextStyles.h2),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                reference,
                                style: AppTextStyles.monoSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical:   AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color:        AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  typeLabel,
                                  style: AppTextStyles.monoLabel.copyWith(
                                    color:      AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                ],
              ),
            ),

            const Spacer(),

            // ── Actions ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl, 0,
                AppSpacing.xxl, AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        context.push('/report-form', extra: vehicle),
                    child: const Text('Signaler un problème'),
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                  const SizedBox(height: AppSpacing.md),

                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Ce n\'est pas mon véhicule',
                      style: AppTextStyles.body.copyWith(
                        color:      AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.textSecondary,
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 350.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}