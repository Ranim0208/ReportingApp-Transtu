import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../domain/repositories/tracking_repository_impl.dart';
import '../../domain/entities/tracking_result.dart';
import '../../domain/usecases/tracking/track_report_usecase.dart';
import 'package:flutter/foundation.dart';

// ── Repository + Use Case Providers ──────────────────────────────────────────

final trackingRepositoryProvider = Provider((ref) {
  return TrackingRepositoryImpl(ref.read(apiClientProvider));
});

final trackReportUseCaseProvider = Provider((ref) {
  return TrackReportUseCase(ref.read(trackingRepositoryProvider));
});

// ── Tracking State ────────────────────────────────────────────────────────────

class TrackingState {
  final TrackingResult? result;
  final bool isLoading;
  final String? error;

  const TrackingState({
    this.result,
    this.isLoading = false,
    this.error,
  });

  TrackingState copyWith({
    TrackingResult? result,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return TrackingState(
      result: clearResult ? null : result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ── Tracking Notifier ─────────────────────────────────────────────────────────

class TrackingNotifier extends StateNotifier<TrackingState> {
  final TrackReportUseCase _trackReport;

  TrackingNotifier(this._trackReport) : super(const TrackingState());

  Future<bool> track(String uuid) async {
    state =
        state.copyWith(isLoading: true, clearError: true, clearResult: true);

    final result = await _trackReport(uuid);

    return result.fold(
      (failure) {
        debugPrint('=== TRACKING ERROR ===');
        debugPrint('failure.message: "${failure.message}"');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (tracking) {
        state = state.copyWith(isLoading: false, result: tracking);
        return true;
      },
    );
  }

  Future<bool> refresh(String uuid) => track(uuid);

  void clear() {
    state = const TrackingState();
  }
}

// ── Tracking Provider ─────────────────────────────────────────────────────────

final trackingProvider =
    StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(ref.read(trackReportUseCaseProvider));
});
