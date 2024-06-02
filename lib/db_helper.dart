import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper();
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE data('
      'timestamp TEXT PRIMARY KEY, '
      'voltage REAL, '
      'current REAL, '
      'torque REAL, '
      'temperature REAL, '
      'thrust REAL, '
      'power REAL, '
      'rpm REAL, '
      'throttle REAL'
      ')',
    );
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await instance.database;
    return await db.query('data');
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
      final db = await instance.database;
      await db.insert(
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

  Future<List<Map<String, dynamic>>> fetchData() async {
    final db = await instance.database;
    final result = await db.query('data');
    return result;
  }

  Future<void> resetDatabase() async {
    final db = await instance.database;
    await db.delete('data');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
