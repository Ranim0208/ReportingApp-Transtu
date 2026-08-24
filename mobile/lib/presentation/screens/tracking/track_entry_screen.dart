import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../providers/tracking_provider.dart';
import '../../widgets/status_badge.dart';
import '../../../data/datasources/remote/api_client.dart';

class TrackEntryScreen extends ConsumerStatefulWidget {
  const TrackEntryScreen({super.key});

  @override
  ConsumerState<TrackEntryScreen> createState() => _TrackEntryScreenState();
}

class _TrackEntryScreenState extends ConsumerState<TrackEntryScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthStorageKeys.recentReports);
    if (raw != null && mounted) {
      setState(() {
        _recentReports = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _removeRecent(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _recentReports.removeAt(index);
    await prefs.setString(
        AuthStorageKeys.recentReports, jsonEncode(_recentReports));
    setState(() {});
  }

  Future<void> _track(String uuid) async {
    if (uuid.trim().isEmpty) {
      SnackbarHelper.showError(context, 'Veuillez entrer un UUID.');
      return;
    }
    final success =
        await ref.read(trackingProvider.notifier).track(uuid.trim());
    if (!mounted) return;
    if (success) {
      context.push('/report-detail/$uuid');
    } else {
      final error = ref.read(trackingProvider).error;
      SnackbarHelper.showError(context, error ?? 'Signalement introuvable.');
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() => _controller.text = data!.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(trackingProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mes signalements', style: AppTextStyles.display),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Suivez l\'avancement de chaque déclaration.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Search bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.card,
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: AppSpacing.md),
                      child: Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Code ou référence (ex : SIG-20260807-…)',
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        style: AppTextStyles.body,
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            size: 16, color: AppColors.textHint),
                        onPressed: () => setState(() => _controller.clear()),
                      ),
                    IconButton(
                      icon: const Icon(Icons.content_paste_rounded,
                          size: 16, color: AppColors.primary),
                      onPressed: _paste,
                    ),
                  ],
                ),
              ),
            ),

            // ── Search hint ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: AppColors.textHint),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: 'Sans compte ? ',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Collez le code reçu par e-mail',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: ' — pas besoin de compte.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Search button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _track(_controller.text),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Rechercher'),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Recent list ───────────────────────────────────────────────
            if (_recentReports.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _EyebrowLabel(label: 'Récents'),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    90,
                  ),
                  itemCount: _recentReports.length,
                  itemBuilder: (_, i) {
                    final report = _recentReports[i];
                    return Dismissible(
                      key: Key(report['uuid'] as String),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeRecent(i),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                      ),
                      child: _RecentTicket(
                        report: report,
                        onTap: () => _track(report['uuid'] as String),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.history_rounded,
                        size: 48, color: AppColors.border),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Aucun signalement récent',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Recent Ticket ─────────────────────────────────────────────────────────────

class _RecentTicket extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const _RecentTicket({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['reference'] as String? ?? '',
                    style: AppTextStyles.h3,
                  ),
                  if (report['creationDate'] != null)
                    Text(
                      DateFormatter.formatShort(
                          report['creationDate'] as String),
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(
              statusCode: report['statusCode'] as String? ?? 'NEW',
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
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
