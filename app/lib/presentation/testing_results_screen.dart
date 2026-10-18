import 'package:flutter/material.dart';
import 'dart:convert';
import '/data/test_models.dart';
import '/data/database_helper.dart';
import '/domain/health_score_calculator.dart';
import 'details_screen.dart';
import 'testing_progress_screen.dart';
import 'cable_passport_screen.dart';
import '/domain/freq_response_stats.dart';

class TestingResultsScreen extends StatelessWidget {
  final CableType cableType;
  final List<TestType> selectedTests;
  final double totalTimeSeconds;

  // Сгенерированные (mock) или реальные результаты
  final Map<String, dynamic>? continuityResult;
  final double? cmrrDb;
  final List<double>? freqValues;

  const TestingResultsScreen({
    super.key,
    required this.cableType,
    required this.selectedTests,
    required this.totalTimeSeconds,
    this.continuityResult,
    this.cmrrDb,
    this.freqValues,
  });

  // -------------------------------------------------------------------------
  // Расчёт Health Score по сгенерированным данным
  // -------------------------------------------------------------------------

  HealthScoreResult get _healthResult {
    final conductors = (continuityResult?['conductors'] as List?)
        ?.cast<Map<String, dynamic>>() ??
        [];

    return HealthScoreCalculator.calculate(
      cableType: cableType,
      continuityConductors: conductors,
      cmrrDb: cmrrDb,
      freqResponseValues: freqValues,
      continuityRun: selectedTests.contains(TestType.continuity),
      cmrrRun: selectedTests.contains(TestType.cmrr),
      freqRun: selectedTests.contains(TestType.freqResponse),
    );
  }

  int get _healthScore => (_healthResult.score ?? 0).round();

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
    final score = _healthScore;
    if (_healthResult.score == null) return 'НЕПОЛНЫЙ';
    if (score >= 80) return 'ИСПРАВЕН';
    if (score >= 50) return 'ВНИМАНИЕ';
    return 'БРАК';
  }

  Color get _statusColor {
    if (_healthResult.score == null) return const Color(0xFF888888);
    final score = _healthScore;
    if (score >= 80) return const Color(0xFF97C459);
    if (score >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  /// Строка результата целостности: диапазон сопротивлений + худший статус
  String get _continuityResultText {
    if (continuityResult == null) return '—';
    final conductors =
    (continuityResult!['conductors'] as List).cast<Map<String, dynamic>>();
    if (conductors.isEmpty) return '—';

    final rs = conductors.map((c) => c['r'] as double).toList();
    final minR = rs.reduce((a, b) => a < b ? a : b);
    final maxR = rs.reduce((a, b) => a > b ? a : b);

    // Если есть open/short — показываем это явно
    final hasOpen = conductors.any((c) => c['s'] == 'open');
    final hasShort = conductors.any((c) => c['s'] == 'short');
    if (hasOpen) return 'обрыв';
    if (hasShort) return 'КЗ';

    return '${minR.toStringAsFixed(2)}–${maxR.toStringAsFixed(2)} Ом';
  }

  /// Статус целостности для иконки: ok / warning / fail
  String get _continuityStatus {
    if (continuityResult == null) return 'fail';
    final conductors =
    (continuityResult!['conductors'] as List).cast<Map<String, dynamic>>();
    if (conductors.any((c) => c['s'] == 'open' || c['s'] == 'short')) {
      return 'fail';
    }
    if (conductors.any((c) => c['s'] == 'warning')) return 'warning';
    return 'ok';
  }

  /// Строка результата CMRR
  String get _cmrrResultText {
    if (cmrrDb == null) return '—';
    return '${cmrrDb!.toStringAsFixed(1)} дБ';
  }

  /// Статус CMRR для иконки
  String get _cmrrStatus {
    if (cmrrDb == null) return 'fail';
    if (cmrrDb! >= 60) return 'ok';
    if (cmrrDb! >= 40) return 'warning';
    return 'fail';
  }

  /// Строка результата АЧХ: пик завала в аудиодиапазоне
  String get _freqResultText {
    if (freqValues == null || freqValues!.isEmpty) return '—';
    if (freqValues!.any((v) => v <= -99.0)) return 'нет сигнала';

    // Пик в аудиодиапазоне: индексы 3..26 (20 Гц – 17 кГц)
    final audio = freqValues!.sublist(3, 27);
    double peak = 0.0;
    for (final v in audio) {
      if (v.abs() > peak) peak = v.abs();
    }
    return 'спад −${peak.toStringAsFixed(1)} дБ';
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
                Text(
                  'Текущий результат (Health Score $_healthScore) будет отброшен.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
        selectedTests: selectedTests,
        healthScore: _healthScore.toInt(),
        continuityResult: _continuityResultText,
        cmrrDb: cmrrDb ?? 0.0,
        freqResponseResult: _freqResultText,
        totalTimeSeconds: totalTimeSeconds,
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
                              text: '$_healthScore',
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
                    value: _continuityResultText,
                    status: _continuityStatus,
                  ),
                  const SizedBox(height: 6),
                  // CMRR (показываем только если был выбран)
                  if (selectedTests.contains(TestType.cmrr))
                    _buildMeasurementItem(
                      title: 'CMRR',
                      value: _cmrrResultText,
                      status: _cmrrStatus,
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
                      _freqResultText,
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
                  // Считаем peak/sigma в аудио-диапазоне для передачи в DetailsScreen
                  final freqValues = this.freqValues;
                  double? peak;
                  double? sigma;
                  bool hasNoSignal = false;

                  if (freqValues != null && freqValues.isNotEmpty) {
                    if (freqValues.length < FreqResponseStats.audioEndIndex) {
                      hasNoSignal = true;
                    } else {
                      final stats = FreqResponseStats.fromValues(freqValues);
                      if (stats.noSignal) {
                        hasNoSignal = true;
                      } else {
                        peak = stats.peak;
                        sigma = stats.sigma;
                      }
                    }
                  }

                  // Считаем диапазон сопротивлений из continuityResult
                  double? contMin;
                  double? contMax;
                  if (continuityResult != null) {
                    final conductors = (continuityResult!['conductors'] as List)
                        .cast<Map<String, dynamic>>();
                    if (conductors.isNotEmpty) {
                      final rs = conductors.map((c) => c['r'] as double).toList();
                      contMin = rs.reduce((a, b) => a < b ? a : b);
                      contMax = rs.reduce((a, b) => a > b ? a : b);
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(
                        cableType: cableType,
                        healthScore: _healthScore,
                        continuityMin: contMin,
                        continuityMax: contMax,
                        cmrrDb: cmrrDb,
                        freqPeak: peak,
                        freqSigma: sigma,
                        freqHasNoSignal: hasNoSignal,
                      ),
                    ),
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
// Bottom sheet для сохранения в коллекцию (с интеграцией БД)
// ---------------------------------------------------------------------
class _SaveToCollectionSheet extends StatefulWidget {
  final CableType cableType;
  final List<TestType> selectedTests;
  final int healthScore;
  final String continuityResult;
  final double cmrrDb;
  final String freqResponseResult;
  final double totalTimeSeconds;

  const _SaveToCollectionSheet({
    required this.cableType,
    required this.selectedTests,
    required this.healthScore,
    required this.continuityResult,
    required this.cmrrDb,
    required this.freqResponseResult,
    required this.totalTimeSeconds,
  });

  @override
  State<_SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<_SaveToCollectionSheet> {
  bool _isNewCable = true;
  Color _selectedColor = const Color(0xFF639922);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Map<String, dynamic>> _cables = [];
  bool _isLoading = true;
  String? _selectedCableId;

  final List<Color> _colorPalette = const [
    Color(0xFF639922),
    Color(0xFFEF9F27),
    Color(0xFFE24B4A),
    Color(0xFF378ADD),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
  ];

  @override
  void initState() {
    super.initState();
    _loadCables();
  }

  Future<void> _loadCables() async {
    setState(() => _isLoading = true);
    try {
      final cables = await DatabaseHelper().getCables();
      setState(() {
        _cables = cables;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки кабелей: $e'), backgroundColor: const Color(0xFFE24B4A)),
        );
      }
    }
  }

  String _cableTypeDisplay(String type) {
    switch (type) {
      case 'jack_ts': return 'JACK TS';
      case 'jack_trs': return 'JACK TRS';
      case 'xlr': return 'XLR';
      default: return type.toUpperCase();
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2);
  }

  String _mapCableType(CableType type) {
    switch (type) {
      case CableType.jackTs: return 'jack_ts';
      case CableType.jackTrs: return 'jack_trs';
      case CableType.xlr: return 'xlr';
    }
  }

  Map<String, dynamic> _parseContinuityResult() {
    // Пример парсинга для демонстрации
    if (widget.cableType == CableType.xlr) {
      return {
        'pin1': {'r': 0.9, 's': 'ok'},
        'pin2': {'r': 1.2, 's': 'ok'},
        'pin3': {'r': 1.4, 's': 'ok'},
      };
    } else if (widget.cableType == CableType.jackTrs) {
      return {
        'tip': {'r': 0.9, 's': 'ok'},
        'ring': {'r': 1.2, 's': 'ok'},
        'sleeve': {'r': 1.4, 's': 'ok'},
      };
    } else {
      return {
        'tip': {'r': 0.9, 's': 'ok'},
        'sleeve': {'r': 1.4, 's': 'ok'},
      };
    }
  }

  String _getContinuityStatus() {
    return 'ok';
  }

  String _getCmrrStatus() {
    if (widget.cmrrDb >= 60) return 'excellent';
    if (widget.cmrrDb >= 40) return 'ok';
    return 'fail';
  }

  List<List<num>> _generateFreqPoints() {
    return [
      [10, 0.1], [20, 0.1], [50, 0.0], [100, 0.0], [200, -0.1],
      [500, -0.2], [1000, -0.2], [2000, -0.3], [5000, -0.5],
      [10000, -0.8], [20000, -2.1], [40000, -4.5]
    ];
  }

  String _getFreqStatus() {
    if (widget.freqResponseResult.contains('−2.1')) return 'excellent';
    if (widget.freqResponseResult.contains('−3')) return 'ok';
    return 'fail';
  }

  Future<void> _saveTestSession(int cableId) async {
    final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final String bleDeviceId = 'HM-2A4F-001'; // В реальном приложении брать из BleProvider

    final Map<String, dynamic> session = {
      'cable_id': cableId,
      'started_at': now - (widget.totalTimeSeconds ~/ 1).toInt(),
      'health_score': widget.healthScore,
      'ble_device_id': bleDeviceId,
    };
    final int sessionId = await DatabaseHelper().insertTestSession(session);

    // Сохраняем результаты целостности, если тест был выбран
    if (widget.selectedTests.contains(TestType.continuity)) {
      final conductors = _parseContinuityResult();
      final continuityStatus = _getContinuityStatus();
      await DatabaseHelper().insertContinuityResult({
        'session_id': sessionId,
        'status': continuityStatus,
        'conductors': jsonEncode(conductors),
      });
    }

    // Сохраняем CMRR, если был выбран
    if (widget.selectedTests.contains(TestType.cmrr)) {
      final cmrrStatus = _getCmrrStatus();
      await DatabaseHelper().insertCmrrResult({
        'session_id': sessionId,
        'value_db': widget.cmrrDb,
        'status': cmrrStatus,
      });
    }

    // Сохраняем АЧХ, если был выбран
    if (widget.selectedTests.contains(TestType.freqResponse)) {
      final points = _generateFreqPoints();
      final freqStatus = _getFreqStatus();
      await DatabaseHelper().insertFreqResponseResult({
        'session_id': sessionId,
        'status': freqStatus,
        'points': jsonEncode(points),
      });
    }
  }

  Future<void> _save() async {
    if (_isNewCable) {
      final String name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите название кабеля'), backgroundColor: Color(0xFFE24B4A)),
        );
        return;
      }

      final String colorHex = _colorToHex(_selectedColor);
      final String cableTypeStr = _mapCableType(widget.cableType);
      final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String note = _noteController.text.trim();

      final Map<String, dynamic> newCable = {
        'name': name,
        'color': colorHex,
        'cable_type': cableTypeStr,
        'created_at': now,
        'note': note,
      };

      try {
        final int cableId = await DatabaseHelper().insertCable(newCable);
        await _saveTestSession(cableId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Новый кабель сохранён'), backgroundColor: Color(0xFF97C459)),
          );
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CablePassportScreen(
                cableName: name,
                cableType: cableTypeStr,
                healthScore: widget.healthScore,
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка сохранения: $e'), backgroundColor: const Color(0xFFE24B4A)),
          );
        }
      }
    } else {
      if (_selectedCableId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите кабель из списка'), backgroundColor: Color(0xFFEF9F27)),
        );
        return;
      }

      final int cableId = int.parse(_selectedCableId!);
      try {
        await _saveTestSession(cableId);
        final cable = _cables.firstWhere((c) => c['id'] == cableId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Результат добавлен к кабелю ${cable['name']}'), backgroundColor: Color(0xFF97C459)),
          );
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CablePassportScreen(
                cableName: cable['name'],
                cableType: cable['cable_type'],
                healthScore: widget.healthScore,
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка сохранения: $e'), backgroundColor: const Color(0xFFE24B4A)),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
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
          // Заголовок
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
          // Переключатель режимов
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildModeButton('+ Новый кабель', 'Добавить в коллекцию', true),
                const SizedBox(width: 6),
                _buildModeButton('К существующему', 'В историю кабеля', false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Контент в зависимости от режима
          if (_isNewCable) ...[
            _buildColorPicker(),
            _buildNameField(),
            _buildNoteField(),
          ] else ...[
            _buildExistingCablesList(),
          ],
          // Кнопка сохранения
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

  Widget _buildModeButton(String title, String subtitle, bool isNew) {
    final isSelected = _isNewCable == isNew;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isNewCable = isNew),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFEF9F27).withValues(alpha: 0.08)
                : const Color(0xFF111111),
            border: Border.all(
              color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFFFAFAFA) : const Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? const Color(0xFF888888) : const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Padding(
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
    );
  }

  Widget _buildNameField() {
    return Padding(
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
    );
  }

  Widget _buildNoteField() {
    return Padding(
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
    );
  }

  Widget _buildExistingCablesList() {
    return Padding(
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
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_cables.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Нет сохранённых кабелей',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _cables.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final cable = _cables[index];
                  final isSelected = _selectedCableId == cable['id'].toString();
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCableId = cable['id'].toString()),
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
                              color: _hexToColor(cable['color']),
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
                                  _cableTypeDisplay(cable['cable_type']),
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
    );
  }
}