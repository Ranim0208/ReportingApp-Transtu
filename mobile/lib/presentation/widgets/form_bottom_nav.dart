import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class FormBottomNav extends StatelessWidget {
  final int          currentStep;
  final bool         isSubmitting;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSubmit;

  const FormBottomNav({
    super.key,
    required this.currentStep,
    required this.isSubmitting,
    required this.onNext,
    required this.onPrev,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                ),
                child: const Text('Retour'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : currentStep < 2
                      ? onNext
                      : onSubmit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      currentStep < 2
                          ? 'Suivant'
                          : 'Soumettre',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}