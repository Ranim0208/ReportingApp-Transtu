import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  List<Map<String, dynamic>> _recentReports = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthStorageKeys.recentReports);
    if (raw != null) {
      setState(() {
        _recentReports = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final passenger = ref.watch(authProvider).passenger;
    if (passenger == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Vous n\'êtes pas connecté.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    final initials = passenger.name.isNotEmpty
        ? passenger.name.split(' ').map((e) => e[0]).take(2).join()
        : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar section
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(passenger.name, style: AppTextStyles.h2),
                Text(
                  passenger.email,
                  style: AppTextStyles.caption,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _ProfileRow(
                    icon: Icons.person_outline,
                    label: 'Nom',
                    value: passenger.name,
                  ),
                  const Divider(),
                  _ProfileRow(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: passenger.email,
                  ),
                  if (passenger.phoneNumber != null) ...[
                    const Divider(),
                    _ProfileRow(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: passenger.phoneNumber!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent reports
            if (_recentReports.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child:
                    Text('Mes signalements récents', style: AppTextStyles.h2),
              ),
              const SizedBox(height: 12),
              ..._recentReports.take(5).map((report) {
                return ListTile(
                  leading: const Icon(Icons.assignment_outlined,
                      color: AppColors.primary),
                  title: Text(report['reference'] as String? ?? ''),
                  subtitle: report['creationDate'] != null
                      ? Text(DateFormatter.formatShort(
                          report['creationDate'] as String))
                      : null,
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppColors.textSecondary),
                  onTap: () => context.push('/report-detail/${report['uuid']}'),
                );
              }),
              const SizedBox(height: 24),
            ],

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: _confirmLogout,
                child: const Text('Se déconnecter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
