import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/my_reports_provider.dart';
import '../../widgets/status_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passenger = ref.watch(authProvider).passenger;
    final myReportsState = ref.watch(myReportsProvider);

    if (passenger == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_outlined,
                  size: 56, color: AppColors.textHint),
              const SizedBox(height: AppSpacing.lg),
              Text('Vous n\'êtes pas connecté.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  )),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    final initials = passenger.name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0])
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Avatar header ─────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      initials,
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(passenger.name, style: AppTextStyles.h1),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    passenger.email,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Info card ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.large,
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    _ProfileRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Nom complet',
                      value: passenger.name,
                    ),
                    const Divider(height: 1, indent: 52),
                    _ProfileRow(
                      icon: Icons.mail_outline_rounded,
                      label: 'Adresse email',
                      value: passenger.email,
                    ),
                    if (passenger.phoneNumber != null) ...[
                      const Divider(height: 1, indent: 52),
                      _ProfileRow(
                        icon: Icons.phone_outlined,
                        label: 'Téléphone',
                        value: passenger.phoneNumber!,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── My reports ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mes signalements', style: AppTextStyles.h2),
                  const SizedBox(height: AppSpacing.md),
                  if (myReportsState.isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else if (myReportsState.reports.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.large,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.inbox_outlined,
                              size: 40, color: AppColors.textHint),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Aucun signalement',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.large,
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: myReportsState.reports
                            .take(5)
                            .toList()
                            .asMap()
                            .entries
                            .map((e) {
                          final i = e.key;
                          final report = e.value;
                          final isLast = i ==
                              (myReportsState.reports.length > 5
                                      ? 5
                                      : myReportsState.reports.length) -
                                  1;
                          return Column(
                            children: [
                              ListTile(
                                onTap: () => context.push(
                                  '/report-detail/${report.uuid}',
                                ),
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
                                  report.reference,
                                  style: AppTextStyles.h3,
                                ),
                                subtitle: Text(
                                  DateFormatter.formatShort(
                                      report.creationDate),
                                  style: AppTextStyles.caption,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StatusBadge(
                                      statusCode: report.statusCode ?? 'NEW',
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast) const Divider(height: 1, indent: 68),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Logout ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => _confirmLogout(context, ref),
                child: const Text('Se déconnecter'),
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
      title: const Text('Déconnexion'),
      content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Déconnecter'),
        ),
      ],
    ),
  );

  if (confirm == true && context.mounted) {
    await ref.read(authProvider.notifier).logout();
    ref.read(myReportsProvider.notifier).clear();
    if (context.mounted) context.go('/home');
  }
}
}

// ── Profile Row ───────────────────────────────────────────────────────────────

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
