import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/sembast_memory.dart';

class SembastDatabaseService with Loggable implements DatabaseService {
  Database? _db;
  final String? dbPath;
  final String dbName;

  SembastDatabaseService({
    required this.dbPath,
    required this.dbName,
    Logger? logger,
  }) {
    this.logger = logger;
  }

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
    dynamic transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    await record.put((transaction as Transaction?) ?? db, value);
  }

  @override
  Future<Map<String, dynamic>?> get({
    required String storeName,
    required String key,
    dynamic transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    return await record.get((transaction as Transaction?) ?? db);
  }

  @override
  Future<List<Map<String, dynamic>>> find({
    required String storeName,
    dynamic transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final records = await store.find((transaction as Transaction?) ?? db);
    return records.map((r) => r.value).toList();
  }

  @override
  Future<void> drop({required String storeName, dynamic transaction}) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    await store.drop((transaction as Transaction?) ?? db);
  }

  @override
  Future<void> delete({
    required String storeName,
    required String key,
    dynamic transaction,
  }) async {
    final db = _db!;
    final store = stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    await record.delete((transaction as Transaction?) ?? db);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
