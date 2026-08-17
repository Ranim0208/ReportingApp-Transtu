import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/public_report_model.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class PublicReportsState {
  final List<PublicReportModel> reports;
  final bool isLoading;
  final String? error;

  const PublicReportsState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  PublicReportsState copyWith({
    List<PublicReportModel>? reports,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PublicReportsState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class PublicReportsNotifier extends StateNotifier<PublicReportsState> {
  final ApiClient _apiClient;

  PublicReportsNotifier(this._apiClient) : super(const PublicReportsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _apiClient.getPublishedReports();
      final models = list
          .map((e) => PublicReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, reports: models);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger les signalements.',
      );
    }
  }

  Future<void> refresh() => load();
}

// ── Provider ──────────────────────────────────────────────────────────────────

final publicReportsProvider =
    StateNotifierProvider<PublicReportsNotifier, PublicReportsState>((ref) {
  return PublicReportsNotifier(ref.read(apiClientProvider));
});
