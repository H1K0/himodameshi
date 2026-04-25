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

  Future<void> _loadCables() async {
    try {
      final jsonString = await rootBundle.loadString('mock/ble_mock_packets.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final continuityResults = jsonData['results']['continuity'] as Map<String, dynamic>;
      final cmrrResults = jsonData['results']['cmrr'] as Map<String, dynamic>;
      final freqResults = jsonData['results']['freq_response'] as Map<String, dynamic>;

      final List<Map<String, dynamic>> results = [];

      // Берем только xlr_ok
      final xlrOkId = 'xlr_ok';
      if (continuityResults.containsKey(xlrOkId) &&
          cmrrResults.containsKey(xlrOkId) &&
          freqResults.containsKey(xlrOkId)) {

        final continuityData = continuityResults[xlrOkId];
        final cmrrData = cmrrResults[xlrOkId];
        final freqData = freqResults[xlrOkId];

        // Формируем проводники
        final conductorsMap = continuityData['conductors'] as Map<String, dynamic>;
        final List<Map<String, dynamic>> conductors = [];
        for (final entry in conductorsMap.entries) {
          conductors.add({
            'r': (entry.value['r'] as num).toDouble(),
            's': entry.value['s'] as String,
          });
        }

        final cmrrDb = (cmrrData['cmrr_db'] as num).toDouble();
        final freqValues = (freqData['v'] as List).map((e) => (e as num).toDouble()).toList();

        final double healthScore = HealthScoreCalculator.calculate(
          cableType: CableType.xlr,
          continuityConductors: conductors,
          cmrrDb: cmrrDb,
          freqResponseValues: freqValues,
        );

        results.add({
          'name': 'XLR OK',
          'cableType': 'xlr',
          'healthScore': healthScore,
          'cmrrDb': cmrrDb,
        });
      }

      // Берем jack_trs_ok
      final jackTrsOkId = 'jack_trs_ok';
      if (continuityResults.containsKey(jackTrsOkId) &&
          cmrrResults.containsKey(jackTrsOkId) &&
          freqResults.containsKey(jackTrsOkId)) {

        final continuityData = continuityResults[jackTrsOkId];
        final cmrrData = cmrrResults[jackTrsOkId];
        final freqData = freqResults[jackTrsOkId];

        // Формируем проводники
        final conductorsMap = continuityData['conductors'] as Map<String, dynamic>;
        final List<Map<String, dynamic>> conductors = [];
        for (final entry in conductorsMap.entries) {
          conductors.add({
            'r': (entry.value['r'] as num).toDouble(),
            's': entry.value['s'] as String,
          });
        }

        final cmrrDb = (cmrrData['cmrr_db'] as num).toDouble();
        final freqValues = (freqData['v'] as List).map((e) => (e as num).toDouble()).toList();

        final double healthScore = HealthScoreCalculator.calculate(
          cableType: CableType.jackTrs,
          continuityConductors: conductors,
          cmrrDb: cmrrDb,
          freqResponseValues: freqValues,
        );

        results.add({
          'name': 'Jack TRS OK',
          'cableType': 'jack_trs',
          'healthScore': healthScore,
          'cmrrDb': cmrrDb,
        });
      }

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
          'Нет кабелей с полным набором тестов',
          style: TextStyle(color: Color(0xFF888888)),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cables.length,
        itemBuilder: (context, index) {
          final cable = _cables[index];
          final score = cable['healthScore'];

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F1F1F)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cable['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFAFAFA),
                        ),
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
                        '$score',
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
                if (cable['cmrrDb'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'CMRR: ${cable['cmrrDb']} дБ',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}