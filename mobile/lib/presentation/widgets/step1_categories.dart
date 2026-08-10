import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../domain/entities/report_type.dart';
import '../providers/report_form_provider.dart';

class Step1Categories extends ConsumerWidget {
  const Step1Categories({super.key});

  IconData _iconForCode(String code) => switch (code.toUpperCase()) {
        'CLEANLINESS' => Icons.cleaning_services_outlined,
        'BREAKDOWN' => Icons.build_outlined,
        'BEHAVIOR' => Icons.people_outline,
        'SAFETY' => Icons.security_outlined,
        _ => Icons.report_problem_outlined,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportFormProvider);

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.reportTypes.isEmpty) {
      return Center(
        child: Text(
          'Aucune catégorie disponible.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quel type de problème ?', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sélectionnez la catégorie qui correspond le mieux.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
              ),
              itemCount: state.reportTypes.length,
              itemBuilder: (_, i) => _CategoryCard(
                type: state.reportTypes[i],
                isSelected: state.selectedReportType?.reportTypeId ==
                    state.reportTypes[i].reportTypeId,
                icon: _iconForCode(state.reportTypes[i].code),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final ReportType type;
  final bool isSelected;
  final IconData icon;

  const _CategoryCard({
    required this.type,
    required this.isSelected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(reportFormProvider.notifier).selectReportType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.background,
                borderRadius: AppRadius.medium,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              type.label,
              style: AppTextStyles.h3.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
