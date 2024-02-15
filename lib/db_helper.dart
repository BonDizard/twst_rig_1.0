import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  var _database;

  Future<void> initializeDatabase() async {
    String path = await getDatabasesPath();
    _database = await openDatabase(
      join(path, 'my_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data(timestamp TEXT PRIMARY KEY, voltage REAL, current REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertData(
      DateTime timestamp, double voltage, double current) async {
    await _database.insert(
      'data',
      {
        'timestamp': timestamp.toIso8601String(),
        'voltage': voltage,
        'current': current
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    return await _database.query('data');
  }

  void dispose() {
    _database.close();
  }
}
