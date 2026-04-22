import 'package:flutter/material.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF9F27),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '紐',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Himo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFAFAFA),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ПРОВЕРКА КАБЕЛЯ',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _buildBleButton(),
              ],
            ),
          ),

          // Статистика коллекции
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1F1F1F)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'КОЛЛЕКЦИЯ',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: '24 ',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'кабеля',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'ПОСЛЕДНЯЯ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '2 часа назад',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(flex: 18, child: Container(height: 4, color: const Color(0xFF639922))),
                      Expanded(flex: 4, child: Container(height: 4, color: const Color(0xFFEF9F27))),
                      Expanded(flex: 2, child: Container(height: 4, color: const Color(0xFFE24B4A))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusDot(const Color(0xFF97C459), '18 исправны'),
                      const SizedBox(width: 16),
                      _buildStatusDot(const Color(0xFFEF9F27), '4 внимание'),
                      const SizedBox(width: 16),
                      _buildStatusDot(const Color(0xFFE24B4A), '2 брак'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Кнопка "Запустить тестирование"
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
            child: ElevatedButton(
              onPressed: () {
                // TODO: перейти на экран тестирования
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF9F27),
                foregroundColor: const Color(0xFF2A1A00),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 18),
                  SizedBox(width: 10),
                  Text(
                    'Запустить тестирование',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),

          // Карточки Коллекция и Устройство
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.view_list_outlined,
                    title: 'Коллекция',
                    subtitle: 'Все кабели',
                    onTap: () {
                      // TODO: перейти на коллекцию
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickCard(
                    icon: Icons.devices_outlined,
                    title: 'Устройство',
                    subtitle: '78% · откалибровано',
                    onTap: () {
                      // TODO: перейти на устройство
                    },
                  ),
                ),
              ],
            ),
          ),

          // Последние проверки
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ПОСЛЕДНИЕ ПРОВЕРКИ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                _buildHistoryItem(
                  color: const Color(0xFF639922),
                  title: 'Mogami #1 · XLR',
                  subtitle: 'CMRR 68 дБ · 2 часа назад',
                ),
                const SizedBox(height: 6),
                _buildHistoryItem(
                  color: const Color(0xFFEF9F27),
                  title: 'Гитарный длинный · Jack',
                  subtitle: 'сопр. растёт · вчера',
                ),
                const SizedBox(height: 6),
                _buildHistoryItem(
                  color: const Color(0xFFE24B4A),
                  title: 'XLR #07 · XLR',
                  subtitle: 'обрыв pin 3 · 3 дня',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBleButton() {
    return GestureDetector(
      onTap: () {
        // TODO: показать BLE меню
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEF9F27).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEF9F27).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFEF9F27),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'BLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFEF9F27),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: const Color(0xFFEF9F27)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFAFAFA),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {
        // TODO: перейти на детали кабеля
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1F1F1F)),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFAFAFA),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF444444)),
          ],
        ),
      ),
    );
  }
}