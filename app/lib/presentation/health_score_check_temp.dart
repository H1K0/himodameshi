import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '/domain/health_score_calculator.dart';
import '/data/test_models.dart';

/// ВРЕМЕННЫЙ ЭКРАН ДЛЯ ПРОВЕРКИ РАСЧЁТА HEALTH SCORE
/// МОЖНО БУДЕТ УДАЛИТЬ ПОСЛЕ ВЕРИФИКАЦИИ

class HealthScoreCheckTemp extends StatefulWidget {
  const HealthScoreCheckTemp({super.key});

  @override
  State<HealthScoreCheckTemp> createState() => _HealthScoreCheckTempState();
}

class _HealthScoreCheckTempState extends State<HealthScoreCheckTemp> {
  List<Map<String, dynamic>> _cables = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadCables();
  }

  /// Проверяет, есть ли в проводниках open или short
  bool _hasCatastrophicFailure(List<Map<String, dynamic>> conductors) {
    for (final conductor in conductors) {
      final status = conductor['s'] as String;
      if (status == 'open' || status == 'short') {
        return true;
      }
    }
    return false;
  }

  Future<void> _loadCables() async {
    try {
      final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final continuityResults = jsonData['results']['continuity'] as Map<String, dynamic>;
      final cmrrResults = jsonData['results']['cmrr'] as Map<String, dynamic>;
      final freqResults = jsonData['results']['freq_response'] as Map<String, dynamic>;

      final List<Map<String, dynamic>> results = [];

      // Проходим по всем кабелям в continuity
      for (final entry in continuityResults.entries) {
        final String cableId = entry.key;
        final continuityData = entry.value;

        // Определяем тип кабеля
        final String cableTypeStr = continuityData['cable'] ?? 'unknown';
        CableType? cableType;
        switch (cableTypeStr) {
          case 'xlr':
            cableType = CableType.xlr;
            break;
          case 'jack_trs':
            cableType = CableType.jackTrs;
            break;
          case 'jack_ts':
            cableType = CableType.jackTs;
            break;
          default:
            continue;
        }

        // Формируем проводники из continuity (ВСЕГДА есть)
        final conductorsMap = continuityData['conductors'] as Map<String, dynamic>;
        final List<Map<String, dynamic>> conductors = [];
        for (final condEntry in conductorsMap.entries) {
          conductors.add({
            'r': (condEntry.value['r'] as num).toDouble(),
            's': condEntry.value['s'] as String,
          });
        }

        // Проверяем наличие CMRR
        final hasCmrr = cmrrResults.containsKey(cableId);
        final double? cmrrDb = hasCmrr
            ? (cmrrResults[cableId]['cmrr_db'] as num).toDouble()
            : null;
        final String? cmrrStatus = hasCmrr ? cmrrResults[cableId]['status'] : null;

        // Проверяем наличие АЧХ
        final hasFreq = freqResults.containsKey(cableId);
        List<double>? freqValues;
        String? freqStatus;
        if (hasFreq) {
          final freqData = freqResults[cableId];
          freqValues = (freqData['v'] as List).map((e) => (e as num).toDouble()).toList();
          freqStatus = freqData['status'];
        }

        // Проверяем катастрофические условия
        final bool hasCatastrophic = _hasCatastrophicFailure(conductors);

        // Рассчитываем Health Score
        // Для балансных кабелей CMRR запускается, для TS — нет
        final bool cmrrRun = cableType.supportsCmrr;

        final HealthScoreResult result = HealthScoreCalculator.calculate(
          cableType: cableType,
          continuityConductors: conductors,
          cmrrDb: cmrrDb,
          freqResponseValues: freqValues,
          continuityRun: true,      // continuity всегда есть
          cmrrRun: cmrrRun,         // для балансных true, для TS false
          freqRun: true,         // АЧХ всегда есть
        );

        final double? healthScore = result.score;
        final bool isPartial = result.isPartial;
        final List<String> missingTests = result.missingTests;

        // Форматируем имя для отображения
        String displayName = cableId;
        if (cableTypeStr == 'jack_ts') {
          displayName = 'Jack TS (${continuityData['status']})';
          if (hasFreq) displayName += ' + АЧХ';
        } else if (cableTypeStr == 'jack_trs') {
          displayName = 'Jack TRS (${continuityData['status']})';
          if (hasCmrr) displayName += ' + CMRR(${cmrrDb?.toStringAsFixed(1)}дБ)';
          if (hasFreq) displayName += ' + АЧХ';
        } else if (cableTypeStr == 'xlr') {
          displayName = 'XLR (${continuityData['status']})';
          if (hasCmrr) displayName += ' + CMRR(${cmrrDb?.toStringAsFixed(1)}дБ)';
          if (hasFreq) displayName += ' + АЧХ';
        }

        results.add({
          'id': cableId,
          'name': displayName,
          'cableType': cableTypeStr,
          'healthScore': healthScore,
          'isPartial': isPartial,
          'missingTests': missingTests,
          'hasCatastrophic': hasCatastrophic,
          'continuityStatus': continuityData['status'],
          'hasCmrr': hasCmrr,
          'cmrrStatus': cmrrStatus,
          'cmrrDb': cmrrDb,
          'hasFreq': hasFreq,
          'freqStatus': freqStatus,
        });
      }

      // Сортируем по Health Score (от лучшего к худшему, null в конец)
      results.sort((a, b) {
        final scoreA = a['healthScore'];
        final scoreB = b['healthScore'];
        if (scoreA == null && scoreB == null) return 0;
        if (scoreA == null) return 1;
        if (scoreB == null) return -1;
        return scoreB.compareTo(scoreA);
      });

      setState(() {
        _cables = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  Color _getScoreColor(double? score) {
    if (score == null) return const Color(0xFF666666);
    if (score >= 80) return const Color(0xFF97C459);
    if (score >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  String _getScoreText(double? score) {
    if (score == null) return '—';
    return score.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Health Score Check',
          style: TextStyle(color: Color(0xFFFAFAFA), fontSize: 16),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF9F27)),
      )
          : _error.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFE24B4A)),
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cables.length,
        itemBuilder: (context, index) {
          final cable = _cables[index];
          final double? score = cable['healthScore'];
          final bool hasCatastrophic = cable['hasCatastrophic'] ?? false;
          final bool isPartial = cable['isPartial'] ?? false;
          final List<String> missingTests = cable['missingTests'] ?? [];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: hasCatastrophic
                  ? const Color(0xFF1A0A0A)
                  : const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasCatastrophic
                    ? const Color(0xFFE24B4A).withValues(alpha: 0.3)
                    : const Color(0xFF1F1F1F),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cable['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFAFAFA),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildTestBadge(
                                'Целостность',
                                cable['continuityStatus'],
                                true,
                              ),
                              _buildTestBadge(
                                'CMRR',
                                cable['cmrrStatus'],
                                cable['hasCmrr'] ?? false,
                              ),
                              _buildTestBadge(
                                'АЧХ',
                                cable['freqStatus'],
                                cable['hasFreq'] ?? false,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(score).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getScoreColor(score).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getScoreText(score),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(score),
                            ),
                          ),
                          if (isPartial && score != null)
                            const Text(
                              'неполный',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFFEF9F27),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Тип: ${cable['cableType']}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                ),
                if (hasCatastrophic)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: const Text(
                      '⚠️ Обрыв или короткое замыкание — кабель неисправен',
                      style: TextStyle(fontSize: 11, color: Color(0xFFE24B4A)),
                    ),
                  ),
                if (isPartial && missingTests.isNotEmpty && !hasCatastrophic)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '📊 Не хватает данных: ${missingTests.join(", ")}',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFEF9F27)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestBadge(String label, String? status, bool hasData) {
    if (!hasData) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF444444).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$label: нет',
          style: const TextStyle(fontSize: 9, color: Color(0xFF666666), fontWeight: FontWeight.w500),
        ),
      );
    }

    Color color;
    switch (status) {
      case 'excellent':
        color = const Color(0xFF97C459);
        break;
      case 'ok':
        color = const Color(0xFFEF9F27);
        break;
      case 'warning':
        color = const Color(0xFFEF9F27);
        break;
      case 'fail':
        color = const Color(0xFFE24B4A);
        break;
      default:
        color = const Color(0xFF888888);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${status?.toUpperCase()}',
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}