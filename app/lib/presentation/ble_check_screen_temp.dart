import 'dart:async';
import 'package:flutter/material.dart';
import '../data/ble_provider.dart';

class BleCheckScreen extends StatefulWidget {
  const BleCheckScreen({super.key});

  @override
  State<BleCheckScreen> createState() => _BleCheckScreenState();
}

class _BleCheckScreenState extends State<BleCheckScreen> {
  final BleProvider _bleProvider = BleProvider();
  late StreamSubscription<ConnectionStatus> _statusSub;

  String _status = 'Готов';
  String _connectionResult = '';
  String _mtuInfo = '';
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    // Слушаем изменения статуса
    _statusSub = _bleProvider.statusStream.listen((status) {
      setState(() {
        switch (status) {
          case ConnectionStatus.disconnected:
            _status = 'Отключено';
            break;
          case ConnectionStatus.connecting:
            _status = 'Подключение...';
            break;
          case ConnectionStatus.connected:
            _status = 'Подключено ✅';
            _mtuInfo = 'MTU: ${_bleProvider.currentMtu}';
            break;
          case ConnectionStatus.error:
            _status = 'Ошибка: ${_bleProvider.lastError}';
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _statusSub.cancel();
    _bleProvider.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _isConnecting = true;
      _connectionResult = '';
    });

    final result = await _bleProvider.connect();

    setState(() {
      _isConnecting = false;
      switch (result) {
        case ConnectionResult.success:
          _connectionResult = '✅ Подключено успешно! MTU: ${_bleProvider.currentMtu}';
          break;
        case ConnectionResult.timeout:
          _connectionResult = '❌ Таймаут подключения';
          break;
        case ConnectionResult.mtuTooLow:
          _connectionResult = '❌ MTU слишком низкий (< 100)';
          break;
        case ConnectionResult.permissionDenied:
          _connectionResult = '❌ Нет разрешений';
          break;
        case ConnectionResult.bluetoothOff:
          _connectionResult = '❌ Bluetooth выключен';
          break;
        case ConnectionResult.deviceNotFound:
          _connectionResult = '❌ Устройство не найдено (проверьте UUID сервиса)';
          break;
        default:
          _connectionResult = '❌ Неизвестная ошибка';
      }
    });
  }

  Future<void> _disconnect() async {
    await _bleProvider.disconnect();
    setState(() {
      _connectionResult = '';
      _mtuInfo = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'BLE Test',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Статус
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1F1F1F)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'СТАТУС',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFAFAFA),
                    ),
                  ),
                  if (_mtuInfo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _mtuInfo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Результат подключения
            if (_connectionResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _connectionResult.contains('✅')
                      ? const Color(0xFF639922).withValues(alpha: 0.1)
                      : const Color(0xFFE24B4A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _connectionResult.contains('✅')
                        ? const Color(0xFF639922).withValues(alpha: 0.3)
                        : const Color(0xFFE24B4A).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _connectionResult.contains('✅') ? Icons.check_circle : Icons.error,
                      color: _connectionResult.contains('✅')
                          ? const Color(0xFF639922)
                          : const Color(0xFFE24B4A),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _connectionResult,
                        style: TextStyle(
                          fontSize: 12,
                          color: _connectionResult.contains('✅')
                              ? const Color(0xFF639922)
                              : const Color(0xFFE24B4A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnecting ? null : _connect,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF9F27),
                      foregroundColor: const Color(0xFF2A1A00),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isConnecting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2A1A00),
                      ),
                    )
                        : const Text(
                      'Подключиться к Himo',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _bleProvider.isConnected ? _disconnect : null,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Color(0xFF2A2A2A)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Отключить',
                      style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Информация
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1F1F1F)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ИНФОРМАЦИЯ',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF666666),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UUID сервиса: ${BleProvider.serviceUuid}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1. Нажмите "Подключиться"',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                  const Text(
                    '2. Приложение найдёт устройство с нужным UUID',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                  const Text(
                    '3. Подключится и запросит MTU 247',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                  const Text(
                    '4. Если MTU < 100 — отключится',
                    style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}