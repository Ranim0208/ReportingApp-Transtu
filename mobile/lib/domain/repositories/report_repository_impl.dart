import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/report.dart';
import '../../domain/entities/report_type.dart';
import '../../domain/entities/transport_support.dart';
import '../../domain/repositories/report_repository.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/report_response_model.dart';
import '../../data/models/report_type_model.dart';
import '../../data/models/transport_support_model.dart';
import 'package:dio/dio.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ApiClient _apiClient;

  const ReportRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, List<ReportType>>> getReportTypes() async {
    try {
      final list = await _apiClient.getReportTypes();
      final types = list
          .map((e) => ReportTypeModel.fromJson(e as Map<String, dynamic>))
          .map((m) => ReportType(
                reportTypeId: m.reportTypeId,
                code: m.code,
                label: m.label,
                description: m.description,
                active: m.active,
              ))
          .toList();
      return Right(types);
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
  Future<Either<Failure, TransportSupport>> getVehicleByUuid(
      String uuid) async {
    try {
      final json = await _apiClient.getVehicleByUuid(uuid);
      final model = TransportSupportModel.fromJson(json);
      return Right(TransportSupport(
        transportSupportId: model.transportSupportId,
        uuid: model.uuid,
        reference: model.reference,
        label: model.label,
        supportStatus: model.supportStatus,
        supportTypeCode: model.supportTypeCode,
        supportTypeLabel: model.supportTypeLabel,
      ));
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
  Future<Either<Failure, Report>> submitReport({
    required String supportUuid,
    required int reportTypeId,
    required String description,
    String? passengerName,
    String? passengerEmail,
    String? passengerPhone,
    List<File>? files,
  }) async {
    try {
      final json = await _apiClient.submitReport(
        supportUuid: supportUuid,
        reportTypeId: reportTypeId,
        description: description,
        passengerName: passengerName,
        passengerEmail: passengerEmail,
        passengerPhone: passengerPhone,
        filePaths: files?.map((f) => f.path).toList(),
      );
      final model = ReportResponseModel.fromJson(json);
      return Right(Report(
        reportId: model.reportId,
        uuid: model.uuid,
        reference: model.reference,
        creationDate: model.creationDate,
        description: model.description,
        priority: model.priority,
        reportTypeCode: model.reportTypeCode,
        reportTypeLabel: model.reportTypeLabel,
        statusCode: model.status.code,
        statusLabel: model.status.label,
        supportLabel: model.supportLabel,
        supportTypeCode: model.supportTypeCode,
        supportTypeLabel: model.supportTypeLabel,
      ));
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
}
