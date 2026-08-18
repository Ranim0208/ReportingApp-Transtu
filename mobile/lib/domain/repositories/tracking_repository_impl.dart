import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/tracking_result.dart';
import '../../domain/repositories/tracking_repository.dart';
import '../../data/datasources/remote/api_client.dart';
import '../../data/models/tracking_response_model.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final ApiClient _apiClient;

  const TrackingRepositoryImpl(this._apiClient);

  @override
  Future<Either<Failure, TrackingResult>> trackReport(String uuid) async {
    try {
      final json = await _apiClient.trackReport(uuid);
      final model = TrackingResponseModel.fromJson(json);
      return Right(TrackingResult(
        uuid: model.uuid,
        reference: model.reference,
        creationDate: model.creationDate,
        description: model.description,
        statusCode: model.statusCode,
        statusLabel: model.statusLabel,
        reportTypeLabel: model.reportTypeLabel,
        supportLabel: model.supportLabel,
        replies: model.replies
            .map((r) => ReplyEntity(
                  message: r.message,
                  replyDate: r.replyDate,
                ))
            .toList(),
      ));
    } on AppException catch (e) {
      return Left(Failure(e.message));
    } on DioException catch (e) {
      final appError = e.error;
      if (appError is AppException) {
        return Left(Failure(appError.message));
      }
      // Extrait le message du backend directement
      try {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          final message = data['message'] as String?;
          if (message != null) {
            // Traduit les messages techniques en français
            if (message.contains('not found') ||
                message.contains('Not Found')) {
              return Left(
                  Failure('Signalement introuvable. Vérifiez l\'UUID saisi.'));
            }
            return Left(Failure(message));
          }
        }
      } catch (_) {}
      return Left(Failure('Signalement introuvable. Vérifiez l\'UUID saisi.'));
    } catch (e) {
      final raw = e.toString();
      if (raw.contains('Error:')) {
        final extracted = raw.split('Error:').last.trim();
        return Left(Failure(extracted));
      }
      return Left(Failure('Une erreur est survenue.'));
    }
  }
}
