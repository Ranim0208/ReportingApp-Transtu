import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../entities/passenger.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Either<Failure, Passenger>> call({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? recaptchaToken,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      recaptchaToken: recaptchaToken,
    );
  }
}
