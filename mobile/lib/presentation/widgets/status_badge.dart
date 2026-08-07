import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String statusCode;

  const StatusBadge({super.key, required this.statusCode});

  String get _label => switch (statusCode) {
        'IN_PROGRESS' => 'En cours',
        'RESOLVED' => 'Résolu',
        'CLOSED' => 'Clôturé',
        _ => 'Nouveau',
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _label,
        style: AppTextStyles.label.copyWith(
          color: _text,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
