import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Map<String, dynamic>> _recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadRecentReports();
  }

  Future<void> _loadRecentReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthStorageKeys.recentReports);
    if (raw != null) {
      setState(() {
        _recentReports = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context, authState, isLoggedIn),
              const SizedBox(height: 20),
              _buildHeroBanner(context, isLoggedIn, authState),
              const SizedBox(height: 24),
              _buildActionCards(context),
              if (!isLoggedIn) ...[
                const SizedBox(height: 24),
                _buildGuestSection(context),
              ],
              if (isLoggedIn && _recentReports.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildRecentReports(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AuthState authState,
    bool isLoggedIn,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TRANSTU',
          style: AppTextStyles.heading.copyWith(
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
        if (isLoggedIn)
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                authState.passenger!.name.isNotEmpty
                    ? authState.passenger!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () => context.push('/login'),
          ),
      ],
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    bool isLoggedIn,
    AuthState authState,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 4),
            color: AppColors.primary.withOpacity(0.3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLoggedIn
                ? 'Bonjour, ${authState.passenger!.name.split(' ').first} 👋'
                : 'Bienvenue sur Transtu',
            style: AppTextStyles.heading.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Signalez un problème sur votre transport en commun',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _ActionCard(
          icon: Icons.qr_code_scanner,
          title: 'Scanner un QR Code',
          description: 'Identifiez votre véhicule et signalez un problème',
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          onTap: () => context.push('/scanner'),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.search,
          title: 'Suivre mon signalement',
          description: 'Consultez l\'état de vos signalements en cours',
          backgroundColor: AppColors.surface,
          textColor: AppColors.textPrimary,
          borderColor: AppColors.primary,
          onTap: () => context.push('/track'),
        ),
      ],
    );
  }

  Widget _buildGuestSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(
            'Vous avez un compte ?',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push('/login'),
                  child: const Text('Se connecter'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('S\'inscrire'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes signalements récents', style: AppTextStyles.heading),
        const SizedBox(height: 12),
        ..._recentReports.take(3).map((report) {
          return _RecentReportTile(
            report: report,
            onTap: () => context.push(
              '/report-detail/${report['uuid']}',
            ),
          );
        }),
      ],
    );
  }
}

// ── Action Card Widget ────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recent Report Tile ────────────────────────────────────────────────────────

class _RecentReportTile extends StatelessWidget {
  final Map<String, dynamic> report;
  final VoidCallback onTap;

  const _RecentReportTile({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusCode = report['statusCode'] as String? ?? 'NEW';
    final statusColor = switch (statusCode) {
      'IN_PROGRESS' => AppColors.statusProgressBg,
      'RESOLVED' => AppColors.statusResolvedBg,
      'CLOSED' => AppColors.statusClosedBg,
      _ => AppColors.statusNewBg,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['reference'] as String? ?? '',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (report['creationDate'] != null)
                    Text(
                      DateFormatter.formatShort(
                        report['creationDate'] as String,
                      ),
                      style: AppTextStyles.caption,
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
