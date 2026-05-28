import 'package:flutter/material.dart';
import 'testing_screen.dart';
import 'device_settings_screen.dart';
import 'cable_passport_screen.dart';
import '/data/ble_data_manager.dart';
import '/data/ble_provider.dart';
import '/data/ble_real_data_source.dart';
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

  final BleDataManager _dataManager = BleDataManager();
  ConnectionStatus _bleStatus = ConnectionStatus.disconnected;

  int _totalCables = 0;
  int _excellentCount = 0;
  int _okCount = 0;
  int _failCount = 0;
  String? _lastTestTime;
  bool _isMockMode = true;

  @override
  void initState() {
    super.initState();
    _updateConnectionStatus();

    _dataManager.typeStream.listen((_) {
      if (mounted) {
        _updateConnectionStatus();
        _loadData();  // перезагружаем при смене источника
      }
    });

    _loadData();
    _autoConnect();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isMockMode || _dataManager.currentDataSource == null) {
        // Загружаем через менеджер (он сам возьмёт из mock)
        final stats = await _dataManager.getCollectionStatistics();
        final recentTests = await _dataManager.getRecentTests(limit: 6);

        setState(() {
          _totalCables = stats['total'];
          _excellentCount = stats['excellent'];
          _okCount = stats['ok'];
          _failCount = stats['fail'];
          _recentCables = recentTests;
          _lastTestTime = _getLastTestTimeFromList(recentTests);
        });
      } else {
        // Загружаем из реального источника
        final stats = await _dataManager.getCollectionStatistics();
        final recentTests = await _dataManager.getRecentTests(limit: 6);

        setState(() {
          _totalCables = stats['total'];
          _excellentCount = stats['excellent'];
          _okCount = stats['ok'];
          _failCount = stats['fail'];
          _recentCables = recentTests;
          _lastTestTime = _getLastTestTimeFromList(recentTests);
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _recentCables = [];
        _totalCables = 0;
        _excellentCount = 0;
        _okCount = 0;
        _failCount = 0;
        _lastTestTime = 'нет данных';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Вспомогательный метод для получения времени последнего теста
  String _getLastTestTimeFromList(List<Map<String, dynamic>> tests) {
    if (tests.isEmpty) return 'нет данных';

    int latestTs = 0;
    for (final test in tests) {
      final ts = test['ts'] ?? 0;
      if (ts > latestTs) latestTs = ts;
    }

    if (latestTs == 0) return 'нет данных';

    final dateTime = DateTime.fromMillisecondsSinceEpoch(latestTs * 1000);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  void _updateConnectionStatus() {
    final dataSource = _dataManager.currentDataSource;
    if (dataSource != null) {
      setState(() {
        if (dataSource is BleRealDataSource) {
          _bleStatus = dataSource.bleProvider.connectionStatus;
          _isMockMode = false;
        } else {
          _bleStatus = ConnectionStatus.connected;
          _isMockMode = true;
        }
      });
    } else {
      setState(() {
        _bleStatus = ConnectionStatus.disconnected;
        _isMockMode = false;
      });
    }
  }

  void _autoConnect() async {
    final dataSource = _dataManager.currentDataSource;
    if (dataSource is BleRealDataSource) {
      await dataSource.bleProvider.connect();
      if (mounted) {
        _updateConnectionStatus();
      }
    }
  }

  String _getStatusText() {
    switch (_bleStatus) {
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

  Color _getBleDotColor() {
    switch (_bleStatus) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return const Color(0xFF639922);
      case 'ok':
      case 'warning':
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

  String? _selectedCableName;
  String? _selectedCableType;
  int? _selectedCableScore;

  void _showCablePassport(String name, String cableType, int score) {
    setState(() {
      _selectedCableName = name;
      _selectedCableType = cableType;
      _selectedCableScore = score;
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
      return TestingScreen(
        onBack: _showMain,
        preselectedCableType: null,
      );
    }
    if (_currentView == 'device') {
      return DeviceSettingsScreen(onBack: _showMain);
    }
    if (_currentView == 'cable_passport' && _selectedCableName != null) {
      return CablePassportScreen(
        cableName: _selectedCableName!,
        cableType: _selectedCableType ?? 'unknown',
        healthScore: _selectedCableScore ?? 0,
        onBack: _showMain,
      );
    }
    return Stack(
      children: [
        _buildMainContent(),
        if (_isBleMenuVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeBleMenu,
              child: Container(color: Colors.transparent),
            ),
          ),
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
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
                      _isMockMode ? 'ПРОВЕРКА КАБЕЛЯ (MOCK)' : 'ПРОВЕРКА КАБЕЛЯ',
                      style: TextStyle(
                        fontSize: 10,
                        color: _isMockMode ? const Color(0xFF6366F1) : Colors.grey[600],
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
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$_totalCables ',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                  ),
                                  TextSpan(
                                    text: _getCableWord(_totalCables),
                                    style: const TextStyle(
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
                            _lastTestTime ?? 'нет данных',
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
                      Expanded(flex: _excellentCount, child: Container(height: 4, color: const Color(0xFF639922))),
                      Expanded(flex: _okCount, child: Container(height: 4, color: const Color(0xFFEF9F27))),
                      Expanded(flex: _failCount, child: Container(height: 4, color: const Color(0xFFE24B4A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusDot(const Color(0xFF97C459), '$_excellentCount ${_getStatusWord(_excellentCount, "исправен", "исправны", "исправно")}'),
                      const SizedBox(width: 16),
                      _buildStatusDot(const Color(0xFFEF9F27), '$_okCount ${_getStatusWord(_okCount, "внимание", "внимание", "внимание")}'),
                      const SizedBox(width: 16),
                      _buildStatusDot(const Color(0xFFE24B4A), '$_failCount ${_getStatusWord(_failCount, "брак", "брак", "брак")}'),
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
                    subtitle: _isMockMode ? 'MOCK-режим' : _getStatusText(),
                    onTap: _showDevice,
                  ),
                ),
              ],
            ),
          ),

          // Последние проверки (CMRR)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ПОСЛЕДНИЕ ПРОВЕРКИ (CMRR)',
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
                else if (!_isMockMode && _bleStatus == ConnectionStatus.disconnected)
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
                else if (_recentCables.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.inbox_outlined,
                              size: 40,
                              color: Color(0xFF666666),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Нет проверенных кабелей',
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
                        color: _getStatusColor(cable['status'] ?? 'unknown'),
                        title: _getCableTitle(cable),
                        subtitle: _getSubtitleForCable(cable),
                        cableId: cable['id'] ?? '',
                        cableName: cable['name'] ?? '',
                        cableType: cable['cable'] ?? 'unknown',
                        healthScore: _calculateHealthScore(cable),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCableTitle(Map<String, dynamic> cable) {
    final cableType = (cable['cable'] ?? 'unknown').toString();
    final name = cable['name']?.toString() ?? '';

    // Преобразуем тип кабеля в читаемый формат
    String cableTypeName = cableType.toUpperCase();
    switch (cableType) {
      case 'jack_ts':
        cableTypeName = 'JACK TS';
        break;
      case 'jack_trs':
        cableTypeName = 'JACK TRS';
        break;
      case 'xlr':
        cableTypeName = 'XLR';
        break;
    }

    return '$cableTypeName · $name';
  }

  String _getSubtitleForCable(Map<String, dynamic> cable) {
    final cmrr = cable['cmrr_db'] ?? '--';
    final status = cable['status'] ?? '';

    if (status == 'excellent') {
      return 'cmrr $cmrr дБ · Отлично';
    } else if (status == 'ok' || status == 'warning') {
      return 'cmrr $cmrr дБ · Удовлетворительно';
    } else if (status == 'fail') {
      return 'cmrr $cmrr дБ · Неудовлетворительно';
    }
    return 'cmrr $cmrr дБ';
  }

  int _calculateHealthScore(Map<String, dynamic> cable) {
    final status = cable['status'] ?? '';
    final cmrrDb = double.tryParse(cable['cmrr_db']?.toString() ?? '0') ?? 0;

    switch (status) {
      case 'excellent':
        return (85.0 + (cmrrDb - 60) * 0.5).toInt(); // 85-100 в зависимости от CMRR
      case 'ok':
      case 'warning':
        return (50.0 + (cmrrDb - 30) * 0.8).toInt(); // 50-75
      case 'fail':
        return (20.0 + cmrrDb * 0.5).toInt(); // 20-50
      default:
        return 0;
    }
  }

  String _getCableWord(int count) {
    if (count == 1) return 'кабель';
    if (count >= 2 && count <= 4) return 'кабеля';
    return 'кабелей';
  }

  String _getStatusWord(int count, String one, String two, String five) {
    if (count == 1) return one;
    if (count >= 2 && count <= 4) return two;
    return five;
  }

  Widget _buildBleButton() {
    return GestureDetector(
      onTap: _toggleBleMenu,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _isMockMode
              ? const Color(0xFF6366F1).withValues(alpha: 0.1)
              : const Color(0xFFEF9F27).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isMockMode
                ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                : const Color(0xFFEF9F27).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _isMockMode ? const Color(0xFF6366F1) : _getBleDotColor(),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _isMockMode ? 'MOCK' : 'BLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _isMockMode ? const Color(0xFF6366F1) : const Color(0xFFEF9F27),
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
    required String cableName,
    required String cableType,
    required int healthScore,
  }) {
    return GestureDetector(
      onTap: () {
        _showCablePassport(cableName, cableType, healthScore);
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