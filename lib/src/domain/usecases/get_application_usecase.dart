import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

class GetApplicationUseCase with Loggable {
  final ApplicationRepository repository;

  GetApplicationUseCase(this.repository);

  Future<Either<Failure, Application>> execute(ApplicationHandle handle) async {
    final results = await repository.getByHandle(handle: handle);
    results.match(
      (failure) => logger?.error(
        '[GetApplicationUseCase] Failed to get application: ${failure.message}',
      ),
      (_) => {},
    );
    return results;
  }
}
