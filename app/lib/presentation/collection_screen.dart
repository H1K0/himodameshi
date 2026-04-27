import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '/domain/health_score_calculator.dart';
import '/data/test_models.dart';
import 'cable_passport_screen.dart';
import 'dart:math';
import 'package:intl/intl.dart';

/// Статус фильтрации по цвету
enum ColorFilter {
  all,
  green,
  yellow,
  red,
}

/// Статус фильтрации по типу кабеля
enum TypeFilter {
  all,
  xlr,
  jackTrs,
  jackTs,
}

/// Направление сортировки
enum SortDirection {
  ascending,
  descending,
}

/// Поле сортировки
enum SortField {
  date,
  healthScore,
  name,
}

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<Map<String, dynamic>> _allCables = [];
  List<Map<String, dynamic>> _filteredCables = [];
  bool _isLoading = true;
  String _error = '';

  // Фильтры и сортировка
  ColorFilter _colorFilter = ColorFilter.all;
  TypeFilter _typeFilter = TypeFilter.all;
  SortField _sortField = SortField.date;
  SortDirection _sortDirection = SortDirection.descending;
  String _searchQuery = '';

  bool _isSortMenuVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCables();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

      for (final entry in continuityResults.entries) {
        final String cableId = entry.key;
        final continuityData = entry.value;

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

        // Формируем проводники
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

        // Проверяем наличие АЧХ
        final hasFreq = freqResults.containsKey(cableId);
        List<double>? freqValues;
        if (hasFreq) {
          final freqData = freqResults[cableId];
          freqValues = (freqData['v'] as List).map((e) => (e as num).toDouble()).toList();
        }

        final bool hasCatastrophic = _hasCatastrophicFailure(conductors);
        final bool cmrrRun = cableType.supportsCmrr;

        final HealthScoreResult result = HealthScoreCalculator.calculate(
          cableType: cableType,
          continuityConductors: conductors,
          cmrrDb: cmrrDb,
          freqResponseValues: freqValues,
          continuityRun: true,
          cmrrRun: cmrrRun,
          freqRun: hasFreq,
        );

        final double? healthScore = result.score;

        // Определяем цвет для фильтрации (по health score или для катастрофических)
        String colorCategory = 'green';
        if (hasCatastrophic) {
          colorCategory = 'red';
        } else if (healthScore != null) {
          if (healthScore >= 80) colorCategory = 'green';
          else if (healthScore >= 50) colorCategory = 'yellow';
          else colorCategory = 'red';
        }

        // Форматируем имя
        String displayName = _formatName(cableId);
        if (cableTypeStr == 'jack_ts') {
          displayName = 'Jack TS ${_capitalize(continuityData['status'] ?? '')}';
        } else if (cableTypeStr == 'jack_trs') {
          displayName = 'Jack TRS ${_capitalize(cmrrResults[cableId]?['status'] ?? '')}';
        } else if (cableTypeStr == 'xlr') {
          displayName = 'XLR ${_capitalize(cmrrResults[cableId]?['status'] ?? '')}';
        }

        results.add({
          'id': cableId,
          'name': displayName,
          'cableType': cableTypeStr,
          'healthScore': healthScore,
          'hasCatastrophic': hasCatastrophic,
          'continuityStatus': continuityData['status'],
          'colorCategory': colorCategory,
          'checksCount': _getChecksCount(continuityData),
          'lastCheck': _getLastCheckDate(cableId),
        });
      }

      setState(() {
        _allCables = results;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  String _formatName(String key) {
    final parts = key.split('_');
    if (parts.length >= 2) {
      final type = parts[0].toUpperCase();
      final status = parts[1];
      return '$type ${status[0].toUpperCase()}${status.substring(1)}';
    }
    return key;
  }

  String _capitalize(String str) {
    if (str.isEmpty) return str;
    return str[0].toUpperCase() + str.substring(1);
  }

  int _getChecksCount(Map<String, dynamic> continuityData) {
    // Заглушка — позже заменим на реальные данные
    return Random().nextInt(6);
  }

  String _getLastCheckDate(String cableId) {
    // Заглушка — позже заменим на реальные данные
    return DateFormat('dd/MM/yyyy').format(DateTime.utc(2026, 4, Random().nextInt(25)+1));
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allCables);

    // Поиск по имени
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cable) {
        return cable['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Фильтр по цвету (Health Score) — применяется ТОЛЬКО если выбран цветовой фильтр
    if (_colorFilter != ColorFilter.all && _typeFilter == TypeFilter.all) {
      filtered = filtered.where((cable) {
        switch (_colorFilter) {
          case ColorFilter.green:
            return cable['colorCategory'] == 'green';
          case ColorFilter.yellow:
            return cable['colorCategory'] == 'yellow';
          case ColorFilter.red:
            return cable['colorCategory'] == 'red';
          default:
            return true;
        }
      }).toList();
    }
    // Фильтр по типу кабеля — применяется ТОЛЬКО если выбран типовой фильтр
    else if (_typeFilter != TypeFilter.all && _colorFilter == ColorFilter.all) {
      filtered = filtered.where((cable) {
        switch (_typeFilter) {
          case TypeFilter.xlr:
            return cable['cableType'] == 'xlr';
          case TypeFilter.jackTrs:
            return cable['cableType'] == 'jack_trs';
          case TypeFilter.jackTs:
            return cable['cableType'] == 'jack_ts';
          default:
            return true;
        }
      }).toList();
    }

    // Сортировка
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortField) {
        case SortField.date:
          comparison = a['lastCheck'].compareTo(b['lastCheck']);
          break;
        case SortField.healthScore:
          final scoreA = a['healthScore'] ?? -1.0;
          final scoreB = b['healthScore'] ?? -1.0;
          comparison = scoreA.compareTo(scoreB);
          break;
        case SortField.name:
          comparison = a['name'].compareTo(b['name']);
          break;
      }
      return _sortDirection == SortDirection.ascending ? comparison : -comparison;
    });

    setState(() {
      _filteredCables = filtered;
    });
  }

  void _updateSearch(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _setColorFilter(ColorFilter filter) {
    setState(() {
      _colorFilter = filter;
      _typeFilter = TypeFilter.all; // При выборе цвета — сбрасываем тип
    });
    _applyFilters();
  }

  void _setTypeFilter(TypeFilter filter) {
    setState(() {
      _typeFilter = filter;
      _colorFilter = ColorFilter.all; // При выборе типа — сбрасываем цвет
    });
    _applyFilters();
  }

  void _clearFilters() {
    setState(() {
      _colorFilter = ColorFilter.all;
      _typeFilter = TypeFilter.all;
    });
    _applyFilters();
  }

  void _setSortField(SortField field) {
    if (_sortField == field) {
      // Если то же поле — меняем направление
      setState(() {
        _sortDirection = _sortDirection == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.ascending;
      });
    } else {
      setState(() {
        _sortField = field;
        _sortDirection = SortDirection.descending;
      });
    }
    _isSortMenuVisible = false;
    _applyFilters();
  }

  void _toggleSortDirection() {
    setState(() {
      _sortDirection = _sortDirection == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending;
    });
    _applyFilters();
  }

  Color _getScoreColor(double? score) {
    if (score == null) return const Color(0xFF666666);
    if (score >= 80) return const Color(0xFF97C459);
    if (score >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  String _getScoreText(double? score) {
    if (score == null) return '—';
    return '${score.toInt()}';
  }

  void _navigateToCableDetail(Map<String, dynamic> cable) {
    final double healthScore = cable['healthScore'] ?? 0.0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CablePassportScreen(
          cableName: cable['name'],
          cableType: cable['cableType'],
          healthScore: healthScore,
          onBack: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  String _getTypeLabel(TypeFilter filter) {
    switch (filter) {
      case TypeFilter.all:
        return 'Все';
      case TypeFilter.xlr:
        return 'XLR';
      case TypeFilter.jackTrs:
        return 'Jack TRS';
      case TypeFilter.jackTs:
        return 'Jack TS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Коллекция',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        actions: [
          // Кнопка сортировки (пирамидка)
          IconButton(
            icon: Icon(
              _sortDirection == SortDirection.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: const Color(0xFFAAAAAA),
              size: 20,
            ),
            onPressed: _toggleSortDirection,
          ),
          // Кнопка меню сортировки
          PopupMenuButton<SortField>(
            icon: const Icon(Icons.sort, color: Color(0xFFAAAAAA)),
            color: const Color(0xFF141414),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            onSelected: _setSortField,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortField.date,
                child: Text('По дате проверки', style: TextStyle(color: Color(0xFFE8E8E8))),
              ),
              const PopupMenuItem(
                value: SortField.healthScore,
                child: Text('По Health Score', style: TextStyle(color: Color(0xFFE8E8E8))),
              ),
              const PopupMenuItem(
                value: SortField.name,
                child: Text('По имени (А–Я)', style: TextStyle(color: Color(0xFFE8E8E8))),
              ),
            ],
          ),
        ],
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
          : Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Color(0xFFFAFAFA)),
              onChanged: _updateSearch,
              decoration: InputDecoration(
                hintText: 'Поиск по названию',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF666666), size: 18),
                filled: true,
                fillColor: const Color(0xFF111111),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF1F1F1F)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFEF9F27)),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          // Чипсы фильтров
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Цветовые фильтры
                _buildFilterChip('Все · ${_allCables.length}', ColorFilter.all, _colorFilter == ColorFilter.all && _typeFilter == TypeFilter.all),
                _buildColorFilterChip('${_getCountByColor('green')}', ColorFilter.green, Colors.green),
                _buildColorFilterChip('${_getCountByColor('yellow')}', ColorFilter.yellow, Colors.orange),
                _buildColorFilterChip('${_getCountByColor('red')}', ColorFilter.red, Colors.red),
                // Типовые фильтры
                _buildTypeFilterChip('XLR', TypeFilter.xlr),
                _buildTypeFilterChip('Jack TS', TypeFilter.jackTs),
                _buildTypeFilterChip('Jack TRS', TypeFilter.jackTrs),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Список кабелей
          Expanded(
            child: _filteredCables.isEmpty
                ? const Center(
              child: Text(
                'Нет кабелей',
                style: TextStyle(color: Color(0xFF888888)),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
              itemCount: _filteredCables.length,
              itemBuilder: (context, index) {
                final cable = _filteredCables[index];
                final double? score = cable['healthScore'];
                final bool hasCatastrophic = cable['hasCatastrophic'] ?? false;

                Color stripColor = _getScoreColor(score);
                if (hasCatastrophic) stripColor = const Color(0xFFE24B4A);

                return GestureDetector(
                  onTap: () => _navigateToCableDetail(cable),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1F1F1F)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 36,
                          decoration: BoxDecoration(
                            color: stripColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    cable['name'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A1A1A),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      _getTypeLabelFromString(cable['cableType']),
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${cable['checksCount']} проверок · ${cable['lastCheck']}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getScoreText(score),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '/100',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF444444)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCountByColor(String color) {
    return _allCables.where((c) => c['colorCategory'] == color).length;
  }

  String _getTypeLabelFromString(String type) {
    switch (type) {
      case 'xlr':
        return 'XLR';
      case 'jack_trs':
        return 'TRS';
      case 'jack_ts':
        return 'TS';
      default:
        return type;
    }
  }

  Widget _buildFilterChip(String label, ColorFilter? filter, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFFAAAAAA),
          ),
        ),
        selected: isSelected,
        onSelected: (_) {
          if (filter == null) {
            _clearFilters();
          } else {
            _setColorFilter(filter);
          }
        },
        backgroundColor: const Color(0xFF111111),
        selectedColor: const Color(0xFFEF9F27).withValues(alpha: 0.1),
        side: BorderSide(
          color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }

  Widget _buildColorFilterChip(String label, ColorFilter filter, Color dotColor) {
    final isSelected = _colorFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => _setColorFilter(filter),
        backgroundColor: const Color(0xFF111111),
        selectedColor: const Color(0xFFEF9F27).withValues(alpha: 0.1),
        side: BorderSide(
          color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }

  Widget _buildTypeFilterChip(String label, TypeFilter filter) {
    final isSelected = _typeFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFFAAAAAA),
          ),
        ),
        selected: isSelected,
        onSelected: (_) => _setTypeFilter(filter),
        backgroundColor: const Color(0xFF111111),
        selectedColor: const Color(0xFFEF9F27).withValues(alpha: 0.1),
        side: BorderSide(
          color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
        ),
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? const Color(0xFFEF9F27) : const Color(0xFF1F1F1F),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }
}