import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/my_report_model.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class MyReportsState {
  final List<MyReportModel> reports;
  final bool                isLoading;
  final String?             error;

  const MyReportsState({
    this.reports   = const [],
    this.isLoading = false,
    this.error,
  });

  MyReportsState copyWith({
    List<MyReportModel>? reports,
    bool?                isLoading,
    String?              error,
    bool                 clearError = false,
  }) {
    return MyReportsState(
      reports:   reports   ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error:     clearError ? null : error ?? this.error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class MyReportsNotifier extends StateNotifier<MyReportsState> {
  final ApiClient _apiClient;

  MyReportsNotifier(this._apiClient) : super(const MyReportsState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list   = await _apiClient.getMyReports();
      final models = list
          .map((e) => MyReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isLoading: false, reports: models);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Impossible de charger vos signalements.',
      );
    }
  }

  void clear() {
    state = const MyReportsState();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final myReportsProvider =
    StateNotifierProvider<MyReportsNotifier, MyReportsState>((ref) {
  return MyReportsNotifier(ref.read(apiClientProvider));
});