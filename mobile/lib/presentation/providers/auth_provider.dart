import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../domain/repositories/auth_repository_impl.dart';
import '../../domain/entities/passenger.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';

// ── Repository + Use Case Providers ──────────────────────────────────────────

final authRepositoryProvider = Provider((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});

final loginUseCaseProvider = Provider((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

// ── Auth State ────────────────────────────────────────────────────────────────

class AuthState {
  final Passenger? passenger;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.passenger,
    this.isLoading = false,
    this.error,
  });

  bool get isLoggedIn => passenger != null;

  AuthState copyWith({
    Passenger? passenger,
    bool? isLoading,
    String? error,
    bool clearPassenger = false,
    bool clearError = false,
  }) {
    return AuthState(
      passenger: clearPassenger ? null : passenger ?? this.passenger,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ── Auth Notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        super(const AuthState()) {
    _restoreSession();
  }

  /// Restores session from SharedPreferences on app start.
  /// Never calls the API — assumes token is valid until a 401 proves otherwise.
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AuthStorageKeys.token);
    if (token == null) return;

    final passengerId = prefs.getInt(AuthStorageKeys.passengerId);
    final name = prefs.getString(AuthStorageKeys.name);
    final email = prefs.getString(AuthStorageKeys.email);
    final phoneNumber = prefs.getString(AuthStorageKeys.phoneNumber);

    if (passengerId != null && name != null && email != null) {
      state = state.copyWith(
        passenger: Passenger(
          passengerId: passengerId,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          token: token,
        ),
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    String? recaptchaToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _loginUseCase(
      email: email,
      password: password,
      recaptchaToken: recaptchaToken,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (passenger) {
        state = state.copyWith(isLoading: false, passenger: passenger);
        return true;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? recaptchaToken,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _registerUseCase(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      recaptchaToken: recaptchaToken,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (passenger) {
        // Ne pas sauvegarder — email non vérifié
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _logoutUseCase();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ── Auth Provider ─────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.read(loginUseCaseProvider),
    registerUseCase: ref.read(registerUseCaseProvider),
    logoutUseCase: ref.read(logoutUseCaseProvider),
  );
});
