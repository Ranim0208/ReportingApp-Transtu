import 'package:dartz/dartz.dart';
import '../../core/errors/failure.dart';
import '../entities/tracking_result.dart';

abstract class TrackingRepository {
  Future<Either<Failure, TrackingResult>> trackReport(String uuid);
}
