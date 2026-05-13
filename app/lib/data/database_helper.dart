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
      version: 2, // увеличиваем версию для миграции
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Создание таблиц (как было ранее)
    await db.execute('''
      CREATE TABLE cables (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT     NOT NULL,
        color       TEXT     NOT NULL,
        cable_type  TEXT     NOT NULL,
        created_at  INTEGER  NOT NULL
      )
    ''');

    // Добавляем колонку note в cables (для заметки)
    await db.execute('ALTER TABLE cables ADD COLUMN note TEXT');

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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Добавляем колонку note в таблицу cables, если её нет
      try {
        await db.execute('ALTER TABLE cables ADD COLUMN note TEXT');
      } catch (e) {
        // Колонка уже существует
      }
    }
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
    // ... остальные вставки без изменений
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}