import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/public_reports_provider.dart';
import '../../widgets/ticket_card.dart';

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
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => ref.read(publicReportsProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // ── Top bar ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _TopBar(
                  authState: authState,
                  isLoggedIn: isLoggedIn,
                ).animate().fadeIn(duration: 400.ms),
              ),

              // ── Hero card ─────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _HeroCard(
                    authState: authState,
                    isLoggedIn: isLoggedIn,
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 80.ms)
                      .slideY(begin: 0.08, end: 0, curve: Curves.easeOut),
                ),
              ),

              // ── Guest banner ──────────────────────────────────────────────
              if (!isLoggedIn)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _GuestBanner()
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 150.ms),
                  ),
                ),

              // ── Section label ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: const _EyebrowLabel(label: 'Réponses publiques')
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms),
                ),
              ),

              // ── Public reports ────────────────────────────────────────────
              if (publicReportsState.isLoading &&
                  publicReportsState.reports.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                )
              else if (!publicReportsState.isLoading &&
                  publicReportsState.reports.isEmpty)
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverToBoxAdapter(
                    child: _EmptyPublicReports(),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final report = publicReportsState.reports[i];
                        final route = [
                          report.supportLabel,
                          report.reportTypeLabel,
                        ].where((e) => e != null).join(' · ');

                        return TicketCard(
                          route: route.isEmpty ? 'TRANSTU' : route,
                          title: report.reference,
                          message: report.description,
                          statusCode: report.statusCode ?? 'NEW',
                          onTap: () => context.push(
                            '/report-detail/${report.uuid}',
                          ),
                        )
                            .animate()
                            .fadeIn(
                              duration: 300.ms,
                              delay: Duration(milliseconds: 250 + i * 80),
                            )
                            .slideY(begin: 0.05, end: 0);
                      },
                      childCount: publicReportsState.reports.length,
                    ),
                  ),
                ),

              // Bottom padding pour la nav
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

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final dynamic authState;
  final bool isLoggedIn;

  const _TopBar({required this.authState, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + tagline
          Row(
            children: [
              // Logo placeholder — remplace par Image.asset si logo dispo
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_transit_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSTU',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    'Signalement',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Profile icon
          GestureDetector(
            onTap: () =>
                isLoggedIn ? context.go('/profile') : context.push('/login'),
            child: Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: isLoggedIn
                      ? Center(
                          child: Text(
                            (authState.passenger.name as String)[0]
                                .toUpperCase(),
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                ),
                if (isLoggedIn)
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final dynamic authState;
  final bool isLoggedIn;

  const _HeroCard({required this.authState, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            isLoggedIn
                ? 'Bonjour, ${(authState.passenger.name as String).split(' ').first} 👋'
                : 'Bienvenue sur Transtu',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Title
          Text(
            isLoggedIn
                ? 'Votre espace\nsignalement'
                : 'Signalez,\non s\'en occupe.',
            style: AppTextStyles.display.copyWith(
              color: Colors.white,
              height: 1.1,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick actions
          Row(
            children: [
              _HeroAction(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scanner',
                onTap: () => context.go('/scanner'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroAction(
                icon: Icons.manage_search_rounded,
                label: 'Suivre',
                onTap: () => context.go('/track'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_add_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Créez un compte pour accéder à plus de fonctionnalités.',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => context.push('/register'),
            child: Text(
              'S\'inscrire',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
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

// ── Empty public reports ──────────────────────────────────────────────────────

class _EmptyPublicReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Icon(
            Icons.inbox_outlined,
            size: 40,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Aucune réponse publique pour l\'instant',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
