import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Статус подключения
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

/// Результат подключения
enum ConnectionResult {
  success,
  timeout,
  mtuTooLow,
  permissionDenied,
  bluetoothOff,
  deviceNotFound,
  unknownError,
}

/// Провайдер для работы с BLE устройством
class BleProvider {
  // UUID сервиса Himo (замените на реальный)
  static const String serviceUuid = "484D0001-4A5B-6C7D-8E9F-A0B1C2D3E4F5";

  // Состояния
  BluetoothDevice? _connectedDevice;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  int _currentMtu = 0;
  String _lastError = '';

  // Подписки
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Completer<BluetoothDevice?>? _scanCompleter;   // для safe stop

  // Геттеры
  BluetoothDevice? get connectedDevice => _connectedDevice;
  ConnectionStatus get connectionStatus => _connectionStatus;
  int get currentMtu => _currentMtu;
  String get lastError => _lastError;
  bool get isConnected => _connectionStatus == ConnectionStatus.connected;

  // Стримы для UI
  final _statusController = StreamController<ConnectionStatus>.broadcast();
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  final _mtuController = StreamController<int>.broadcast();
  Stream<int> get mtuStream => _mtuController.stream;

  // --------------------------------------------------------------------------
  // Инициализация и разрешения
  // --------------------------------------------------------------------------

  /// Проверка и запрос разрешений
  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ];

    for (final permission in permissions) {
      if (await permission.isDenied) {
        final status = await permission.request();
        if (status != PermissionStatus.granted) {
          _lastError = 'Не получено разрешение: $permission';
          return false;
        }
      }
    }
    return true;
  }

  /// Включение Bluetooth (только Android)
  Future<bool> enableBluetooth() async {
    if (!await FlutterBluePlus.isSupported) {
      _lastError = 'Bluetooth не поддерживается';
      return false;
    }

    // Просто вызываем turnOn – если Bluetooth уже включён, метод завершится быстро.
    // Затем ждём состояния "включено".
    try {
      await FlutterBluePlus.turnOn();
      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      _lastError = 'Не удалось включить Bluetooth: $e';
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // Сканирование по UUID
  // --------------------------------------------------------------------------

  /// Сканирование устройств с нужным UUID сервиса
  /// Возвращает первое найденное устройство или null
  Future<BluetoothDevice?> scanForDevice({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Если уже идёт сканирование – отменяем его
    if (_scanCompleter != null && !_scanCompleter!.isCompleted) {
      stopScan();
    }

    _scanCompleter = Completer<BluetoothDevice?>();

    // Начинаем сканирование с фильтром по UUID сервиса
    await FlutterBluePlus.startScan(
      timeout: timeout,
      withServices: [Guid(serviceUuid)],
    );

    // Подписываемся на результаты
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        // Проверяем, что устройство рекламирует нужный сервис
        if (result.advertisementData.serviceUuids.contains(Guid(serviceUuid))) {
          if (_scanCompleter != null && !_scanCompleter!.isCompleted) {
            _scanCompleter!.complete(result.device);
            stopScan(); // остановим сканирование и очистим подписки
          }
          break;
        }
      }
    });

    // Таймаут сканирования
    Future.delayed(timeout, () {
      if (_scanCompleter != null && !_scanCompleter!.isCompleted) {
        _scanCompleter!.complete(null);
        stopScan();
      }
    });

    return _scanCompleter!.future;
  }

  /// Остановка сканирования
  void stopScan() {
    FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;

    // Завершаем Completer, если он ещё активен
    if (_scanCompleter != null && !_scanCompleter!.isCompleted) {
      _scanCompleter!.complete(null);
    }
    _scanCompleter = null;
  }

  // --------------------------------------------------------------------------
  // Подключение и MTU
  // --------------------------------------------------------------------------

  /// Подключение к устройству с запросом MTU 247 (минимум 100)
  Future<ConnectionResult> connectToDevice(BluetoothDevice device) async {
    if (_connectionStatus == ConnectionStatus.connecting) {
      return ConnectionResult.unknownError;
    }

    _setStatus(ConnectionStatus.connecting);
    _lastError = '';

    try {
      // Отключаемся от предыдущего устройства
      if (_connectedDevice != null) {
        await disconnect();
      }

      // Подключаемся
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      // Проверяем состояние подключения
      await device.connectionState
          .where((state) => state == BluetoothConnectionState.connected)
          .first
          .timeout(const Duration(seconds: 10));

      _connectedDevice = device;

      // Запрашиваем MTU 247
      final mtuResult = await _requestMtu(device);
      if (!mtuResult) {
        await disconnect();
        return ConnectionResult.mtuTooLow;
      }

      // Подписываемся на изменения состояния
      _connectionSubscription = device.connectionState.listen(_onConnectionStateChanged);

      _setStatus(ConnectionStatus.connected);
      return ConnectionResult.success;

    } on TimeoutException {
      _lastError = 'Таймаут подключения';
      _setStatus(ConnectionStatus.error);
      await disconnect();
      return ConnectionResult.timeout;
    } catch (e) {
      _lastError = e.toString();
      _setStatus(ConnectionStatus.error);
      await disconnect();
      return ConnectionResult.unknownError;
    }
  }

  /// Подключение по UUID сервиса (всё в одном методе)
  Future<ConnectionResult> connect({
    Duration scanTimeout = const Duration(seconds: 10),
  }) async {
    // Проверяем разрешения
    if (!await requestPermissions()) {
      return ConnectionResult.permissionDenied;
    }

    // Проверяем Bluetooth
    if (!await enableBluetooth()) {
      return ConnectionResult.bluetoothOff;
    }

    // Сканируем устройство
    final device = await scanForDevice(timeout: scanTimeout);
    if (device == null) {
      return ConnectionResult.deviceNotFound;
    }

    // Подключаемся
    return await connectToDevice(device);
  }

  /// Запрос MTU 247 (минимум 100)
  Future<bool> _requestMtu(BluetoothDevice device) async {
    try {
      const int requestedMtu = 247;
      final mtu = await device.requestMtu(requestedMtu);
      _currentMtu = mtu;
      _mtuController.add(mtu);

      print('MTU negotiated: $mtu');

      if (mtu < 100) {
        _lastError = 'MTU слишком мал: $mtu (минимум 100)';
        return false;
      }

      return true;
    } catch (e) {
      _lastError = 'Ошибка запроса MTU: $e';
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // Отключение
  // --------------------------------------------------------------------------

  /// Отключение от устройства
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        print('Disconnect error: $e');
      }
      _connectedDevice = null;
    }

    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _currentMtu = 0;
    _setStatus(ConnectionStatus.disconnected);
  }

  // --------------------------------------------------------------------------
  // Отправка команд
  // --------------------------------------------------------------------------

  /// Отправка CMD-пакета (будет реализовано позже)
  Future<bool> sendCommand(List<int> data) async {
    if (!isConnected || _connectedDevice == null) {
      _lastError = 'Нет подключения к устройству';
      return false;
    }

    // TODO: найти нужную характеристику и отправить данные
    print('Sending command: $data');
    return true;
  }

  // --------------------------------------------------------------------------
  // Приватные методы
  // --------------------------------------------------------------------------

  void _setStatus(ConnectionStatus status) {
    _connectionStatus = status;
    _statusController.add(status);
  }

  void _onConnectionStateChanged(BluetoothConnectionState state) {
    if (state == BluetoothConnectionState.disconnected) {
      _setStatus(ConnectionStatus.disconnected);
      _connectedDevice = null;
      _currentMtu = 0;
    }
  }

  // --------------------------------------------------------------------------
  // Очистка
  // --------------------------------------------------------------------------

  void dispose() {
    stopScan();
    disconnect();
    _statusController.close();
    _mtuController.close();
  }
}