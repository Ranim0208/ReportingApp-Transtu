import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/passenger.dart';

abstract class AuthRepository {
  Future<Either<Failure, Passenger>> register({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? recaptchaToken,
  });

  Future<Either<Failure, Passenger>> login({
    required String email,
    required String password,
    String? recaptchaToken,
  });

  Future<Either<Failure, void>> logout();
}
