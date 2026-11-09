import 'package:flutter/material.dart';
import '/data/test_models.dart';
import 'testing_progress_screen.dart';

class TestingScreen extends StatefulWidget {
  final VoidCallback onBack;
  final CableType? preselectedCableType;

  const TestingScreen({
    super.key,
    required this.onBack,
    this.preselectedCableType,
  });

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  CableType _selectedCable = CableType.jackTs;
  final Set<TestType> _selectedTests = {
    TestType.continuity,
    TestType.freqResponse,
  };

  @override
  void initState() {
    super.initState();
    // Если передан предустановленный тип кабеля, используем его
    _selectedCable = widget.preselectedCableType ?? CableType.jackTs;

    // Если выбран Jack TS и CMRR был в выбранных тестах — убираем
    if (!_selectedCable.supportsCmrr &&
        _selectedTests.contains(TestType.cmrr)) {
      _selectedTests.remove(TestType.cmrr);
    }
  }

  // Блокирован ли CMRR
  bool get _isCmrrBlocked => !_selectedCable.supportsCmrr;

  // Общее время тестирования
  int get _totalDuration {
    int total = 0;
    for (final test in _selectedTests) {
      total += test.durationSeconds;
    }
    return total;
  }

  String get _startButtonText {
    final minutes = _totalDuration ~/ 60;
    final seconds = _totalDuration % 60;
    if (minutes > 0) {
      return 'Старт · ~$minutes мин ${seconds} сек';
    } else {
      return 'Старт · ~$seconds сек';
    }
  }

  void _selectCable(CableType cable) {
    setState(() {
      _selectedCable = cable;
      // Если выбран Jack TS и CMRR был выбран — убираем его
      if (!cable.supportsCmrr && _selectedTests.contains(TestType.cmrr)) {
        _selectedTests.remove(TestType.cmrr);
      }
    });
  }

  void _toggleTest(TestType test, bool isSelected) {
    if (!isSelected && test == TestType.cmrr && _isCmrrBlocked) {
      return;
    }
    setState(() {
      if (isSelected) {
        _selectedTests.add(test);
      } else {
        _selectedTests.remove(test);
      }
    });
  }

  void _startTesting() {
    if (_selectedTests.isEmpty) {
      // Показать snackbar, что нужно выбрать хотя бы один тест
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один тест'),
          backgroundColor: Color(0xFFE24B4A),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestingProgressScreen(
          cableType: _selectedCable,
          selectedTests: _selectedTests.toList(),
          totalDuration: _totalDuration,
        ),
      ),
    );
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
          'Новый тест',
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
            // 1 · Тип кабеля
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: Text(
                '1 · ТИП КАБЕЛЯ',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _buildCableTypeCard(CableType.jackTs, iconPath: 'ts'),
                  const SizedBox(width: 8),
                  _buildCableTypeCard(CableType.jackTrs, iconPath: 'trs'),
                  const SizedBox(width: 8),
                  _buildCableTypeCard(CableType.xlr, iconPath: 'xlr'),
                ],
              ),
            ),

            // 2 · Подключение
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
              child: Text(
                '2 · ПОДКЛЮЧЕНИЕ',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1F1F1F)),
                ),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Подключите оба конца кабеля к разъёмам ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                      TextSpan(
                        text: 'A',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFEF9F27),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text: ' и ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                      TextSpan(
                        text: 'B',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFEF9F27),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text: ' на приборе',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3 · Будут выполнены тесты
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
              child: Text(
                '3 · БУДУТ ВЫПОЛНЕНЫ ТЕСТЫ',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTestCard(
                    test: TestType.continuity,
                    duration: 3,
                    isSelected: _selectedTests.contains(TestType.continuity),
                    isBlocked: false,
                  ),
                  const SizedBox(height: 6),
                  _buildTestCard(
                    test: TestType.cmrr,
                    duration: 3,
                    isSelected: _selectedTests.contains(TestType.cmrr),
                    isBlocked: _isCmrrBlocked,
                  ),
                  const SizedBox(height: 6),
                  _buildTestCard(
                    test: TestType.freqResponse,
                    duration: 3,
                    isSelected: _selectedTests.contains(TestType.freqResponse),
                    isBlocked: false,
                  ),
                ],
              ),
            ),

            // Кнопка Старт
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
              child: ElevatedButton(
                onPressed: _selectedTests.isEmpty ? null : _startTesting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF9F27),
                  foregroundColor: const Color(0xFF2A1A00),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      _startButtonText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCableTypeCard(CableType type, {required String iconPath}) {
    final isSelected = _selectedCable == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectCable(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEF9F27).withValues(alpha: 0.08)
                : const Color(0xFF111111),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFEF9F27)
                  : const Color(0xFF1F1F1F),
            ),
          ),
          child: Column(
            children: [
              _buildCableIcon(iconPath, isSelected),
              const SizedBox(height: 6),
              Text(
                type.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFFFAFAFA)
                      : const Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCableIcon(String type, bool isSelected) {
    final color = isSelected
        ? const Color(0xFFEF9F27)
        : const Color(0xFF666666);

    switch (type) {
      case 'ts':
        return SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(painter: _TsIconPainter(color: color)),
        );
      case 'trs':
        return SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(painter: _TrsIconPainter(color: color)),
        );
      case 'xlr':
        return SizedBox(
          width: 26,
          height: 26,
          child: CustomPaint(painter: _XlrIconPainter(color: color)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTestCard({
    required TestType test,
    required int duration,
    required bool isSelected,
    required bool isBlocked,
    String blockedHint = '',
  }) {
    return GestureDetector(
      onTap: () {
        if (!isBlocked) {
          _toggleTest(test, !isSelected);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isBlocked
              ? const Color(0xFF0D0D0D)
              : (isSelected
                    ? const Color(0xFF111111)
                    : const Color(0xFF0D0D0D)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFEF9F27).withValues(alpha: 0.55)
                : const Color(0xFF1F1F1F),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected && !isBlocked
                    ? const Color(0xFFEF9F27).withValues(alpha: 0.1)
                    : const Color(0xFF1A1A1A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected && !isBlocked
                      ? const Color(0xFFEF9F27).withValues(alpha: 0.4)
                      : const Color(0xFF2A2A2A),
                ),
              ),
              child: Center(
                child: isSelected && !isBlocked
                    ? const Icon(
                        Icons.check,
                        size: 12,
                        color: Color(0xFFEF9F27),
                      )
                    : Text(
                        _getTestNumber(test),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isBlocked
                              ? const Color(0xFF555555)
                              : const Color(0xFF888888),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Text(
                    test.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isBlocked
                          ? const Color(0xFF888888)
                          : (isSelected
                                ? const Color(0xFFFAFAFA)
                                : const Color(0xFF888888)),
                    ),
                  ),
                  if (blockedHint.isNotEmpty)
                    Text(
                      blockedHint,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF444444),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              '~${duration}с',
              style: TextStyle(
                fontSize: 10,
                color: isBlocked
                    ? const Color(0xFF444444)
                    : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTestNumber(TestType test) {
    switch (test) {
      case TestType.continuity:
        return '1';
      case TestType.cmrr:
        return '2';
      case TestType.freqResponse:
        return '3';
    }
  }
}

// Кастомные иконки для типов кабелей
class _TsIconPainter extends CustomPainter {
  final Color color;

  _TsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Корпус разъёма
    canvas.drawRect(const Rect.fromLTWH(2, 9, 10, 12), paint);
    // Контакт
    canvas.drawRect(const Rect.fromLTWH(15, 11, 22, 6), paint);
    // Кружок на конце
    canvas.drawCircle(const Offset(37, 14), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrsIconPainter extends CustomPainter {
  final Color color;

  _TrsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Корпус разъёма
    canvas.drawRect(const Rect.fromLTWH(2, 9, 10, 12), paint);
    // Контакты TRS (два кольца)
    canvas.drawRect(const Rect.fromLTWH(15, 11, 13, 6), paint);
    canvas.drawRect(const Rect.fromLTWH(28, 11, 4, 6), paint);
    canvas.drawRect(const Rect.fromLTWH(32, 11, 4, 6), paint);
    // Кружок на конце
    canvas.drawCircle(const Offset(37, 14), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _XlrIconPainter extends CustomPainter {
  final Color color;

  _XlrIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Корпус XLR
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 7, 12, 14),
        const Radius.circular(2),
      ),
      paint,
    );
    // Три пина
    canvas.drawCircle(const Offset(22, 11), 2, paint);
    canvas.drawCircle(const Offset(19, 16), 2, paint);
    canvas.drawCircle(const Offset(25, 16), 2, paint);
    // Хвост
    canvas.drawRect(const Rect.fromLTWH(29, 12, 9, 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
