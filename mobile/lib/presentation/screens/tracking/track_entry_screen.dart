import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
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
      appBar: AppBar(
        title: const Text('Suivre un signalement'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entrez votre référence',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Vous trouverez l\'UUID dans l\'email de confirmation.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_controller.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () =>
                                  setState(() => _controller.clear()),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.content_paste_rounded,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: _paste,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed:
                        isLoading ? null : () => _track(_controller.text),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Rechercher'),
                  ),
                ],
              ),
            ),

            // Recent reports
            if (_recentReports.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              Text('Récents', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.large,
                    boxShadow: AppShadows.card,
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: _recentReports.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 68),
                    itemBuilder: (_, i) {
                      final report = _recentReports[i];
                      return Dismissible(
                        key: Key(report['uuid'] as String),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeRecent(i),
                        background: Container(
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: i == 0
                                ? const BorderRadius.vertical(
                                    top: Radius.circular(16))
                                : i == _recentReports.length - 1
                                    ? const BorderRadius.vertical(
                                        bottom: Radius.circular(16))
                                    : BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.only(right: AppSpacing.lg),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: AppRadius.medium,
                            ),
                            child: const Icon(
                              Icons.assignment_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            report['reference'] as String? ?? '',
                            style: AppTextStyles.h3,
                          ),
                          subtitle: report['creationDate'] != null
                              ? Text(
                                  DateFormatter.formatShort(
                                    report['creationDate'] as String,
                                  ),
                                  style: AppTextStyles.caption,
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(
                                statusCode:
                                    report['statusCode'] as String? ?? 'NEW',
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                          onTap: () => _track(report['uuid'] as String),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ] else ...[
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.history_rounded,
                        size: 56, color: AppColors.border),
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

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
