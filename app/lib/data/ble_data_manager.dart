import 'dart:async';
import 'ble_data_source.dart';
import 'ble_mock_data_source.dart';
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

  // Поток для уведомления UI о смене источника
  final _typeController = StreamController<DataSourceType>.broadcast();
  Stream<DataSourceType> get typeStream => _typeController.stream;

  DataSourceType get currentType => _currentType;

  /// Переключение между источниками данных
  Future<void> switchTo(DataSourceType type, {String sequenceName = 'full_xlr_excellent'}) async {
    // Отключаем текущий источник
    if (_currentDataSource != null) {
      await _currentDataSource!.disconnect();
      _currentDataSource = null;
    }

    // Создаём новый источник
    if (type == DataSourceType.mock) {
      _currentDataSource = BleMockDataSource(sequenceName: sequenceName);
    } else {
      final realSource = BleRealDataSource();
      // Для реального источника нужно сначала подключиться к устройству
      await realSource.bleProvider.connect();
      _currentDataSource = realSource;
    }

    _currentType = type;
    _typeController.add(type);
  }

  /// Получить текущий источник данных
  BleDataSource? get currentDataSource => _currentDataSource;

  /// Проверка, активен ли реальный источник
  bool get isRealMode => _currentType == DataSourceType.real;

  /// Проверка, активен ли mock-источник
  bool get isMockMode => _currentType == DataSourceType.mock;

  void dispose() {
    _currentDataSource?.dispose();
    _typeController.close();
  }
}