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
import '../../providers/auth_provider.dart';
import '../../providers/report_form_provider.dart';
import '../../providers/my_reports_provider.dart';
import '../../widgets/form_step_indicator.dart';
import '../../widgets/form_bottom_nav.dart';
import '../../widgets/step1_categories.dart';
import '../../widgets/step2_details.dart';
import '../../widgets/step3_contact.dart';
import '../../../data/datasources/remote/api_client.dart';

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

  // ── Navigation ─────────────────────────────────────────────────────────────

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

  // ── File Picker ────────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

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

    final report = ref.read(reportFormProvider).submittedReport;
    final attachmentCount = ref.read(reportFormProvider).attachments.length;

    if (success && report != null) {
      // Save to SharedPreferences for guest
      if (!authState.isLoggedIn) {
        await _saveRecentReport(
          report.uuid,
          report.reference,
          report.creationDate,
          report.statusCode,
        );
      } else {
        // Refresh my-reports for logged-in user
        ref.read(myReportsProvider.notifier).load();
      }

      ref.read(reportFormProvider.notifier).reset();

      if (!mounted) return;
      context.pushReplacement('/success', extra: {
        'uuid': report.uuid,
        'reference': report.reference,
        'attachmentCount': attachmentCount,
      });
    } else {
      final error = ref.read(reportFormProvider).error;
      SnackbarHelper.showError(context, error ?? 'Erreur lors de l\'envoi.');
    }
  }

  Future<void> _saveRecentReport(
    String uuid,
    String reference,
    String date,
    String statusCode,
  ) async {
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportFormProvider);
    final vehicleLabel = widget.vehicle['label'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nouveau signalement'),
            Text(
              vehicleLabel,
              style: AppTextStyles.caption,
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          FormStepIndicator(currentStep: state.currentStep),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const Step1Categories(),
                Step2Details(
                  descriptionController: _descriptionController,
                  onPickFile: _showPickerSheet,
                ),
                Step3Contact(
                  authState: ref.watch(authProvider),
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                ),
              ],
            ),
          ),

          // Bottom navigation
          FormBottomNav(
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
