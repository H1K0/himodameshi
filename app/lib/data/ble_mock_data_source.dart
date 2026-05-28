import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'ble_data_source.dart';
import 'package:app/domain/health_score_calculator.dart';
import 'test_models.dart';

/// Mock-источник данных (читает из JSON файла)
class BleMockDataSource implements BleDataSource {
  final String sequenceName;
  StreamController<Map<String, dynamic>>? _controller;
  bool _isActive = false;

  // Кэш для данных кабелей (чтобы не парсить JSON каждый раз)
  List<Map<String, dynamic>>? _cachedCables;
  Map<String, dynamic>? _cachedStatistics;
  List<Map<String, dynamic>>? _cachedRecentTests;

  BleMockDataSource({required this.sequenceName});

  @override
  Stream<Map<String, dynamic>> get dataStream {
    if (_controller == null) {
      _controller = StreamController<Map<String, dynamic>>.broadcast();
      _startMockStream();
    }
    return _controller!.stream;
  }

  void _startMockStream() async {
    if (_isActive) return;
    _isActive = true;

    try {
      final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final sequences = jsonData['sequences'] as Map<String, dynamic>;
      if (!sequences.containsKey(sequenceName)) {
        _controller?.addError('Sequence "$sequenceName" not found');
        return;
      }

      final packets = sequences[sequenceName]['packets'] as List;

      for (final packet in packets) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (!_isActive) break;
        _controller?.add(packet as Map<String, dynamic>);
      }

      _controller?.add({'type': 'finished', 'message': 'Mock sequence completed'});
    } catch (e) {
      _controller?.addError(e);
    } finally {
      _isActive = false;
    }
  }

  // --------------------------------------------------------------------------
  // НОВЫЕ МЕТОДЫ для работы с данными кабелей
  // --------------------------------------------------------------------------

  @override
  Future<List<Map<String, dynamic>>> getAllCables() async {
    // Возвращаем из кэша, если уже загружены
    if (_cachedCables != null) return _cachedCables!;

    try {
      final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      _cachedCables = _parseCablesFromJson(jsonData);
      return _cachedCables!;
    } catch (e) {
      print('[MOCK] Error loading cables: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getCollectionStatistics() async {
    if (_cachedStatistics != null) return _cachedStatistics!;

    final cables = await getAllCables();
    int excellent = 0, ok = 0, fail = 0;

    for (final cable in cables) {
      final healthScore = cable['healthScore'] as int?;
      final hasCatastrophic = cable['hasCatastrophic'] as bool? ?? false;

      if (hasCatastrophic) {
        fail++;
      } else if (healthScore != null) {
        if (healthScore >= 80) excellent++;
        else if (healthScore >= 50) ok++;
        else fail++;
      }
    }

    _cachedStatistics = {
      'total': cables.length,
      'excellent': excellent,
      'ok': ok,
      'fail': fail,
    };

    return _cachedStatistics!;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentTests({int limit = 6}) async {
    if (_cachedRecentTests != null) return _cachedRecentTests!;

    try {
      final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      _cachedRecentTests = _parseRecentTestsFromJson(jsonData, limit);
      return _cachedRecentTests!;
    } catch (e) {
      print('[MOCK] Error loading recent tests: $e');
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // ПРИВАТНЫЕ методы парсинга JSON
  // --------------------------------------------------------------------------

  /// Парсит все кабели из JSON-файла
  List<Map<String, dynamic>> _parseCablesFromJson(Map<String, dynamic> jsonData) {
    final List<Map<String, dynamic>> results = [];

    try {
      final continuityResults = jsonData['results']['continuity'] as Map<String, dynamic>;
      final cmrrResults = jsonData['results']['cmrr'] as Map<String, dynamic>;
      final freqResults = jsonData['results']['freq_response'] as Map<String, dynamic>;

      for (final entry in continuityResults.entries) {
        final String cableId = entry.key;
        final continuityData = entry.value;

        // Пропускаем служебные записи (начинаются с _)
        if (cableId.startsWith('_')) continue;

        final String cableTypeStr = continuityData['cable'] ?? 'unknown';

        // Определяем CableType
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
          default:
            continue;
        }

        // Формируем проводники
        final conductorsMap = continuityData['conductors'] as Map<String, dynamic>;
        final List<Map<String, dynamic>> conductors = [];
        for (final condEntry in conductorsMap.entries) {
          conductors.add({
            'r': (condEntry.value['r'] as num).toDouble(),
            's': condEntry.value['s'] as String,
          });
        }

        // Проверяем катастрофические failure (open/short)
        final bool hasCatastrophic = conductors.any((c) =>
        c['s'] == 'open' || c['s'] == 'short'
        );

        // Берём CMRR если есть
        final hasCmrr = cmrrResults.containsKey(cableId);
        final double? cmrrDb = hasCmrr
            ? (cmrrResults[cableId]['cmrr_db'] as num).toDouble()
            : null;

        // Берём АЧХ если есть
        final hasFreq = freqResults.containsKey(cableId);
        List<double>? freqValues;
        if (hasFreq) {
          final freqData = freqResults[cableId];
          freqValues = (freqData['v'] as List).map((e) => (e as num).toDouble()).toList();
        }

        // Рассчитываем Health Score
        final bool cmrrRun = cableType.supportsCmrr;
        final HealthScoreResult result = HealthScoreCalculator.calculate(
          cableType: cableType,
          continuityConductors: conductors,
          cmrrDb: cmrrDb,
          freqResponseValues: freqValues,
          continuityRun: true,
          cmrrRun: cmrrRun,
          freqRun: hasFreq,
        );

        final int? healthScore = result.score?.toInt();

        // Определяем цветовую категорию
        String colorCategory = 'green';
        if (hasCatastrophic) {
          colorCategory = 'red';
        } else if (healthScore != null) {
          if (healthScore >= 80) colorCategory = 'green';
          else if (healthScore >= 50) colorCategory = 'yellow';
          else colorCategory = 'red';
        }

        // Форматируем имя для отображения
        String displayName = _formatCableName(cableId, cableTypeStr, continuityData, cmrrResults);

        results.add({
          'id': cableId,
          'name': displayName,
          'cable_type': cableTypeStr,
          'healthScore': healthScore,
          'hasCatastrophic': hasCatastrophic,
          'continuityStatus': continuityData['status'],
          'colorCategory': colorCategory,
          'checksCount': _calculateChecksCount(cableId, continuityData),
          'lastCheck': _getLastCheckDate(cableId, continuityData, cmrrResults, freqResults),
        });
      }
    } catch (e) {
      print('[MOCK] Parse error: $e');
    }

    return results;
  }

  /// Парсит последние тесты (CMRR) для главного экрана
  List<Map<String, dynamic>> _parseRecentTestsFromJson(Map<String, dynamic> jsonData, int limit) {
    final List<Map<String, dynamic>> tests = [];

    try {
      final cmrrResults = jsonData['results']['cmrr'] as Map<String, dynamic>?;
      if (cmrrResults != null) {
        // Сортируем по времени (ts) от новых к старым
        final sortedEntries = cmrrResults.entries.toList()
          ..sort((a, b) {
            final tsA = (a.value as Map<String, dynamic>)['ts'] ?? 0;
            final tsB = (b.value as Map<String, dynamic>)['ts'] ?? 0;
            return tsB.compareTo(tsA);
          });

        // Берём первые limit записей
        for (final entry in sortedEntries.take(limit)) {
          final testId = entry.key;
          if (testId.startsWith('_')) continue; // пропускаем служебные

          final testData = entry.value as Map<String, dynamic>;

          tests.add({
            'id': 'cmrr_$testId',
            'name': _formatCableNameShort(testData['cable'] ?? 'unknown'),
            'cable': testData['cable'] ?? 'unknown',
            'status': testData['status'] ?? 'unknown',
            'cmrr_db': testData['cmrr_db']?.toString() ?? '--',
            'ts': testData['ts'] ?? 0,
            'test_type': 'cmrr',
            'note': testData['_note'] ?? '',
          });
        }
      }
    } catch (e) {
      print('[MOCK] Error parsing recent tests: $e');
    }

    return tests;
  }

  /// Форматирует имя кабеля для отображения в коллекции
  String _formatCableName(String id, String type, Map<String, dynamic> continuityData, Map<String, dynamic> cmrrResults) {
    switch (type) {
      case 'jack_ts':
        return 'Jack TS ${_capitalize(continuityData['status'] ?? '')}';
      case 'jack_trs':
        return 'Jack TRS ${_capitalize(cmrrResults[id]?['status'] ?? '')}';
      case 'xlr':
        return 'XLR ${_capitalize(cmrrResults[id]?['status'] ?? '')}';
      default:
        return id;
    }
  }

  /// Короткое имя для последних тестов
  String _formatCableNameShort(String cableType) {
    switch (cableType) {
      case 'jack_ts': return 'JACK TS';
      case 'jack_trs': return 'JACK TRS';
      case 'xlr': return 'XLR';
      default: return cableType.toUpperCase();
    }
  }

  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  int _calculateChecksCount(String cableId, Map<String, dynamic> continuityData) {
    // В mock-режиме возвращаем случайное число (или можно парсить из истории)
    // Для реального режима это будет из БД
    return DateTime.now().millisecondsSinceEpoch % 10 + 1;
  }

  String _getLastCheckDate(String cableId, Map<String, dynamic> continuityData,
      Map<String, dynamic> cmrrResults, Map<String, dynamic> freqResults) {
    // Ищем максимальный ts среди всех результатов для этого кабеля
    int maxTs = continuityData['ts'] ?? 0;

    if (cmrrResults.containsKey(cableId)) {
      final ts = cmrrResults[cableId]['ts'] ?? 0;
      if (ts > maxTs) maxTs = ts;
    }

    if (freqResults.containsKey(cableId)) {
      final ts = freqResults[cableId]['ts'] ?? 0;
      if (ts > maxTs) maxTs = ts;
    }

    if (maxTs == 0) return 'нет данных';

    final date = DateTime.fromMillisecondsSinceEpoch(maxTs * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  // --------------------------------------------------------------------------
  // СУЩЕСТВУЮЩИЕ МЕТОДЫ (без изменений)
  // --------------------------------------------------------------------------

  @override
  Future<bool> sendCommand(Map<String, dynamic> command) async {
    print('[MOCK] Sending command: $command');
    return true;
  }

  @override
  bool get isConnected => true;

  @override
  Future<void> disconnect() async {
    _isActive = false;
    await _controller?.close();
    _controller = null;
  }

  @override
  void dispose() {
    _isActive = false;
    _controller?.close();
  }
}