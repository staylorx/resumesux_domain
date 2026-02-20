import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:resumesux_domain/resumesux_domain.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:sembast/sembast_memory.dart' as sembast_memory;

class SembastDatabaseService implements DatabaseService {
  sembast.Database? _db;
  final String? dbPath;
  final String dbName;

  SembastDatabaseService({required this.dbPath, required this.dbName});

  @override
  Future<void> initialize() async {
    if (_db != null) return;
    if (dbPath != null) {
      final dbPathFull = path.join(Directory.current.path, dbPath!, dbName);
      await Directory(path.dirname(dbPathFull)).create(recursive: true);
      _db = await sembast_io.databaseFactoryIo.openDatabase(dbPathFull);
    } else {
      _db = await sembast_memory.databaseFactoryMemory.openDatabase(dbName);
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
    final store = sembast.stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    await record.put((transaction as sembast.Transaction?) ?? db as sembast.Database, value);
  }

  @override
  Future<Map<String, dynamic>?> get({
    required String storeName,
    required String key,
    dynamic transaction,
  }) async {
    final db = _db!;
    final store = sembast.stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    return await record.get((transaction as sembast.Transaction?) ?? db as sembast.Database);
  }

  @override
  Future<List<Map<String, dynamic>>> find({
    required String storeName,
    dynamic transaction,
  }) async {
    final db = _db!;
    final store = sembast.stringMapStoreFactory.store(storeName);
    final records = await store.find((transaction as sembast.Transaction?) ?? db as sembast.Database);
    return records.map((r) => r.value).toList();
  }

  @override
  Future<void> drop({required String storeName, dynamic transaction}) async {
    final db = _db!;
    final store = sembast.stringMapStoreFactory.store(storeName);
    await store.drop((transaction as sembast.Transaction?) ?? db as sembast.Database);
  }

  @override
  Future<void> delete({
    required String storeName,
    required String key,
    dynamic transaction,
  }) async {
    final db = _db!;
    final store = sembast.stringMapStoreFactory.store(storeName);
    final record = store.record(key);
    await record.delete((transaction as sembast.Transaction?) ?? db as sembast.Database);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
