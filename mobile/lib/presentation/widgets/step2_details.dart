import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../providers/report_form_provider.dart';

class Step2Details extends ConsumerWidget {
  final TextEditingController descriptionController;
  final VoidCallback onPickFile;

  const Step2Details({
    super.key,
    required this.descriptionController,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportFormProvider);
    final totalSize = state.attachments.fold<int>(
      0,
      (sum, f) => sum + f.lengthSync(),
    );
    final totalMb = totalSize / (1024 * 1024);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Décrivez le problème', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Soyez le plus précis possible pour faciliter le traitement.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Description field
          TextField(
            controller: descriptionController,
            maxLines: 7,
            maxLength: 5000,
            decoration: const InputDecoration(
              hintText: 'Ex: La climatisation ne fonctionne pas depuis...',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Attachments header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Photos / Documents',
                style: AppTextStyles.h3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  '${state.attachments.length} / 5',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Optionnel — JPG, PNG ou PDF, max 10 Mo par fichier.',
              style: AppTextStyles.caption),

          // Size warning
          if (totalMb > 20) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: AppRadius.small,
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${totalMb.toStringAsFixed(1)} Mo / 25 Mo utilisés',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Thumbnails row
          if (state.attachments.isNotEmpty) ...[
            SizedBox(
              height: 88,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.attachments.length,
                itemBuilder: (_, i) => _FileThumbnail(
                  file: state.attachments[i],
                  index: i,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Add button
          if (state.attachments.length < 5)
            OutlinedButton.icon(
              onPressed: onPickFile,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
              ),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Ajouter un fichier'),
            ),
        ],
      ),
    );
  }
}

class _FileThumbnail extends ConsumerWidget {
  final File file;
  final int index;

  const _FileThumbnail({required this.file, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');

    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadius.medium,
        image: !isPdf
            ? DecorationImage(
                image: FileImage(file),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (isPdf)
            const Center(
              child: Icon(
                Icons.picture_as_pdf_outlined,
                color: AppColors.error,
                size: 32,
              ),
            ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () =>
                  ref.read(reportFormProvider.notifier).removeAttachment(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
