import 'package:flutter/material.dart';
import '/data/ble_data_manager.dart';
import '/data/ble_provider.dart';
import '/data/ble_real_data_source.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const DeviceSettingsScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  final BleDataManager _dataManager = BleDataManager();
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  bool _isReconnecting = false;

  @override
  void initState() {
    super.initState();
    _updateConnectionStatus();

    // Подписываемся на изменения типа источника
    _dataManager.typeStream.listen((_) {
      if (mounted) {
        _updateConnectionStatus();
      }
    });
  }

  void _updateConnectionStatus() {
    final dataSource = _dataManager.currentDataSource;
    if (dataSource != null) {
      setState(() {
        if (dataSource is BleRealDataSource) {
          _connectionStatus = dataSource.bleProvider.connectionStatus;
        } else {
          _connectionStatus = ConnectionStatus.connected;
        }
      });
    } else {
      setState(() {
        _connectionStatus = ConnectionStatus.disconnected;
      });
    }
  }

  String _getConnectionText() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return 'ПОДКЛЮЧЕНО';
      case ConnectionStatus.disconnected:
        return 'НЕ ПОДКЛЮЧЕНО';
      case ConnectionStatus.connecting:
        return 'ПОДКЛЮЧЕНИЕ...';
      case ConnectionStatus.error:
        return 'ОШИБКА ПОДКЛЮЧЕНИЯ';
    }
  }

  Color _getConnectionColor() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return const Color(0xFF97C459);
      case ConnectionStatus.disconnected:
        return const Color(0xFFE24B4A);
      case ConnectionStatus.connecting:
        return const Color(0xFFEF9F27);
      case ConnectionStatus.error:
        return const Color(0xFF860E0D);
    }
  }

  String _getConnectionStatusText() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return 'в сети 42 мин';
      case ConnectionStatus.disconnected:
        return 'нет соединения';
      case ConnectionStatus.connecting:
        return 'подключение...';
      case ConnectionStatus.error:
        return 'Ошибка подключения';
    }
  }

  Future<void> _handleReconnect() async {
    if (!mounted) return;

    setState(() {
      _isReconnecting = true;
    });

    try {
      final dataSource = _dataManager.currentDataSource;
      if (dataSource is BleRealDataSource) {
        await dataSource.bleProvider.disconnect();
        await dataSource.bleProvider.connect();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReconnecting = false;
          _updateConnectionStatus();
        });
      }
    }
  }

  Future<void> _handleForget() async {
    await _dataManager.currentDataSource?.disconnect();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Устройство забыто'),
          backgroundColor: Color(0xFFE24B4A),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Устройство',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карточка устройства с индикатором подключения
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFEF9F27).withValues(alpha: 0.08),
                      const Color(0xFFEF9F27).withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF9F27).withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1205),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF9F27).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.devices,
                            size: 22,
                            color: Color(0xFFEF9F27),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getConnectionColor().withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _getConnectionColor().withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: _getConnectionColor(),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _getConnectionText(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: _getConnectionColor(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Himo · HM-2A4F',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getConnectionStatusText(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Остальной код без изменений...
            // Батарея
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1F1F1F)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'БАТАРЕЯ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF666666),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '78',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFAFAFA),
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '~6 ч работы',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 0.78,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF97C459),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // О приборе
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'О ПРИБОРЕ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1F1F1F)),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Модель', 'Himo MVP rev 1'),
                        const Divider(height: 0.5, thickness: 0.5, color: Color(0xFF1A1A1A)),
                        _buildInfoRow('Серийный', 'HM2025-00142'),
                        const Divider(height: 0.5, thickness: 0.5, color: Color(0xFF1A1A1A)),
                        _buildInfoRow('Прошивка', '0.1'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Калибровка
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'КАЛИБРОВКА',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1F1F1F)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF639922).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF97C459).withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 11,
                                  color: Color(0xFF97C459),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Откалиброван',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '28 марта · 16 дней назад',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Калибровка (в разработке)'),
                                  backgroundColor: Color(0xFFEF9F27),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(color: Color(0xFF2A2A2A)),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Откалибровать заново',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Кнопки Переподключить и Забыть
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isReconnecting ? null : _handleReconnect,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Color(0xFF2A2A2A)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isReconnecting
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFEF9F27),
                        ),
                      )
                          : const Text(
                        'Переподключить',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleForget,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Color(0xFFE24B4A).withValues(alpha: 0.35)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Забыть',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE24B4A),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE8E8E8),
            ),
          ),
        ],
      ),
    );
  }
}