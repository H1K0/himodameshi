import 'package:flutter/material.dart';
import '/data/ble_data_manager.dart';
import '/data/ble_provider.dart';
import '/data/ble_real_data_source.dart';

class BleMenu extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onNavigateToDevice;

  const BleMenu({
    super.key,
    required this.onClose,
    required this.onNavigateToDevice,
  });

  @override
  State<BleMenu> createState() => _BleMenuState();
}

class _BleMenuState extends State<BleMenu> {
  final BleDataManager _dataManager = BleDataManager();
  late ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  bool _isReconnecting = false;

  @override
  void initState() {
    super.initState();
    // Получаем начальный статус
    _updateConnectionStatus();

    // Подписываемся на изменения типа источника
    _dataManager.typeStream.listen((_) {
      if (mounted) {
        _updateConnectionStatus();
      }
    });

    // Подписываемся на изменения статуса провайдера
    BleDataManager().currentDataSource?.dataStream.listen((_) {
      // Обновляем статус при изменении данных
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
          _connectionStatus = (dataSource).bleProvider.connectionStatus;
        } else {
          // В мок-режиме всегда "подключены"
          _connectionStatus = ConnectionStatus.connected;
        }
      });
    } else {
      setState(() {
        _connectionStatus = ConnectionStatus.disconnected;
      });
    }
  }

  String _getStatusText() {
    switch (_connectionStatus) {
      case ConnectionStatus.connected:
        return 'Подключено';
      case ConnectionStatus.disconnected:
        return 'Не подключено';
      case ConnectionStatus.connecting:
        return 'Подключение...';
      case ConnectionStatus.error:
        return 'Ошибка подключения';
    }
  }

  Color _getStatusColor() {
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

  Future<void> _handleReconnect() async {
    if (!mounted) return;

    setState(() {
      _isReconnecting = true;
    });

    try {
      final dataSource = _dataManager.currentDataSource;
      if (dataSource is BleRealDataSource) {
        // Для реального источника - переподключаемся
        await dataSource.bleProvider.disconnect();
        await dataSource.bleProvider.connect();
      } else {
        // Для мок-режима просто переключаемся на реальный
        await _dataManager.switchTo(DataSourceType.real);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Статус
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'СТАТУС',
                  style: TextStyle(
                    fontSize: 9,
                    color: Color(0xFF666666),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Himo · HM-2A4F',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getStatusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(),
                      style: TextStyle(fontSize: 10, color: _getStatusColor()),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Разделитель
          Container(
            height: 0.5,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFF2A2A2A),
          ),
          // Кнопка "Открыть устройство"
          _buildMenuItem(
            icon: Icons.devices_outlined,
            label: 'Открыть устройство',
            onTap: () {
              widget.onNavigateToDevice();
              widget.onClose();
            },
          ),
          // Кнопка "Переподключить"
          _buildMenuItem(
            icon: Icons.refresh_outlined,
            label: 'Переподключить',
            onTap: _isReconnecting ? null : _handleReconnect,
            showLoader: _isReconnecting,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool showLoader = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFAAAAAA)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onTap == null
                      ? const Color(0xFF666666)
                      : const Color(0xFFE8E8E8),
                ),
              ),
            ),
            if (showLoader)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Color(0xFFEF9F27),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
