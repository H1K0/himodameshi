import 'dart:async';
import 'ble_data_source.dart';
import 'ble_mock_data_source.dart';
import 'ble_provider.dart';
import 'ble_real_data_source.dart';

/// Тип источника данных
enum DataSourceType {
  mock,
  real,
}

/// Менеджер для переключения между mock и real источниками
class BleDataManager {
  static final BleDataManager _instance = BleDataManager._internal();
  factory BleDataManager() => _instance;
  BleDataManager._internal();

  BleDataSource? _currentDataSource;
  DataSourceType _currentType = DataSourceType.mock;

  // Флаг для отслеживания подключения
  bool _isConnecting = false;

  // Поток для уведомления UI о смене источника
  final _typeController = StreamController<DataSourceType>.broadcast();
  Stream<DataSourceType> get typeStream => _typeController.stream;

  // Поток для уведомления о статусе подключения BLE
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;

  DataSourceType get currentType => _currentType;

  /// Переключение между источниками данных
  Future<void> switchTo(DataSourceType type, {String sequenceName = 'full_xlr_excellent'}) async {
    // Отключаем текущий источник
    if (_currentDataSource != null) {
      try {
        await _currentDataSource!.disconnect();
      } catch (e) {
        print('[BLE] Error disconnecting: $e');
      }
      _currentDataSource = null;
    }

    // Создаём новый источник
    if (type == DataSourceType.mock) {
      // Всегда используем реальный источник, так как данные (и моки, и реал) теперь в БД
      _currentDataSource = BleRealDataSource();
      _currentType = type;
      if (!_typeController.isClosed) {
        _typeController.add(type);
      }
    } else {
      // Для реального источника
      final realSource = BleRealDataSource();
      _currentDataSource = realSource;
      _currentType = type;

      // Сразу уведомляем UI, что источник сменился (данные из БД будут доступны)
      if (!_typeController.isClosed) {
        _typeController.add(type);
      }

      // Запускаем подключение к BLE в фоне (не ждём)
      _connectToBleInBackground(realSource);
    }
  }

  /// Фоновое подключение к BLE устройству
  Future<void> _connectToBleInBackground(BleRealDataSource realSource) async {
    if (_isConnecting) return;
    _isConnecting = true;

    print('[BLE] Starting background connection...');

    // Уведомляем о начале подключения
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(ConnectionStatus.connecting);
    }

    try {
      final result = await realSource.bleProvider.connect();
      print('[BLE] Connection result: $result');

      // Уведомляем о результате подключения
      if (!_connectionStatusController.isClosed) {
        if (result == ConnectionResult.success) {
          _connectionStatusController.add(ConnectionStatus.connected);
        } else {
          _connectionStatusController.add(ConnectionStatus.error);
        }
      }
    } catch (e) {
      print('[BLE] Connection error: $e');
      if (!_connectionStatusController.isClosed) {
        _connectionStatusController.add(ConnectionStatus.error);
      }
    } finally {
      _isConnecting = false;
    }
  }

  /// Получить текущий источник данных
  BleDataSource? get currentDataSource => _currentDataSource;

  /// Проверка, активен ли реальный источник
  bool get isRealMode => _currentType == DataSourceType.real;

  /// Проверка, активен ли mock-источник
  bool get isMockMode => _currentType == DataSourceType.mock;

  void dispose() {
    _currentDataSource?.dispose();
    if (!_typeController.isClosed) {
      _typeController.close();
    }
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.close();
    }
  }

  /// Получить список кабелей (автоматически из текущего источника)
  Future<List<Map<String, dynamic>>> getAllCables() async {
    if (_currentDataSource == null) return [];
    return await _currentDataSource!.getAllCables();
  }

  /// Получить статистику коллекции
  Future<Map<String, dynamic>> getCollectionStatistics() async {
    if (_currentDataSource == null) return {'total': 0, 'excellent': 0, 'ok': 0, 'fail': 0};
    return await _currentDataSource!.getCollectionStatistics();
  }

  /// Получить последние тесты
  Future<List<Map<String, dynamic>>> getRecentTests({int limit = 6}) async {
    if (_currentDataSource == null) return [];
    return await _currentDataSource!.getRecentTests(limit: limit);
  }
}