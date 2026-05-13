import 'package:flutter/material.dart';
import '/data/test_models.dart';
import 'testing_progress_screen.dart';
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
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showSaveToCollectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SaveToCollectionSheet(
        cableType: cableType,
        healthScore: healthScore,
        continuityResult: continuityResult,
        cmrrDb: cmrrDb,
        freqResponseResult: freqResponseResult,
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
                    onPressed: () => _showSaveToCollectionSheet(context),
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

// ---------------------------------------------------------------------
// Bottom sheet для сохранения в коллекцию (полностью по макету)
// ---------------------------------------------------------------------
class _SaveToCollectionSheet extends StatefulWidget {
  final CableType cableType;
  final double healthScore;
  final String continuityResult;
  final double cmrrDb;
  final String freqResponseResult;

  const _SaveToCollectionSheet({
    required this.cableType,
    required this.healthScore,
    required this.continuityResult,
    required this.cmrrDb,
    required this.freqResponseResult,
  });

  @override
  State<_SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<_SaveToCollectionSheet> {
  // Режим: true - новый кабель, false - к существующему
  bool _isNewCable = true;

  // Выбранный цвет (по умолчанию #639922)
  Color _selectedColor = const Color(0xFF639922);

  // Контроллеры полей
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Временные данные для существующих кабелей (позже будут из БД)
  final List<Map<String, dynamic>> _existingCables = [
    {'name': 'Mogami #1', 'color': const Color(0xFF639922), 'type': 'XLR', 'id': '1'},
    {'name': 'Klotz патч', 'color': const Color(0xFF639922), 'type': 'TRS', 'id': '2'},
    {'name': 'Гитарный длинный', 'color': const Color(0xFFEF9F27), 'type': 'JACK', 'id': '3'},
    {'name': 'XLR #07', 'color': const Color(0xFFE24B4A), 'type': 'XLR', 'id': '4'},
  ];

  String? _selectedCableId; // id выбранного существующего кабеля

  // Список доступных цветов (как в макете)
  final List<Color> _colorPalette = const [
    Color(0xFF639922),
    Color(0xFFEF9F27),
    Color(0xFFE24B4A),
    Color(0xFF378ADD),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (_isNewCable) {
      final String name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите название кабеля'), backgroundColor: Color(0xFFE24B4A)),
        );
        return;
      }
      // TODO: сохранить новый кабель с именем name, заметкой _noteController.text, цветом _selectedColor
      // и привязать результат тестирования
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новый кабель сохранён (демо)'), backgroundColor: Color(0xFF97C459)),
      );
    } else {
      if (_selectedCableId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите кабель из списка'), backgroundColor: Color(0xFFEF9F27)),
        );
        return;
      }
      // TODO: привязать результат к существующему кабелю
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Результат добавлен к кабелю ${_getSelectedCableName()}'), backgroundColor: Color(0xFF97C459)),
      );
    }
    Navigator.pop(context);
    // Имитация перехода на экран деталей кабеля (как в макете)
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailsScreen()));
    });
  }

  String _getSelectedCableName() {
    final cable = _existingCables.firstWhere((c) => c['id'] == _selectedCableId, orElse: () => {'name': ''});
    return cable['name'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ручка-индикатор
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Сохранить результат',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF666666)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          // Две кнопки выбора режима
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isNewCable = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isNewCable ? const Color(0xFFEF9F27).withValues(alpha: 0.08) : const Color(0xFF111111),
                        border: Border.all(
                          color: _isNewCable ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '+ Новый кабель',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _isNewCable ? const Color(0xFFFAFAFA) : const Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Добавить в коллекцию',
                            style: TextStyle(
                              fontSize: 9,
                              color: _isNewCable ? const Color(0xFF888888) : const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isNewCable = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isNewCable ? const Color(0xFFEF9F27).withValues(alpha: 0.08) : const Color(0xFF111111),
                        border: Border.all(
                          color: !_isNewCable ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'К существующему',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: !_isNewCable ? const Color(0xFFFAFAFA) : const Color(0xFFAAAAAA),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'В историю кабеля',
                            style: TextStyle(
                              fontSize: 9,
                              color: !_isNewCable ? const Color(0xFF888888) : const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isNewCable) ...[
            // Цветовая метка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ЦВЕТОВАЯ МЕТКА',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _colorPalette.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final color = _colorPalette[index];
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            // Название
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'НАЗВАНИЕ *',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFFAFAFA)),
                    decoration: InputDecoration(
                      hintText: 'Например: Mogami студийный',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      filled: true,
                      fillColor: const Color(0xFF111111),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFEF9F27)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            // Заметка
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ЗАМЕТКА · ОПЦИОНАЛЬНО',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _noteController,
                    style: const TextStyle(fontSize: 12, color: Color(0xFFFAFAFA)),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Купил в 2024…',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      filled: true,
                      fillColor: const Color(0xFF111111),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFEF9F27)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ] else ...[
            // Список существующих кабелей
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ВЫБЕРИТЕ КАБЕЛЬ',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _existingCables.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final cable = _existingCables[index];
                        final isSelected = _selectedCableId == cable['id'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCableId = cable['id'] as String),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF111111),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: cable['color'] as Color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cable['name'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFFAFAFA),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        cable['type'],
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Color(0xFF888888),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, size: 16, color: Color(0xFFEF9F27)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
          // Кнопка Сохранить
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF9F27),
                  foregroundColor: const Color(0xFF2A1A00),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}