import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/tracking_provider.dart';

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

  Color _statusColor(String code) => switch (code) {
        'IN_PROGRESS' => AppColors.statusProgressBg,
        'RESOLVED' => AppColors.statusResolvedBg,
        'CLOSED' => AppColors.statusClosedBg,
        _ => AppColors.statusNewBg,
      };

  String _statusLabel(String code) => switch (code) {
        'IN_PROGRESS' => 'En cours',
        'RESOLVED' => 'Résolu',
        'CLOSED' => 'Clôturé',
        _ => 'Nouveau',
      };

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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: () =>
                ref.read(trackingProvider.notifier).refresh(widget.uuid),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.error!, style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(trackingProvider.notifier)
                        .refresh(widget.uuid),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (state.result == null) return const SizedBox();

          final result = state.result!;
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(trackingProvider.notifier).refresh(widget.uuid),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _statusColor(result.statusCode),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _statusLabel(result.statusCode),
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mis à jour le ${DateFormatter.formatShort(result.creationDate)}',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (result.reportTypeLabel != null)
                          _InfoRow(
                            icon: Icons.report_problem_outlined,
                            text: result.reportTypeLabel!,
                          ),
                        if (result.supportLabel != null) ...[
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.directions_bus_outlined,
                            text: result.supportLabel!,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          text: DateFormatter.format(result.creationDate),
                        ),
                        const Divider(height: 24),
                        Text('Description',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 8),
                        Text(result.description, style: AppTextStyles.body),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Replies
                  Text('Réponses de Transtu', style: AppTextStyles.h2),
                  const SizedBox(height: 12),

                  if (result.replies.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.hourglass_empty,
                              size: 48, color: AppColors.divider),
                          const SizedBox(height: 12),
                          Text(
                            'En attente de traitement.',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Nous reviendrons vers vous bientôt.',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    )
                  else
                    ...result.replies.asMap().entries.map((entry) {
                      final i = entry.key;
                      final reply = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                'T',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(reply.message,
                                        style: AppTextStyles.body),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormatter.format(reply.replyDate),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 300.ms,
                                    delay: Duration(milliseconds: i * 100),
                                  )
                                  .slideY(begin: 0.2, end: 0),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}
