import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';

class FormStepIndicator extends StatelessWidget {
  final int currentStep;
  static const _labels = ['Catégorie', 'Détails', 'Coordonnées'];

  const FormStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical:   AppSpacing.lg,
        horizontal: AppSpacing.xxl,
      ),
      child: Row(
        children: List.generate(3, (i) {
          final isActive   = i == currentStep;
          final isComplete = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width:  28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isActive || isComplete
                              ? AppColors.primary
                              : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isComplete
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _labels[i],
                        style: AppTextStyles.caption.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                      color: i < currentStep
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}