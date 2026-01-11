import 'package:sembast/sembast.dart';

/// Abstract interface for database operations to allow swapping implementations (e.g., Sembast, Hive, SQLite).
abstract class DatabaseService {
  /// Initializes the database with optional path and name.
  Future<void> initialize(String? dbPath, String dbName);

  /// Stores a value in the specified store with the given key.
  Future<void> put(
    String storeName,
    String key,
    Map<String, dynamic> value, {
    Transaction? transaction,
  });

  /// Retrieves a value from the specified store by key.
  Future<Map<String, dynamic>?> get(
    String storeName,
    String key, {
    Transaction? transaction,
  });

  /// Finds all records in the specified store.
  Future<List<Map<String, dynamic>>> find(
    String storeName, {
    Transaction? transaction,
  });

  /// Drops the specified store.
  Future<void> drop(String storeName, {Transaction? transaction});
}
