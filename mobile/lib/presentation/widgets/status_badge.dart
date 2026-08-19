import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final String statusCode;

  const StatusBadge({super.key, required this.statusCode});

  String get _label => switch (statusCode) {
        'IN_PROGRESS' => 'EN COURS',
        'RESOLVED' => 'RÉSOLU',
        'CLOSED' => 'CLÔTURÉ',
        _ => 'ENVOYÉ',
      };

  Color get _bg => switch (statusCode) {
        'IN_PROGRESS' => AppColors.statusProgressBg,
        'RESOLVED' => AppColors.statusResolvedBg,
        'CLOSED' => AppColors.statusClosedBg,
        _ => AppColors.statusNewBg,
      };

  Color get _text => switch (statusCode) {
        'IN_PROGRESS' => AppColors.statusProgressText,
        'RESOLVED' => AppColors.statusResolvedText,
        'CLOSED' => AppColors.statusClosedText,
        _ => AppColors.statusNewText,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: AppTextStyles.monoLabel.copyWith(
          color: _text,
          fontWeight: FontWeight.w700,
          fontSize: 8.5,
        ),
      ),
    );
  }
}
