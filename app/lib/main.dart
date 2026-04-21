import 'dart:async';
import 'package:flutter/material.dart';
import 'data/ble_mock_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Mock Тестер',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BleMockScreen(),
    );
  }
}

class BleMockScreen extends StatefulWidget {
  const BleMockScreen({super.key});

  @override
  State<BleMockScreen> createState() => _BleMockScreenState();
}

class _BleMockScreenState extends State<BleMockScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<String> _outputMessages = [];
  Stream<Map<String, dynamic>>? _currentStream;

  // Контроллер для отмены текущей подписки
  StreamSubscription<Map<String, dynamic>>? _subscription;

  // Флаг, показывающий идёт ли сейчас тест
  bool _isTesting = false;

  @override
  void dispose() {
    _inputController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  // Функция, которая запускает выбранную последовательность
  void _startSequence(String sequenceName) {
    // Останавливаем предыдущую подписку, если была
    _subscription?.cancel();

    // Очищаем вывод
    setState(() {
      _outputMessages.clear();
      _isTesting = true;
    });

    // Добавляем сообщение о старте
    _addMessage('🚀 Запуск последовательности: $sequenceName');

    // Получаем Stream и подписываемся
    _currentStream = getBlePacketStream(sequenceName);

    _subscription = _currentStream!.listen(
          (packet) {
        // Обрабатываем каждый пришедший пакет
        final message = _formatPacket(packet);
        _addMessage(message);

        // Если пакет типа 'finished' или 'error' — тест закончен
        if (packet['type'] == 'finished' || packet['type'] == 'error') {
          setState(() {
            _isTesting = false;
          });
        }
      },
      onError: (error) {
        _addMessage('❌ Ошибка: $error');
        setState(() {
          _isTesting = false;
        });
      },
    );
  }

  // Добавляет сообщение в список вывода
  void _addMessage(String message) {
    setState(() {
      _outputMessages.insert(0, message); // новые сообщения сверху
      // Ограничиваем историю 100 сообщениями
      if (_outputMessages.length > 100) {
        _outputMessages.removeLast();
      }
    });
  }

  // Форматирует пакет в понятный текст
  String _formatPacket(Map<String, dynamic> packet) {
    final type = packet['type'];

    switch (type) {
      case 'status':
        final state = packet['state'];
        if (state == 'testing') {
          final test = packet['test'] ?? '?';
          final progress = (packet['progress'] as num?)?.toDouble() ?? 0.0;
          final percent = (progress * 100).toInt();
          return '🟡 СТАТУС: тест "$test" — $percent%';
        } else if (state == 'done') {
          return '✅ СТАТУС: тест завершён!';
        } else if (state == 'error') {
          return '❌ СТАТУС: ошибка ${packet['err_code']}';
        } else if (state == 'idle') {
          return '⚪ СТАТУС: ожидание';
        }
        return '📡 СТАТУС: $state';

      case 'result:continuity':
        final cable = packet['cable'] ?? '?';
        final status = packet['status'] ?? '?';

        if (status == 'ok') {
          return '✅ ЦЕЛОСТНОСТЬ [$cable]: OK';
        } else if (status == 'warning') {
          return '⚠️ ЦЕЛОСТНОСТЬ [$cable]: ПРЕДУПРЕЖДЕНИЕ';
        } else if (status == 'fail') {
          return '❌ ЦЕЛОСТНОСТЬ [$cable]: ПРОВАЛ';
        }
        return '🔌 ЦЕЛОСТНОСТЬ: $status';

      case 'result:cmrr':
        final cable = packet['cable'] ?? '?';
        final db = packet['cmrr_db'] ?? 0.0;
        final status = packet['status'] ?? '?';

        String emoji;
        if (status == 'excellent') emoji = '🌟';
        else if (status == 'ok') emoji = '👍';
        else emoji = '⚠️';

        return '$emoji CMRR [$cable]: ${db.toStringAsFixed(1)} дБ ($status)';

      case 'result:freq_response':
        final cable = packet['cable'] ?? '?';
        final status = packet['status'] ?? '?';

        if (status == 'excellent') {
          return '🎵 АЧХ [$cable]: ОТЛИЧНАЯ';
        } else if (status == 'ok') {
          return '🎵 АЧХ [$cable]: ХОРОШАЯ';
        } else {
          return '🎵 АЧХ [$cable]: ПРОВАЛ';
        }

      case 'finished':
        return packet['message'] ?? '🏁 Тест завершён';

      case 'error':
        return '❌ ${packet['message']}';

      default:
        return '📦 ${packet['type']}: ${packet.keys.join(", ")}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Mock Тестер'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Поле ввода
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Введите название последовательности...',
                      labelText: 'Название',
                      border: OutlineInputBorder(),
                      suffixIcon: _isTesting
                          ? const Icon(Icons.play_circle, color: Colors.green)
                          : null,
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty && !_isTesting) {
                        _startSequence(value.trim());
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isTesting
                      ? null
                      : () {
                    if (_inputController.text.trim().isNotEmpty) {
                      _startSequence(_inputController.text.trim());
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Старт'),
                ),
              ],
            ),
          ),

          // Подсказка с доступными последовательностями
          FutureBuilder<List<String>>(
            future: getAvailableSequences(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              final sequences = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sequences.map((name) {
                    return ActionChip(
                      label: Text(name),
                      onPressed: _isTesting
                          ? null
                          : () {
                        _inputController.text = name;
                        _startSequence(name);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const Divider(),

          // Заголовок вывода
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.list_alt, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Вывод (${_outputMessages.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _outputMessages.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Очистить'),
                ),
              ],
            ),
          ),

          // Список вывода
          Expanded(
            child: _outputMessages.isEmpty
                ? const Center(
              child: Text(
                'Введите название последовательности и нажмите Enter\nили кликните на чип с названием',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              reverse: true, // новые сообщения сверху
              padding: const EdgeInsets.all(8),
              itemCount: _outputMessages.length,
              itemBuilder: (context, index) {
                final message = _outputMessages[index];
                // Определяем цвет фона по типу сообщения
                Color? backgroundColor;
                if (message.contains('✅')) {
                  backgroundColor = Colors.green.shade50;
                } else if (message.contains('❌')) {
                  backgroundColor = Colors.red.shade50;
                } else if (message.contains('⚠️')) {
                  backgroundColor = Colors.orange.shade50;
                } else if (message.contains('🟡')) {
                  backgroundColor = Colors.yellow.shade50;
                }

                return Card(
                  color: backgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      message,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),

          // Индикатор активного теста
          if (_isTesting)
            const LinearProgressIndicator(),
        ],
      ),
    );
  }
}