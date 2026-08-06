import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../entities/passenger.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<Either<Failure, Passenger>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
