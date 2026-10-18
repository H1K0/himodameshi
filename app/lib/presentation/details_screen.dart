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
                    height: 230,
                    child: CustomPaint(
                      painter: _FrGraphPainter(),
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
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Сетка
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Горизонтальные линии
    canvas.drawLine(Offset(0, 20), Offset(width, 20), gridPaint);
    canvas.drawLine(Offset(0, 100), Offset(width, 100), gridPaint);
    canvas.drawLine(Offset(0, 220), Offset(width, 220), gridPaint);

    // Вертикальные линии
    canvas.drawLine(Offset(30, 14), Offset(30, 228), gridPaint);
    canvas.drawLine(Offset(190, 14), Offset(190, 228), gridPaint);
    canvas.drawLine(Offset(width - 2, 14), Offset(width - 2, 228), gridPaint);

    // Основная линия графика
    final graphPaint = Paint()
      ..color = const Color(0xFFEF9F27)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, 112);
    path.lineTo(30, 106);
    path.lineTo(60, 102);
    path.lineTo(90, 100);
    path.lineTo(150, 100);
    path.lineTo(210, 100);
    path.lineTo(250, 106);
    path.lineTo(280, 138);
    path.lineTo(width, 194);

    canvas.drawPath(path, graphPaint);

    // Точка на 20 кГц
    final pointPaint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.fill;

    final pointStrokePaint = Paint()
      ..color = const Color(0xFFEF9F27)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(width - 20, 138), 4, pointPaint);
    canvas.drawCircle(Offset(width - 20, 138), 4, pointStrokePaint);

    // Рисуем тексты
    _drawText(canvas, '10 Гц', 30, 250);
    _drawText(canvas, '1 кГц', 190, 250);
    _drawText(canvas, '40 кГц', width - 2, 250, alignRight: true);
    _drawText(canvas, '+2', 24, 24, alignRight: true);
    _drawText(canvas, '0', 24, 104, alignRight: true);
    _drawText(canvas, '−3', 24, 224, alignRight: true);
    _drawText(canvas, '20 кГц', width - 20, 270);
  }

  void _drawText(Canvas canvas, String text, double x, double y,
      {bool alignRight = false}) {
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontSize: 9,
      textAlign: TextAlign.center,
    ));
    paragraphBuilder.addText(text);
    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 100));

    double dx = x;
    if (alignRight) {
      dx = x - paragraph.width;
    } else {
      dx = x - paragraph.width / 2;
    }

    canvas.drawParagraph(paragraph, Offset(dx, y - 9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}