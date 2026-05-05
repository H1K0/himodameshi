import 'package:flutter/material.dart';
import '../data/ble_data_manager.dart';
import '../data/ble_real_data_source.dart';

class BleDataTestScreen extends StatefulWidget {
  const BleDataTestScreen({super.key});

  @override
  State<BleDataTestScreen> createState() => _BleDataTestScreenState();
}

class _BleDataTestScreenState extends State<BleDataTestScreen> {
  final BleDataManager _manager = BleDataManager();
  List<Map<String, dynamic>> _receivedPackets = [];
  DataSourceType _currentType = DataSourceType.mock;
  bool _isReceiving = false;

  @override
  void initState() {
    super.initState();
    _manager.typeStream.listen((type) {
      setState(() {
        _currentType = type;
      });
    });
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  void _switchToMock() async {
    await _manager.switchTo(DataSourceType.mock);
    _subscribeToData();
  }

  void _switchToReal() async {
    await _manager.switchTo(DataSourceType.real);
    _subscribeToData();
  }

  void _subscribeToData() {
    setState(() {
      _receivedPackets.clear();
      _isReceiving = true;
    });

    _manager.currentDataSource?.dataStream.listen((packet) {
      setState(() {
        _receivedPackets.insert(0, packet);
        if (_receivedPackets.length > 50) {
          _receivedPackets.removeLast();
        }
      });
    }, onError: (error) {
      setState(() {
        _receivedPackets.insert(0, {'type': 'error', 'message': error.toString()});
      });
    });
  }

  Future<void> _sendStartTest() async {
    if (_manager.currentDataSource is BleRealDataSource) {
      final realSource = _manager.currentDataSource as BleRealDataSource;
      await realSource.startTest(test: 'full', cable: 'xlr');
    } else {
      await _manager.currentDataSource?.sendCommand({
        'type': 'cmd',
        'cmd': 'start_test',
        'test': 'full',
        'cable': 'xlr',
      });
    }
  }

  Future<void> _sendCancel() async {
    await _manager.currentDataSource?.sendCommand({
      'type': 'cmd',
      'cmd': 'cancel',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'BLE Data Test',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Переключатель источника
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _switchToMock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentType == DataSourceType.mock
                          ? const Color(0xFFEF9F27)
                          : const Color(0xFF2A2A2A),
                      foregroundColor: _currentType == DataSourceType.mock
                          ? const Color(0xFF2A1A00)
                          : const Color(0xFF888888),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('MOCK'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _switchToReal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentType == DataSourceType.real
                          ? const Color(0xFFEF9F27)
                          : const Color(0xFF2A2A2A),
                      foregroundColor: _currentType == DataSourceType.real
                          ? const Color(0xFF2A1A00)
                          : const Color(0xFF888888),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('REAL'),
                  ),
                ),
              ],
            ),
          ),

          // Кнопки команд
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _sendStartTest,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2A2A2A)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('start_test', style: TextStyle(color: Color(0xFFEF9F27))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _sendCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2A2A2A)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('cancel', style: TextStyle(color: Color(0xFFE24B4A))),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFF2A2A2A)),

          // Заголовок списка
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Text(
                  'ПОЛУЧЕННЫЕ ПАКЕТЫ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF666666),
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_receivedPackets.length}',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),

          // Список пакетов
          Expanded(
            child: _receivedPackets.isEmpty
                ? const Center(
              child: Text(
                'Нет данных\nПереключитесь на MOCK или REAL',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF888888)),
              ),
            )
                : ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _receivedPackets.length,
              itemBuilder: (context, index) {
                final packet = _receivedPackets[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF1F1F1F)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packet['type'] ?? 'unknown',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _getTypeColor(packet['type']),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        packet.toString(),
                        style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'status':
        return const Color(0xFFEF9F27);
      case 'result:continuity':
        return const Color(0xFF97C459);
      case 'result:cmrr':
        return const Color(0xFF97C459);
      case 'result:freq_response':
        return const Color(0xFF97C459);
      case 'error':
        return const Color(0xFFE24B4A);
      default:
        return const Color(0xFF888888);
    }
  }
}