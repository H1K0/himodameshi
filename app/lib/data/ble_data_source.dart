import 'dart:async';

/// Абстрактный источник данных BLE
abstract class BleDataSource {
  /// Поток входящих DATA-пакетов
  Stream<Map<String, dynamic>> get dataStream;

  /// Отправка CMD-пакета
  Future<bool> sendCommand(Map<String, dynamic> command);

  /// Проверка, подключено ли устройство
  bool get isConnected;

  /// Отключение
  Future<void> disconnect();

  /// Освобождение ресурсов
  void dispose();
}