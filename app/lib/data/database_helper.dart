import 'package:app/data/test_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:uuidv7/uuidv7.dart';
import '../domain/health_score_calculator.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'himo_database.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cables (
        id          TEXT     PRIMARY KEY,
        name        TEXT     NOT NULL,
        color       TEXT     NOT NULL,
        cable_type  TEXT     NOT NULL,
        created_at  INTEGER  NOT NULL,
        note        TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE test_sessions (
        id             TEXT     PRIMARY KEY,
        cable_id       TEXT     NOT NULL REFERENCES cables(id) ON DELETE CASCADE,
        started_at     INTEGER  NOT NULL,
        health_score   INTEGER,
        ble_device_id  TEXT     NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE continuity_results (
        session_id   TEXT PRIMARY KEY REFERENCES test_sessions(id) ON DELETE CASCADE,
        status       TEXT NOT NULL,
        conductors   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cmrr_results (
        session_id  TEXT PRIMARY KEY REFERENCES test_sessions(id) ON DELETE CASCADE,
        value_db    REAL NOT NULL,
        status      TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE freq_response_results (
        session_id  TEXT PRIMARY KEY REFERENCES test_sessions(id) ON DELETE CASCADE,
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

  Future<Map<String, dynamic>?> getCableById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'cables',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<String> insertCable(Map<String, dynamic> cable) async {
    final db = await database;
    final String newId = generateUuidV7String();
    final Map<String, dynamic> data = Map.from(cable);
    data['id'] = newId;
    await db.insert('cables', data);
    return newId; // Возвращаем сгенерированный ID
  }

  Future<int> updateCable(String id, Map<String, dynamic> cable) async {
    final db = await database;
    return await db.update('cables', cable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCable(String id) async {
    final db = await database;
    return await db.delete('cables', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- T E S T   S E S S I O N S ----------

  Future<String> insertTestSession(Map<String, dynamic> session) async {
    final db = await database;
    final String newId = generateUuidV7String();
    final Map<String, dynamic> data = Map.from(session);
    data['id'] = newId;
    await db.insert('test_sessions', data);
    return newId; // Возвращаем сгенерированный ID
  }

  // ---------- R E S U L T S ----------

  Future<int> insertContinuityResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('continuity_results', result);
  }

  Future<int> insertCmrrResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('cmrr_results', result);
  }

  Future<int> insertFreqResponseResult(Map<String, dynamic> result) async {
    final db = await database;
    return await db.insert('freq_response_results', result);
  }

  /// Получить последнюю тестовую сессию для кабеля
  Future<Map<String, dynamic>?> getLastTestSession(String cableId) async {
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

  // ---------- Вспомогательные методы ----------
  Future<void> importMockDataIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM cables'),
    );

    if (count != null && count > 0)
      return; // Если уже есть данные, не импортируем

    final jsonString = await rootBundle.loadString(
      'mock/ble_mock_packets.json',
    );
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final continuityResults =
        jsonData['results']['continuity'] as Map<String, dynamic>;
    final cmrrResults = jsonData['results']['cmrr'] as Map<String, dynamic>;
    final freqResults =
        jsonData['results']['freq_response'] as Map<String, dynamic>;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    for (final entry in continuityResults.entries) {
      final cableIdStr = entry.key;
      if (cableIdStr.startsWith('_')) continue;

      final continuityData = entry.value;
      final cableTypeStr = continuityData['cable'] ?? 'unknown';

      String displayName = cableIdStr
          .split('_')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '',
          )
          .join(' ');

      // ИСПОЛЬЗУЕМ insertCable
      final String cableId = await insertCable({
        'name': displayName,
        'color': '639922',
        'cable_type': cableTypeStr,
        'created_at': now,
        'note': 'Импортирован из mock-данных',
      });

      final conductorsMap =
          continuityData['conductors'] as Map<String, dynamic>;
      final List<Map<String, dynamic>> conductors = [];
      for (final condEntry in conductorsMap.entries) {
        conductors.add({
          'name': condEntry.key,
          'r': (condEntry.value['r'] as num).toDouble(),
          's': condEntry.value['s'] as String,
        });
      }

      final double? cmrrDb = cmrrResults.containsKey(cableIdStr)
          ? (cmrrResults[cableIdStr]['cmrr_db'] as num).toDouble()
          : null;

      List<double>? freqValues;
      if (freqResults.containsKey(cableIdStr)) {
        freqValues = (freqResults[cableIdStr]['v'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }

      CableType? cableType;
      switch (cableTypeStr) {
        case 'xlr':
          cableType = CableType.xlr;
          break;
        case 'jack_trs':
          cableType = CableType.jackTrs;
          break;
        case 'jack_ts':
          cableType = CableType.jackTs;
          break;
      }

      int healthScore = 0;
      if (cableType != null) {
        final healthResult = HealthScoreCalculator.calculate(
          cableType: cableType,
          continuityConductors: conductors,
          cmrrDb: cmrrDb,
          freqResponseValues: freqValues,
          continuityRun: true,
          cmrrRun: cableType.supportsCmrr,
          freqRun: freqValues != null,
        );
        healthScore = (healthResult.score ?? 0).toInt();
      }

      // ИСПОЛЬЗУЕМ insertTestSession
      final String sessionId = await insertTestSession({
        'cable_id': cableId,
        'started_at': now,
        'health_score': healthScore,
        'ble_device_id': 'MOCK-DEVICE',
      });

      // Вставляем результаты
      await insertContinuityResult({
        'session_id': sessionId,
        'status': continuityData['status'],
        'conductors': jsonEncode(conductors),
      });

      if (cmrrDb != null) {
        await insertCmrrResult({
          'session_id': sessionId,
          'value_db': cmrrDb,
          'status': cmrrResults[cableIdStr]['status'],
        });
      }

      if (freqValues != null) {
        await insertFreqResponseResult({
          'session_id': sessionId,
          'status': freqResults[cableIdStr]['status'],
          'points': jsonEncode(freqValues),
        });
      }
    }
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

  /// Получить последние N тестовых сессий для главного экрана
  /// Возвращает список с информацией о кабеле и результатах CMRR
  Future<List<Map<String, dynamic>>> getRecentTestSessions({
    int limit = 6,
  }) async {
    final db = await database;

    // Убрали WHERE, чтобы показывать ВСЕ сессии, а не только с CMRR
    final result = await db.rawQuery(
      '''
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
      ORDER BY ts.started_at DESC
      LIMIT ?
    ''',
      [limit],
    );

    // Форматируем результат для UI
    return result.map((row) {
      return {
        'id': 'session_${row['session_id']}',
        'cable_id': row['cable_id'],
        'name': row['cable_name'],
        'cable': row['cable_type'],
        'status':
            row['cmrr_status'] ?? 'unknown', // Если нет CMRR, будет unknown
        'cmrr_db': row['cmrr_db']?.toString() ?? '--',
        'ts': row['started_at'],
        'health_score': row['health_score'],
        'test_type': row['cmrr_db'] != null
            ? 'cmrr'
            : 'other', // Помечаем тип теста
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
        ts.started_at as last_check_date,
        (SELECT COUNT(*) FROM test_sessions WHERE cable_id = c.id) as checks_count
      FROM cables c
      LEFT JOIN test_sessions ts ON c.id = ts.cable_id
      WHERE ts.id IN (
        SELECT MAX(id) 
        FROM test_sessions 
        GROUP BY cable_id
      )
      OR ts.id IS NULL
      ORDER BY c.name ASC
    ''');

    return result.map((row) {
      return {
        'id': row['id'] as String,
        'name': row['name'],
        'color': row['color'],
        'cable_type': row['cable_type'],
        'created_at': row['created_at'],
        'note': row['note'] ?? '',
        'healthScore': row['last_health_score'],
        'lastCheck': row['last_check_date'],
        'checksCount': row['checks_count'] ?? 0,
      };
    }).toList();
  }

  /// Получить полную информацию о кабеле для паспорта
  Future<Map<String, dynamic>?> getCableWithHistory(String cableId) async {
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

  /// Получить полные данные конкретной сессии для отображения результатов
  Future<Map<String, dynamic>?> getSessionDetails(String sessionId) async {
    final db = await database;

    // Получаем сессию и кабель
    final sessionResult = await db.rawQuery(
      '''
      SELECT 
        ts.id as session_id,
        ts.health_score,
        ts.started_at,
        c.cable_type
      FROM test_sessions ts
      JOIN cables c ON ts.cable_id = c.id
      WHERE ts.id = ?
    ''',
      [sessionId],
    );

    if (sessionResult.isEmpty) return null;
    final session = sessionResult.first;

    // Целостность
    final continuity = await db.query(
      'continuity_results',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    // CMRR
    final cmrr = await db.query(
      'cmrr_results',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    // АЧХ
    final freq = await db.query(
      'freq_response_results',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    return {
      'session_id': session['session_id'],
      'health_score': session['health_score'],
      'started_at': session['started_at'],
      'cable_type': session['cable_type'],
      'continuity': continuity.isNotEmpty ? continuity.first : null,
      'cmrr': cmrr.isNotEmpty ? cmrr.first : null,
      'freq_response': freq.isNotEmpty ? freq.first : null,
    };
  }
}
