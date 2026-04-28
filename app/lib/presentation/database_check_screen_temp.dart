import 'dart:io';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import 'dart:convert';

class DatabaseCheckScreenTemp extends StatefulWidget {
  const DatabaseCheckScreenTemp({super.key});

  @override
  State<DatabaseCheckScreenTemp> createState() => _DatabaseCheckScreenTempState();
}

class _DatabaseCheckScreenTempState extends State<DatabaseCheckScreenTemp> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _cables = [];
  List<Map<String, dynamic>> _testSessions = [];
  List<Map<String, dynamic>> _continuityResults = [];
  List<Map<String, dynamic>> _cmrrResults = [];
  List<Map<String, dynamic>> _freqResults = [];
  bool _isLoading = true;

  // Дополнительная информация о БД
  String _dbPath = '';
  int _dbSize = 0;
  int _lastInsertId = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    await _dbHelper.checkFirstLaunchAndInsertMockData();

    _cables = await _dbHelper.getAllCables();
    _testSessions = await _dbHelper.getAllTestSessions();
    _continuityResults = await _dbHelper.getAllContinuityResults();
    _cmrrResults = await _dbHelper.getAllCmrrResults();
    _freqResults = await _dbHelper.getAllFreqResponseResults();

    // Получаем информацию о БД
    await _loadDatabaseInfo();

    setState(() => _isLoading = false);
  }

  Future<void> _loadDatabaseInfo() async {
    try {
      // Получаем путь к БД
      final db = await _dbHelper.database;
      _dbPath = db.path;

      // Получаем размер файла БД
      final file = File(_dbPath);
      if (await file.exists()) {
        _dbSize = await file.length();
      }

      // Пробуем вставить тестовую запись и получить последний ID
      // (только для демонстрации работы с БД)
      final testId = await _dbHelper.insertTestRecord();
      if (testId > 0) {
        _lastInsertId = testId;
        // Удаляем тестовую запись, чтобы не засорять БД
        await _dbHelper.deleteTestRecord(testId);
      }
    } catch (e) {
      print('Error loading DB info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Database Check',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF9F27)),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Кабели', _cables, _buildCableRow),
            const SizedBox(height: 24),
            _buildSection('Тестовые сессии', _testSessions, _buildTestSessionRow),
            const SizedBox(height: 24),
            _buildSection('Результаты целостности', _continuityResults, _buildContinuityRow),
            const SizedBox(height: 24),
            _buildSection('Результаты CMRR', _cmrrResults, _buildCmrrRow),
            const SizedBox(height: 24),
            _buildSection('Результаты АЧХ', _freqResults, _buildFreqRow),
            const SizedBox(height: 24),
            _buildDatabaseInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDatabaseInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ИНФОРМАЦИЯ О БАЗЕ ДАННЫХ',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF666666),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1F1F1F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.storage, size: 18, color: Color(0xFFEF9F27)),
                  const SizedBox(width: 10),
                  const Text(
                    'Файл БД:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dbPath.split('/').last,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFFAFAFA)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.sd_storage, size: 18, color: Color(0xFFEF9F27)),
                  const SizedBox(width: 10),
                  const Text(
                    'Размер:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatFileSize(_dbSize),
                    style: const TextStyle(fontSize: 12, color: Color(0xFFFAFAFA)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.table_chart, size: 18, color: Color(0xFFEF9F27)),
                  const SizedBox(width: 10),
                  const Text(
                    'Всего записей:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_cables.length + _testSessions.length + _continuityResults.length + _cmrrResults.length + _freqResults.length}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFFAFAFA)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: Color(0xFF97C459)),
                  const SizedBox(width: 10),
                  const Text(
                    'Статус:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Подключено',
                    style: TextStyle(fontSize: 12, color: Color(0xFF97C459)),
                  ),
                ],
              ),
              if (_lastInsertId > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.code, size: 18, color: Color(0xFFEF9F27)),
                    const SizedBox(width: 10),
                    const Text(
                      'Последний INSERT ID:',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_lastInsertId',
                      style: const TextStyle(fontSize: 12, color: Color(0xFFFAFAFA)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> data, Widget Function(Map<String, dynamic>) buildRow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEF9F27),
          ),
        ),
        const SizedBox(height: 8),
        if (data.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Нет данных',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          )
        else
          ...data.map((item) => buildRow(item)),
      ],
    );
  }

  Widget _buildCableRow(Map<String, dynamic> cable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID: ${cable['id']} | ${cable['name']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Тип: ${cable['cable_type']} | Цвет: #${cable['color']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
          Text(
            'Создан: ${_formatTimestamp(cable['created_at'])}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSessionRow(Map<String, dynamic> session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID: ${session['id']} | Cable ID: ${session['cable_id']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Health Score: ${session['health_score'] ?? 'NULL'} | BLE: ${session['ble_device_id']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
          Text(
            'Начало: ${_formatTimestamp(session['started_at'])}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildContinuityRow(Map<String, dynamic> result) {
    final conductors = jsonDecode(result['conductors']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session ID: ${result['session_id']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Статус: ${result['status']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
          Text(
            'Проводники: ${conductors}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildCmrrRow(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session ID: ${result['session_id']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'CMRR: ${result['value_db']} дБ | Статус: ${result['status']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  Widget _buildFreqRow(Map<String, dynamic> result) {
    final points = jsonDecode(result['points']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Session ID: ${result['session_id']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAFAFA),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Статус: ${result['status']}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
          Text(
            'Точки: ${points}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}