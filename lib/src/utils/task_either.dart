import 'package:fpdart/fpdart.dart';

/// Converts `TaskEither<L, R>` to `Future<Either<L, R>>` - call this at your boundary
Future<Either<L, R>> runTaskEither<L, R>(TaskEither<L, R> taskEither) {
  return taskEither.run();
}
