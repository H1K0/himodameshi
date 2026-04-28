import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  String _userName = 'Алексей Петров';
  String _userEmail = 'a.petrov@example.com';

  final String _appVersion = '0.1';
  final String _websiteUrl = 'https://git.hakoniwa.ru/H1K0-dev/himodameshi';

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть: $url'),
            backgroundColor: const Color(0xFFE24B4A),
          ),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    final TextEditingController emailController = TextEditingController(text: _userEmail);

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
                const Text(
                  'Редактировать профиль',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFAFAFA),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Color(0xFFFAFAFA)),
                  decoration: InputDecoration(
                    labelText: 'Имя',
                    labelStyle: const TextStyle(color: Color(0xFF888888)),
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
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Color(0xFFFAFAFA)),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFF888888)),
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
                const SizedBox(height: 20),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _userName = nameController.text.trim().isEmpty
                                ? _userName
                                : nameController.text.trim();
                            _userEmail = emailController.text.trim().isEmpty
                                ? _userEmail
                                : emailController.text.trim();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF9F27),
                          foregroundColor: const Color(0xFF2A1A00),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Сохранить',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Настройки',
          style: TextStyle(color: Color(0xFFFAFAFA)),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Профиль
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ПРОФИЛЬ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1F1F1F)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF9F27).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(21),
                                border: Border.all(color: const Color(0xFFEF9F27).withValues(alpha: 0.4)),
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(_userName),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFEF9F27),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _userEmail,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF888888),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: _showEditProfileDialog,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                side: const BorderSide(color: Color(0xFF2A2A2A)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Изменить',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF9F27).withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFEF9F27).withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_outline,
                                    size: 12,
                                    color: Color(0xFFEF9F27),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Free',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFFAFAFA),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Text(
                                'текущий план',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _launchUrl(_websiteUrl),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF9F27),
                              foregroundColor: const Color(0xFF2A1A00),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: const Text(
                              'Премиум · 29 € / год',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // О приложении
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'О ПРИЛОЖЕНИИ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1F1F1F)),
                    ),
                    child: Column(
                      children: [
                        _buildSettingsRow(
                          label: 'Версия',
                          value: _appVersion,
                        ),
                        const Divider(height: 0.5, thickness: 0.5, color: Color(0xFF1A1A1A)),
                        _buildSettingsButtonRow(
                          label: 'Сайт проекта',
                          value: 'himo.app ↗',
                          onTap: () => _launchUrl(_websiteUrl),
                        ),
                        const Divider(height: 0.5, thickness: 0.5, color: Color(0xFF1A1A1A)),
                        _buildSettingsButtonRow(
                          label: 'Политика приватности',
                          value: '›',
                          onTap: () => _launchUrl(_websiteUrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Обратная связь
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ОБРАТНАЯ СВЯЗЬ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF666666),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1F1F1F)),
                    ),
                    child: Column(
                      children: [
                        _buildFeedbackRow(
                          icon: Icons.error_outline,
                          iconColor: const Color(0xFFE24B4A),
                          label: 'Сообщить об ошибке',
                          onTap: () => _launchUrl(_websiteUrl),
                        ),
                        const Divider(height: 0.5, thickness: 0.5, color: Color(0xFF1A1A1A)),
                        _buildFeedbackRow(
                          icon: Icons.lightbulb_outline,
                          iconColor: const Color(0xFFEF9F27),
                          label: 'Предложить идею',
                          onTap: () => _launchUrl(_websiteUrl),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildSettingsRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, color: Color(0xFFE8E8E8), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButtonRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFFE8E8E8)),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 12, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFFFAFAFA)),
              ),
            ),
            const Icon(Icons.chevron_right, size: 12, color: Color(0xFF444444)),
          ],
        ),
      ),
    );
  }
}