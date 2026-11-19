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

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cables (
        id           TEXT     PRIMARY KEY,
        name         TEXT     NOT NULL,
        color        TEXT     NOT NULL,
        cable_type   TEXT     NOT NULL,
        created_at   INTEGER  NOT NULL,
        note         TEXT,
        team_id      TEXT,
        synced       INTEGER  NOT NULL DEFAULT 0,
        version      INTEGER  NOT NULL DEFAULT 0,
        dirty        INTEGER  NOT NULL DEFAULT 0,
        assignee_id  TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE test_sessions (
        id                TEXT     PRIMARY KEY,
        cable_id          TEXT     NOT NULL REFERENCES cables(id) ON DELETE CASCADE,
        started_at        INTEGER  NOT NULL,
        health_score      INTEGER,
        ble_device_id     TEXT     NOT NULL,
        synced            INTEGER  NOT NULL DEFAULT 0,
        pv                INTEGER  NOT NULL DEFAULT 1,
        rules_version     TEXT,
        health_incomplete INTEGER  NOT NULL DEFAULT 0,
        note              TEXT
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

    await db.execute('''
      CREATE TABLE team_cursors (
        team_id       TEXT     PRIMARY KEY,
        cursor        INTEGER  NOT NULL DEFAULT 0,
        last_sync_at  INTEGER,
        last_status   TEXT
      )
    ''');
  }

  /// Миграция v1 → v2: добираем sync-колонки и таблицу team_cursors.
  /// Существующие строки получают значения по умолчанию; health_incomplete и
  /// rules_version для уже лежащих сессий пересчитываются, иначе push упадёт
  /// на серверной валидации (testMetaErrors требует непустой rules_version).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // cables: sync-колонки. NOT NULL DEFAULT позволяет ALTER для существующих строк.
      await db.execute('ALTER TABLE cables ADD COLUMN team_id TEXT');
      await db.execute(
        'ALTER TABLE cables ADD COLUMN synced INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE cables ADD COLUMN version INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE cables ADD COLUMN dirty INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE cables ADD COLUMN assignee_id TEXT');

      // test_sessions: поля, требуемые NewTest при push.
      await db.execute(
        'ALTER TABLE test_sessions ADD COLUMN synced INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE test_sessions ADD COLUMN pv INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE test_sessions ADD COLUMN rules_version TEXT',
      );
      await db.execute(
        'ALTER TABLE test_sessions ADD COLUMN health_incomplete INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute('ALTER TABLE test_sessions ADD COLUMN note TEXT');

      // rules_version — обязательно непустое (сервер: 1..32 символа).
      await db.execute(
        "UPDATE test_sessions SET rules_version = '0.1' WHERE rules_version IS NULL",
      );

      // health_incomplete: истина, если выполнены не все применимые измерения.
      // jack_ts — только целостность; jack_trs/xlr — целостность + CMRR + АЧХ.
      await db.execute('''
        UPDATE test_sessions SET health_incomplete = 1
        WHERE id IN (
          SELECT ts.id
          FROM test_sessions ts
          JOIN cables c ON ts.cable_id = c.id
          WHERE
            (c.cable_type IN ('jack_trs','xlr') AND (
               NOT EXISTS(SELECT 1 FROM cmrr_results cr WHERE cr.session_id = ts.id)
               OR NOT EXISTS(SELECT 1 FROM freq_response_results fr WHERE fr.session_id = ts.id)
            ))
            OR (c.cable_type = 'jack_ts' AND
               NOT EXISTS(SELECT 1 FROM continuity_results cr WHERE cr.session_id = ts.id))
            OR (c.cable_type NOT IN ('jack_ts','jack_trs','xlr'))
        )
      ''');

      await db.execute('''
        CREATE TABLE team_cursors (
          team_id       TEXT     PRIMARY KEY,
          cursor        INTEGER  NOT NULL DEFAULT 0,
          last_sync_at  INTEGER,
          last_status   TEXT
        )
      ''');
    }
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
    // Новый локальный кабель: не выгружен (synced=0), без правок (dirty=0),
    // версия 0 — сервер назначит version при приёме (sync.md §3.4).
    // team_id не трогаем: null, пока пользователь не выберет команду для выгрузки.
    data['synced'] = 0;
    data['dirty'] = 0;
    data['version'] = 0;
    await db.insert('cables', data);
    return newId; // Возвращаем сгенерированный ID
  }

  Future<int> updateCable(String id, Map<String, dynamic> cable) async {
    final db = await database;
    final Map<String, dynamic> data = Map.from(cable);
    // Правка атрибутов. Если кабель уже выгружен (synced=1) — помечаем dirty=1:
    // правка уйдёт в push как cable_update (sync.md §3.1). Невыгруженный кабель
    // остаётся в секции новых (synced=0), dirty не нужен.
    final existing = await db.query(
      'cables',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (existing.isNotEmpty && (existing.first['synced'] as int?) == 1) {
      data['dirty'] = 1;
    }
    // version не трогаем: это последняя известная серверная версия, её шлём как
    // базу правки (CableUpdateItem.version).
    return await db.update('cables', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCable(String id) async {
    final db = await database;
    // Локальное удаление отслеживаемого кабеля = перестать отслеживать:
    // сервер не оповещается, его копия остаётся (sync.md §5.5). CASCADE удаляет
    // сессии и результаты локально.
    return await db.delete('cables', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- T E S T   S E S S I O N S ----------

  Future<String> insertTestSession(Map<String, dynamic> session) async {
    final db = await database;
    final String newId = generateUuidV7String();
    final Map<String, dynamic> data = Map.from(session);
    data['id'] = newId;
    // Новый тест: не выгружен (synced=0). Поля NewTest добираем дефолтами,
    // если вызывающая сторона не задала явно. health_incomplete пересчитывается
    // recomputeHealthIncomplete() после вставки результатов.
    data['synced'] = 0;
    data.putIfAbsent('pv', () => 1);
    data.putIfAbsent('rules_version', () => '0.1');
    data.putIfAbsent('health_incomplete', () => 0);
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

    if (count != null && count > 0) {
      return; // Если уже есть данные, не импортируем
    }

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

      // health_incomplete: jack_ts — только целостность; jack_trs/xlr — + CMRR + АЧХ.
      final bool healthIncomplete = cableType == null
          ? false
          : !(cableType.supportsCmrr
                ? (cmrrDb != null && freqValues != null)
                : true);

      // ИСПОЛЬЗУЕМ insertTestSession
      final String sessionId = await insertTestSession({
        'cable_id': cableId,
        'started_at': now,
        'health_score': healthScore,
        'ble_device_id': 'MOCK-DEVICE',
        'pv': 1,
        'rules_version': '0.1',
        'health_incomplete': healthIncomplete ? 1 : 0,
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

  // ---------- S Y N C   (Himo Hub) ----------
  // Контракт: docs/spec/hub/sync.md. Методы для SyncEngine: что отправлять,
  // как применять ответ pull и per-item результаты push.

  /// Кабели для секции `cables` push: team_id задан, synced=0 (sync.md §3.1).
  Future<List<Map<String, dynamic>>> getNewCablesForPush() async {
    final db = await database;
    return await db.query(
      'cables',
      where: 'team_id IS NOT NULL AND synced = 0',
    );
  }

  /// Кабели для секции `cable_updates` push: synced=1 AND dirty=1 (sync.md §3.1).
  Future<List<Map<String, dynamic>>> getDirtyCableUpdates() async {
    final db = await database;
    return await db.query('cables', where: 'synced = 1 AND dirty = 1');
  }

  /// Тесты для секции `tests` push: synced=0 у кабелей с team_id (sync.md §3.1).
  Future<List<Map<String, dynamic>>> getUnsyncedTestsForPush() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT ts.* FROM test_sessions ts
      JOIN cables c ON ts.cable_id = c.id
      WHERE ts.synced = 0 AND c.team_id IS NOT NULL
      ORDER BY ts.started_at ASC
    ''');
  }

  /// Строки результатов сессии для сборки NewTest.
  Future<
    ({
      Map<String, dynamic>? continuity,
      Map<String, dynamic>? cmrr,
      Map<String, dynamic>? freq,
    })
  >
  getTestResults(String sessionId) async {
    final db = await database;
    final cont = await db.query(
      'continuity_results',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    final cmrr = await db.query(
      'cmrr_results',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    final freq = await db.query(
      'freq_response_results',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return (
      continuity: cont.isNotEmpty ? cont.first : null,
      cmrr: cmrr.isNotEmpty ? cmrr.first : null,
      freq: freq.isNotEmpty ? freq.first : null,
    );
  }

  /// Отслеживаемые кабели команды для pull (sync.md §5.2): team_id AND synced=1.
  Future<List<String>> getTrackedCableIds(String teamId) async {
    final db = await database;
    final rows = await db.query(
      'cables',
      columns: ['id'],
      where: 'team_id = ? AND synced = 1',
      whereArgs: [teamId],
    );
    return rows.map((r) => r['id'] as String).toList();
  }

  /// Команды, по которым есть отслеживаемые кабели — для pull per team.
  Future<List<String>> getTrackedTeamIds() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT team_id FROM cables WHERE team_id IS NOT NULL AND synced = 1',
    );
    return rows.map((r) => r['team_id'] as String).toList();
  }

  /// Курсор команды (sync.md §5.1). 0 — ещё ничего не загружалось.
  Future<int> getCursor(String teamId) async {
    final db = await database;
    final rows = await db.query(
      'team_cursors',
      where: 'team_id = ?',
      whereArgs: [teamId],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return (rows.first['cursor'] as int?) ?? 0;
  }

  /// Сохранить курсор команды и статус последней синхронизации.
  Future<void> saveCursor(String teamId, int cursor, String status) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await db.insert('team_cursors', {
      'team_id': teamId,
      'cursor': cursor,
      'last_sync_at': now,
      'last_status': status,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// upsert кабеля из pull (sync.md §5.4). [row] — готовая строка cables из
  /// маппера `cableToRow` (без dirty — его проставляет этот метод). При local
  /// dirty=1 атрибуты и version НЕ перезаписываем — локальная правка ещё не
  /// выгружена, конфликт вернёт сервер при следующем push. Тесты такого кабеля
  /// записываются как обычно.
  Future<void> upsertCableFromPull(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'] as String;
    final existing = await db.query(
      'cables',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (existing.isEmpty) {
      // Новый для приложения кабель (первая загрузка из каталога, §6).
      final r = Map<String, dynamic>.from(row)..['dirty'] = 0;
      await db.insert(
        'cables',
        r,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }
    final dirty = (existing.first['dirty'] as int?) == 1;
    if (dirty) {
      // Не трогаем атрибуты/version; только подтверждаем отслеживание.
      await db.update(
        'cables',
        {'synced': 1, 'team_id': row['team_id']},
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      final r = Map<String, dynamic>.from(row)..['dirty'] = 0;
      await db.update('cables', r, where: 'id = ?', whereArgs: [id]);
    }
  }

  /// upsert теста из pull. Тесты неизменяемы — перезаписываем по id (sync.md §5.4).
  /// Строки ([session], [continuity], [cmrr], [freq]) — готовые из маппера
  /// `testToRows`. Состав результатов может измениться (например, тест
  /// инвалидирован) — отсутствующие result-таблицы очищаем.
  Future<void> upsertTestFromPull(
    Map<String, dynamic> session,
    Map<String, dynamic>? continuity,
    Map<String, dynamic>? cmrr,
    Map<String, dynamic>? freq,
  ) async {
    final db = await database;
    final id = session['id'] as String;
    await db.insert(
      'test_sessions',
      session,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (continuity != null) {
      await db.insert(
        'continuity_results',
        continuity,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        'continuity_results',
        where: 'session_id = ?',
        whereArgs: [id],
      );
    }
    if (cmrr != null) {
      await db.insert(
        'cmrr_results',
        cmrr,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete('cmrr_results', where: 'session_id = ?', whereArgs: [id]);
    }
    if (freq != null) {
      await db.insert(
        'freq_response_results',
        freq,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete(
        'freq_response_results',
        where: 'session_id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Кабель удалён в Hub (sync.md §5.5): перестаём отслеживать, локальная
  /// копия с историей остаётся.
  Future<void> untrackCable(String id) async {
    final db = await database;
    await db.update(
      'cables',
      {'team_id': null, 'synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Принять серверную версию кабеля при конфликте (sync.md §4): пользователь
  /// выбрал версию Hub — перезаписываем локальные атрибуты, dirty=0.
  /// [row] — готовая строка из `cableToRow`.
  Future<void> applyServerCableVersion(Map<String, dynamic> row) async {
    final db = await database;
    final r = Map<String, dynamic>.from(row)..['dirty'] = 0;
    await db.update(
      'cables',
      r,
      where: 'id = ?',
      whereArgs: [row['id'] as String],
    );
  }

  /// Оставить свою версию при конфликте (sync.md §4): берём version из ответа
  /// как базу, свои значения и dirty=1 оставляем — правка уйдёт со следующим push.
  Future<void> keepLocalCableVersion(String id, int serverVersion) async {
    final db = await database;
    await db.update(
      'cables',
      {'version': serverVersion, 'dirty': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Новый кабель принят сервером (sync.md §3.4): synced=1, version из ответа.
  Future<void> markCableSynced(String id, int version) async {
    final db = await database;
    await db.update(
      'cables',
      {'synced': 1, 'version': version, 'dirty': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Правка принята сервером (sync.md §3.4): dirty=0, version из ответа.
  Future<void> markCableUpdateSynced(String id, int version) async {
    final db = await database;
    await db.update(
      'cables',
      {'dirty': 0, 'version': version},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Тест принят сервером (sync.md §3.4): synced=1.
  Future<void> markTestSynced(String id) async {
    final db = await database;
    await db.update(
      'test_sessions',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Пересчитать health_incomplete по наличию результатов и типу кабеля.
  /// Вызывается после вставки результатов нового теста (testing_results).
  Future<void> recomputeHealthIncomplete(String sessionId) async {
    final db = await database;
    final sess = await db.query(
      'test_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    if (sess.isEmpty) return;
    final cableId = sess.first['cable_id'] as String;
    final cables = await db.query(
      'cables',
      where: 'id = ?',
      whereArgs: [cableId],
      limit: 1,
    );
    if (cables.isEmpty) return;
    final cableType = cables.first['cable_type'] as String?;
    final hasCont =
        (Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COUNT(*) FROM continuity_results WHERE session_id = ?',
                [sessionId],
              ),
            ) ??
            0) >
        0;
    final hasCmrr =
        (Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COUNT(*) FROM cmrr_results WHERE session_id = ?',
                [sessionId],
              ),
            ) ??
            0) >
        0;
    final hasFreq =
        (Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COUNT(*) FROM freq_response_results WHERE session_id = ?',
                [sessionId],
              ),
            ) ??
            0) >
        0;
    bool incomplete;
    switch (cableType) {
      case 'jack_ts':
        incomplete = !hasCont;
        break;
      case 'jack_trs':
      case 'xlr':
        incomplete = !(hasCont && hasCmrr && hasFreq);
        break;
      default:
        incomplete = true;
    }
    await db.update(
      'test_sessions',
      {'health_incomplete': incomplete ? 1 : 0},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }
}
