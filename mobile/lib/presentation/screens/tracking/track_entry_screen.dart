import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../providers/tracking_provider.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      _controller.text = data!.text!;
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UUID input
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'UUID du signalement',
                hintText: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _controller.clear()),
                      ),
                    IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: _paste,
                    ),
                  ],
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: isLoading ? null : () => _track(_controller.text),
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

            const SizedBox(height: 24),

            if (_recentReports.isNotEmpty) ...[
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Récents', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _recentReports.length,
                  itemBuilder: (_, i) {
                    final report = _recentReports[i];
                    return Dismissible(
                      key: Key(report['uuid'] as String),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _removeRecent(i),
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: AppColors.error,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.history,
                            color: AppColors.textSecondary),
                        title: Text(report['reference'] as String? ?? ''),
                        subtitle: report['creationDate'] != null
                            ? Text(DateFormatter.formatShort(
                                report['creationDate'] as String))
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppColors.textSecondary),
                        onTap: () => _track(report['uuid'] as String),
                      ),
                    );
                  },
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history,
                          size: 64, color: AppColors.divider),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun signalement récent',
                        style: AppTextStyles.body.copyWith(
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
    );
  }
}
