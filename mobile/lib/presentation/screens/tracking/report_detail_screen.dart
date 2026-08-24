import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/app_error.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  final String uuid;
  const ReportDetailScreen({super.key, required this.uuid});

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trackingProvider.notifier).track(widget.uuid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 16, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      state.result?.reference ?? 'Signalement',
                      style: AppTextStyles.h2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppColors.primary, size: 20),
                    onPressed: () => ref
                        .read(trackingProvider.notifier)
                        .refresh(widget.uuid),
                  ),
                ],
              ),
            ),

            // ── Body ──────────────────────────────────────────────────────
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TrackingState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      return AppError(
        message: state.error!,
        onRetry: () => ref.read(trackingProvider.notifier).refresh(widget.uuid),
      );
    }

    if (state.result == null) return const SizedBox();

    final result = state.result!;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(trackingProvider.notifier).refresh(widget.uuid),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Trail card ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reference + meta
                  Text(
                    '${result.reference} · ${result.supportLabel ?? ''}'
                    ' · Ouvert le ${DateFormatter.formatShort(result.creationDate)}',
                    style: AppTextStyles.monoSmall,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Trail steps
                  _TrailLine(statusCode: result.statusCode),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),

            const SizedBox(height: AppSpacing.xxl),

            // ── Description ───────────────────────────────────────────────
            const _EyebrowLabel(label: 'Description'),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (result.reportTypeLabel != null)
                    Row(
                      children: [
                        const Icon(Icons.report_problem_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.xs),
                        Text(result.reportTypeLabel!,
                            style: AppTextStyles.monoSmall),
                      ],
                    ),
                  if (result.reportTypeLabel != null)
                    const SizedBox(height: AppSpacing.sm),
                  Text(result.description, style: AppTextStyles.body),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),

            const SizedBox(height: AppSpacing.xxl),

            // ── Replies ───────────────────────────────────────────────────
            const _EyebrowLabel(label: 'Échange'),
            const SizedBox(height: AppSpacing.md),

            if (result.replies.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.hourglass_empty_rounded,
                        size: 36, color: AppColors.textHint),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'En attente de traitement',
                      style: AppTextStyles.h3
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Nous reviendrons vers vous bientôt.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms, delay: 160.ms)
            else
              ...result.replies.asMap().entries.map((e) {
                final i = e.key;
                final reply = e.value;
                return _ReplyBubble(
                  message: reply.message,
                  replyDate: reply.replyDate,
                  index: i,
                )
                    .animate()
                    .fadeIn(
                      duration: 300.ms,
                      delay: Duration(milliseconds: 160 + i * 80),
                    )
                    .slideY(begin: 0.1, end: 0);
              }),
          ],
        ),
      ),
    );
  }
}

// ── Trail Line ────────────────────────────────────────────────────────────────

class _TrailLine extends StatelessWidget {
  final String statusCode;
  const _TrailLine({required this.statusCode});

  List<_TrailStep> get _steps => [
        const _TrailStep(
          label: 'Envoyé',
          sub: 'Reçu par l\'agence',
          done: true,
        ),
        _TrailStep(
          label: 'Pris en charge',
          sub: 'Agent assigné',
          done: statusCode == 'IN_PROGRESS' ||
              statusCode == 'RESOLVED' ||
              statusCode == 'CLOSED',
        ),
        _TrailStep(
          label: 'Résolu',
          sub: 'Incident clôturé',
          done: statusCode == 'RESOLVED' || statusCode == 'CLOSED',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isLast = i == _steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line + dot
              SizedBox(
                width: 26,
                child: Column(
                  children: [
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color:
                            step.done ? AppColors.primary : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              step.done ? AppColors.primary : AppColors.border,
                          width: step.done ? 3 : 1.5,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: step.done
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.sm,
                    bottom: isLast ? 0 : AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.label,
                        style: AppTextStyles.h3.copyWith(
                          color: step.done
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                      Text(
                        step.sub,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TrailStep {
  final String label;
  final String sub;
  final bool done;
  const _TrailStep({
    required this.label,
    required this.sub,
    required this.done,
  });
}

// ── Reply Bubble ──────────────────────────────────────────────────────────────

class _ReplyBubble extends StatelessWidget {
  final String message;
  final String replyDate;
  final int index;

  const _ReplyBubble({
    required this.message,
    required this.replyDate,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.railBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'AG',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Agent Transtu', style: AppTextStyles.h3),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PUBLIC',
                  style: AppTextStyles.monoLabel.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Message
          Text(message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              )),

          const SizedBox(height: AppSpacing.xs),

          // Date
          Text(
            DateFormatter.format(replyDate),
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

// ── Eyebrow Label ─────────────────────────────────────────────────────────────

class _EyebrowLabel extends StatelessWidget {
  final String label;
  const _EyebrowLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.monoLabel.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.border,
                  AppColors.border.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
