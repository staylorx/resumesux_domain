import 'package:sembast/sembast.dart';

/// Abstract interface for database operations to allow swapping implementations (e.g., Sembast, Hive, SQLite).
abstract class DatabaseService {
  /// Initializes the database.
  Future<void> initialize();

  /// Stores a value in the specified store with the given key.
  Future<void> put({
    required String storeName,
    required String key,
    required Map<String, dynamic> value,
    Transaction? transaction,
  });

  /// Retrieves a value from the specified store by key.
  Future<Map<String, dynamic>?> get({
    required String storeName,
    required String key,
    Transaction? transaction,
  });

  /// Finds all records in the specified store.
  Future<List<Map<String, dynamic>>> find({
    required String storeName,
    Transaction? transaction,
  });

  /// Drops the specified store.
  Future<void> drop({required String storeName, Transaction? transaction});

  /// Deletes a record from the specified store by key.
  Future<void> delete({
    required String storeName,
    required String key,
    Transaction? transaction,
  });
}
