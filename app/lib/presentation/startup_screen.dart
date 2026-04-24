import 'package:flutter/material.dart';
import 'testing_screen.dart';
import 'device_settings_screen.dart';
import 'cable_passport_screen.dart';
import '/data/ble_mock_provider.dart';
import 'ble_menu.dart';

class StartupScreen extends StatefulWidget {
  final VoidCallback? onNavigateToCollection;

  const StartupScreen({super.key, this.onNavigateToCollection});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  String _currentView = 'main';
  String? _selectedCableId;
  List<Map<String, dynamic>> _recentCables = [];
  bool _isLoading = true;
  bool _isBleMenuVisible = false;
  BleConnectionStatus _bleStatus = bleProvider.currentStatus;

  @override
  void initState() {
    super.initState();
    _loadCables();
    // Подписываемся на изменения статуса BLE
    bleProvider.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _bleStatus = status;
        });
        // Если подключились, перезагружаем данные
        if (status == BleConnectionStatus.connected) {
          _loadCables();
        }
      }
    });
    // Автоматически подключаемся при старте
    _autoConnect();
  }

  void _autoConnect() async {
    await bleProvider.connect();
  }

  Future<void> _loadCables() async {
    setState(() {
      _isLoading = true;
    });
    await for (final cables in bleProvider.getCmrrResultsStream()) {
      setState(() {
        _recentCables = cables;
        _isLoading = false;
      });
      break;
    }
  }

  Color _getBleDotColor() {
    switch (_bleStatus) {
      case BleConnectionStatus.connected:
        return const Color(0xFF97C459);
      case BleConnectionStatus.disconnected:
        return const Color(0xFFE24B4A);
      case BleConnectionStatus.connecting:
        return const Color(0xFFEF9F27);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return const Color(0xFF639922);
      case 'ok':
        return const Color(0xFFEF9F27);
      case 'fail':
        return const Color(0xFFE24B4A);
      default:
        return const Color(0xFF888888);
    }
  }

  void _showTesting() {
    setState(() {
      _currentView = 'testing';
    });
  }

  void _showDevice() {
    setState(() {
      _currentView = 'device';
    });
  }

  void _showCablePassport(String cableId) {
    setState(() {
      _selectedCableId = cableId;
      _currentView = 'cable_passport';
    });
  }

  void _showMain() {
    setState(() {
      _currentView = 'main';
      _selectedCableId = null;
    });
  }

  void _toggleBleMenu() {
    setState(() {
      _isBleMenuVisible = !_isBleMenuVisible;
    });
  }

  void _closeBleMenu() {
    setState(() {
      _isBleMenuVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentView == 'testing') {
      return TestingScreen(onBack: _showMain);
    }
    if (_currentView == 'device') {
      return DeviceSettingsScreen(onBack: _showMain);
    }
    if (_currentView == 'cable_passport' && _selectedCableId != null) {
      return CablePassportScreen(
        cableId: _selectedCableId!,
        onBack: _showMain,
      );
    }
    return Stack(
      children: [
        _buildMainContent(),
        // Затемнение фона при открытом меню (снизу)
        if (_isBleMenuVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeBleMenu,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        // BLE Menu Overlay (СВЕРХУ, чтобы получать касания первым)
        if (_isBleMenuVisible)
          Positioned(
            top: 70,
            right: 20,
            child: BleMenu(
              onClose: _closeBleMenu,
              onNavigateToDevice: _showDevice,
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF9F27),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '紐',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Himo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFAFAFA),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ПРОВЕРКА КАБЕЛЯ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildBleButton(),
              ],
            ),
          ),

          // Статистика коллекции
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1F1F1F)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'КОЛЛЕКЦИЯ',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '24 ',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'кабеля',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ПОСЛЕДНЯЯ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '2 часа назад',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(flex: 18, child: Container(height: 4, color: const Color(0xFF639922))),
                      Expanded(flex: 4, child: Container(height: 4, color: const Color(0xFFEF9F27))),
                      Expanded(flex: 2, child: Container(height: 4, color: const Color(0xFFE24B4A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusDot(const Color(0xFF97C459), '18 исправны'),
                      const SizedBox(width: 16),
                      _buildStatusDot(const Color(0xFFEF9F27), '4 внимание'),
                      const SizedBox(width: 16),
                      _buildStatusDot(const Color(0xFFE24B4A), '2 брак'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Кнопка "Запустить тестирование"
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
            child: ElevatedButton(
              onPressed: _showTesting,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF9F27),
                foregroundColor: const Color(0xFF2A1A00),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Запустить тестирование',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),

          // Карточки Коллекция и Устройство
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.view_list_outlined,
                    title: 'Коллекция',
                    subtitle: 'Все кабели',
                    onTap: () {
                      widget.onNavigateToCollection?.call();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.devices_outlined,
                    title: 'Устройство',
                    subtitle: '78% · откалибровано',
                    onTap: _showDevice,
                  ),
                ),
              ],
            ),
          ),

          // Последние проверки
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ПОСЛЕДНИЕ ПРОВЕРКИ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: Color(0xFFEF9F27),
                      ),
                    ),
                  )
                else if (_bleStatus == BleConnectionStatus.disconnected)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.bluetooth_disabled,
                            size: 40,
                            color: Color(0xFF666666),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Нет подключения к устройству',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._recentCables.map((cable) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _buildHistoryItem(
                      color: _getStatusColor(cable['status']),
                      title: '${cable['name']} · ${cable['cable']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                      subtitle: 'cmrr ${cable['cmrr_db']} дБ',
                      cableId: cable['id'],
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBleButton() {
    return GestureDetector(
      onTap: _toggleBleMenu,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEF9F27).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEF9F27).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _getBleDotColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'BLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFEF9F27),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, size: 18, color: const Color(0xFFEF9F27)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFAFAFA),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required Color color,
    required String title,
    required String subtitle,
    required String cableId,
  }) {
    return GestureDetector(
      onTap: () {
        _showCablePassport(cableId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFAFAFA),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF444444)),
          ],
        ),
      ),
    );
  }
}