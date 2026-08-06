import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/report.dart';
import '../entities/report_type.dart';
import '../entities/transport_support.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<ReportType>>> getReportTypes();

  Future<Either<Failure, TransportSupport>> getVehicleByUuid(String uuid);

  Future<Either<Failure, Report>> submitReport({
    required String supportUuid,
    required int reportTypeId,
    required String description,
    String? passengerName,
    String? passengerEmail,
    String? passengerPhone,
    List<File>? files,
  });
}
