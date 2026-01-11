import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';
import '../../domain/services/database_service.dart';

class SembastDatabaseService implements DatabaseService {
  Database? _db;
  final String? dbPath;
  final String dbName;

  SembastDatabaseService({required this.dbPath, required this.dbName});

  @override
  Future<void> initialize() async {
    if (_db != null) return;
    if (dbPath != null) {
      final dbPathFull = path.join(Directory.current.path, dbPath!, dbName);
      await Directory(path.dirname(dbPathFull)).create(recursive: true);
      _db = await databaseFactoryIo.openDatabase(dbPathFull);
    } else {
      _db = await databaseFactoryMemory.openDatabase(dbName);
    }
  }

  @override
  Future<void> put({
    required String storeName,
    required String key,
    required Map<String, dynamic> value,
    Transaction? transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    await record.put(transaction ?? db, value);
  }

  @override
  Future<Map<String, dynamic>?> get({
    required String storeName,
    required String key,
    Transaction? transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    return await record.get(transaction ?? db);
  }

  @override
  Future<List<Map<String, dynamic>>> find({
    required String storeName,
    Transaction? transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final records = await store.find(transaction ?? db);
    return records.map((r) => r.value).toList();
  }

  @override
  Future<void> drop({
    required String storeName,
    Transaction? transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    await store.drop(transaction ?? db);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
