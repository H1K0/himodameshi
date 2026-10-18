import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

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

  Future<void> _onCreate(Database db, int version) async {
    // Создание таблиц
    await db.execute('''
      CREATE TABLE cables (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT     NOT NULL,
        color       TEXT     NOT NULL,
        cable_type  TEXT     NOT NULL,
        created_at  INTEGER  NOT NULL,
        note        TEXT
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

  // ---------- C A B L E S ----------
  Future<List<Map<String, dynamic>>> getCables() async {
    final db = await database;
    return await db.query('cables', orderBy: 'name ASC');
  }

  Future<Map<String, dynamic>?> getCableById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cables',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertCable(Map<String, dynamic> cable) async {
    final db = await database;
    return await db.insert('cables', cable);
  }

  Future<int> updateCable(int id, Map<String, dynamic> cable) async {
    final db = await database;
    return await db.update('cables', cable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCable(int id) async {
    final db = await database;
    return await db.delete('cables', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- T E S T   S E S S I O N S ----------
  Future<int> insertTestSession(Map<String, dynamic> session) async {
    final db = await database;
    return await db.insert('test_sessions', session);
  }

  // ---------- C O N T I N U I T Y   R E S U L T S ----------
  Future<int> insertContinuityResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('continuity_results', result);
  }

  // ---------- C M R R   R E S U L T S ----------
  Future<int> insertCmrrResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('cmrr_results', result);
  }

  // ---------- F R E Q   R E S P O N S E   R E S U L T S ----------
  Future<int> insertFreqResponseResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('freq_response_results', result);
  }

  // ---------- Вспомогательные методы ----------
  Future<void> checkFirstLaunchAndInsertMockData() async {
    if (_isFirstLaunchChecked) return;
    final db = await database;
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM cables')
    );
    if (count == 0) {
      await _insertMockData(db);
    }
    _isFirstLaunchChecked = true;
  }

  Future<void> _insertMockData(Database db) async {
    // ... (как в исходном файле, плюс добавить поле note)
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await db.insert('cables', {
      'name': 'Mogami #1',
      'color': '639922',
      'cable_type': 'xlr',
      'created_at': now - 30 * 24 * 60 * 60,
      'note': 'Купил в 2024, для вокала',
    });
    await db.insert('cables', {
      'name': 'Гитарный длинный',
      'color': 'EF9F27',
      'cable_type': 'jack_ts',
      'created_at': now - 14 * 24 * 60 * 60,
      'note': '',
    });
    await db.insert('cables', {
      'name': 'XLR Neutrik',
      'color': '639922',
      'cable_type': 'xlr',
      'created_at': now - 60 * 24 * 60 * 60,
      'note': 'Профессиональный',
    });

    await db.insert('cables', {
      'name': 'Jack TRS Proel',
      'color': 'EF9F27',
      'cable_type': 'jack_trs',
      'created_at': now - 45 * 24 * 60 * 60,
      'note': '',
    });

    await db.insert('cables', {
      'name': 'Jack TS Klotz',
      'color': 'E24B4A',
      'cable_type': 'jack_ts',
      'created_at': now - 90 * 24 * 60 * 60,
      'note': 'Требует ремонта',
    });
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // ---------- НОВЫЕ МЕТОДЫ ДЛЯ СТАТИСТИКИ И ОТЧЁТОВ ----------

  /// Получить общее количество кабелей
  Future<int> getCablesCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM cables');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Получить количество кабелей по статусу Health Score
  /// status: 'excellent' (score >= 80), 'ok' (score >= 50), 'fail' (score < 50)
  Future<int> getCablesCountByHealthStatus(String status) async {
    final db = await database;

    String whereClause;
    switch (status) {
      case 'excellent':
        whereClause = 'health_score >= 80';
        break;
      case 'ok':
        whereClause = 'health_score >= 50 AND health_score < 80';
        break;
      case 'fail':
        whereClause = 'health_score < 50';
        break;
      default:
        return 0;
    }

    // Нужно получить последний health_score для каждого кабеля
    final result = await db.rawQuery('''
      SELECT COUNT(DISTINCT c.id) as count
      FROM cables c
      LEFT JOIN test_sessions ts ON c.id = ts.cable_id
      WHERE ts.id IN (
        SELECT MAX(id) 
        FROM test_sessions 
        GROUP BY cable_id
      )
      AND ts.health_score IS NOT NULL
      AND $whereClause
    ''');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Получить последнюю тестовую сессию для кабеля
  Future<Map<String, dynamic>?> getLastTestSession(int cableId) async {
    final db = await database;
    final result = await db.query(
      'test_sessions',
      where: 'cable_id = ?',
      whereArgs: [cableId],
      orderBy: 'started_at DESC',
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Получить последние N тестовых сессий для главного экрана
  /// Возвращает список с информацией о кабеле и результатах CMRR
  Future<List<Map<String, dynamic>>> getRecentTestSessions({int limit = 6}) async {
    final db = await database;

    // Получаем последние сессии с информацией о кабеле и CMRR
    final result = await db.rawQuery('''
      SELECT 
        ts.id as session_id,
        ts.cable_id,
        ts.started_at,
        ts.health_score,
        c.name as cable_name,
        c.cable_type,
        c.color as cable_color,
        cr.value_db as cmrr_db,
        cr.status as cmrr_status
      FROM test_sessions ts
      JOIN cables c ON ts.cable_id = c.id
      LEFT JOIN cmrr_results cr ON ts.id = cr.session_id
      WHERE cr.value_db IS NOT NULL
      ORDER BY ts.started_at DESC
      LIMIT ?
    ''', [limit]);

    // Форматируем результат для UI
    return result.map((row) {
      return {
        'id': 'session_${row['session_id']}',
        'cable_id': row['cable_id'],
        'name': row['cable_name'],
        'cable': row['cable_type'],
        'status': row['cmrr_status'] ?? 'unknown',
        'cmrr_db': row['cmrr_db']?.toString() ?? '--',
        'ts': row['started_at'],
        'health_score': row['health_score'],
        'test_type': 'cmrr',
      };
    }).toList();
  }

  /// Получить все кабели с их последним Health Score
  Future<List<Map<String, dynamic>>> getAllCablesWithHealthScore() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT 
        c.*,
        ts.health_score as last_health_score,
        ts.started_at as last_check_date
      FROM cables c
      LEFT JOIN test_sessions ts ON c.id = ts.cable_id
      WHERE ts.id IN (
        SELECT MAX(id) 
        FROM test_sessions 
        GROUP BY cable_id
      )
      ORDER BY c.name ASC
    ''');

    // Для кабелей без тестов health_score будет null
    return result.map((row) {
      return {
        'id': row['id'],
        'name': row['name'],
        'color': row['color'],
        'cable_type': row['cable_type'],
        'created_at': row['created_at'],
        'note': row['note'] ?? '',
        'healthScore': row['last_health_score'],
        'lastCheck': row['last_check_date'],
      };
    }).toList();
  }

  /// Получить полную информацию о кабеле для паспорта
  Future<Map<String, dynamic>?> getCableWithHistory(int cableId) async {
    final db = await database;

    // Основная информация о кабеле
    final cableResult = await db.query(
      'cables',
      where: 'id = ?',
      whereArgs: [cableId],
    );

    if (cableResult.isEmpty) return null;

    final cable = cableResult.first;

    // Все тестовые сессии для этого кабеля
    final sessions = await db.query(
      'test_sessions',
      where: 'cable_id = ?',
      whereArgs: [cableId],
      orderBy: 'started_at DESC',
    );

    // Для каждой сессии получаем результаты тестов
    final List<Map<String, dynamic>> history = [];
    for (final session in sessions) {
      final sessionId = session['id'];

      // Continuity результаты
      final continuity = await db.query(
        'continuity_results',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );

      // CMRR результаты
      final cmrr = await db.query(
        'cmrr_results',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );

      // Freq Response результаты
      final freq = await db.query(
        'freq_response_results',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );

      history.add({
        'session_id': sessionId,
        'started_at': session['started_at'],
        'health_score': session['health_score'],
        'continuity': continuity.isNotEmpty ? continuity.first : null,
        'cmrr': cmrr.isNotEmpty ? cmrr.first : null,
        'freq_response': freq.isNotEmpty ? freq.first : null,
      });
    }

    return {
      'id': cable['id'],
      'name': cable['name'],
      'color': cable['color'],
      'cable_type': cable['cable_type'],
      'created_at': cable['created_at'],
      'note': cable['note'] ?? '',
      'history': history,
    };
  }
}