import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import '../../domain/services/database_service.dart';

class SembastDatabaseService implements DatabaseService {
  Database? _db;
  final String? dbPath;
  final String dbName;

  SembastDatabaseService(this.dbPath, this.dbName);

  @override
  Future<void> initialize(String? dbPath, String dbName) async {
    if (_db != null) return;
    if (dbPath != null) {
      final dbPathFull = path.join(Directory.current.path, dbPath);
      await Directory(path.dirname(dbPathFull)).create(recursive: true);
      _db = await databaseFactoryIo.openDatabase(dbPathFull);
    } else {
      _db = await databaseFactoryMemory.openDatabase(dbName);
    }
  }

  @override
  Future<void> put(
    String storeName,
    String key,
    Map<String, dynamic> value, {
    Transaction? transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    await record.put(transaction ?? db, value);
  }

  @override
  Future<Map<String, dynamic>?> get(
    String storeName,
    String key, {
    Transaction? transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    return await record.get(transaction ?? db);
  }

  @override
  Future<List<Map<String, dynamic>>> find(
    String storeName, {
    Transaction? transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final records = await store.find(transaction ?? db);
    return records.map((r) => r.value).toList();
  }

  @override
  Future<void> drop(String storeName, {Transaction? transaction}) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    await store.drop(transaction ?? db);
  }
}
