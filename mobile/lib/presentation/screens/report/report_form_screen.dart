import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/file_validator.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_form_provider.dart';
import '../../../domain/entities/report_type.dart';

class ReportFormScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> vehicle;
  const ReportFormScreen({super.key, required this.vehicle});

  @override
  ConsumerState<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends ConsumerState<ReportFormScreen> {
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportFormProvider.notifier).loadReportTypes();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final state = ref.read(reportFormProvider);
    if (state.currentStep == 0 && state.selectedReportType == null) {
      SnackbarHelper.showError(context, 'Veuillez choisir une catégorie.');
      return;
    }
    if (state.currentStep == 1) {
      final desc = _descriptionController.text.trim();
      if (desc.length < 20) {
        SnackbarHelper.showError(
            context, 'Description trop courte (min 20 caractères).');
        return;
      }
      ref.read(reportFormProvider.notifier).setDescription(desc);
    }
    ref.read(reportFormProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevStep() {
    ref.read(reportFormProvider.notifier).previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickFile(ImageSource source) async {
    final state = ref.read(reportFormProvider);
    if (state.attachments.length >= 5) {
      SnackbarHelper.showError(context, 'Maximum 5 fichiers autorisés.');
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final file = File(picked.path);
    final error = FileValidator.validateFile(file);
    if (error != null) {
      if (mounted) SnackbarHelper.showError(context, error);
      return;
    }
    ref.read(reportFormProvider.notifier).addAttachment(file);
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.pop(context);
                _pickFile(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickFile(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final authState = ref.read(authProvider);
    String? name, email, phone;

    if (authState.isLoggedIn) {
      name = authState.passenger!.name;
      email = authState.passenger!.email;
      phone = authState.passenger!.phoneNumber;
    } else {
      name = _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim();
      email = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();
      phone = _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim();
    }

    final success = await ref.read(reportFormProvider.notifier).submit(
          passengerName: name,
          passengerEmail: email,
          passengerPhone: phone,
        );

    if (!mounted) return;

    if (success) {
      final report = ref.read(reportFormProvider).submittedReport!;
      await _saveRecentReport(report.uuid, report.reference,
          report.creationDate, report.statusCode);
      ref.read(reportFormProvider.notifier).reset();
      context.pushReplacement('/success', extra: {
        'uuid': report.uuid,
        'reference': report.reference,
        'attachmentCount': ref.read(reportFormProvider).attachments.length,
      });
    } else {
      final error = ref.read(reportFormProvider).error;
      SnackbarHelper.showError(context, error ?? 'Erreur lors de l\'envoi.');
    }
  }

  Future<void> _saveRecentReport(
      String uuid, String reference, String date, String statusCode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AuthStorageKeys.recentReports);
    final list = raw != null
        ? (jsonDecode(raw) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    list.insert(0, {
      'uuid': uuid,
      'reference': reference,
      'creationDate': date,
      'statusCode': statusCode,
    });

    if (list.length > 5) list.removeLast();
    await prefs.setString(AuthStorageKeys.recentReports, jsonEncode(list));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportFormProvider);
    final vehicle = widget.vehicle;
    final vehicleLabel = vehicle['label'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouveau signalement'),
            Text(vehicleLabel, style: AppTextStyles.caption),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          _StepIndicator(currentStep: state.currentStep),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1Categories(state: state),
                _Step2Details(
                  state: state,
                  descriptionController: _descriptionController,
                  onPickFile: _showPickerSheet,
                ),
                _Step3Contact(
                  authState: ref.watch(authProvider),
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                ),
              ],
            ),
          ),

          // Navigation buttons
          _BottomNavigation(
            currentStep: state.currentStep,
            isSubmitting: state.isSubmitting,
            onNext: _nextStep,
            onPrev: _prevStep,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Catégorie', 'Détails', 'Coordonnées'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == currentStep;
          final isComplete = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive || isComplete
                            ? AppColors.primary
                            : AppColors.divider,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isComplete
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[i],
                      style: AppTextStyles.caption.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 20),
                      color: i < currentStep
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1: Categories ────────────────────────────────────────────────────────

class _Step1Categories extends StatelessWidget {
  final ReportFormState state;
  const _Step1Categories({required this.state});

  IconData _iconForCode(String code) => switch (code.toUpperCase()) {
        'CLEANLINESS' => Icons.cleaning_services,
        'BREAKDOWN' => Icons.build,
        'BEHAVIOR' => Icons.people,
        'SAFETY' => Icons.security,
        _ => Icons.report_problem,
      };

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.reportTypes.isEmpty) {
      return const Center(child: Text('Aucune catégorie disponible.'));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quel type de problème ?', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: state.reportTypes.length,
              itemBuilder: (_, i) {
                final type = state.reportTypes[i];
                final isSelected =
                    state.selectedReportType?.reportTypeId == type.reportTypeId;
                return _CategoryCard(
                  type: type,
                  isSelected: isSelected,
                  icon: _iconForCode(type.code),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final ReportType type;
  final bool isSelected;
  final IconData icon;

  const _CategoryCard({
    required this.type,
    required this.isSelected,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(reportFormProvider.notifier).selectReportType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              type.label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: Details ───────────────────────────────────────────────────────────

class _Step2Details extends StatelessWidget {
  final ReportFormState state;
  final TextEditingController descriptionController;
  final VoidCallback onPickFile;

  const _Step2Details({
    required this.state,
    required this.descriptionController,
    required this.onPickFile,
  });

  @override
  Widget build(BuildContext context) {
    final totalSize =
        state.attachments.fold<int>(0, (sum, f) => sum + f.lengthSync());
    final totalMb = totalSize / (1024 * 1024);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Décrivez le problème', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            maxLines: 6,
            maxLength: 5000,
            decoration: const InputDecoration(
              hintText: 'Décrivez le problème en détail...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Photos ou documents (optionnel)',
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text(
                '${state.attachments.length} / 5 fichiers',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Warn if approaching 25MB
          if (totalMb > 20)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Taille totale : ${totalMb.toStringAsFixed(1)} Mo / 25 Mo',
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
          // File thumbnails
          if (state.attachments.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.attachments.length,
                itemBuilder: (context, i) =>
                    _FileThumbnail(file: state.attachments[i], index: i),
              ),
            ),

          const SizedBox(height: 12),
          if (state.attachments.length < 5)
            OutlinedButton.icon(
              onPressed: onPickFile,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Ajouter'),
            ),
        ],
      ),
    );
  }
}

class _FileThumbnail extends ConsumerWidget {
  final File file;
  final int index;
  const _FileThumbnail({required this.file, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(8),
        image: !isPdf
            ? DecorationImage(
                image: FileImage(file),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (isPdf)
            const Center(
              child:
                  Icon(Icons.picture_as_pdf, color: AppColors.error, size: 32),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () =>
                  ref.read(reportFormProvider.notifier).removeAttachment(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Contact ───────────────────────────────────────────────────────────

class _Step3Contact extends StatelessWidget {
  final dynamic authState;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const _Step3Contact({
    required this.authState,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = authState.isLoggedIn as bool;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vos coordonnées', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            'Optionnel — votre email permet de suivre votre signalement',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (isLoggedIn) ...[
            // Logged-in: show read-only profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (authState.passenger.name as String)[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.passenger.name as String,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          authState.passenger.email as String,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: AppColors.success),
                ],
              ),
            ),
          ] else ...[
            // Guest: optional fields
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sans email, vous ne pourrez pas recevoir le lien de suivi',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom (optionnel)',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optionnel)',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone (optionnel)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────

class _BottomNavigation extends StatelessWidget {
  final int currentStep;
  final bool isSubmitting;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSubmit;

  const _BottomNavigation({
    required this.currentStep,
    required this.isSubmitting,
    required this.onNext,
    required this.onPrev,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                child: const Text('Retour'),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : currentStep < 2
                      ? onNext
                      : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      currentStep < 2 ? 'Suivant' : 'Soumettre le signalement',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
