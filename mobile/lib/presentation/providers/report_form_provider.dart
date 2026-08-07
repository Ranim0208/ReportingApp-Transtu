import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../domain/repositories/report_repository_impl.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_type.dart';
import '../../domain/entities/transport_support.dart';
import '../../domain/usecases/report/get_report_types_usescase.dart';
import '../../domain/usecases/report/get_vehicle_by_uuid_usecase.dart';
import '../../domain/usecases/report/submit_report_usecase.dart';

// ── Repository + Use Case Providers ──────────────────────────────────────────

final reportRepositoryProvider = Provider((ref) {
  return ReportRepositoryImpl(ref.read(apiClientProvider));
});

final getReportTypesUseCaseProvider = Provider((ref) {
  return GetReportTypesUseCase(ref.read(reportRepositoryProvider));
});

final getVehicleByUuidUseCaseProvider = Provider((ref) {
  return GetVehicleByUuidUseCase(ref.read(reportRepositoryProvider));
});

final submitReportUseCaseProvider = Provider((ref) {
  return SubmitReportUseCase(ref.read(reportRepositoryProvider));
});

// ── Report Form State ─────────────────────────────────────────────────────────

class ReportFormState {
  final TransportSupport? vehicle;
  final List<ReportType> reportTypes;
  final ReportType? selectedReportType;
  final String description;
  final List<File> attachments;
  final int currentStep;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final Report? submittedReport;

  const ReportFormState({
    this.vehicle,
    this.reportTypes = const [],
    this.selectedReportType,
    this.description = '',
    this.attachments = const [],
    this.currentStep = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.submittedReport,
  });

  ReportFormState copyWith({
    TransportSupport? vehicle,
    List<ReportType>? reportTypes,
    ReportType? selectedReportType,
    String? description,
    List<File>? attachments,
    int? currentStep,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    Report? submittedReport,
    bool clearError = false,
    bool clearSelectedType = false,
    bool clearSubmittedReport = false,
  }) {
    return ReportFormState(
      vehicle: vehicle ?? this.vehicle,
      reportTypes: reportTypes ?? this.reportTypes,
      selectedReportType: clearSelectedType
          ? null
          : selectedReportType ?? this.selectedReportType,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      submittedReport:
          clearSubmittedReport ? null : submittedReport ?? this.submittedReport,
    );
  }
}

// ── Report Form Notifier ──────────────────────────────────────────────────────

class ReportFormNotifier extends StateNotifier<ReportFormState> {
  final GetReportTypesUseCase _getReportTypes;
  final GetVehicleByUuidUseCase _getVehicleByUuid;
  final SubmitReportUseCase _submitReport;

  ReportFormNotifier({
    required GetReportTypesUseCase getReportTypes,
    required GetVehicleByUuidUseCase getVehicleByUuid,
    required SubmitReportUseCase submitReport,
  })  : _getReportTypes = getReportTypes,
        _getVehicleByUuid = getVehicleByUuid,
        _submitReport = submitReport,
        super(const ReportFormState());

  void setVehicle(TransportSupport vehicle) {
    state = state.copyWith(vehicle: vehicle);
  }

  void selectReportType(ReportType type) {
    state = state.copyWith(selectedReportType: type);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void addAttachment(File file) {
    if (state.attachments.length >= 5) return;
    state = state.copyWith(
      attachments: [...state.attachments, file],
    );
  }

  void removeAttachment(int index) {
    final updated = [...state.attachments]..removeAt(index);
    state = state.copyWith(attachments: updated);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void reset() {
    state = const ReportFormState();
  }

  Future<void> loadReportTypes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getReportTypes();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (types) => state = state.copyWith(
        isLoading: false,
        reportTypes: types,
      ),
    );
  }

  Future<bool> loadVehicle(String uuid) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getVehicleByUuid(uuid);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (vehicle) {
        state = state.copyWith(isLoading: false, vehicle: vehicle);
        return true;
      },
    );
  }

  Future<bool> submit({
    String? passengerName,
    String? passengerEmail,
    String? passengerPhone,
  }) async {
    if (state.vehicle == null || state.selectedReportType == null) return false;

    // Prevent double-submit
    state = state.copyWith(isSubmitting: true, clearError: true);

    final result = await _submitReport(
      supportUuid: state.vehicle!.uuid,
      reportTypeId: state.selectedReportType!.reportTypeId,
      description: state.description,
      passengerName: passengerName,
      passengerEmail: passengerEmail,
      passengerPhone: passengerPhone,
      files: state.attachments.isEmpty ? null : state.attachments,
    );

    return result.fold(
      (failure) {
        // Re-enable submit button on error
        state = state.copyWith(isSubmitting: false, error: failure.message);
        return false;
      },
      (report) {
        state = state.copyWith(isSubmitting: false, submittedReport: report);
        return true;
      },
    );
  }
}

// ── Report Form Provider ──────────────────────────────────────────────────────

final reportFormProvider =
    StateNotifierProvider<ReportFormNotifier, ReportFormState>((ref) {
  return ReportFormNotifier(
    getReportTypes: ref.read(getReportTypesUseCaseProvider),
    getVehicleByUuid: ref.read(getVehicleByUuidUseCaseProvider),
    submitReport: ref.read(submitReportUseCaseProvider),
  );
});
