import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../entities/tracking_result.dart';
import '../../repositories/tracking_repository.dart';

class TrackReportUseCase {
  final TrackingRepository _repository;
  const TrackReportUseCase(this._repository);

  Future<Either<Failure, TrackingResult>> call(String uuid) {
    return _repository.trackReport(uuid);
  }
}
