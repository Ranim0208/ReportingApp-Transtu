import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/utils/date_formatter.dart';

class ReplyBubble extends StatelessWidget {
  final String message;
  final String replyDate;
  final int index;

  const ReplyBubble({
    super.key,
    required this.message,
    required this.replyDate,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: Text(
            'T',
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormatter.format(replyDate),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: index * 100),
        )
        .slideY(begin: 0.15, end: 0);
  }
}
