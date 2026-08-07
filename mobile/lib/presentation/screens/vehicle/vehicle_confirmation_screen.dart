import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class VehicleConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleConfirmationScreen({super.key, required this.vehicle});

  IconData _vehicleIcon(String? code) => switch (code?.toUpperCase()) {
        'BUS' => Icons.directions_bus,
        'METRO' => Icons.subway,
        _ => Icons.directions_transit,
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Check icon
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 64,
            ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 24),

            // Vehicle card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Vehicle type icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _vehicleIcon(typeCode),
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(label, style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Text(
                    reference,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 12),

                  // Type chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
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
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Report button
            ElevatedButton(
              onPressed: () => context.push('/report-form', extra: vehicle),
              child: const Text('Signaler un problème sur ce véhicule'),
            ),
            const SizedBox(height: 12),

            // Wrong vehicle
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Ce n\'est pas mon véhicule',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
