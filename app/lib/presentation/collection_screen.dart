import 'package:flutter/material.dart';
import '/data/ble_data_manager.dart';
import 'cable_passport_screen.dart';

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
  final BleDataManager _dataManager = BleDataManager();

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

    // Подписываемся на смену источника данных (mock/real)
    _dataManager.typeStream.listen((_) {
      _loadCables(); // перезагружаем при переключении
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCables() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Получаем данные через менеджер (он сам решит, из mock или real)
      final cables = await _dataManager.getAllCables();

      setState(() {
        _allCables = cables;
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

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allCables);

    // Поиск по имени
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((cable) {
        return cable['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Фильтр по цвету (Health Score)
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
    // Фильтр по типу кабеля
    else if (_typeFilter != TypeFilter.all && _colorFilter == ColorFilter.all) {
      filtered = filtered.where((cable) {
        switch (_typeFilter) {
          case TypeFilter.xlr:
            return cable['cable_type'] == 'xlr';
          case TypeFilter.jackTrs:
            return cable['cable_type'] == 'jack_trs';
          case TypeFilter.jackTs:
            return cable['cable_type'] == 'jack_ts';
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
          final dateA = a['lastCheck'] ?? 0;
          final dateB = b['lastCheck'] ?? 0;
          comparison = dateA.compareTo(dateB);
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
      _typeFilter = TypeFilter.all;
    });
    _applyFilters();
  }

  void _setTypeFilter(TypeFilter filter) {
    setState(() {
      _typeFilter = filter;
      _colorFilter = ColorFilter.all;
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

  Color _getScoreColor(int? score) {
    if (score == null) return const Color(0xFF666666);
    if (score >= 80) return const Color(0xFF97C459);
    if (score >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }

  String _getScoreText(int? score) {
    if (score == null) return '—';
    return '${score.toInt()}';
  }

  void _navigateToCableDetail(Map<String, dynamic> cable) {
    final int healthScore = cable['healthScore'] ?? 0;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CablePassportScreen(
          cableName: cable['name'],
          cableType: cable['cable_type'],
          healthScore: healthScore,
          onBack: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
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

  int _getCountByColor(String color) {
    return _allCables.where((c) => c['colorCategory'] == color).length;
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCables,
              child: const Text('Повторить'),
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
                _buildFilterChip('Все · ${_allCables.length}', null, _colorFilter == ColorFilter.all && _typeFilter == TypeFilter.all),
                _buildColorFilterChip('${_getCountByColor('green')}', ColorFilter.green, Colors.green),
                _buildColorFilterChip('${_getCountByColor('yellow')}', ColorFilter.yellow, Colors.orange),
                _buildColorFilterChip('${_getCountByColor('red')}', ColorFilter.red, Colors.red),
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
                final int? score = cable['healthScore'];
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
                                      _getTypeLabelFromString(cable['cable_type']),
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
                                '${cable['checksCount'] ?? 0} проверок · ${cable['lastCheck'] ?? 'нет данных'}',
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