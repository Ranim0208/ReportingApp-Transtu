import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/info_row.dart';
import '../../widgets/reply_bubble.dart';
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
      appBar: AppBar(
        title: Text(
          state.result?.reference ?? 'Suivi',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () =>
                ref.read(trackingProvider.notifier).refresh(widget.uuid),
          ),
        ],
      ),
      body: _buildBody(state),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status card ───────────────────────────────────────────────
            _StatusCard(result: result)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // ── Info card ─────────────────────────────────────────────────
            _InfoCard(result: result)
                .animate()
                .fadeIn(duration: 300.ms, delay: 80.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: AppSpacing.lg),

            // ── Replies section ───────────────────────────────────────────
            Text('Réponses de Transtu', style: AppTextStyles.h2)
                .animate()
                .fadeIn(duration: 300.ms, delay: 160.ms),

            const SizedBox(height: AppSpacing.md),

            if (result.replies.isEmpty)
              _EmptyReplies().animate().fadeIn(duration: 300.ms, delay: 200.ms)
            else
              ...result.replies.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ReplyBubble(
                        message: e.value.message,
                        replyDate: e.value.replyDate,
                        index: e.key,
                      ),
                    ),
                  ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

// ── Status Card ───────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final dynamic result;
  const _StatusCard({required this.result});

  Color get _bgColor => switch (result.statusCode as String) {
        'IN_PROGRESS' => AppColors.statusProgressBg,
        'RESOLVED' => AppColors.statusResolvedBg,
        'CLOSED' => AppColors.statusClosedBg,
        _ => AppColors.statusNewBg,
      };

  Color get _textColor => switch (result.statusCode as String) {
        'IN_PROGRESS' => AppColors.statusProgressText,
        'RESOLVED' => AppColors.statusResolvedText,
        'CLOSED' => AppColors.statusClosedText,
        _ => AppColors.statusNewText,
      };

  IconData get _icon => switch (result.statusCode as String) {
        'IN_PROGRESS' => Icons.pending_actions_rounded,
        'RESOLVED' => Icons.check_circle_rounded,
        'CLOSED' => Icons.lock_rounded,
        _ => Icons.fiber_new_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppRadius.large,
      ),
      child: Row(
        children: [
          Icon(_icon, color: _textColor, size: 32),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.statusLabel as String,
                  style: AppTextStyles.h2.copyWith(color: _textColor),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Mis à jour le ${DateFormatter.formatShort(result.creationDate as String)}',
                  style: AppTextStyles.caption.copyWith(color: _textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final dynamic result;
  const _InfoCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.reportTypeLabel != null)
            InfoRow(
              icon: Icons.report_problem_outlined,
              text: result.reportTypeLabel as String,
            ),
          if (result.supportLabel != null) ...[
            const SizedBox(height: AppSpacing.md),
            InfoRow(
              icon: Icons.directions_bus_outlined,
              text: result.supportLabel as String,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            text: DateFormatter.format(result.creationDate as String),
          ),
          const Divider(height: AppSpacing.xxl),
          Text(
            'Description',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            result.description as String,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}

// ── Empty Replies ─────────────────────────────────────────────────────────────

class _EmptyReplies extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.hourglass_empty_rounded,
            size: 40,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'En attente de traitement',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Nous reviendrons vers vous bientôt.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
