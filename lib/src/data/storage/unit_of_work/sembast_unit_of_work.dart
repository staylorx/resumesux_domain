import 'package:fpdart/fpdart.dart';
import 'package:resumesux_domain/resumesux_domain.dart';

import 'sembast_transaction.dart';

/// Sembast implementation of UnitOfWork.
class SembastUnitOfWork implements UnitOfWork {
  final DatabaseService dbService;

  /// Creates a SembastUnitOfWork with the required DatabaseService.
  SembastUnitOfWork({required this.dbService});

  @override
  TaskEither<Failure, T> run<T>(
    TaskEither<Failure, T> Function(Transaction txn) operation,
  ) {
    return TaskEither.tryCatch(
      () async {
        T? result;
        final txnResult = await dbService
            .transaction(
              operation: (txn) async {
                final opResult = await operation(SembastTransaction(txn)).run();
                result = opResult.fold((l) => throw l, (r) => r);
                return unit;
              },
            )
            .run();
        return txnResult.match((failure) => throw failure, (_) => result as T);
      },
      (error, stackTrace) =>
          error is Failure ? error : ServiceFailure(error.toString()),
    );
  }

  @override
  TaskEither<Failure, Unit> commit() {
    // Sembast transactions are auto-committed; manual commit not supported
    return TaskEither.left(
      ServiceFailure('Manual commit not supported in SembastUnitOfWork'),
    );
  }

  @override
  TaskEither<Failure, Unit> rollback() {
    // Sembast transactions are auto-rolled back on failure; manual rollback not supported
    return TaskEither.left(
      ServiceFailure('Manual rollback not supported in SembastUnitOfWork'),
    );
  }
}
