import 'package:flutter/material.dart';
import '/data/test_models.dart';
import 'testing_progress_screen.dart';
import 'startup_screen.dart';
import 'details_screen.dart';

class TestingResultsScreen extends StatelessWidget {
  final CableType cableType;
  final List<TestType> selectedTests;
  final double totalTimeSeconds;

  // Статичные данные для демонстрации (позже заменятся на реальные)
  final double healthScore = 92;
  final String continuityResult = '0.9–1.4 Ом';
  final double cmrrDb = 68;
  final String freqResponseResult = 'Спад −2.1 дБ на 20 кГц';

  const TestingResultsScreen({
    super.key,
    required this.cableType,
    required this.selectedTests,
    required this.totalTimeSeconds,
  });

  String get _formattedTime {
    if (totalTimeSeconds < 60) {
      return '${totalTimeSeconds.toStringAsFixed(1)} с';
    } else {
      final minutes = (totalTimeSeconds / 60).floor();
      final seconds = totalTimeSeconds % 60;
      return '$minutes мин ${seconds.toStringAsFixed(1)} с';
    }
  }

  String get _cableDisplayName {
    switch (cableType) {
      case CableType.jackTs:
        return 'Jack TS · 2-pin';
      case CableType.jackTrs:
        return 'Jack TRS · 3-pin';
      case CableType.xlr:
        return 'XLR · 3-pin';
    }
  }

  String get _statusText {
    if (healthScore >= 80) return 'ИСПРАВЕН';
    if (healthScore >= 50) return 'ВНИМАНИЕ';
    return 'БРАК';
  }

  Color get _statusColor {
    if (healthScore >= 80) return const Color(0xFF97C459);
    if (healthScore >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  void _showRepeatDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF9F27).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFEF9F27).withValues(alpha: 0.4)),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    size: 20,
                    color: Color(0xFFEF9F27),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Повторить тест?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Текущий результат (Health Score 92) будет отброшен.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Color(0xFF2A2A2A)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Отмена',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestingProgressScreen(
                                cableType: cableType,
                                selectedTests: selectedTests,
                                totalDuration: selectedTests.length * 10,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          side: const BorderSide(color: Color(0xFF2A2A2A)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Повторить',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _discardResult(BuildContext context) {
    // Возвращаемся на главный экран (StartupScreen внутри MainScreen)
    // Закрываем все экраны до самого первого
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _saveToCollection(BuildContext context) {
    // TODO: реализовать сохранение в коллекцию
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Сохранение в коллекцию (в разработке)'),
        backgroundColor: Color(0xFFEF9F27),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF888888)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Результаты',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          children: [
            // Главный статус
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _statusColor.withValues(alpha: 0.12),
                      _statusColor.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _statusColor.withValues(alpha: 0.35)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _statusText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${healthScore.toInt()}',
                              style: const TextStyle(
                                fontSize: 46,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                            const TextSpan(
                              text: ' / 100',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_cableDisplayName · $_formattedTime',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Измерения
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ИЗМЕРЕНИЯ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Целостность
                  _buildMeasurementItem(
                    title: 'Целостность',
                    value: continuityResult,
                    status: 'ok',
                  ),
                  const SizedBox(height: 6),
                  // CMRR (показываем только если был выбран)
                  if (selectedTests.contains(TestType.cmrr))
                    _buildMeasurementItem(
                      title: 'CMRR',
                      value: '$cmrrDb дБ',
                      status: cmrrDb >= 50 ? 'ok' : (cmrrDb >= 30 ? 'warning' : 'fail'),
                    ),
                  const SizedBox(height: 6),
                  // АЧХ (показываем только если был выбран)
                  if (selectedTests.contains(TestType.freqResponse))
                    _buildFreqResponseItem(context),
                ],
              ),
            ),

            // Кнопки действий
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _saveToCollection(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF9F27),
                      foregroundColor: const Color(0xFF2A1A00),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Сохранить в коллекцию',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showRepeatDialog(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: Color(0xFF2A2A2A)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Повторить',
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
                          onPressed: () => _discardResult(context),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: Color(0xFF2A2A2A)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Отбросить',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementItem({
    required String title,
    required String value,
    required String status,
  }) {
    final isOk = status == 'ok';
    final isWarning = status == 'warning';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F1F1F)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isOk
                  ? const Color(0xFF639922).withValues(alpha: 0.12)
                  : (isWarning
                  ? const Color(0xFFEF9F27).withValues(alpha: 0.12)
                  : const Color(0xFFE24B4A).withValues(alpha: 0.12)),
              shape: BoxShape.circle,
              border: Border.all(
                color: isOk
                    ? const Color(0xFF97C459).withValues(alpha: 0.5)
                    : (isWarning
                    ? const Color(0xFFEF9F27).withValues(alpha: 0.5)
                    : const Color(0xFFE24B4A).withValues(alpha: 0.5)),
              ),
            ),
            child: Icon(
              isOk ? Icons.check : (isWarning ? Icons.warning_amber : Icons.close),
              size: 12,
              color: isOk
                  ? const Color(0xFF97C459)
                  : (isWarning ? const Color(0xFFEF9F27) : const Color(0xFFE24B4A)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFAFAFA),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isOk
                  ? const Color(0xFFFAFAFA)
                  : (isWarning ? const Color(0xFFEF9F27) : const Color(0xFFE24B4A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreqResponseItem(BuildContext context) {
    return Container(
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
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF9F27).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEF9F27).withValues(alpha: 0.5)),
                ),
                child: const Icon(
                  Icons.info_outline,
                  size: 12,
                  color: Color(0xFFEF9F27),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'АЧХ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFAFAFA),
                      ),
                    ),
                    Text(
                      freqResponseResult,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DetailsScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  minimumSize: Size.zero,
                  side: const BorderSide(color: Color(0xFF2A2A2A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'детали',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: CustomPaint(
              painter: _MiniGraphPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// Мини-график для АЧХ в результатах
class _MiniGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final gridPaint = Paint()
      ..color = const Color(0xFF1F1F1F)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, 14), Offset(width, 14), gridPaint);
    canvas.drawLine(Offset(0, 25), Offset(width, 25), gridPaint);
    canvas.drawLine(Offset(0, 36), Offset(width, 36), gridPaint);

    final graphPaint = Paint()
      ..color = const Color(0xFFEF9F27)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 27);
    path.lineTo(width * 0.1, 26);
    path.lineTo(width * 0.2, 25);
    path.lineTo(width * 0.3, 25);
    path.lineTo(width * 0.5, 25);
    path.lineTo(width * 0.7, 26);
    path.lineTo(width * 0.85, 28);
    path.lineTo(width * 0.95, 33);
    path.lineTo(width, 40);

    canvas.drawPath(path, graphPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}