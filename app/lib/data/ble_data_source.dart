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

  /// Получить список всех кабелей
  Future<List<Map<String, dynamic>>> getAllCables();

  /// Получить статистику коллекции
  Future<Map<String, dynamic>> getCollectionStatistics();

  /// Получить последние тесты
  Future<List<Map<String, dynamic>>> getRecentTests({int limit});
}