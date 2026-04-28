import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _isFirstLaunchChecked = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'himo_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<int> insertTestRecord() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return await db.insert('cables', {
      'name': 'TEST_TEMP_ДЛЯ_ПРОВЕРКИ',
      'color': 'EF9F27',
      'cable_type': 'jack_ts',
      'created_at': now,
    });
  }

  /// Удаляет тестовую запись по ID
  Future<void> deleteTestRecord(int id) async {
    final db = await database;
    await db.delete('cables', where: 'id = ? AND name = ?', whereArgs: [id, 'TEST_TEMP_ДЛЯ_ПРОВЕРКИ']);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Создание таблиц
    await db.execute('''
      CREATE TABLE cables (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT     NOT NULL,
        color       TEXT     NOT NULL,
        cable_type  TEXT     NOT NULL,
        created_at  INTEGER  NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE test_sessions (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        cable_id       INTEGER NOT NULL REFERENCES cables(id) ON DELETE CASCADE,
        started_at     INTEGER NOT NULL,
        health_score   INTEGER,
        ble_device_id  TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE continuity_results (
        session_id   INTEGER PRIMARY KEY REFERENCES test_sessions(id) ON DELETE CASCADE,
        status       TEXT NOT NULL,
        conductors   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cmrr_results (
        session_id  INTEGER PRIMARY KEY REFERENCES test_sessions(id) ON DELETE CASCADE,
        value_db    REAL NOT NULL,
        status      TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE freq_response_results (
        session_id  INTEGER PRIMARY KEY REFERENCES test_sessions(id) ON DELETE CASCADE,
        status      TEXT NOT NULL,
        points      TEXT NOT NULL
      )
    ''');
  }

  /// Проверяет, первый ли запуск, и вставляет тестовые данные если нужно
  Future<void> checkFirstLaunchAndInsertMockData() async {
    if (_isFirstLaunchChecked) return;

    final db = await database;

    // Проверяем, есть ли данные в таблице cables
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM cables')
    );

    if (count == 0) {
      await _insertMockData(db);
    }

    _isFirstLaunchChecked = true;
  }

  Future<void> _insertMockData(Database db) async {
    try {
      // Вставка кабелей
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final cable1Id = await db.insert('cables', {
        'name': 'Mogami #1',
        'color': '639922',
        'cable_type': 'xlr',
        'created_at': now - 30 * 24 * 60 * 60, // 30 дней назад
      });

      final cable2Id = await db.insert('cables', {
        'name': 'Гитарный длинный',
        'color': 'EF9F27',
        'cable_type': 'jack_ts',
        'created_at': now - 14 * 24 * 60 * 60, // 14 дней назад
      });

      // Вставка тестовых сессий
      final session1Id = await db.insert('test_sessions', {
        'cable_id': cable1Id,
        'started_at': now - 2 * 24 * 60 * 60, // 2 дня назад
        'health_score': 94,
        'ble_device_id': 'HM-2A4F-001',
      });

      final session2Id = await db.insert('test_sessions', {
        'cable_id': cable2Id,
        'started_at': now - 1 * 24 * 60 * 60, // 1 день назад
        'health_score': 68,
        'ble_device_id': 'HM-2A4F-001',
      });

      // Вставка результатов целостности
      await db.insert('continuity_results', {
        'session_id': session1Id,
        'status': 'ok',
        'conductors': jsonEncode({
          'pin1': {'r': 0.68, 's': 'ok'},
          'pin2': {'r': 0.74, 's': 'ok'},
          'pin3': {'r': 0.71, 's': 'ok'},
        }),
      });

      await db.insert('continuity_results', {
        'session_id': session2Id,
        'status': 'warning',
        'conductors': jsonEncode({
          'tip': {'r': 0.85, 's': 'ok'},
          'sleeve': {'r': 18.70, 's': 'warning'},
        }),
      });

      // Вставка результатов CMRR
      await db.insert('cmrr_results', {
        'session_id': session1Id,
        'value_db': 68.4,
        'status': 'excellent',
      });

      await db.insert('cmrr_results', {
        'session_id': session2Id,
        'value_db': 31.2,
        'status': 'fail',
      });

      // Вставка результатов АЧХ
      await db.insert('freq_response_results', {
        'session_id': session1Id,
        'status': 'excellent',
        'points': jsonEncode([
          [10, 0.1], [20, 0.1], [100, 0.0], [1000, 0.0],
          [10000, 0.0], [20000, -0.2], [40000, -0.9]
        ]),
      });

      await db.insert('freq_response_results', {
        'session_id': session2Id,
        'status': 'fail',
        'points': jsonEncode([
          [10, 0.3], [20, 0.2], [100, 0.0], [1000, 0.0],
          [10000, -2.4], [20000, -3.6], [40000, -16.5]
        ]),
      });

      print('Mock data inserted successfully');
    } catch (e) {
      print('Error inserting mock data: $e');
    }
  }

  // Методы для получения данных (для временного экрана)
  Future<List<Map<String, dynamic>>> getAllCables() async {
    final db = await database;
    return await db.query('cables', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getAllTestSessions() async {
    final db = await database;
    return await db.query('test_sessions', orderBy: 'started_at DESC');
  }

  Future<List<Map<String, dynamic>>> getAllContinuityResults() async {
    final db = await database;
    return await db.query('continuity_results');
  }

  Future<List<Map<String, dynamic>>> getAllCmrrResults() async {
    final db = await database;
    return await db.query('cmrr_results');
  }

  Future<List<Map<String, dynamic>>> getAllFreqResponseResults() async {
    final db = await database;
    return await db.query('freq_response_results');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}