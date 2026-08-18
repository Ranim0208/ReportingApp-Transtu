import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/passenger.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/passenger_auth_response.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  const AuthRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, Passenger>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? recaptchaToken,
  }) async {
    try {
      final json = await _apiClient.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        recaptchaToken: recaptchaToken,
      );
      final model = PassengerAuthResponseModel.fromJson(json);
      final passenger = _toEntity(model);
      // Ne pas sauvegarder — email non vérifié
      return Right(passenger);
    } on AppException catch (e) {
      return Left(Failure(e.message));
    } on DioException catch (e) {
      // Extrait le vrai message depuis l'erreur Dio
      final appError = e.error;
      if (appError is AppException) {
        return Left(Failure(appError.message));
      }
      final message = e.message ?? 'Une erreur est survenue.';
      return Left(Failure(message));
    } catch (e) {
      // Extrait le message depuis "DioException [unknown]: null\nError: ..."
      final raw = e.toString();
      if (raw.contains('Error:')) {
        final extracted = raw.split('Error:').last.trim();
        return Left(Failure(extracted));
      }
      return const Left(Failure('Une erreur est survenue.'));
    }
  }

  @override
  Future<Either<Failure, Passenger>> login({
    required String email,
    required String password,
    String? recaptchaToken,
  }) async {
    try {
      final json = await _apiClient.login(
        email: email,
        password: password,
        recaptchaToken: recaptchaToken,
      );
      final model = PassengerAuthResponseModel.fromJson(json);
      final passenger = _toEntity(model);
      await _saveToPrefs(model);
      return Right(passenger);
    } on AppException catch (e) {
      return Left(Failure(e.message));
    } on DioException catch (e) {
      // Extrait le vrai message depuis l'erreur Dio
      final appError = e.error;
      if (appError is AppException) {
        return Left(Failure(appError.message));
      }
      final message = e.message ?? 'Une erreur est survenue.';
      return Left(Failure(message));
    } catch (e) {
      // Extrait le message depuis "DioException [unknown]: null\nError: ..."
      final raw = e.toString();
      if (raw.contains('Error:')) {
        final extracted = raw.split('Error:').last.trim();
        return Left(Failure(extracted));
      }
      return const Left(Failure('Une erreur est survenue.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AuthStorageKeys.token);
      await prefs.remove(AuthStorageKeys.name);
      await prefs.remove(AuthStorageKeys.email);
      await prefs.remove(AuthStorageKeys.phoneNumber);
      await prefs.remove(AuthStorageKeys.passengerId);
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Passenger _toEntity(PassengerAuthResponseModel model) {
    return Passenger(
      passengerId: model.passengerId,
      name: model.name,
      email: model.email,
      phoneNumber: model.phoneNumber,
      token: model.token,
    );
  }

  Future<void> _saveToPrefs(PassengerAuthResponseModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthStorageKeys.token, model.token);
    await prefs.setString(AuthStorageKeys.name, model.name);
    await prefs.setString(AuthStorageKeys.email, model.email);
    await prefs.setInt(AuthStorageKeys.passengerId, model.passengerId);
    if (model.phoneNumber != null) {
      await prefs.setString(AuthStorageKeys.phoneNumber, model.phoneNumber!);
    }
  }
}
