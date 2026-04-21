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
    // 1. Загружаем JSON файл
    final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');

    // 2. Превращаем текст в объекты Dart
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    // 3. Ищем нужную последовательность
    final sequences = jsonData['sequences'] as Map<String, dynamic>;

    if (!sequences.containsKey(sequenceName)) {
      // Если последовательности нет — выдаём ошибку и выходим
      yield {
        'type': 'error',
        'message': 'Последовательность "$sequenceName" не найдена',
        'available': sequences.keys.toList(),
      };
      return;
    }

    // 4. Берём список пакетов
    final packets = sequences[sequenceName]['packets'] as List;

    // 5. Выдаём пакеты по одному с интервалом
    for (var packet in packets) {
      await Future.delayed(const Duration(milliseconds: 500));
      yield packet as Map<String, dynamic>;
    }

    // 6. В конце выдаём сигнал, что всё закончено
    yield {
      'type': 'finished',
      'message': '✅ Последовательность "$sequenceName" завершена',
    };

  } catch (e) {
    // Если произошла ошибка (например, файл не найден)
    yield {
      'type': 'error',
      'message': 'Ошибка: $e',
    };
  }
}

/// Список всех доступных последовательностей (для удобства)
Future<List<String>> getAvailableSequences() async {
  try {
    final jsonString = await rootBundle.loadString('assets/app/mock/ble_mock_packets.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);
    final sequences = jsonData['sequences'] as Map<String, dynamic>;
    return sequences.keys.toList();
  } catch (e) {
    return [];
  }
}