import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '/data/test_models.dart';
import '/data/insight_generator_provider.dart';
import '/data/insight_input.dart';
import '/domain/insight_exceptions.dart';

class DetailsScreen extends StatefulWidget {
  final CableType cableType;
  final int? healthScore;
  final double? continuityMin;
  final double? continuityMax;
  final double? cmrrDb;
  final double? freqPeak;
  final double? freqSigma;
  final List<double>? freqValues;
  final bool freqHasNoSignal;

  const DetailsScreen({
    super.key,
    required this.cableType,
    this.healthScore,
    this.continuityMin,
    this.continuityMax,
    this.cmrrDb,
    this.freqPeak,
    this.freqSigma,
    this.freqValues,
    this.freqHasNoSignal = false,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String? _insight;
  bool _isLoading = true;
  InsightException? _error;

  @override
  void initState() {
    super.initState();
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final input = InsightInput(
      cableType: widget.cableType,
      healthScore: widget.healthScore,
      continuity: (widget.continuityMin != null && widget.continuityMax != null)
          ? ContinuityInsight(
        min: widget.continuityMin!,
        max: widget.continuityMax!,
      )
          : null,
      cmrr: widget.cmrrDb != null
          ? CmrrInsight(valueDb: widget.cmrrDb!)
          : null,
      freq: widget.freqHasNoSignal
          ? const FreqInsight(noSignal: true)
          : (widget.freqPeak != null && widget.freqSigma != null)
          ? FreqInsight(
        peak: widget.freqPeak,
        sigma: widget.freqSigma,
      )
          : null,
    );

    try {
      final result = await InsightGeneratorProvider.instance.generate(input);

      if (!mounted) return;
      setState(() {
        _insight = result;
        _isLoading = false;
      });
    } on InsightException catch (e) {
      debugPrint('InsightGenerator error: $e');
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('InsightGenerator unexpected error: $e');
      if (!mounted) return;
      setState(() {
        _error = InsightUnknownException('$e');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'АЧХ детально',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Три карточки с показателями
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Полоса −3 дБ',
                    value: '22.4',
                    unit: 'кГц',
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMetricCard(
                    title: 'На 20 кГц',
                    value: '−2.1',
                    unit: 'дБ',
                    valueColor: const Color(0xFF97C459),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Неравн.',
                    value: '±0.4',
                    unit: 'дБ',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // График АЧХ
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1F1F1F)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 260,
                    child: CustomPaint(
                      painter: _FrGraphPainter(values: widget.freqValues),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Пояснение от LLM
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1F1F1F)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ЧТО ЭТО ЗНАЧИТ',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF666666),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildInsightContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    Color valueColor = const Color(0xFFFAFAFA),
  }) {
    return Container(
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
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 3),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightContent() {
    // Загрузка
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Color(0xFFEF9F27),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Анализ результатов...',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF888888),
              ),
            ),
          ],
        ),
      );
    }

    // Ошибка
    if (_error != null) {
      return _buildErrorContent(_error!);
    }

    // Успех
    return Text(
      _insight ?? '',
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFFCCCCCC),
        height: 1.55,
      ),
    );
  }

  Widget _buildErrorContent(InsightException error) {
    final isAuth = error is InsightAuthException;
    final text = _errorText(error);
    final color = isAuth ? const Color(0xFF888888) : const Color(0xFFEF9F27);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isAuth ? Icons.lock_outline : Icons.refresh,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isAuth ? const Color(0xFF888888) : const Color(0xFFCCCCCC),
              height: 1.55,
            ),
          ),
        ),
      ],
    );

    // Для auth — не кликабельно
    if (isAuth) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      );
    }

    // Остальные — кликабельны
    return InkWell(
      onTap: _isLoading ? null : _loadInsight,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: content,
      ),
    );
  }

  String _errorText(InsightException error) {
    if (error is InsightNetworkException) {
      return 'Нет соединения. Нажмите, чтобы повторить';
    }
    if (error is InsightRateLimitException) {
      return 'Слишком много запросов. Подождите минуту и нажмите, чтобы повторить';
    }
    if (error is InsightServerException) {
      return 'Сервис недоступен. Нажмите, чтобы повторить';
    }
    if (error is InsightAuthException) {
      return 'Ошибка доступа к сервису. Проверьте ключ API';
    }
    return 'Не удалось получить комментарий. Нажмите, чтобы повторить';
  }
}

// Кастомный painter для графика АЧХ
class _FrGraphPainter extends CustomPainter {
  final List<double>? values;

  _FrGraphPainter({this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;

    // Частотная таблица
    final List<double> freqTable = [
      10.0, 13.0, 18.0, 24.0, 31.0, 42.0, 56.0, 74.0, 99.0, 131.0,
      175.0, 232.0, 309.0, 412.0, 548.0, 730.0, 1000.0, 1293.0, 1721.0,
      2291.0, 3050.0, 4060.0, 5404.0, 7192.0, 9574.0, 12742.0, 16959.0,
      22573.0, 30043.0, 40000.0,
    ];

    final double minLog = math.log(freqTable[0]);
    final double maxLog = math.log(freqTable[29]);

    double getX(int index) {
      return ((math.log(freqTable[index]) - minLog) / (maxLog - minLog)) * (width - 30) + 15;
    }

    // Новая Y-формула. Теперь 0 дБ находится по центру между 30 и 230 (это 130).
    // Шаг (200 пикселей / 6 дБ) = 33.33 пикселя на 1 дБ.
    double getY(double db) {
      return 130 - (db * (220 / 6));
    }

    // Сетка
    final gridPaint = Paint()
      ..color = const Color(0xFF454545)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Горизонтальные линии (от 30 до 230)
    for (int db = 3; db >= -3; db--) {
      canvas.drawLine(Offset(15, getY(db.toDouble())), Offset(width, getY(db.toDouble())), gridPaint);
    }

    // Вертикальные линии (от 0 до 250)
    canvas.drawLine(Offset(getX(3), 0), Offset(getX(3), 250), gridPaint);   // 20 Гц
    canvas.drawLine(Offset(getX(8), 0), Offset(getX(8), 250), gridPaint);   // 100 Гц
    canvas.drawLine(Offset(getX(16), 0), Offset(getX(16), 250), gridPaint); // 1 кГц
    canvas.drawLine(Offset(getX(24), 0), Offset(getX(24), 250), gridPaint); // 10 кГц
    canvas.drawLine(Offset(getX(29), 0), Offset(getX(29), 250), gridPaint); // 40 кГц

    // Подписи осей Y (сдвинуты вправо на x=45)
    for (int db = 3; db >= -3; db--) {
      String label = db > 0 ? '+$db' : (db == 0 ? '0' : '−${db.abs()}');
      _drawText(canvas, label, 45, getY(db.toDouble()), alignRight: true);
    }

    // Подписи осей X (опущены вниз до y=255)
    _drawText(canvas, '20 Гц', getX(3), 255);
    _drawText(canvas, '100 Гц', getX(8), 255);
    _drawText(canvas, '1 кГц', getX(16), 255);
    _drawText(canvas, '10 кГц', getX(24), 255);
    _drawText(canvas, '40 кГц', getX(29), 255);

    // Если данных нет — прямая линия
    if (values == null || values!.isEmpty || values!.length < 30) {
      final graphPaint = Paint()..color = const Color(0xFFEF9F27)..strokeWidth = 2..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, getY(0)), Offset(width, getY(0)), graphPaint);
      return;
    }

    // Проверяем, есть ли сильный провал (ниже -3 дБ)
    final bool hasDrop = values!.any((v) => v < -3.0);

    // Рисуем график по точкам
    final graphPaint = Paint()
      ..color = hasDrop ? const Color(0xFFE24B4A) : const Color(0xFFEF9F27) // Красный при провале
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool first = true;
    for (int i = 0; i < 30; i++) {
      final double x = getX(i);
      final double y = getY(values![i]);

      if (first) {
        path.moveTo(x, y.clamp(30.0, 240.0));
        first = false;
      } else {
        path.lineTo(x, y.clamp(30.0, 240.0));
      }
    }
    canvas.drawPath(path, graphPaint);

    // Точка на 20 кГц
    final double x20k = getX(27);
    final double v20k = values![27];
    final double y20k = getY(v20k);

    final bool isBad20k = v20k < -3.0;
    final Color pointColor = isBad20k ? const Color(0xFFE24B4A) : const Color(0xFFEF9F27);

    final pointPaint = Paint()..color = const Color(0xFF0A0A0A)..style = PaintingStyle.fill;
    final pointStrokePaint = Paint()..color = pointColor..strokeWidth = 1.5..style = PaintingStyle.stroke;

    // Рисуем точку (прижимая её к нижней границе, если она ушла за -3)
    final double displayY = y20k.clamp(30.0, 240.0);
    canvas.drawCircle(Offset(x20k, displayY), 4, pointPaint);
    canvas.drawCircle(Offset(x20k, displayY), 4, pointStrokePaint);

    // Рисуем подпись со значением: НАД точкой, если это провал, и ПОД точкой в норме
    final String labelText = isBad20k ? '${v20k.toStringAsFixed(1)} дБ' : '20 кГц';
    final double labelY = isBad20k ? displayY - 12 : displayY + 18;

    _drawText(canvas, labelText, x20k, labelY);
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool alignRight = false}) {
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: 9, textAlign: TextAlign.center));
    paragraphBuilder.addText(text);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 100));

    double dx = x;
    if (alignRight) {
      dx = x - paragraph.width;
    } else {
      dx = x - paragraph.width / 2;
    }

    // Вычитаем половину высоты текста (примерно 4.5 пикселя), чтобы центр текста
    // совпал с координатой y.
    canvas.drawParagraph(paragraph, Offset(dx, y-4.5));
  }

  @override
  bool shouldRepaint(covariant _FrGraphPainter oldDelegate) {
    return oldDelegate.values != values; // Перерисовываем при изменении данных
  }
}