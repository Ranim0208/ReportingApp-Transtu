import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/errors/failure.dart';
import '../../entities/report.dart';
import '../../repositories/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository _repository;
  const SubmitReportUseCase(this._repository);

  Future<Either<Failure, Report>> call({
    required String supportUuid,
    required int reportTypeId,
    required String description,
    String? passengerName,
    String? passengerEmail,
    String? passengerPhone,
    List<File>? files,
  }) {
    return _repository.submitReport(
      supportUuid: supportUuid,
      reportTypeId: reportTypeId,
      description: description,
      passengerName: passengerName,
      passengerEmail: passengerEmail,
      passengerPhone: passengerPhone,
      files: files,
    );
  }
}
