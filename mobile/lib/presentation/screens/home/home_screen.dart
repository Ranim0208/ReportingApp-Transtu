import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/public_reports_provider.dart';
import '../../widgets/status_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(publicReportsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;
    final publicReportsState = ref.watch(publicReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(publicReportsProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HomeHeader(
                  authState: authState,
                  isLoggedIn: isLoggedIn,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.1, end: 0, curve: Curves.easeOut),
              ),

              // ── Main actions ──────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      'Que voulez-vous faire ?',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: AppSpacing.md),
                    _MainActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Scanner un QR Code',
                      description:
                          'Identifiez votre véhicule et signalez un problème',
                      isPrimary: true,
                      onTap: () => context.push('/scanner'),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 150.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: AppSpacing.md),
                    _MainActionCard(
                      icon: Icons.manage_search_rounded,
                      title: 'Suivre un signalement',
                      description: 'Consultez l\'état de votre signalement',
                      isPrimary: false,
                      onTap: () => context.push('/track'),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                  ]),
                ),
              ),

              // ── Guest section ─────────────────────────────────────────────
              if (!isLoggedIn)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _GuestBanner()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 250.ms),
                  ),
                ),

              // ── Published reports section ─────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Signalements traités',
                        style: AppTextStyles.h2,
                      ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                      if (publicReportsState.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Loading
              if (publicReportsState.isLoading &&
                  publicReportsState.reports.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xxl),
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                )

              // Empty
              else if (!publicReportsState.isLoading &&
                  publicReportsState.reports.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.large,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 40,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Aucun signalement traité pour l\'instant',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )

              // List
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final report = publicReportsState.reports[i];
                        return _PublicReportCard(
                          report: report,
                          index: i,
                          onTap: () => context.push(
                            '/report-detail/${report.uuid}',
                          ),
                        );
                      },
                      childCount: publicReportsState.reports.length,
                    ),
                  ),
                ),

              const SliverPadding(
                padding: EdgeInsets.only(bottom: 90),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final dynamic authState;
  final bool isLoggedIn;

  const _HomeHeader({
    required this.authState,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'TRANSTU',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              if (isLoggedIn)
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      (authState.passenger.name as String)[0].toUpperCase(),
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => context.push('/login'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            isLoggedIn
                ? 'Bonjour, ${(authState.passenger.name as String).split(' ').first} 👋'
                : 'Bienvenue',
            style: AppTextStyles.display,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Comment pouvons-nous vous aider ?',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main Action Card ──────────────────────────────────────────────────────────

class _MainActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isPrimary;
  final VoidCallback onTap;

  const _MainActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_MainActionCard> createState() => _MainActionCardState();
}

class _MainActionCardState extends State<_MainActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: widget.isPrimary ? AppColors.primary : AppColors.surface,
            borderRadius: AppRadius.large,
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : AppShadows.card,
            border:
                widget.isPrimary ? null : Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.isPrimary
                      ? Colors.white.withValues(alpha: 0.15)
                      : AppColors.primaryLight,
                  borderRadius: AppRadius.medium,
                ),
                child: Icon(
                  widget.icon,
                  size: 26,
                  color: widget.isPrimary ? Colors.white : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.h3.copyWith(
                        color: widget.isPrimary
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.isPrimary
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: widget.isPrimary
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Guest Banner ──────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_circle_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Vous avez un compte ?', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Connectez-vous pour accéder à votre profil.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/login'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('Se connecter'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  child: const Text('S\'inscrire'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Public Report Card ────────────────────────────────────────────────────────

class _PublicReportCard extends StatelessWidget {
  final dynamic report;
  final int index;
  final VoidCallback onTap;

  const _PublicReportCard({
    required this.report,
    required this.index,
    required this.onTap,
  });

  IconData _vehicleIcon(String? code) => switch (code?.toUpperCase()) {
        'BUS' => Icons.directions_bus_rounded,
        'METRO' => Icons.subway_rounded,
        _ => Icons.directions_transit_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Vehicle info
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.small,
                      ),
                      child: Icon(
                        _vehicleIcon(report.supportTypeCode as String?),
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (report.supportLabel != null)
                          Text(
                            report.supportLabel as String,
                            style: AppTextStyles.h3.copyWith(fontSize: 13),
                          ),
                        if (report.reportTypeLabel != null)
                          Text(
                            report.reportTypeLabel as String,
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                  ],
                ),
                StatusBadge(statusCode: report.statusCode as String? ?? 'NEW'),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              report.description as String,
              style: AppTextStyles.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Date + arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatShort(report.creationDate as String),
                  style: AppTextStyles.caption,
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            duration: 300.ms,
            delay: Duration(milliseconds: 300 + index * 80),
          )
          .slideY(begin: 0.05, end: 0),
    );
  }
}
