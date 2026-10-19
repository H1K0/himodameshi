import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_data_source.dart';
import 'ble_provider.dart';
import 'database_helper.dart';

/// Реальный BLE-источник данных
class BleRealDataSource implements BleDataSource {
  final BleProvider bleProvider = BleProvider();
  BluetoothCharacteristic? _dataCharacteristic;
  BluetoothCharacteristic? _commandCharacteristic;
  StreamSubscription<List<int>>? _notificationSubscription;
  StreamController<Map<String, dynamic>>? _controller;

  // UUID для CMD и DATA характеристик (замените на реальные)
  static const String commandCharacteristicUuid = "484D0002-4A5B-6C7D-8E9F-A0B1C2D3E4F5";
  static const String dataCharacteristicUuid = "484D0003-4A5B-6C7D-8E9F-A0B1C2D3E4F5";

  BleRealDataSource() {
    _setupDataSubscription();
  }

  void _setupDataSubscription() async {
    _controller = StreamController<Map<String, dynamic>>.broadcast();

    // Слушаем статус подключения
    bleProvider.statusStream.listen((status) async {
      if (status == ConnectionStatus.connected) {
        await _discoverCharacteristics();
      }
    });
  }

  /// Поиск нужных характеристик после подключения
  Future<void> _discoverCharacteristics() async {
    final device = bleProvider.connectedDevice;
    if (device == null) return;

    await device.discoverServices();

    // Сбрасываем сохранённые характеристики перед новым поиском
    _dataCharacteristic = null;
    _commandCharacteristic = null;

    for (final service in device.servicesList) {
      for (final characteristic in service.characteristics) {
        // Ищем DATA характеристику
        if (characteristic.uuid.toString() == dataCharacteristicUuid) {
          _dataCharacteristic = characteristic;
          // Подписываемся на уведомления
          await characteristic.setNotifyValue(true);
          _notificationSubscription?.cancel();
          _notificationSubscription = characteristic.onValueReceived.listen((value) {
            _onDataReceived(value);
          });
        }
        // Ищем CMD характеристику (исправление 2)
        if (characteristic.uuid.toString() == commandCharacteristicUuid) {
          _commandCharacteristic = characteristic;
        }
      }
    }
  }

  /// Обработка входящих данных
  void _onDataReceived(List<int> data) {
    try {
      final jsonString = utf8.decode(data);
      final Map<String, dynamic> packet = jsonDecode(jsonString);
      _controller?.add(packet);
      print('[REAL] Received: $packet');
    } catch (e) {
      print('[REAL] Parse error: $e, data: $data');
    }
  }

  @override
  Stream<Map<String, dynamic>> get dataStream {
    _controller ??= StreamController<Map<String, dynamic>>.broadcast();
    return _controller!.stream;
  }

  /// Отправка CMD-пакета
  @override
  Future<bool> sendCommand(Map<String, dynamic> command) async {
    if (!bleProvider.isConnected) {
      print('[REAL] Cannot send command: not connected');
      return false;
    }

    // Используем сохранённую командную характеристику (исправление 2)
    if (_commandCharacteristic == null) {
      print('[REAL] Command characteristic not found');
      return false;
    }

    final jsonString = jsonEncode(command);
    final data = utf8.encode(jsonString);

    try {
      await _commandCharacteristic!.write(data, withoutResponse: false);
      print('[REAL] Command sent: $command');
      return true;
    } catch (e) {
      print('[REAL] Send error: $e');
      return false;
    }
  }

  /// Отправка start_test команды
  Future<bool> startTest({
    required String test, // "continuity", "cmrr", "freq_response", "full"
    required String cable, // "jack_ts", "jack_trs", "xlr"
  }) async {
    final command = {
      'type': 'cmd',
      'pv': 1,
      'cmd': 'start_test',
      'test': test,
      'cable': cable,
      'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };
    return await sendCommand(command);
  }

  /// Отправка cancel команды
  Future<bool> cancel() async {
    final command = {
      'type': 'cmd',
      'pv': 1,
      'cmd': 'cancel',
    };
    return await sendCommand(command);
  }

  @override
  bool get isConnected => bleProvider.isConnected;

  @override
  Future<void> disconnect() async {
    // Исправление 1: не закрываем _controller, чтобы переподключение работало
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
    await bleProvider.disconnect();
    // _controller остаётся открытым для будущих подключений
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    if (_controller != null && !_controller!.isClosed) {
      _controller?.close();}
    bleProvider.dispose();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCables() async {
    final db = DatabaseHelper();
    return await db.getAllCablesWithHealthScore();
  }

  @override
  Future<Map<String, dynamic>> getCollectionStatistics() async {
    final db = DatabaseHelper();
    final total = await db.getCablesCount();
    final excellent = await db.getCablesCountByHealthStatus('excellent');
    final ok = await db.getCablesCountByHealthStatus('ok');
    final fail = await db.getCablesCountByHealthStatus('fail');

    return {
      'total': total,
      'excellent': excellent,
      'ok': ok,
      'fail': fail,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentTests({int limit = 6}) async {
    final db = DatabaseHelper();
    return await db.getRecentTestSessions(limit:limit);
  }
}