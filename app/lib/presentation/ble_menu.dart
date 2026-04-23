import 'package:flutter/material.dart';
import '/data/ble_mock_provider.dart';
import '/presentation/device_settings_screen.dart';

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
  BleConnectionStatus _connectionStatus = bleProvider.currentStatus;
  bool _isReconnecting = false;

  @override
  void initState() {
    super.initState();
    // Подписываемся на изменения статуса
    bleProvider.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _connectionStatus = status;
        });
      }
    });
  }

  String _getStatusText() {
    switch (_connectionStatus) {
      case BleConnectionStatus.connected:
        return 'Подключено';
      case BleConnectionStatus.disconnected:
        return 'Не подключено';
      case BleConnectionStatus.connecting:
        return 'Подключение...';
    }
  }

  Color _getStatusColor() {
    switch (_connectionStatus) {
      case BleConnectionStatus.connected:
        return const Color(0xFF97C459);
      case BleConnectionStatus.disconnected:
        return const Color(0xFFE24B4A);
      case BleConnectionStatus.connecting:
        return const Color(0xFFEF9F27);
    }
  }

  Future<void> _handleReconnect() async {
    setState(() {
      _isReconnecting = true;
    });
    await bleProvider.reconnect();
    setState(() {
      _isReconnecting = false;
    });
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
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(),
                      ),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFAAAAAA)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: onTap == null ? const Color(0xFF666666) : const Color(0xFFE8E8E8),
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