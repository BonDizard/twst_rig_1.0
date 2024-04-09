import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  late Database _database;

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

  Future<void> resetDatabase() async {
    await initializeDatabase(); // Ensure the database is initialized
    if (_database == null) {
      throw Exception('Database is not initialized');
    }
    await _database.delete('data');
  }

  void dispose() {
    _database.close();
  }
}
