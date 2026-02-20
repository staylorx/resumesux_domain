import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

/// Use case for removing a job req
class RemoveJobReqUsecase with Loggable {
  final JobReqRepository jobReqRepository;

  /// Creates a new instance of [RemoveJobReqUsecase].
  RemoveJobReqUsecase({Logger? logger, required this.jobReqRepository}) {
    this.logger = logger;
  }

  /// Remove the job req
  Future<Either<Failure, Unit>> call({required JobReqHandle handle}) async {
    logger?.info('[RemoveJobReqUsecase] removing job req ${handle.toString()}');
    final result = await jobReqRepository.remove(handle: handle);
    result.match(
      (failure) => logger?.error(
        '[RemoveJobReqUsecase] Failed to remove job req: ${failure.message}',
      ),
      (_) => {},
    );
    return result;
  }
}
