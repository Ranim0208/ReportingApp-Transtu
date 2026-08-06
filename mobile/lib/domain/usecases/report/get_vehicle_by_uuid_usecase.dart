import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../entities/transport_support.dart';
import '../../repositories/report_repository.dart';

class GetVehicleByUuidUseCase {
  final ReportRepository _repository;
  const GetVehicleByUuidUseCase(this._repository);

  Future<Either<Failure, TransportSupport>> call(String uuid) {
    return _repository.getVehicleByUuid(uuid);
  }
}
