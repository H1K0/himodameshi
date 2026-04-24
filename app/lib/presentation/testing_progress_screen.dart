import 'dart:async';
import 'package:flutter/material.dart';
import '/data/test_models.dart';
import 'testing_results_screen.dart';

class TestingProgressScreen extends StatefulWidget {
  final CableType cableType;
  final List<TestType> selectedTests;
  final int totalDuration;

  const TestingProgressScreen({
    super.key,
    required this.cableType,
    required this.selectedTests,
    required this.totalDuration,
  });

  @override
  State<TestingProgressScreen> createState() => _TestingProgressScreenState();
}

class _TestingProgressScreenState extends State<TestingProgressScreen> {
  int _currentTestIndex = 0;
  double _progress = 0.0;
  Timer? _timer;
  DateTime? _testStartTime;

  // Длительность каждого теста в секундах
  static const int _testDurationSeconds = 10;

  List<TestType> get _tests => widget.selectedTests;

  TestType get _currentTest => _tests[_currentTestIndex];

  String get _cableDisplayName {
    switch (widget.cableType) {
      case CableType.jackTs:
        return 'Jack TS · 2-pin';
      case CableType.jackTrs:
        return 'Jack TRS · 3-pin';
      case CableType.xlr:
        return 'XLR · 3-pin';
    }
  }

  @override
  void initState() {
    super.initState();
    _startCurrentTest();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCurrentTest() {
    _testStartTime = DateTime.now();
    _progress = 0.0;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_testStartTime!).inMilliseconds;
      final newProgress = (elapsed / (_testDurationSeconds * 1000)).clamp(0.0, 1.0);

      setState(() {
        _progress = newProgress;
      });

      if (newProgress >= 1.0) {
        timer.cancel();
        _onTestComplete();
      }
    });
  }

  void _onTestComplete() {
    if (_currentTestIndex + 1 < _tests.length) {
      // Переходим к следующему тесту
      setState(() {
        _currentTestIndex++;
      });
      _startCurrentTest();
    } else {
      // Все тесты завершены
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TestingResultsScreen(
            cableType: widget.cableType,
            selectedTests: _tests,
          ),
        ),
      );
    }
  }

  void _cancelTesting() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  String _getTestDisplayName(TestType test) {
    switch (test) {
      case TestType.continuity:
        return 'Целостность';
      case TestType.cmrr:
        return 'CMRR';
      case TestType.freqResponse:
        return 'АЧХ';
    }
  }

  Color _getTestStatusColor(int index) {
    if (index < _currentTestIndex) {
      // Завершённый тест — зелёный
      return const Color(0xFF97C459);
    } else if (index == _currentTestIndex) {
      // Текущий тест — оранжевый
      return const Color(0xFFEF9F27);
    } else {
      // Предстоящий тест — серый
      return const Color(0xFF2A2A2A);
    }
  }

  String _getTestStatusIcon(int index) {
    if (index < _currentTestIndex) {
      return '✓';
    } else if (index == _currentTestIndex) {
      return '';
    } else {
      return (index + 1).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: const SizedBox(width: 30),
        title: const Text(
          'Тестирование',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildBleButton(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Информация о кабеле
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Column(
              children: [
                Text(
                  _cableDisplayName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF666666),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'тест ${_currentTestIndex + 1} из ${_tests.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),

          // Круговой индикатор прогресса
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _progress),
                      duration: const Duration(milliseconds: 50),
                      builder: (context, value, child) {
                        return CustomPaint(
                          size: const Size(160, 160),
                          painter: _ProgressRingPainter(
                            progress: value,
                            color: const Color(0xFFEF9F27),
                          ),
                        );
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getTestDisplayName(_currentTest).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF666666),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(_progress * 100).toInt()}',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFAFAFA),
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Список этапов
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ЭТАПЫ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF666666),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                ..._tests.asMap().entries.map((entry) {
                  final index = entry.key;
                  final test = entry.value;
                  final isCompleted = index < _currentTestIndex;
                  final isCurrent = index == _currentTestIndex;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFEF9F27).withValues(alpha: 0.06)
                          : const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFEF9F27).withValues(alpha: 0.6)
                            : const Color(0xFF1F1F1F),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFF639922).withValues(alpha: 0.12)
                                : (isCurrent
                                ? const Color(0xFFEF9F27).withValues(alpha: 0.15)
                                : const Color(0xFF1A1A1A)),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? const Color(0xFF97C459).withValues(alpha: 0.5)
                                  : (isCurrent
                                  ? const Color(0xFFEF9F27).withValues(alpha: 0.6)
                                  : const Color(0xFF2A2A2A)),
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, size: 12, color: Color(0xFF97C459))
                                : (isCurrent
                                ? SizedBox(
                              width: 8,
                              height: 8,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: const Color(0xFFEF9F27),
                              ),
                            )
                                : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF555555),
                              ),
                            )),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getTestDisplayName(test),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isCompleted || isCurrent
                                  ? const Color(0xFFFAFAFA)
                                  : const Color(0xFF888888),
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Text(
                            '${(_progress * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFEF9F27),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Кнопка "Отменить"
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
            child: OutlinedButton(
              onPressed: _cancelTesting,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Color(0xFF2A2A2A)),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Отменить',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF888888),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBleButton() {
    return Container(
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
            decoration: const BoxDecoration(
              color: Color(0xFF97C459),
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
    );
  }
}

// Кастомный painter для кругового индикатора
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paintBackground = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Фоновое кольцо
    canvas.drawCircle(center, radius, paintBackground);

    // Прогресс
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Начинаем с верхней точки (12 часов)
      sweepAngle,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}