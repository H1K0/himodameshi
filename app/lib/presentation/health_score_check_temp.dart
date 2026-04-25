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

        // Формируем проводники из continuity
        final conductorsMap = continuityData['conductors'] as Map<String, dynamic>;
        final List<Map<String, dynamic>> conductors = [];
        for (final condEntry in conductorsMap.entries) {
          conductors.add({
            'r': (condEntry.value['r'] as num).toDouble(),
            's': condEntry.value['s'] as String,
          });
        }

        if (conductors.isEmpty) continue;

        // Проверяем катастрофические условия
        final bool hasCatastrophic = _hasCatastrophicFailure(conductors);

        // Проверяем наличие CMRR (для балансных обязательно, для TS не нужно)
        final hasCmrr = cmrrResults.containsKey(cableId);
        if (cableType.supportsCmrr && !hasCmrr && !hasCatastrophic) continue;

        // Проверяем наличие АЧХ (для катастрофических пропускаем проверку)
        final hasFreq = freqResults.containsKey(cableId);
        if (!hasFreq && !hasCatastrophic) continue;

        // Получаем CMRR (если есть)
        final double? cmrrDb = hasCmrr
            ? (cmrrResults[cableId]['cmrr_db'] as num).toDouble()
            : null;

        // Получаем АЧХ (если есть)
        List<double>? freqValues;
        String? freqStatus;
        if (hasFreq) {
          final freqData = freqResults[cableId];
          freqValues = (freqData['v'] as List).map((e) => (e as num).toDouble()).toList();
          freqStatus = freqData['status'];
        }

        // Рассчитываем Health Score
        final double healthScore = hasCatastrophic
            ? 0.0
            : HealthScoreCalculator.calculate(
          cableType: cableType,
          continuityConductors: conductors,
          cmrrDb: cmrrDb,
          freqResponseValues: freqValues,
        );

        results.add({
          'id': cableId,
          'name': cableId,
          'cableType': cableTypeStr,
          'healthScore': healthScore,
          'hasCatastrophic': hasCatastrophic,
          'continuityStatus': continuityData['status'],
          'cmrrStatus': hasCmrr ? cmrrResults[cableId]['status'] : null,
          'freqStatus': freqStatus,
          'cmrrDb': cmrrDb,
          'hasCmrr': hasCmrr,
          'hasFreq': hasFreq,
        });
      }

      // Сортируем по Health Score (от лучшего к худшему)
      results.sort((a, b) => b['healthScore'].compareTo(a['healthScore']));

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

  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return const Color(0xFF97C459);
    if (score >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
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
          : _cables.isEmpty
          ? const Center(
        child: Text(
          'Нет кабелей',
          style: TextStyle(color: Color(0xFF888888)),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cables.length,
        itemBuilder: (context, index) {
          final cable = _cables[index];
          final double score = cable['healthScore'];
          final bool hasCatastrophic = (cable['hasCatastrophic'] ?? false) as bool;

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
                      child: Row(
                        children: [
                          Text(
                            cable['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFAFAFA),
                            ),
                          ),
                          if (hasCatastrophic)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE24B4A).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFE24B4A).withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                'КАТАСТРОФА',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFE24B4A),
                                ),
                              ),
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
                      child: Text(
                        score.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(score),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Тип: ${cable['cableType']}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildStatusChip('Целостность', cable['continuityStatus']),
                    if (cable['hasCmrr'] == true)
                      _buildStatusChip('CMRR', cable['cmrrStatus'])
                    else if (!cable['hasCatastrophic'])
                      _buildStatusChip('CMRR', 'не измерялся'),
                    if (cable['hasFreq'] == true)
                      _buildStatusChip('АЧХ', cable['freqStatus'])
                    else if (!cable['hasCatastrophic'])
                      _buildStatusChip('АЧХ', 'нет данных'),
                  ],
                ),
                if (cable['cmrrDb'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'CMRR: ${cable['cmrrDb']} дБ',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                    ),
                  ),
                if (hasCatastrophic)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: const Text(
                      '⚠️ Обрыв или короткое замыкание — кабель неисправен',
                      style: TextStyle(fontSize: 11, color: Color(0xFFE24B4A)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, String? status) {
    if (status == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF666666).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$label: НЕТ ДАННЫХ',
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
        color = const Color(0xFF666666);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${status.toUpperCase()}',
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}