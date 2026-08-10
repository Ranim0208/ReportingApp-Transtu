import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/my_reports_provider.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../widgets/status_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Map<String, dynamic>> _guestRecentReports = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    if (isLoggedIn) {
      // Load from API for authenticated users
      ref.read(myReportsProvider.notifier).load();
    } else {
      // Load from SharedPreferences for guests
      await _loadGuestReports();
    }
  }

  Future<void> _loadGuestReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthStorageKeys.recentReports);
    if (raw != null && mounted) {
      setState(() {
        _guestRecentReports =
            (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _onRefresh() async {
    final isLoggedIn = ref.read(authProvider).isLoggedIn;
    if (isLoggedIn) {
      await ref.read(myReportsProvider.notifier).load();
    } else {
      await _loadGuestReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;
    final myReportsState = ref.watch(myReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _HomeHeader(
                  authState: authState,
                  isLoggedIn: isLoggedIn,
                ).animate().fadeIn(duration: 400.ms).slideY(
                      begin: -0.1,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
              ),

              // ── Main actions ────────────────────────────────────────────
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
                      description:
                          'Consultez l\'état de vos signalements en cours',
                      isPrimary: false,
                      onTap: () => context.push('/track'),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                  ]),
                ),
              ),

              // ── Guest section ───────────────────────────────────────────
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

              // ── Recent reports (logged in) ──────────────────────────────
              if (isLoggedIn) ...[
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
                        Text('Mes signalements', style: AppTextStyles.h2)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 250.ms),
                        if (myReportsState.isLoading)
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
                if (myReportsState.error != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        myReportsState.error!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  )
                else if (!myReportsState.isLoading &&
                    myReportsState.reports.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
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
                              'Aucun signalement pour l\'instant',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final report = myReportsState.reports[i];
                          return _RecentReportTile(
                            uuid: report.uuid,
                            reference: report.reference,
                            creationDate: report.creationDate,
                            statusCode: report.statusCode ?? 'NEW',
                            index: i,
                            onTap: () => context.push(
                              '/report-detail/${report.uuid}',
                            ),
                          );
                        },
                        childCount: myReportsState.reports.length,
                      ),
                    ),
                  ),
              ],

              // ── Recent reports (guest) ──────────────────────────────────
              if (!isLoggedIn && _guestRecentReports.isNotEmpty) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Signalements récents',
                      style: AppTextStyles.h2,
                    ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final report = _guestRecentReports[i];
                        return _RecentReportTile(
                          uuid: report['uuid'] as String,
                          reference: report['reference'] as String,
                          creationDate: report['creationDate'] as String,
                          statusCode: report['statusCode'] as String? ?? 'NEW',
                          index: i,
                          onTap: () => context.push(
                            '/report-detail/${report['uuid']}',
                          ),
                        );
                      },
                      childCount: _guestRecentReports.take(3).length,
                    ),
                  ),
                ),
              ],

              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.xxxl),
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
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo text
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

              // Profile / Login icon
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

          // Greeting
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
              // Icon container
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

              // Text
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

              // Arrow
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
              Text(
                'Vous avez un compte ?',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Connectez-vous pour suivre vos signalements.',
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

// ── Recent Report Tile ────────────────────────────────────────────────────────

class _RecentReportTile extends StatelessWidget {
  final String uuid;
  final String reference;
  final String creationDate;
  final String statusCode;
  final int index;
  final VoidCallback onTap;

  const _RecentReportTile({
    required this.uuid,
    required this.reference,
    required this.creationDate,
    required this.statusCode,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.small,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reference, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormatter.formatShort(creationDate),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusBadge(statusCode: statusCode),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
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
