import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  late Database _database;

  Future<void> initializeDatabase() async {
    String path = await getDatabasesPath();
    _database = await openDatabase(
      join(path, 'my_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data('
          'timestamp TEXT PRIMARY KEY, '
          'voltage REAL, '
          'current REAL, '
          'torque REAL, '
          'temperature REAL, ' // Ensure temperature column is included
          'thrust REAL, '
          'power REAL, '
          'rpm REAL, '
          'throttle REAL'
          ')',
        );
      },
      version: 2,
    );
  }

  Future<void> insertData(
    DateTime timestamp,
    double voltage,
    double current,
    double torque,
    double temperature,
    double thrust,
    double power,
    double rpm,
    double throttle,
  ) async {
    try {
      await _database.insert(
        'data',
        {
          'timestamp': timestamp.toIso8601String(),
          'voltage': voltage,
          'current': current,
          'torque': torque,
          'temperature': temperature,
          'thrust': thrust,
          'power': power,
          'rpm': rpm,
          'throttle': throttle
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error while inserting: ${e.toString()}');
    }
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
