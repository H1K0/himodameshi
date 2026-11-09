import 'package:flutter/material.dart';
import 'dart:ui';
import '/data/test_models.dart';
import '/data/database_helper.dart';
import 'testing_screen.dart';
import 'testing_results_screen.dart';

class CablePassportScreen extends StatefulWidget {
  final String cableId;
  final VoidCallback onBack;

  const CablePassportScreen({
    super.key,
    required this.cableId,
    required this.onBack,
  });

  @override
  State<CablePassportScreen> createState() => _CablePassportScreenState();
}

class _CablePassportScreenState extends State<CablePassportScreen> {
  Map<String, dynamic>? _cableData;
  bool _isLoading = true;
  String _error = '';

  String get _cableName => _cableData?['name'] ?? 'Загрузка...';
  String get _cableType => _cableData?['cable_type'] ?? 'unknown';
  String get _cableNote => _cableData?['note'] ?? '';

  int get _healthScore {
    final history = _cableData?['history'] as List?;
    if (history != null && history.isNotEmpty) {
      return history.first['health_score'] ?? 0;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadCableData();
  }

  Future<void> _loadCableData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final data = await DatabaseHelper().getCableWithHistory(widget.cableId);
      if (!mounted) return;
      setState(() {
        _cableData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveName(String newName) async {
    if (newName.isEmpty || newName == _cableName) return;
    await DatabaseHelper().updateCable(widget.cableId, {'name': newName});
    _loadCableData();
  }

  Future<void> _saveNote(String newNote) async {
    await DatabaseHelper().updateCable(widget.cableId, {'note': newNote});
    _loadCableData();
  }

  Future<void> _deleteCable() async {
    await DatabaseHelper().deleteCable(widget.cableId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _openRenameSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController controller = TextEditingController(
          text: _cableName,
        );
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Переименовать',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFAFAFA),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Color(0xFFFAFAFA)),
                decoration: InputDecoration(
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _saveName(controller.text.trim());
                    Navigator.pop(context);
                  },
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openNoteSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController controller = TextEditingController(
          text: _cableNote,
        );
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Изменить заметку',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFAFAFA),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Color(0xFFFAFAFA)),
                maxLines: 3,
                decoration: InputDecoration(
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _saveNote(controller.text.trim());
                    Navigator.pop(context);
                  },
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                    color: const Color(0xFFE24B4A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE24B4A).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Color(0xFFE24B4A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Удалить «$_cableName»?',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Все проверки и история динамики будут удалены.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
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
                          Navigator.pop(context);
                          _deleteCable();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE24B4A),
                          foregroundColor: const Color(0xFF2A0606),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Удалить',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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

  Widget _buildPinsCard() {
    List<Map<String, dynamic>> pins = [];
    final typeStr = _cableType.toLowerCase();

    if (typeStr == 'xlr') {
      pins = [
        {'name': '1', 'status': 'ok'},
        {'name': '2', 'status': 'warning'},
        {'name': '3', 'status': 'ok'},
      ];
    } else if (typeStr == 'jack_trs') {
      pins = [
        {'name': 'T', 'status': 'ok'},
        {'name': 'R', 'status': 'fail'},
        {'name': 'S', 'status': 'warning'},
      ];
    } else {
      pins = [
        {'name': 'T', 'status': 'ok'},
        {'name': 'S', 'status': 'ok'},
      ];
    }

    Color getPinColor(String status) {
      switch (status) {
        case 'ok':
          return const Color(0xFF97C459);
        case 'warning':
          return const Color(0xFFEF9F27);
        case 'fail':
          return const Color(0xFFE24B4A);
        default:
          return const Color(0xFF666666);
      }
    }

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
          const Text(
            'ПИНЫ',
            style: TextStyle(fontSize: 8, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: pins.map((pin) {
              return Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Column(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: getPinColor(pin['status']),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pin['name'],
                      style: const TextStyle(
                        fontSize: 7,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  CableType _getCableTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'xlr':
        return CableType.xlr;
      case 'jack_trs':
        return CableType.jackTrs;
      case 'jack_ts':
        return CableType.jackTs;
      default:
        return CableType.xlr;
    }
  }

  List<int> get _healthScoreHistory {
    final history = _cableData?['history'] as List?;
    if (history == null || history.isEmpty) return [];

    final scores = history
        .where((s) => s['health_score'] != null)
        .map((s) => s['health_score'] as int)
        .toList()
        .reversed
        .toList();

    return scores;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(backgroundColor: const Color(0xFF0A0A0A), elevation: 0),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFEF9F27)),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
            onPressed: widget.onBack,
          ),
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
        ),
        body: Center(
          child: Text(_error, style: const TextStyle(color: Color(0xFFE24B4A))),
        ),
      );
    }

    Color getScoreColor() {
      if (_healthScore >= 80) return const Color(0xFF639922);
      if (_healthScore >= 50) return const Color(0xFFEF9F27);
      return const Color(0xFFE24B4A);
    }

    final history = _cableData?['history'] as List? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
          onPressed: widget.onBack,
        ),
        title: const Text('Кабель', style: TextStyle(color: Color(0xFFFAFAFA))),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Color(0xFF888888)),
            color: const Color(0xFF141414),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            offset: const Offset(0, 45),
            onSelected: (String result) {
              switch (result) {
                case 'rename':
                  _openRenameSheet();
                  break;
                case 'note':
                  _openNoteSheet();
                  break;
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFFAAAAAA),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Переименовать',
                      style: TextStyle(fontSize: 14, color: Color(0xFFE8E8E8)),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'note',
                child: Row(
                  children: [
                    Icon(
                      Icons.note_add_outlined,
                      size: 18,
                      color: Color(0xFFAAAAAA),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Изменить заметку',
                      style: TextStyle(fontSize: 14, color: Color(0xFFE8E8E8)),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(color: Color(0xFF2A2A2A)),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFE24B4A),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Удалить кабель',
                      style: TextStyle(fontSize: 14, color: Color(0xFFE24B4A)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 50,
                    decoration: BoxDecoration(
                      color: getScoreColor(),
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
                              _cableName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFAFAFA),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                _cableType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Добавлен недавно',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF888888),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _cableNote.isEmpty ? '' : '«$_cableNote»',
                          style: const TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '$_healthScore',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFAFAFA),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '/100',
                        style: TextStyle(fontSize: 8, color: Color(0xFF666666)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Кнопки
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestingScreen(
                              preselectedCableType: _getCableTypeFromString(
                                _cableType,
                              ),
                              onBack: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF9F27),
                        foregroundColor: const Color(0xFF2A1A00),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Перепроверить',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Поделиться PDF (в разработке)'),
                              backgroundColor: Color(0xFFEF9F27),
                            ),
                          ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: Color(0xFF2A2A2A)),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Поделиться PDF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Динамика Health Score
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ДИНАМИКА HEALTH SCORE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1F1F1F)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 90,
                      child: CustomPaint(
                        painter: _HealthScoreGraphPainter(
                          history: _healthScoreHistory,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Показатели
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ПОКАЗАТЕЛИ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildPinsCard()),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'CMRR',
                          value: '68',
                          unit: 'дБ',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'АЧХ',
                          value: '22.4',
                          unit: 'кГц',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // История проверок
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ИСТОРИЯ ПРОВЕРОК',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (history.isEmpty)
                    const Text(
                      'Нет истории проверок',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    )
                  else
                    ...history.map((item) {
                      final score = item['health_score'] as int? ?? 0;
                      final sessionId = item['session_id'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestingResultsScreen(
                                sessionId: sessionId,
                                selectedTests: const [],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1F1F1F)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: _getScoreColor(
                                    score,
                                  ).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getScoreColor(
                                      score,
                                    ).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$score',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: _getScoreColor(score),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Проверка',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFAFAFA),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Нажмите для деталей',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: Color(0xFF444444),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
            title,
            style: const TextStyle(fontSize: 8, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(fontSize: 9, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF97C459);
    if (score >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }
}

// График динамики Health Score
class _HealthScoreGraphPainter extends CustomPainter {
  final List<int> history;

  _HealthScoreGraphPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;

    // Сетка
    final gridPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Горизонтальные линии (100, 80, 60)
    canvas.drawLine(Offset(0, 20), Offset(width, 20), gridPaint);
    canvas.drawLine(Offset(0, 50), Offset(width, 50), gridPaint);
    canvas.drawLine(Offset(0, 80), Offset(width, 80), gridPaint);

    // Тексты меток
    final paragraphBuilder100 = ParagraphBuilder(
      ParagraphStyle(textAlign: TextAlign.end),
    );
    paragraphBuilder100.addText('100');
    final paragraph100 = paragraphBuilder100.build()
      ..layout(const ParagraphConstraints(width: 30));
    canvas.drawParagraph(paragraph100, Offset(22 - 30, 20 - 6));

    final paragraphBuilder80 = ParagraphBuilder(
      ParagraphStyle(textAlign: TextAlign.end),
    );
    paragraphBuilder80.addText('80');
    final paragraph80 = paragraphBuilder80.build()
      ..layout(const ParagraphConstraints(width: 30));
    canvas.drawParagraph(paragraph80, Offset(22 - 30, 50 - 6));

    final paragraphBuilder60 = ParagraphBuilder(
      ParagraphStyle(textAlign: TextAlign.end),
    );
    paragraphBuilder60.addText('60');
    final paragraph60 = paragraphBuilder60.build()
      ..layout(const ParagraphConstraints(width: 30));
    canvas.drawParagraph(paragraph60, Offset(22 - 30, 80 - 6));

    // Рисуем график
    if (history.isEmpty) return;

    final graphPaint = Paint()
      ..color = const Color(0xFFEF9F27)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.fill;

    // Если точка всего одна, ставим ее по центру
    final int count = history.length;
    final double stepX = count > 1 ? (width - 50) / (count - 1) : 0;
    final List<Offset> points = [];

    for (int i = 0; i < count; i++) {
      final double x = count > 1 ? 50 + i * stepX : width / 2;
      // Значения от 100 до 0 (но на графике ограничиваем диапазоном 20-80px)
      final double y = 20 + (100 - history[i]) / 100 * 60;
      points.add(Offset(x, y.clamp(20, 80)));
    }

    // Рисуем линию (только если точек больше 1)
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, graphPaint);
    }

    // Рисуем точки
    for (int i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;
      canvas.drawCircle(points[i], 4, pointPaint);
      canvas.drawCircle(
        points[i],
        4,
        Paint()
          ..color = isLast ? const Color(0xFF97C459) : const Color(0xFFEF9F27)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HealthScoreGraphPainter oldDelegate) =>
      oldDelegate.history != history;
}
