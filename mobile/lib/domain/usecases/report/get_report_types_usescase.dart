import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../entities/report_type.dart';
import '../../repositories/report_repository.dart';

class GetReportTypesUseCase {
  final ReportRepository _repository;
  const GetReportTypesUseCase(this._repository);

  Future<Either<Failure, List<ReportType>>> call() {
    return _repository.getReportTypes();
  }
}