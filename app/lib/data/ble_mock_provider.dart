import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Единственная функция, которая делает всю работу:
/// - принимает название последовательности (например "full_xlr_excellent")
/// - загружает JSON из файла
/// - находит нужную последовательность
/// - выдаёт пакеты по одному с интервалом 0.5 секунды
Stream<Map<String, dynamic>> getBlePacketStream(String sequenceName) async* {
  try {
    final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final sequences = jsonData['sequences'] as Map<String, dynamic>;

    if (!sequences.containsKey(sequenceName)) {
      yield {
        'type': 'error',
        'message': 'Последовательность "$sequenceName" не найдена',
        'available': sequences.keys.toList(),
      };
      return;
    }

    final packets = sequences[sequenceName]['packets'] as List;

    for (var packet in packets) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield packet as Map<String, dynamic>;
    }

    yield {
      'type': 'finished',
      'message': '✅ Последовательность "$sequenceName" завершена',
    };

  } catch (e) {
    yield {
      'type': 'error',
      'message': 'Ошибка: $e',
    };
  }
}

/// Список всех доступных последовательностей (для удобства)
Future<List<String>> getAvailableSequences() async {
  try {
    final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final sequences = jsonData['sequences'] as Map<String, dynamic>;
    return sequences.keys.toList();
  } catch (e) {
    return [];
  }
}

/// Получить все результаты CMRR через Stream (для имитации BLE)
Stream<List<Map<String, dynamic>>> getCmrrResultsStream() async* {
  try {
    final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final cmrrResults = jsonData['results']['cmrr'] as Map<String, dynamic>;

    final List<Map<String, dynamic>> results = [];
    cmrrResults.forEach((key, value) {
      results.add({
        'id': key,
        'name': _formatName(key),
        'cable': value['cable'],
        'status': value['status'],
        'cmrr_db': value['cmrr_db'],
      });
    });

    // Имитируем задержку получения данных через BLE
    await Future.delayed(const Duration(milliseconds: 300));
    yield results;

  } catch (e) {
    yield [];
  }
}

/// Получить конкретный результат CMRR по ID через Stream
Stream<Map<String, dynamic>?> getCmrrResultByIdStream(String id) async* {
  try {
    final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final cmrrResults = jsonData['results']['cmrr'] as Map<String, dynamic>;

    await Future.delayed(const Duration(milliseconds: 200));

    if (cmrrResults.containsKey(id)) {
      final value = cmrrResults[id];
      yield {
        'id': id,
        'name': _formatName(id),
        'cable': value['cable'],
        'status': value['status'],
        'cmrr_db': value['cmrr_db'],
      };
    } else {
      yield null;
    }

  } catch (e) {
    yield null;
  }
}

String _formatName(String key) {
  final parts = key.split('_');
  if (parts.length >= 2) {
    final type = parts[0].toUpperCase();
    final status = parts[1];
    return '$type ${status[0].toUpperCase()}${status.substring(1)}';
  }
  return key;
}