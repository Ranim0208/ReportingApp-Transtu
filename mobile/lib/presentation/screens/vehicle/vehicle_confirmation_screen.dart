import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_shadows.dart';

class VehicleConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  const VehicleConfirmationScreen({super.key, required this.vehicle});

  IconData _vehicleIcon(String? code) => switch (code?.toUpperCase()) {
        'BUS' => Icons.directions_bus_rounded,
        'METRO' => Icons.subway_rounded,
        _ => Icons.directions_transit_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final typeCode = vehicle['supportTypeCode'] as String?;
    final typeLabel = vehicle['supportTypeLabel'] as String? ?? '';
    final label = vehicle['label'] as String? ?? '';
    final reference = vehicle['reference'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Véhicule identifié'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success icon
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.success,
                size: 36,
              ),
            ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Véhicule identifié',
              style: AppTextStyles.h2,
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

            const SizedBox(height: AppSpacing.xxl),

            // Vehicle card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Icon(
                      _vehicleIcon(typeCode),
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: AppTextStyles.h2),
                        const SizedBox(height: AppSpacing.xs),
                        Text(reference, style: AppTextStyles.caption),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppRadius.small,
                          ),
                          child: Text(
                            typeLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.xxxl),

            // Report button
            ElevatedButton(
              onPressed: () => context.push('/report-form', extra: vehicle),
              child: const Text('Signaler un problème'),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

            const SizedBox(height: AppSpacing.md),

            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Ce n\'est pas mon véhicule',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 340.ms),
          ],
        ),
      ),
    );
  }
}
