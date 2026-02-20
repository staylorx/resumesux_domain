import 'package:resumesux_domain/resumesux_domain.dart';

/// Sembast implementation of Transaction.
class SembastTransaction implements Transaction {
  @override
  final dynamic db;

  /// Creates a SembastTransaction with the database transaction handle.
  SembastTransaction(this.db);
}
