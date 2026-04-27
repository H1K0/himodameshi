import 'package:flutter/material.dart';
import 'dart:ui';
import '/data/test_models.dart';
import 'testing_screen.dart';

class CablePassportScreen extends StatefulWidget {
  final String cableName;
  final String cableType;
  final double healthScore;
  final VoidCallback onBack;

  const CablePassportScreen({
    super.key,
    required this.cableName,
    required this.cableType,
    required this.healthScore,
    required this.onBack,
  });

  @override
  State<CablePassportScreen> createState() => _CablePassportScreenState();
}

class _CablePassportScreenState extends State<CablePassportScreen> {
  late String _cableName;
  late String _cableNote;

  // Статичные данные для демонстрации
  final String _addedDate = '12 фев';
  final int _checksCount = 5;
  final List<double> _healthScoreHistory = [98, 98, 98, 96, 94];
  final List<Map<String, dynamic>> _history = [
    {'date': 'Сегодня · 14:32', 'cmrr': 68, 'freq': -2.1, 'score': 94},
    {'date': '2 апреля', 'cmrr': 67, 'freq': -2.3, 'score': 96},
    {'date': '15 марта', 'cmrr': 66, 'freq': -2.4, 'score': 96},
    {'date': '28 февраля', 'cmrr': 67, 'freq': -2.2, 'score': 98},
    {'date': '10 февраля', 'cmrr': 68, 'freq': -2.0, 'score': 98},
  ];

  @override
  void initState() {
    super.initState();
    _cableName = widget.cableName;
    _cableNote = 'Купил в 2024, для вокала';
  }

  void _openRenameSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0F0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController controller = TextEditingController(text: _cableName);
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _cableName = controller.text.trim().isEmpty ? _cableName : controller.text.trim();
                        });
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
        final TextEditingController controller = TextEditingController(text: _cableNote);
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _cableNote = controller.text.trim();
                        });
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
                    border: Border.all(color: const Color(0xFFE24B4A).withValues(alpha: 0.4)),
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
                          // TODO: реализовать удаление кабеля
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Удаление кабеля (в разработке)'),
                              backgroundColor: Color(0xFFE24B4A),
                            ),
                          );
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

  // Добавляем метод для отображения пинов:
  Widget _buildPinsCard() {
    // Определяем количество пинов и их состояния в зависимости от типа кабеля
    List<Map<String, dynamic>> pins = [];

    if (widget.cableType.toLowerCase() == 'xlr') {
      pins = [
        {'name': '1', 'status': 'ok'},   // можно менять на 'warning' или 'fail' для теста
        {'name': '2', 'status': 'warning'},
        {'name': '3', 'status': 'ok'},
      ];
    } else if (widget.cableType.toLowerCase() == 'jack_trs') {
      pins = [
        {'name': 'T', 'status': 'ok'},
        {'name': 'R', 'status': 'fail'},
        {'name': 'S', 'status': 'warning'},
      ];
    } else {
      // Jack TS — 2 пина
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
            style: TextStyle(
              fontSize: 8,
              color: Color(0xFF666666),
            ),
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

  // Добавляем вспомогательный метод:
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

  @override
  Widget build(BuildContext context) {
    // Определяем цвет полоски в зависимости от Health Score
    Color getScoreColor() {
      if (widget.healthScore >= 80) return const Color(0xFF639922);
      if (widget.healthScore >= 50) return const Color(0xFFEF9F27);
      return const Color(0xFFE24B4A);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Кабель',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
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
                    Icon(Icons.edit_outlined, size: 18, color: Color(0xFFAAAAAA)),
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
                    Icon(Icons.note_add_outlined, size: 18, color: Color(0xFFAAAAAA)),
                    SizedBox(width: 12),
                    Text(
                      'Изменить заметку',
                      style: TextStyle(fontSize: 14, color: Color(0xFFE8E8E8)),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(color: Color(0xFF2A2A2A),),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Color(0xFFE24B4A)),
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
            // Основная информация
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
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                widget.cableType.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Добавлен $_addedDate · $_checksCount проверок',
                          style: const TextStyle(
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
                        '${widget.healthScore.toInt()}',
                        style: const TextStyle(
                          fontSize: 24,
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
                ],
              ),
            ),

            // Кнопки Перепроверить и Поделиться PDF
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Переходим на экран тестирования с предустановленным типом кабеля
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestingScreen(
                              preselectedCableType: _getCableTypeFromString(widget.cableType),
                              onBack: () {
                                // Возвращаемся на экран паспорта
                                Navigator.pop(context);
                              },
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: поделиться PDF
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Поделиться PDF (в разработке)'),
                            backgroundColor: Color(0xFFEF9F27),
                          ),
                        );
                      },
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
                      // Блок с пинами (состояние жил)
                      Expanded(
                        child: _buildPinsCard(),
                      ),
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
                  ..._history.asMap().entries.map((entry) {
                    final item = entry.value;
                    final score = item['score'] as int;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              color: _getScoreColor(score).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _getScoreColor(score).withValues(alpha: 0.5),
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
                                Text(
                                  item['date'],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFAFAFA),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'CMRR ${item['cmrr']} дБ · ${item['freq']} дБ',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF444444)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isDanger ? const Color(0xFFE24B4A) : const Color(0xFFAAAAAA)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDanger ? const Color(0xFFE24B4A) : const Color(0xFFE8E8E8),
                ),
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
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF666666),
            ),
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

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF97C459);
    if (score >= 50) return const Color(0xFFEF9F27);
    return const Color(0xFFE24B4A);
  }
}

// График динамики Health Score
class _HealthScoreGraphPainter extends CustomPainter {
  final List<double> history;

  _HealthScoreGraphPainter({required this.history});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

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
    final textStyle = TextStyle(color: const Color(0xFF555555), fontSize: 8);
    final paragraphBuilder100 = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.end));
    paragraphBuilder100.addText('100');
    final paragraph100 = paragraphBuilder100.build()..layout(const ParagraphConstraints(width: 30));
    canvas.drawParagraph(paragraph100, Offset(22 - 30, 20 - 6));

    final paragraphBuilder80 = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.end));
    paragraphBuilder80.addText('80');
    final paragraph80 = paragraphBuilder80.build()..layout(const ParagraphConstraints(width: 30));
    canvas.drawParagraph(paragraph80, Offset(22 - 30, 50 - 6));

    final paragraphBuilder60 = ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.end));
    paragraphBuilder60.addText('60');
    final paragraph60 = paragraphBuilder60.build()..layout(const ParagraphConstraints(width: 30));
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

    final pointStrokePaint = Paint()
      ..color = const Color(0xFF97C459)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final double stepX = (width - 50) / (history.length - 1);
    final List<Offset> points = [];

    for (int i = 0; i < history.length; i++) {
      final double x = 50 + i * stepX;
      // Значения от 100 до 50, отображаем от 20px до 80px
      final double y = 20 + (100 - history[i]) / 50 * 60;
      points.add(Offset(x, y.clamp(20, 80)));
    }

    // Рисуем линию
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, graphPaint);

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}