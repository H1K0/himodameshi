import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

enum BleConnectionStatus {
  connected,
  disconnected,
  connecting,
}

class BleMockProvider {
  static final BleMockProvider _instance = BleMockProvider._internal();
  factory BleMockProvider() => _instance;
  BleMockProvider._internal();

  final _statusController = StreamController<BleConnectionStatus>.broadcast();
  Stream<BleConnectionStatus> get statusStream => _statusController.stream;

  BleConnectionStatus _currentStatus = BleConnectionStatus.disconnected;
  BleConnectionStatus get currentStatus => _currentStatus;

  StreamSubscription? _currentSubscription;

  void _setStatus(BleConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  Future<void> connect() async {
    if (_currentStatus == BleConnectionStatus.connected) {
      return;
    }

    _setStatus(BleConnectionStatus.connecting);

    // Имитируем подключение через BLE
    await Future.delayed(const Duration(milliseconds: 800));
    _setStatus(BleConnectionStatus.connected);
  }

  Future<void> disconnect() async {
    if (_currentSubscription != null) {
      await _currentSubscription?.cancel();
      _currentSubscription = null;
    }
    _setStatus(BleConnectionStatus.disconnected);
  }

  Future<void> reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  /// Получить все результаты CMRR через Stream (для имитации BLE)
  Stream<List<Map<String, dynamic>>> getCmrrResultsStream() async* {
    // Ждём подключения
    while (_currentStatus != BleConnectionStatus.connected) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_currentStatus == BleConnectionStatus.disconnected) {
        yield [];
        return;
      }
    }

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
    // Ждём подключения
    while (_currentStatus != BleConnectionStatus.connected) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_currentStatus == BleConnectionStatus.disconnected) {
        yield null;
        return;
      }
    }

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

  void dispose() {
    _statusController.close();
    _currentSubscription?.cancel();
  }
}

// Для обратной совместимости с существующим кодом
final bleProvider = BleMockProvider();

Stream<List<Map<String, dynamic>>> getCmrrResultsStream() {
  return bleProvider.getCmrrResultsStream();
}

Stream<Map<String, dynamic>?> getCmrrResultByIdStream(String id) {
  return bleProvider.getCmrrResultByIdStream(id);
}